function plotPeakFitsWithSlider(results)
% Interaktiver Vergleich: Gauss vs. Pseudo-Voigt mit Slider

nSpec = numel(results);

% --- Figure & Layout ---
fig = figure('Name','Peak-Fit Vergleich','NumberTitle','off');
tiledlayout(fig,1,2,'Padding','compact','TileSpacing','compact');

axG  = nexttile; hold(axG,'on'); box(axG,'on');
axPV = nexttile; hold(axPV,'on'); box(axPV,'on');

% --- Slider ---
sld = uicontrol('Style','slider', ...
    'Min',1,'Max',nSpec,'Value',1, ...
    'SliderStep',[1/(nSpec-1) 5/(nSpec-1)], ...
    'Units','normalized', ...
    'Position',[0.2 0.02 0.6 0.04], ...
    'Callback',@updatePlot);

% Initial plot
updatePlot();

% =========================================================
    function updatePlot(~,~)
        s = round(sld.Value);

        % Daten
        x = results(s).thetaFit(:);
        y = results(s).yFit(:);

        cla(axG); cla(axPV);

        % ---------- Gauss ----------
        axes(axG);
        plot(x,y,'k.','DisplayName','Daten');

        if isfield(results(s),'Gauss') && ~isempty(results(s).Gauss)
            for p = 1:numel(results(s).Gauss)
                mdl = results(s).Gauss(p).model;
                plot(x, mdl(x),'r-','LineWidth',1.5);
            end
        end

        title(axG, sprintf('Gauss-Fit | \\gamma = %.2f°', ...
              results(s).gammaCenter));
        xlabel(axG,'2\theta (°)');
        ylabel(axG,'Intensität');

        % ---------- Pseudo-Voigt ----------
        axes(axPV);
        plot(x,y,'k.','DisplayName','Daten');

        if isfield(results(s),'PV') && ~isempty(results(s).PV)
            for p = 1:numel(results(s).PV)
                mdl = results(s).PV(p).model;
                plot(x, mdl(x),'b-','LineWidth',1.5);
            end
        end

        title(axPV, sprintf('Pseudo-Voigt-Fit | \\gamma = %.2f°', ...
              results(s).gammaCenter));
        xlabel(axPV,'2\theta (°)');
        ylabel(axPV,'Intensität');
    end
end
