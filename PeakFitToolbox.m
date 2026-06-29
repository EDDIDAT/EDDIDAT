function results = PeakFitToolbox(x, Y, peakResults, options)
% PeakFitToolbox
%
% ALL-IN-ONE PEAK FITTING PIPELINE
%
% FEATURES:
%   ✓ automatische Fensterbestimmung
%   ✓ mehrere Peaks gleichzeitig fitten
%   ✓ Gauss / Lorentz / Pseudo-Voigt
%   ✓ polynomialer Untergrund (Grad frei wählbar)
%   ✓ Plot-Funktion (optional)
%   ✓ Export als Tabelle / Excel
%
% INPUT:
%   x           - x-Werte (Nx1)
%   Y           - Y-Matrix (NxM)
%   peakResults - Peak-Ergebnisse aus Peak-Suchfunktion
%   options     - Struktur mit:
%
%       .model              ('gauss' 'lorentz' 'pseudo-voigt')
%       .backgroundDegree   (0 = konstant, 1 = linear, 2 = quadratisch, ...)
%       .autoWindow         (true/false)
%       .manualWindow       (falls autoWindow=false)
%       .plotFits           (true/false)
%       .exportTable        (true/false)
%       .exportExcel        (true/false)
%       .excelFile          ('fitresults.xlsx')
%
% OUTPUT:
%   resultsFit – Struktur mit Fitparametern und Modellen
%
% -------------------------------------------------------------

    % ----- Default-Optionen ----- %
    opt = struct( ...
        'model', 'gauss', ...
        'backgroundDegree', 1, ...
        'autoWindow', false, ...
        'manualWindow', 1, ...
        'plotFits', true, ...
        'exportTable', false, ...
        'exportExcel', false, ...
        'excelFile', 'fitresults.xlsx' ...
    );

    % Merge defaults with user options
    if nargin >= 4
        f = fieldnames(options);
        for i = 1:numel(f)
            opt.(f{i}) = options.(f{i});
        end
    end

    % Run fit
    results = runFitting(x, Y, peakResults, opt);

    % Optional export
    if opt.exportTable || opt.exportExcel
        exportFitResults(results, opt);
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% FITTING PIPELINE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function results = runFitting(x, Y, peaks, opt)
% 
%     x = x(:);
%     [N, M] = size(Y);
%     nPeaks = size(peaks,2);
% 
%     results(M, nPeaks) = struct();
% 
%     for c = 1:M
%         y = Y(:,c);
% 
%         for p = 1:nPeaks
% 
%             peakX = peaks(c,p).peakX;
%             if isnan(peakX)
%                 results(c,p).success = false;
%                 continue;
%             end
% 
%             % --- Automatisches Fenster ---
%             if opt.autoWindow
%                 win = autoWindowSize(y, find(x==peakX));
%             else
%                 win = opt.manualWindow;
%             end
% 
%             idx = x >= (peakX-win) & x <= (peakX+win);
%             xf = x(idx);
%             yf = y(idx);
% 
%             if numel(xf) < 5
%                 results(c,p).success = false;
%                 continue;
%             end
% 
%             % --- Modell aufbauen ---
%             modelFun = @(params, xx) compositeModel(params, xx, opt);
% 
%             % Parameterzahl bestimmen
%             nParams = numberOfParameters(opt);
% 
%             % Startwerte
%             p0 = initialGuess(xf, yf, opt);
% 
%             % Fit
%             try
%                 params = lsqcurvefit(modelFun, p0, xf, yf, [], [], optimset('Display','off'));
%                 success = true;
%             catch
%                 params = nan(size(p0));
%                 success = false;
%             end
% 
%             results(c,p).params = params;
%             results(c,p).xfit = xf;
%             results(c,p).yfit = modelFun(params, xf);
%             results(c,p).success = success;
%             results(c,p).model = opt.model;
%             results(c,p).backgroundDegree = opt.backgroundDegree;
% 
%             % Plot optional
%             if opt.plotFits
%                 plotFit(x, y, results(c,p));
%             end
%         end
%     end
% end

