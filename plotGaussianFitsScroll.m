function plotGaussianFitsScroll(x, Y, fitOut)
% PLOTGAUSSIANFITSSCROLL
%   Interaktive Fit-Ansicht:
%   Scrolle durch die Spektren mit Next/Prev-Buttons.
%
% INPUT:
%   x       - x-Achse
%   Y       - Spektrenmatrix (N x M)
%   fitOut  - Struktur mit Fitparametern (M x nPeaks)

    x = x(:);
    [~, nCols] = size(Y);
    [nCols_FO, nPeaks] = size(fitOut);

    if nCols_FO ~= nCols
        error('fitOut und Y müssen die gleiche Anzahl Spalten haben.');
    end

    % --- Figure / GUI ---
    fig = figure('Name','Gaussian Fit Viewer',...
        'NumberTitle','off',...
        'Position',[200 200 800 500]);

    ax = axes('Parent',fig);
    hold(ax,'on');

    % Buttons
    btnPrev = uicontrol(fig,'Style','pushbutton','String','<< Previous',...
        'Units','normalized','Position',[0.02 0.12 0.15 0.06],...
        'Callback',@(~,~) changeSpectrum(-1));

    btnNext = uicontrol(fig,'Style','pushbutton','String','Next >>',...
        'Units','normalized','Position',[0.83 0.12 0.15 0.06],...
        'Callback',@(~,~) changeSpectrum(+1));

    titleText = uicontrol(fig,'Style','text',...
        'Units','normalized','Position',[0.20 0.92 0.60 0.06],...
        'FontSize',12,'HorizontalAlignment','center');

    % Farben
    colors = lines(nPeaks);

    % Startindex
    idxCurrent = 1;

    % Erste Darstellung
    updatePlot();

    % =====================================================================
    % Nested functions für GUI
    % =====================================================================

    function changeSpectrum(direction)
        idxCurrent = idxCurrent + direction;

        if idxCurrent < 1
            idxCurrent = 1;
        elseif idxCurrent > nCols
            idxCurrent = nCols;
        end

        updatePlot();
    end

    function updatePlot()
        cla(ax); hold(ax,'on');

        y = Y(:,idxCurrent);

        % --- Originaldaten zeichnen ---
        plot(ax, x, y, 'k', 'LineWidth', 1.0);

        % --- Titel aktualisieren ---
        titleText.String = sprintf('Spectrum %d / %d', idxCurrent, nCols);

        % --- Peaks zeichnen ---
        for p = 1:nPeaks

            if ~fitOut(idxCurrent,p).success
                continue;
            end

            params = fitOut(idxCurrent,p).params;  % [A mu sigma offset]
            mu = params(2);

            % Fitbereich rekonstruieren
            if isfield(fitOut(idxCurrent,p),'xFit') && ~isempty(fitOut(idxCurrent,p).xFit)
                xFit = fitOut(idxCurrent,p).xFit;
            else
                % Falls xFit nicht gespeichert wurde:
                sigma = params(3);
                xFit = linspace(mu-4*sigma, mu+4*sigma, 200);
            end
            
            yFit = fitGaussian(params, xFit);

            plot(ax, xFit, yFit, 'Color', colors(p,:), 'LineWidth', 1.5);

            % Peakpunkt markieren
            plot(ax, mu, fitGaussian(params, mu), 'o', ...
                'Color', colors(p,:), 'MarkerFaceColor', colors(p,:));
        end

        xlabel(ax,'x');
        ylabel(ax,'Signal');
        grid(ax,'on');
        hold(ax,'off');
    end
end


% Hilfsfunktion: Gaussian
function y = fitGaussian(b, x)
    y = b(1) .* exp(-(x - b(2)).^2 ./ (2*b(3).^2)) + b(4);
end
