function plotPeakPositionsSlider(results)
% plotPeakPositionsSlider
% Interaktiver Plot: 2theta_peak vs gammaCenters
% Slider wählt Peakindex, Dropdown wählt Modell (Gauss/PV).

nSpec = numel(results);

% --- gammaCenters extrahieren ---
gamma = nan(nSpec,1);
for s = 1:nSpec
    if isfield(results(s),'gammaCenter')
        gamma(s) = results(s).gammaCenter;
    else
        error('results(%d).gammaCenter fehlt. Bitte beim Fit speichern.', s);
    end
end

% --- Anzahl Peaks bestimmen (aus erstem gültigen Spektrum) ---
Np = 0;
for s = 1:nSpec
    if isfield(results(s),'Gauss') && ~isempty(results(s).Gauss)
        Np = max(Np, numel(results(s).Gauss));
    end
    if isfield(results(s),'PV') && ~isempty(results(s).PV)
        Np = max(Np, numel(results(s).PV));
    end
end
if Np == 0
    error('Keine Peaks in results gefunden (Gauss/PV leer).');
end

% --- Figure ---
fig = figure('Name','2\theta Peaklage vs. \gamma','NumberTitle','off');
ax = axes(fig); box(ax,'on'); grid(ax,'on'); hold(ax,'on');

hErr = errorbar(ax, gamma, nan(size(gamma)), nan(size(gamma)), ...
    'o', 'CapSize', 0);
hLine = plot(ax, gamma, nan(size(gamma)), '-');

xlabel(ax, '\gamma (°)');
ylabel(ax, '2\theta_{Peak} (°)');

% --- Peak slider ---
sld = uicontrol('Style','slider', ...
    'Min', 1, 'Max', Np, 'Value', 1, ...
    'SliderStep', [1/max(Np-1,1), 1/max(Np-1,1)], ...
    'Units','normalized', 'Position',[0.15 0.02 0.55 0.045], ...
    'Callback', @refreshPlot);

% --- Model dropdown ---
dd = uicontrol('Style','popupmenu', ...
    'String', {'Gauss','Pseudo-Voigt'}, ...
    'Units','normalized', 'Position',[0.72 0.02 0.18 0.045], ...
    'Callback', @refreshPlot);

% Initial plot
refreshPlot();

% =========================================================
    function refreshPlot(~,~)
        p = round(sld.Value);
        modelChoice = dd.Value; % 1=Gauss, 2=PV

        theta = nan(nSpec,1);
        thetaErr = nan(nSpec,1);

        for s = 1:nSpec
            if modelChoice == 1
                if isfield(results(s),'Gauss') && numel(results(s).Gauss) >= p ...
                        && isfield(results(s).Gauss(p),'mu') && ~isempty(results(s).Gauss(p).mu)
                    theta(s) = results(s).Gauss(p).mu;
                    % Fehlerfeld: muErr oder mu_err akzeptieren
                    if isfield(results(s).Gauss(p),'muErr')
                        thetaErr(s) = results(s).Gauss(p).muErr;
                    elseif isfield(results(s).Gauss(p),'mu_err')
                        thetaErr(s) = results(s).Gauss(p).mu_err;
                    end
                end
            else
                if isfield(results(s),'PV') && numel(results(s).PV) >= p ...
                        && isfield(results(s).PV(p),'mu') && ~isempty(results(s).PV(p).mu)
                    theta(s) = results(s).PV(p).mu;
                    if isfield(results(s).PV(p),'muErr')
                        thetaErr(s) = results(s).PV(p).muErr;
                    elseif isfield(results(s).PV(p),'mu_err')
                        thetaErr(s) = results(s).PV(p).mu_err;
                    end
                end
            end
        end

        % Plot aktualisieren
        set(hErr, 'YData', theta, 'UData', thetaErr, 'LData', thetaErr);
        set(hLine,'YData', theta);

        % Achsenlimits sinnvoll setzen (unter Berücksichtigung von Fehlern)
        good = ~isnan(theta);
        if any(good)
            ymin = min(theta(good) - thetaErr(good), [], 'omitnan');
            ymax = max(theta(good) + thetaErr(good), [], 'omitnan');
            pad = 0.05*(ymax - ymin + eps);
            ylim(ax, [ymin-pad, ymax+pad]);
        end

        modelName = dd.String{dd.Value};
        title(ax, sprintf('%s: Peak %d | 2\\theta(\\gamma)', modelName, p));
    end
end
