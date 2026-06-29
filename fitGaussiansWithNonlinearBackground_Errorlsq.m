function [params, yfit, paramErrors, R2] = fitGaussiansWithNonlinearBackground_Errorlsq(x, y, peakPositions, bgOrder, plotFit)
%FITGAUSSIANSWITHNONLINEARBACKGROUND_ERROR
%   Fit one or multiple Gaussian peaks + nonlinear background using lsqcurvefit
%   and compute parameter uncertainties.
%
%   Inputs:
%       x, y            - data vectors
%       peakPositions   - vector of peak centers to fit
%       bgOrder         - polynomial order of background (e.g. 1=linear, 2=quadratic)
%       plotFit         - true/false (optional, default: true)
%
%   Outputs:
%       params       - fitted parameters [a1...aN, c1...cN, bgCoeffs]
%       yfit         - fitted curve
%       paramErrors  - 1σ errors (standard deviation) of fitted parameters
%       R2           - coefficient of determination

if nargin < 4
    bgOrder = 1;
end
if nargin < 5
    plotFit = true;
end

x = x(:);
y = y(:);
nPeaks = numel(peakPositions);

% --- Initial parameter guesses ---
a0 = zeros(1, nPeaks);
c0 = zeros(1, nPeaks);
for i = 1:nPeaks
    [~, idx] = min(abs(x - peakPositions(i)));
    a0(i) = y(idx) - mean(y);
    c0(i) = (max(x) - min(x)) / (10 * nPeaks);
end

bg0 = polyfit(x, y, bgOrder);
bg0 = fliplr(bg0(:)');  % make sure it's in increasing power order

init = [a0, c0, bg0];

% --- Lower and upper bounds (optional for stability) ---
lb = [-inf(1,nPeaks), 0.0001*ones(1,nPeaks), -inf(1,bgOrder+1)];
ub = [ inf(1,nPeaks), inf(1,nPeaks), inf(1,bgOrder+1)];

% --- Model function ---
modelFun = @(p, x) multiGaussWithPoly(p, x, peakPositions, bgOrder);

% --- Fit using lsqcurvefit ---
opts = optimoptions('lsqcurvefit', 'Display', 'off', 'MaxFunEvals', 5000, ...
                    'TolFun',1e-10,'TolX',1e-10);
[params, ~, residuals,~,~,~,J] = lsqcurvefit(modelFun, init, x, y, lb, ub, opts);

yfit = modelFun(params, x);

% --- Goodness of fit ---
SSE = sum(residuals.^2);
SST = sum((y - mean(y)).^2);
R2 = 1 - SSE/SST;

% --- Parameter errors from Jacobian ---
nParams = numel(params);
dof = numel(y) - nParams;
mse = SSE / dof;
covar = mse * inv(J'*J);
paramErrors = sqrt(diag(covar));

% --- Optional plotting ---
if plotFit
    figure; hold on;
    plot(x, y, 'bo', 'MarkerSize', 4, 'DisplayName','Data');
    plot(x, yfit, 'r-', 'LineWidth', 1.5, 'DisplayName','Fit');

    for i = 1:nPeaks
        yi = params(i)*exp(-(x-peakPositions(i)).^2./(2*params(nPeaks+i)^2));
        plot(x, yi + polyval(fliplr(params(2*nPeaks+1:end)), x), '--', 'LineWidth', 1, ...
             'DisplayName', sprintf('Peak %d', i));
    end
    xlabel('x'); ylabel('y');
    legend show; grid on;
    title('Gaussian Fit with Nonlinear Background (lsqcurvefit)');
end

end

% --- Helper function ---
function y = multiGaussWithPoly(p, x, peakPositions, bgOrder)
    nPeaks = numel(peakPositions);
    a = p(1:nPeaks);
    c = p(nPeaks+1:2*nPeaks);
    bg = p(2*nPeaks+1:end);

    % Gaussian peaks
    y = zeros(size(x));
    for i = 1:nPeaks
        y = y + a(i)*exp(-(x-peakPositions(i)).^2 ./ (2*c(i)^2));
    end

    % Polynomial background (in increasing order)
    y = y + polyval(fliplr(bg), x);
end
