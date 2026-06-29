function [params, yfit] = fitMultipleGaussians(x, y, plotFit)
% FITMULTIPLEGAUSSIANS Fit multiple Gaussian peaks with variable background
% Ohne Curve Fitting Toolbox
%
% Inputs:
%   x, y      : Daten
%   plotFit   : optional, true/false, default: true
%
% Outputs:
%   params    : Zellarray, jede Zelle = [a, b, c] für einen Peak
%   yfit      : Gesamter Fit über alle Peaks + Untergrund

if nargin < 3
    plotFit = true;
end

x = x(:); y = y(:);

% --- 1. Peaks automatisch finden (minimale Toolbox-Variante) ---
dy = diff(y);
peaks_idx = find(dy(1:end-1) > 0 & dy(2:end) <= 0) + 1;

% Filter kleine Peaks (optional)
threshold = 0.2*(max(y)-min(y));
peaks_idx(y(peaks_idx) < min(y)+threshold) = [];

numPeaks = length(peaks_idx);

% --- 2. Initialwerte ---
a0 = y(peaks_idx) - mean(y);  % Amplitude
b0 = x(peaks_idx);            % Position
c0 = repmat((max(x)-min(x))/20, size(a0)); % Breite
bg = polyfit(x, y, 1);        % linearer Hintergrund
params0 = [a0(:)', b0(:)', c0(:)', bg]; % Startwerte: [a1..an, b1..bn, c1..cn, d, e]

% --- 3. Definiere Modell ---
model = @(p, xdata) ...
    sumGaussians(xdata, p, numPeaks);

% --- 4. Residuen ---
resid = @(p) sum((y - model(p,x)).^2);

% --- 5. Fit ---
opts = optimset('Display','off');
pfit = fminsearch(resid, params0, opts);

% --- 6. Extrahiere Parameter ---
params = cell(numPeaks,1);
for k = 1:numPeaks
    a = pfit(k);
    b = pfit(numPeaks + k);
    c = pfit(2*numPeaks + k);
    params{k} = [a, b, c];
end
bg_params = pfit(end-1:end);

% --- 7. Gesamter Fit ---
yfit = model(pfit, x);

% --- 8. Plot ---
if plotFit
    figure; hold on;
    plot(x, y, 'bo'); % Daten
    plot(x, yfit, 'r-', 'LineWidth',1.5); % Gesamtfit
    % Einzelne Peaks
    colors = lines(numPeaks);
    for k = 1:numPeaks
        a = params{k}(1);
        b = params{k}(2);
        c = params{k}(3);
        plot(x, a*exp(-(x-b).^2/(2*c^2)) + bg_params(1)*x + bg_params(2), '--', 'Color', colors(k,:));
    end
    xlabel('x'); ylabel('y');
    title('Multiple Gaussian Peaks with Linear Background');
    legend('Data','Total Fit','Individual Peaks');
    grid on;
end

end

% --- Hilfsfunktion: Summe aller Gaussians + linearer Untergrund ---
function ysum = sumGaussians(x, p, nPeaks)
ysum = zeros(size(x));
for k = 1:nPeaks
    a = p(k);
    b = p(nPeaks+k);
    c = p(2*nPeaks+k);
    ysum = ysum + a*exp(-(x-b).^2/(2*c^2));
end
% Linearer Untergrund
ysum = ysum + p(end-1)*x + p(end);
end