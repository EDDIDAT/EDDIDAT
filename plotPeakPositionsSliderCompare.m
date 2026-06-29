function plotPeakPositionsSliderCompare(results)
% Interaktiver Plot: 2theta_peak vs gammaCenters (Gauss vs PV)
% Robust für verschiedene results-Strukturen:
% A) results(s) = Spektrum/GammaBlock, results(s).gammaCenter = Skalar
% B) results(p) = Peak, results(p).gammaCenter = Vektor über Spektren

% ---- 1) Gamma-Achse finden ----
[gamma, layout] = inferGammaAxis(results);

% ---- 2) Peakanzahl bestimmen ----
Np = inferNumPeaks(results, layout);
if Np == 0
    error('Keine Peaks in results gefunden (Gauss/PV leer).');
end

% ---- Figure ----
nG = numel(gamma);

fig = figure('Name','2\theta Peaklage vs. \gamma (Gauss vs PV)','NumberTitle','off');
ax = axes(fig); box(ax,'on'); grid(ax,'on'); hold(ax,'on');
xlabel(ax, '\gamma (°)');
ylabel(ax, '2\theta_{Peak} (°)');

hG  = errorbar(ax, gamma, nan(nG,1), nan(nG,1), 'o-', 'CapSize', 0);
hPV = errorbar(ax, gamma, nan(nG,1), nan(nG,1), 's-', 'CapSize', 0);
legend(ax, {'Gauss','Pseudo-Voigt'}, 'Location','best');

sld = uicontrol('Style','slider', ...
    'Min', 1, 'Max', Np, 'Value', 1, ...
    'SliderStep', [1/max(Np-1,1), 1/max(Np-1,1)], ...
    'Units','normalized', 'Position',[0.15 0.02 0.7 0.045], ...
    'Callback', @refreshPlot);

txt = uicontrol('Style','text', ...
    'Units','normalized', 'Position',[0.02 0.02 0.12 0.045], ...
    'String','Peak 1', 'HorizontalAlignment','left');

refreshPlot();

% =====================================================================
    function refreshPlot(~,~)
        p = round(sld.Value);
        set(txt,'String',sprintf('Peak %d',p));

        [muG, muGe, refG]   = extractMu(results, layout, gamma, 'Gauss', p);
        [muPV, muPVe, refP] = extractMu(results, layout, gamma, 'PV', p);

        set(hG,  'YData', muG,  'UData', muGe,  'LData', muGe);
        set(hPV, 'YData', muPV, 'UData', muPVe, 'LData', muPVe);

        allMu = [muG; muPV];
        allE  = [muGe; muPVe];
        good = ~isnan(allMu);
        if any(good)
            ymin = min(allMu(good) - allE(good), [], 'omitnan');
            ymax = max(allMu(good) + allE(good), [], 'omitnan');
            pad = 0.05*(ymax - ymin + eps);
            ylim(ax, [ymin-pad, ymax+pad]);
        end

        ref = refG; if isnan(ref), ref = refP; end
        if ~isnan(ref)
            title(ax, sprintf('Peak %d (Ref %.3f°): 2\\theta(\\gamma) | Gauss vs PV', p, ref));
        else
            title(ax, sprintf('Peak %d: 2\\theta(\\gamma) | Gauss vs PV', p));
        end
    end
end

% ======================= Helper: Gamma-Achse ==========================
function [gamma, layout] = inferGammaAxis(results)
% layout = 'bySpectrum' oder 'byPeak'

% Fall A: results(1).gammaCenter ist Skalar → bySpectrum
if isstruct(results) && isfield(results(1),'gammaCenter') && isscalar(results(1).gammaCenter)
    gamma = arrayfun(@(r) r.gammaCenter, results(:));
    gamma = gamma(:);
    layout = 'bySpectrum';
    return
end

% Fall B: results(1).gammaCenter ist Vektor → byPeak (oder global gespeichert)
if isstruct(results) && isfield(results(1),'gammaCenter') && ~isscalar(results(1).gammaCenter)
    gamma = results(1).gammaCenter(:);
    layout = 'byPeak';
    return
end

error('Konnte gammaCenter nicht eindeutig finden. Bitte gammaCenter speichern (Skalar pro Spektrum oder Vektor pro Peak).');
end

% ======================= Helper: Peakanzahl ===========================
function Np = inferNumPeaks(results, layout)
Np = 0;
switch layout
    case 'bySpectrum'
        % peaks in results(s).Gauss / results(s).PV
        for s = 1:numel(results)
            if isfield(results(s),'Gauss') && ~isempty(results(s).Gauss)
                Np = max(Np, numel(results(s).Gauss));
            end
            if isfield(results(s),'PV') && ~isempty(results(s).PV)
                Np = max(Np, numel(results(s).PV));
            end
        end
    case 'byPeak'
        % results(p) entspricht Peak
        Np = numel(results);
end
end

% ======================= Helper: mu extrahieren =======================
function [mu, muErr, ref] = extractMu(results, layout, gamma, modelField, p)
nG = numel(gamma);
mu = nan(nG,1);
muErr = nan(nG,1);
ref = NaN;

switch layout
    case 'bySpectrum'
        % results(s).<modelField>(p).mu
        for s = 1:numel(results)
            if ~isfield(results(s), modelField), continue; end
            arr = results(s).(modelField);
            if isempty(arr) || numel(arr) < p, continue; end
            if ~isfield(arr(p),'mu') || isempty(arr(p).mu), continue; end
            mu(s) = arr(p).mu;

            if isfield(arr(p),'muErr') && ~isempty(arr(p).muErr)
                muErr(s) = arr(p).muErr;
            elseif isfield(arr(p),'mu_err') && ~isempty(arr(p).mu_err)
                muErr(s) = arr(p).mu_err;
            end

            if isnan(ref) && isfield(arr(p),'peakRef') && ~isempty(arr(p).peakRef)
                ref = arr(p).peakRef;
            end
        end

    case 'byPeak'
        % results(p).<modelField>.mu ist Vektor über gamma
        if p > numel(results), return; end
        if ~isfield(results(p), modelField), return; end

        arr = results(p).(modelField);

        % Unterstütze zwei Varianten:
        % 1) arr.mu als Vektor
        % 2) arr ist struct-array über gamma (selten)
        if isstruct(arr) && isfield(arr,'mu') && ~isscalar(arr.mu)
            mu = arr.mu(:);
            if isfield(arr,'muErr'), muErr = arr.muErr(:); end
            if isfield(arr,'mu_err'), muErr = arr.mu_err(:); end
        elseif isstruct(arr) && numel(arr) == nG && isfield(arr(1),'mu')
            mu = arrayfun(@(z) z.mu, arr(:));
            mu = mu(:);
            if isfield(arr(1),'muErr')
                muErr = arrayfun(@(z) z.muErr, arr(:)); muErr = muErr(:);
            elseif isfield(arr(1),'mu_err')
                muErr = arrayfun(@(z) z.mu_err, arr(:)); muErr = muErr(:);
            end
        end

        if isfield(results(p),'peakRef') && ~isempty(results(p).peakRef)
            ref = results(p).peakRef;
        end
end

% Längen anpassen, falls nötig
mu = mu(1:min(end,nG));
muErr = muErr(1:min(end,nG));
if numel(mu) < nG, mu(end+1:nG) = NaN; end
if numel(muErr) < nG, muErr(end+1:nG) = NaN; end
end
