function plotPeakPositionsSliderCompare_48x6(results)
% results: [Nspec x Npeaks] struct (bei dir 48x6)
% results(s,p).Gauss.mu, .muErr (oder .mu_err)
% results(s,p).PV.mu, .muErr (oder .mu_err)
% results(s,p).gammaCenter: [1 x Nspec] (redundant gespeichert)

[Nspec, Npeaks] = size(results);

% gamma-Achse (einmalig aus erstem Element)
gamma = results(1,1).gammaCenter(:);
if numel(gamma) ~= Nspec
    error('gammaCenter hat %d Elemente, aber Nspec=%d. Bitte prüfen.', numel(gamma), Nspec);
end

fig = figure('Name','2\theta Peaklage vs \gamma (Gauss vs PV)','NumberTitle','off');
ax  = axes(fig); hold(ax,'on'); box(ax,'on'); grid(ax,'on');
xlabel(ax,'\gamma (°)');
ylabel(ax,'2\theta_{Peak} (°)');

hG  = errorbar(ax, gamma, nan(Nspec,1), nan(Nspec,1), 'o-', 'CapSize',0);
hPV = errorbar(ax, gamma, nan(Nspec,1), nan(Nspec,1), 's-', 'CapSize',0);
legend(ax, {'Gauss','Pseudo-Voigt'}, 'Location','best');

% Peak-Slider
sld = uicontrol('Style','slider', ...
    'Min',1,'Max',Npeaks,'Value',1, ...
    'SliderStep',[1/max(Npeaks-1,1) 1/max(Npeaks-1,1)], ...
    'Units','normalized','Position',[0.18 0.02 0.68 0.05], ...
    'Callback',@refreshPlot);

txt = uicontrol('Style','text', ...
    'Units','normalized','Position',[0.02 0.02 0.15 0.05], ...
    'String','Peak 1','HorizontalAlignment','left');

refreshPlot();

% =========================================================
    function [mu, muErr] = getMuErr(fieldName, p)
        mu = nan(Nspec,1);
        muErr = nan(Nspec,1);

        for s = 1:Nspec
            if ~isfield(results(s,p), fieldName), continue; end
            m = results(s,p).(fieldName);

            if isempty(m) || ~isstruct(m) || ~isfield(m,'mu') || isempty(m.mu)
                continue
            end

            mu(s) = m.mu;

            if isfield(m,'muErr') && ~isempty(m.muErr)
                muErr(s) = m.muErr;
            elseif isfield(m,'mu_err') && ~isempty(m.mu_err)
                muErr(s) = m.mu_err;
            end
        end
    end

    function refreshPlot(~,~)
        p = round(sld.Value);
        set(txt,'String',sprintf('Peak %d',p));

        [muG,  muGe]  = getMuErr('Gauss', p);
        [muPV, muPVe] = getMuErr('PV', p);

        set(hG,  'YData', muG,  'UData', muGe,  'LData', muGe);
        set(hPV, 'YData', muPV, 'UData', muPVe, 'LData', muPVe);

        % y-limits sinnvoll
        allMu = [muG; muPV];
        allE  = [muGe; muPVe];
        good = ~isnan(allMu);
        if any(good)
            ymin = min(allMu(good) - allE(good), [], 'omitnan');
            ymax = max(allMu(good) + allE(good), [], 'omitnan');
            pad  = 0.05*(ymax - ymin + eps);
            % ylim(ax, [mean(allMu)-0.2 mean(allMu)+0.2]);
            ylim(ax, [ymin-pad ymax+pad]);
        end

        % Referenzpeak (falls vorhanden)
        ref = NaN;
        if isfield(results(1,p),'peakRef') && ~isempty(results(1,p).peakRef)
            ref = results(1,p).peakRef;
        end

        if ~isnan(ref)
            title(ax, sprintf('Peak %d (Ref %.3f°): 2\\theta(\\gamma) | Gauss vs PV', p, ref));
        else
            title(ax, sprintf('Peak %d: 2\\theta(\\gamma) | Gauss vs PV', p));
        end
    end
end
