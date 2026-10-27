function peakFitSlider(thetaSub, gammaCenters, gammaBlock, profiles, fits, peakWins)
fig = figure('Name','γ-Block Peak-Fits','NumberTitle','off');

ax = axes(fig);
hData = plot(ax, thetaSub, nan(size(thetaSub)), 'k'); hold on
hFit  = plot(ax, thetaSub, nan(size(thetaSub)), 'r','LineWidth',2);
hold off

xlabel(ax,'2\theta (°)')
ylabel(ax,'Intensität (aufsummiert)')
grid(ax,'on')

sld = uicontrol('Style','slider', ...
    'Min',1,'Max',numel(gammaCenters),'Value',1, ...
    'SliderStep',[1/(numel(gammaCenters)-1), 0.1], ...
    'Units','normalized','Position',[0.15 0.02 0.7 0.04], ...
    'Callback', @(src,~) updateGammaPlot(round(src.Value)) );

updateGammaPlot(1)

function updateGammaPlot(i)

    if isempty(profiles{i}) || isempty(fits{i})
        return
    end

    set(hData,'YData',profiles{i});

    yFit = nan(size(thetaSub));
    pw = peakWins{i};
    yFit(pw) = feval(fits{i}, thetaSub(pw));

    set(hFit,'YData',yFit);

    title(ax, sprintf('\\gamma = %.1f° ± %.1f°', ...
          gammaCenters(i), gammaBlock/2))

    ylim(ax,[0 max(profiles{i})*1.1])
end


end