function results = runFitting(x, Y, peakResults, opt)
% runFitting – passt Peaks in jeder Y-Matrix-Spalte an
%
% INPUT:
%   x  :   x-Vektor Nx1
%   Y  :   Y-Matrix NxM (M Spektren)
%   peakResults : M x nPeaks (peakX usw.)
%   opt : Settings-Struktur
%
% OUTPUT:
%   results(c,p) = Fitstruktur des p-ten Peaks der c-ten Spalte

    x = x(:);
    [N, M] = size(Y);

    nPeaks = size(peakResults, 2);
    results = repmat(struct(), M, nPeaks);

    for c = 1:M

        y = Y(:,c);

        for p = 1:nPeaks

            peakX = peakResults(c,p).peakX;
            if isnan(peakX)
                results(c,p).success = false;
                continue;
            end

            % ----------------------------
            % Fenster bestimmen
            % ----------------------------
            if opt.autoWindow
                [~, idx0] = min(abs(x - peakX));
                win = autoWindowSize(y, idx0);
            else
                win = opt.manualWindow;
            end

            idx = (x >= peakX - win) & (x <= peakX + win);
            xf = x(idx);
            yf = y(idx);

            if numel(xf) < 6
                results(c,p).success = false;
                continue;
            end

            % ----------------------------
            % Startparameter
            % ----------------------------
            modelFun = @(params, xx) compositeModel(params, xx, opt);
            p0 = initialGuess(xf, yf, opt);

            opts = optimoptions('lsqcurvefit', ...
                'Display','off', ...
                'Algorithm','levenberg-marquardt', ...
                'FiniteDifferenceType','central');

            % ----------------------------
            % Fit
            % ----------------------------
            try
                [params, ~, res, ~, ~, ~, J] = lsqcurvefit( ...
                    modelFun, p0, xf, yf, [], [], opts);
            catch
                results(c,p).success = false;
                continue;
            end

            % ----------------------------
            % Unsicherheiten
            % ----------------------------
            covp = inv(J.'*J) * var(res);
            stderr = sqrt(diag(covp));
            ci95 = 1.96 * stderr;

            % ----------------------------
            % Modell-Komponenten
            % ----------------------------
            yfit = modelFun(params, xf);
            bg = computeBackground(params, xf, opt);
            peakOnly = yfit - bg;

            integral = trapz(xf, peakOnly);
            fwhm = computeFWHM(params, opt);

            % SPEICHERN
            results(c,p).success = true;
            results(c,p).xfit = xf;
            results(c,p).yfit = yfit;
            results(c,p).bg = bg;
            results(c,p).peakOnly = peakOnly;
            results(c,p).params = params;
            results(c,p).paramStdErr = stderr;
            results(c,p).paramCI95 = ci95;
            results(c,p).integral = integral;
            results(c,p).FWHM = fwhm;
        end

        % ==========================================
        %   NEU: EIN PLOT PRO SPALTE
        % ==========================================
        if opt.plotFits
            plotFit(x, y, results(c,:), c);
        end

    end
end


% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% AUTOMATISCHES FENSTER (aus Rohdaten)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function w = autoWindowSize(y, idxPeak)
%     leftMin = min(y(1:idxPeak));
%     rightMin = min(y(idxPeak:end));
%     prominence = y(idxPeak) - max(leftMin, rightMin);
% 
%     w = 2 * prominence;   % heuristisch gut für typische Spektren
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PARAMETERANZAHL
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function n = numberOfParameters(opt)
%     switch opt.model
%         case 'gauss'
%             n = 3;
%         case 'lorentz'
%             n = 3;
%         case 'pseudo-voigt'
%             n = 4;
%     end
%     n = n + (opt.backgroundDegree + 1);
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% INITIALWERTE
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function p0 = initialGuess(x, y, opt)
%     A = max(y) - min(y);
%     x0 = x(y==max(y));
%     sigma = (max(x)-min(x))/6;
% 
%     switch opt.model
%         case 'gauss'
%             base = [A, x0, sigma];
%         case 'lorentz'
%             base = [A, x0, sigma];
%         case 'pseudo-voigt'
%             base = [A, x0, sigma, 0.5];
%     end
% 
%     % Hintergrund
%     bg = polyfit(x, y, opt.backgroundDegree);
% 
%     p0 = [base, bg];
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% COMPOSITE MODEL (PEAK + POLYNOMIAL)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function y = compositeModel(p, x, opt)
% 
%     % Peakparameter
%     switch opt.model
%         case 'gauss'
%             A = p(1); x0 = p(2); s = p(3);
%             peak = A * exp(-(x-x0).^2 / (2*s^2));
% 
%             bg = polyval(p(4:end), x);
% 
%         case 'lorentz'
%             A = p(1); x0 = p(2); s = p(3);
%             peak = A * (s^2 ./ ((x-x0).^2 + s^2));
% 
%             bg = polyval(p(4:end), x);
% 
%         case 'pseudo-voigt'
%             A = p(1); x0 = p(2); s = p(3); eta = p(4);
%             G = exp(-(x-x0).^2 / (2*s^2));
%             L = (s^2 ./ ((x-x0).^2 + s^2));
%             peak = A * (eta*L + (1-eta)*G);
% 
%             bg = polyval(p(5:end), x);
%     end
% 
%     y = peak + bg;
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% PLOT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function plotFit(x, y, r)
% 
%     figure; hold on;
%     plot(x, y, 'k'); 
%     plot(r.xfit, r.yfit, 'r', 'LineWidth', 2);
%     title('Peak-Fit');
%     xlabel('x'); ylabel('Signal');
%     legend('Signal', 'Fit');
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %% EXPORT
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function exportFitResults(results, opt)
% 
%     M = numel(results);
%     rows = cell(M,1);
% 
%     k = 1;
%     for i = 1:size(results,1)
%         for j = 1:size(results,2)
%             if results(i,j).success
%                 rows{k,1} = i;
%                 rows{k,2} = j;
%                 rows{k,3} = results(i,j).model;
%                 rows{k,4} = results(i,j).params;
%                 k = k + 1;
%             end
%         end
%     end
% 
%     T = cell2table(rows, ...
%         'VariableNames', {'Column', 'PeakIndex', 'Model', 'Params'});
% 
%     if opt.exportTable
%         disp(T);
%     end
% 
%     if opt.exportExcel
%         writetable(T, opt.excelFile);
%         fprintf('Excel export completed: %s\n', opt.excelFile);
%     end
% end

%% automatische Fensterbestimmung
function w = autoWindowSize(y, idxPeak)
    leftMin = min(y(1:idxPeak));
    rightMin = min(y(idxPeak:end));
    prominence = y(idxPeak) - max(leftMin, rightMin);
    w = max( (prominence * 2),  (idxPeak));  % heuristisch
    % Optional: begrenzen ausserhalb sinnvoller Grenzen
    % w = min(w, some_max);
end

function n = numberOfParameters(opt)
    switch lower(opt.model)
        case 'gauss'
            n = 3;
        case 'lorentz'
            n = 3;
        case 'pseudo-voigt'
            n = 4;
        otherwise
            error('Unbekanntes Modell');
    end
    n = n + (opt.backgroundDegree + 1);
end

function p0 = initialGuess(x, y, opt)
    A = max(y)-min(y);
    [~, imax] = max(y);
    x0 = x(imax);
    sigma = (max(x)-min(x))/6;

    switch lower(opt.model)
        case 'gauss'
            base = [A, x0, sigma];
        case 'lorentz'
            base = [A, x0, sigma];
        case 'pseudo-voigt'
            base = [A, x0, sigma, 0.5];
    end

    bg = polyfit(x, y, opt.backgroundDegree);
    p0 = [base, bg];
end

function y = compositeModel(p, x, opt)
    switch lower(opt.model)
        case 'gauss'
            A = p(1); x0 = p(2); s = p(3);
            peak = A * exp(-(x-x0).^2 / (2*s^2));
            bg = polyval(p(4:end), x);

        case 'lorentz'
            A = p(1); x0 = p(2); s = p(3);
            peak = A * (s^2 ./ ((x-x0).^2 + s^2));
            bg = polyval(p(4:end), x);

        case 'pseudo-voigt'
            A = p(1); x0 = p(2); s = p(3); eta = p(4);
            G = exp(-(x-x0).^2 / (2*s^2));
            L = (s^2 ./ ((x-x0).^2 + s^2));
            peak = A * (eta * L + (1-eta) * G);
            bg = polyval(p(5:end), x);

        otherwise
            error('Unbekanntes Modell');
    end
    y = peak + bg;
end

function bg = computeBackground(p, x, opt)
    if strcmpi(opt.model, 'pseudo-voigt')
        coeffs = p(5:end);
    else
        coeffs = p(4:end);
    end
    bg = polyval(coeffs, x);
end

function fwhm = computeFWHM(p, opt)
    switch lower(opt.model)
        case 'gauss'
            s = p(3);
            fwhm = 2*sqrt(2*log(2))*s;
        case 'lorentz'
            s = p(3);
            fwhm = 2*s;
        case 'pseudo-voigt'
            s = p(3);
            eta = p(4);
            % Näherung: FWHM ≈ s * (some function of eta)
            % Eine gängige Approximation:
            fwhm_gauss = 2*sqrt(2*log(2))*s;
            fwhm_lorentz = 2*s;
            fwhm = eta * fwhm_lorentz + (1-eta) * fwhm_gauss;
        otherwise
            fwhm = NaN;
    end
end