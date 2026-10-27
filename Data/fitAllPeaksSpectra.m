function results = fitAllPeaksSpectra(theta, spectra, Peaks, fitWin, gammaCenters)
% FITALLPEAKSSPECTRA
% Fit aller vorgegebenen Peaks in allen Spektren
% mit Gauß und Pseudo-Voigt inkl. Fehlern
%
% INPUT:
%   theta    - [N x 1] 2theta-Achse
%   spectra  - [Ns x N] Spektren (z.B. gamma-Blöcke)
%   Peaks    - [1 x Np] Peakpositionen (Startwerte)
%   fitWin   - Fitfenster-Halbbereich (z.B. 0.8)
%
% OUTPUT:
%   results(s,p) - Struktur mit Fitparametern

Ns = size(spectra,1);
Np = numel(Peaks);

results = struct();

% --- Fittypen ---
ftGauss = fittype('A*exp(-(x-mu)^2/(2*sigma^2))', ...
                  'independent','x');

% optsG = fitoptions(ftGauss,...
%     'StartPoint',[amp0 p0 0.3],...
%     'Lower',[0 p0-0.5 0.05],...
%     'Upper',[Inf p0+0.5 2]);

ftPV = fittype([ ...
 '(1-eta)*A*exp(-(x-mu)^2/(2*sigma^2)) + ' ...
 'eta*A*(sigma^2./((x-mu).^2+sigma^2))'], ...
 'independent','x', ...
 'coefficients',{'A','mu','sigma','eta'});

% optsPV = fitoptions(ftPV,...
%     'StartPoint',[amp0 p0 0.3 0.5],...
%     'Lower',[0 p0-0.5 0.05 0],...
%     'Upper',[Inf p0+0.5 2 1]);

for s = 1:Ns

    if size(spectra,2) == numel(theta)
        y = spectra(s,:)';
    elseif size(spectra,1) == numel(theta)
        y = spectra(:,s);
    else
        error('Dimensionen von spectra und theta passen nicht zusammen.');
    end
    
    % % Hintergrund entfernen
    % bg = movmedian(y, 25);
    % yCorr = y - bg;
    % yCorr(yCorr < 0) = 0;
    yCorr = y;

    for p = 1:Np

        mu0 = Peaks(p);
        win = abs(theta - mu0) < fitWin;

        if sum(win) < 6 || max(yCorr(win)) <= 0
            results(s,p).valid = false;
            continue
        end

        xFit = theta(win);
        yFit = yCorr(win);

        % ------------------
        % GAUSS-FIT
        % ------------------
        try
            startG = [max(yFit), mu0, 0.2];
            fitG = fit(xFit', yFit, ftGauss, ...
                       'StartPoint', startG);

            ciG = confint(fitG, 0.68);

            results(s,p).Gauss.A      = fitG.A;
            results(s,p).Gauss.AErr   = diff(ciG(:,1))/2;
            results(s,p).Gauss.mu     = fitG.mu;
            results(s,p).Gauss.muErr  = diff(ciG(:,2))/2;
            results(s,p).Gauss.sigma  = fitG.sigma;
            results(s,p).Gauss.sigmaErr = diff(ciG(:,3))/2;
            results(s,p).Gauss.model = fitG;

        catch
            results(s,p).Gauss = [];
        end

        % ------------------
        % PSEUDO-VOIGT-FIT
        % ------------------
        try
            opts = fitoptions(ftPV);
            opts.StartPoint = [max(yFit), mu0, 0.2, 0.5];
            opts.Lower = [0, mu0-fitWin/2, 0.05, 0];
            opts.Upper = [Inf, mu0+fitWin/2, 1.0, 1];

            fitPV = fit(xFit', yFit, ftPV, opts);
            ciPV = confint(fitPV, 0.68);

            results(s,p).PV.A      = fitPV.A;
            results(s,p).PV.AErr   = diff(ciPV(:,1))/2;
            results(s,p).PV.mu     = fitPV.mu;
            results(s,p).PV.muErr  = diff(ciPV(:,2))/2;
            results(s,p).PV.sigma  = fitPV.sigma;
            results(s,p).PV.sigmaErr = diff(ciPV(:,3))/2;
            results(s,p).PV.eta    = fitPV.eta;
            results(s,p).PV.etaErr = diff(ciPV(:,4))/2;
            results(s,p).PV.model = fitPV;

        catch
            results(s,p).PV = [];
        end

        results(s,p).valid = true;
        results(s,p).peakRef = mu0;
        results(s,p).gammaCenter = gammaCenters;
        results(s,p).thetaFit = xFit';
        results(s,p).yFit = yFit;
    end
end
end
