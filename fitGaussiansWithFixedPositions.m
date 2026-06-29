function [params, yfit] = fitGaussiansWithFixedPositions(x, y, peakPositions, plotFit)
% FITGAUSSIANSWITHFIXEDPOSITIONS Fit Gaussian peaks at fixed positions
% mit variablem linearen Untergrund, ohne Curve Fitting Toolbox
%
% Inputs:
%   x, y           : Daten
%   peakPositions  : Vektor mit vorgegebenen Peak-Positionen
%   plotFit        : optional, true/false (default: true)
%
% Outputs:
%   params         : Zellarray, jede Zelle = [a, b, c] für einen Peak
%   yfit           : Gesamter Fit über alle Peaks + Untergrund

if nargin < 4
    plotFit = true;
end

x = x(:); y = y(:);
numPeaks = length(peakPositions);

% --- Initialwerte für Amplitude und Breite ---
a0 = y(round(interp1(x,1:length(x),peakPositions))) - mean(y); % grobe Amplitude
c0 = repmat(0.3, size(a0)); % Breite
bg = polyfit(x, y, 1); % linearer Untergrund

% Parameter-Vektor: [a1..an, c1..cn, d, e]
params0 = [a0(:)', c0(:)', bg];

% --- Modell ---
model = @(p, xdata) sumGaussiansFixed(xdata, p, peakPositions);

% --- Residuen ---
resid = @(p) sum((y - model(p,x)).^2);

% --- Fit ---
opts = optimset('Display','off');
pfit = fminsearch(resid, params0, opts);

% --- Extrahiere Parameter ---
params = cell(numPeaks,1);
for k = 1:numPeaks
    a = pfit(k);
    b = peakPositions(k);
    c = pfit(numPeaks + k);
    params{k} = [a, b, c];
end
bg_params = pfit(end-1:end);

% --- Gesamter Fit ---
yfit = model(pfit, x);

% --- Plot ---
if plotFit
    figure; hold on;
    plot(x, y, 'bo'); % Daten
    plot(x, yfit, 'r-', 'LineWidth',1.5); % Gesamtfit
    colors = lines(numPeaks);
    for k = 1:numPeaks
        a = params{k}(1);
        b = params{k}(2);
        c = params{k}(3);
        plot(x, a*exp(-(x-b).^2/(2*c^2)) + bg_params(1)*x + bg_params(2), '--', 'Color', colors(k,:));
    end
    xlabel('x'); ylabel('y');
    title('Gaussians with Fixed Positions + Linear Background');
    legend('Data','Total Fit','Individual Peaks');
    grid on;
end

end

% --- Hilfsfunktion: Summe der Gaussians mit festen Positionen ---
function ysum = sumGaussiansFixed(x, p, peakPositions)
numPeaks = length(peakPositions);
ysum = zeros(size(x));
for k = 1:numPeaks
    a = p(k);
    b = peakPositions(k);
    c = p(numPeaks + k);
    ysum = ysum + a*exp(-(x-b).^2/(2*c^2));
end
ysum = ysum + p(end-1)*x + p(end); % linearer Untergrund
end