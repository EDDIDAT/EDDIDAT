function [params, yfit, paramErrors] = fitGaussiansWithNonlinearBackground_Error(x, y, peakPositions, bgOrder, plotFit)
% Fit mit Fehlerabschätzungen
% paramErrors = Standardabweichungen der Fitparameter

if nargin < 5
    plotFit = true;
end

x = x(:); y = y(:);
numPeaks = length(peakPositions);

% --- Initialwerte ---
a0 = y(round(interp1(x,1:length(x),peakPositions))) - mean(y);
c0 = repmat((max(x)-min(x))/20, size(a0));
bg0 = polyfit(x, y, bgOrder); % Untergrund
bg0 = fliplr(bg0);

init = [a0(:); c0(:); bg0'];

% --- Modell & Residuen ---
model = @(p,xdata) sumGaussiansWithPolyBG(xdata, p, peakPositions, bgOrder);
resid = @(p) y - model(p,x);

% --- Fit ---
opts = optimset('Display','off');
params = fminsearch(@(p) sum(resid(p).^2), init, opts);
yfit = model(params, x);

% --- 1. Jacobi-Matrix numerisch berechnen ---
delta = 1e-6;
nParams = length(params);
J = zeros(length(x), nParams);

for k = 1:nParams
    dp = zeros(size(params));
    dp(k) = delta;
    J(:,k) = (model(params+dp, x) - model(params-dp, x))/(2*delta);
end

% --- 2. Varianz der Residuen ---
res = y - yfit;
sigma2 = sum(res.^2)/(length(x)-nParams);

% --- 3. Kovarianzmatrix der Parameter ---
CovP = sigma2 * inv(J'*J);

% --- 4. Standardabweichung der Parameter ---
paramErrors = sqrt(diag(CovP));

% --- Plot ---
if plotFit
    figure; hold on;
    plot(x, y, 'bo');
    plot(x, yfit, 'r-', 'LineWidth',1.5);
    colors = lines(numPeaks);
    for k = 1:numPeaks
        a = params(k);
        b = peakPositions(k);
        c = params(numPeaks + k);
        ypeak = a*exp(-(x-b).^2/(2*c^2)) + polyval(flip(params(end-bgOrder:end)), x);
        plot(x, ypeak, '--', 'Color', colors(k,:));
    end
    xlabel('x'); ylabel('y');
    title(sprintf('Gaussian Fit with Polynomial Background (Order %d)', bgOrder));
    legend('Data','Total Fit','Individual Peaks');
    grid on;
end

end