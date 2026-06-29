for k = 1:size(h.epsfitdataexport,2)
    figure
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPositionMode = 'manual';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.085 1.025];
    ax.TickDir = 'out';
    ax.YAxis.TickLabelFormat = '%,.3f';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;
    ax.YLabel.String = [char(949),'(',char(947),')'];
    ax.YLabel.FontSize = 24;
    ax.XLabel.String = [char(947),' [°]'];
    ax.XLabel.FontSize = 24;
    ax.XLim = [0 1];
    ax.YLim = [-Inf,Inf];

    ax.LabelFontSizeMultiplier = 1.3;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',18)
    hold on
    set(fig, 'Visible', 'off');
    
    errorbar(h.epsfitdataexport{k}(:,1),h.epsfitdataexport{k}(:,2),h.epsfitdataexport{k}(:,3),'s'); 
    plot(h.epsfitdataexport{k}(:,1),h.epsgammaergfunc{k}','-');
    LegLabeldata = num2str(h.DEKdataMatchedPeaks(k,1:3));
    % Create legend
    l = legend(h.LegLabelData);
    % Find best legend position
    % legposcell = {'NorthWest','NorthEast','SouthWest','SouthEast'};
    % Loop through legend positions in order to get coordinates of all
    % possible corner positions
    % l.Location = legposcell{m};
    
    % Set legend location and properties
%     l.Location = legposcell{LegPosOptInd(1)};
    l.FontSize = 10;
    l.LineWidth = 0.5;
    
    title(l,[label(k,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
    set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);

    FileName = sprintf([strrep(h.FileNameEditField.Value(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_epsilonfit_Line_','%d'],k);
    
    print(fig,[Path,FileName],'-painters','-dtiff','-r300')

end



% Plots
set(h.plotdata,'Xdata',epsfitdataexport{1}(:,1))
set(h.plotdata,'Ydata',epsfitdataexport{1}(:,2))
set(h.plotdata,'YNegativeDelta',epsfitdataexport{1}(:,3))
set(h.plotdata,'YPositiveDelta',epsfitdataexport{1}(:,3))

set(h.fitcurvestress,'Xdata',epsfitdataexport{1}(:,1))
set(h.fitcurvestress,'Ydata',epsgammaergfunc{1}')
set(h.fitcurvestress,'Visible','on')

set(h.plotdatasin2psi,'Xdata',epssin2psifitdaten{1}(:,1))
set(h.plotdatasin2psi,'Ydata',epssin2psifitdaten{1}(:,2))
set(h.plotdatasin2psi,'YNegativeDelta',epssin2psifitdaten{1}(:,3))
set(h.plotdatasin2psi,'YPositiveDelta',epssin2psifitdaten{1}(:,3))

set(h.plotdatasin2psi,'Visible','on')

set(h.fitcurvestresssin2psi,'Xdata',(0:0.05:1))
set(h.fitcurvestresssin2psi,'Ydata',sin2psiregres{1})
set(h.fitcurvestresssin2psi,'Visible','on')


h.axesStressData.XLim = [0,20];
h.axesStressData.YLim = [-Inf,Inf];
h.axesStressData.YLimMode = 'auto';
h.axesStressData.YLabel.String = [char(963),' [MPa]'];
h.axesStressData.YLabel.FontSize = 16;
h.axesStressData.XLabel.String = [char(964),' [',char(956),'m]'];
h.axesStressData.XLabel.FontSize = 16;
grid(h.axesStressData,'on')

h.plotstressdata = errorbar(h.axesStressData, x,y,err,'s'); 


% Create plot for raw data
h.plotdata = errorbar(h.ax, x,y,err,'s','Visible','off');
hold(h.ax,'on')
h.fitcurvestress = plot(h.ax,0,0,'-',"Visible",'off');

% Create plot for sin²psi data
h.plotdatasin2psi = errorbar(h.axessin2psi, x,y,err,'s','Visible','off');
hold(h.axessin2psi,'on')
h.fitcurvestresssin2psi = plot(h.axessin2psi,0,0,'-',"Visible",'off');


h.ax.XLim = [-90,40];
h.ax.YLim = [-Inf,Inf];
h.ax.YLimMode = 'auto';
h.ax.YLabel.String = [char(949),'(',char(947),')'];
h.ax.YLabel.FontSize = 16;
h.ax.XLabel.String = [char(947),' [°]'];
h.ax.XLabel.FontSize = 16;



h.axessin2psi.XLim = [0 1];
h.axessin2psi.YLim = [0,Inf];
h.axessin2psi.YLimMode = 'auto';
h.axessin2psi.YLabel.String = [char(949),'(',char(947),')'];
h.axessin2psi.YLabel.FontSize = 16;
h.axessin2psi.XLabel.String = ['sin²',char(968)];
h.axessin2psi.XLabel.FontSize = 16;



figure
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPositionMode = 'manual';
fig.PaperPosition = [0 0 18 12];
ax = gca;
ax.OuterPosition = [0 0 1.085 1.025];
ax.TickDir = 'out';
ax.YAxis.TickLabelFormat = '%,.1f';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 0.3;
ax.YLabel.String = [char(963),' [MPa]'];
ax.YLabel.FontSize = 12;
ax.XLabel.String = [char(964),' [',char(956),'m]'];
ax.XLabel.FontSize = 12;

ax.XLim = [0 Inf];
% ax.YLim = [-Inf,Inf];

ax.LabelFontSizeMultiplier = 1;
ax.LineWidth = 1.3;
set(gca,'FontSize',12)
hold on
set(fig, 'Visible', 'off');

errorbar(h.taumean,h.sigmaFinal(:,1),sigmaerrFinal(:,1),'s');
errorbar(h.taumean,h.sigmasin2psiFinal,deltasigmasin2psiFinal,'o');

% Bereich inkl. Fehler
y_min = min(h.epssin2psifitdaten{k}(:,2) - h.epssin2psifitdaten{k}(:,3));
y_max = max(h.epssin2psifitdaten{k}(:,2) + h.epssin2psifitdaten{k}(:,3));

% Abstände berechnen (10 % des Wertebereichs)
y_range = y_max - y_min;
margin = 0.05 * y_range;  % 5% Puffer oben und unten

% Neue Limits setzen
ylim([y_min - margin, y_max + margin]);

LegLabeldata = {'Stressfactor-method','sin²psi-method'};
% Create legend
l = legend(LegLabeldata);

l.FontSize = 10;
l.LineWidth = 0.5;

FileName1 = sprintf([strrep(h.FileNameEditField.Value(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_stressdata']);

print(fig,[PathName,FileName1],'-painters','-dtiff','-r300')



for k = 1:size(h.DEKdataMatchedPeaks,1)
   hkllabestressplot{k} = num2str(h.DEKdataMatchedPeaks(k,1:3))
end


hold on;

% --- Parameter für die Label-Positionierung ---
dy = 0.02 * range(y);   % vertikaler Basisversatz
dx = 0.01 * range(x);   % horizontaler Basisversatz
min_dist = 0.03 * range(y); % Mindestabstand zwischen Labels

% Label-Positionen initialisieren
label_pos = zeros(length(x), 2);
for i = 1:length(x)
    % Startposition: leicht oberhalb
    label_pos(i,:) = [x(i) + dx, y(i) + dy];
end

% --- Kollisionsprüfung und Verschiebung ---
for i = 1:length(x)
    for j = 1:i-1
        % Abstand zwischen Labels prüfen
        dist = sqrt((label_pos(i,1)-label_pos(j,1))^2 + (label_pos(i,2)-label_pos(j,2))^2);
        if dist < min_dist
            % zu nah -> vertikal oder seitlich verschieben
            shift_y = (rand-0.5)*2*dy;  % zufälliger kleiner Y-Shift
            shift_x = (rand-0.5)*2*dx;  % zufälliger kleiner X-Shift
            label_pos(i,1) = label_pos(i,1) + shift_x;
            label_pos(i,2) = label_pos(i,2) + shift_y;
        end
    end
end

% --- Labels zeichnen ---
for i = 1:length(x)
    text(label_pos(i,1), label_pos(i,2), labels{i}, ...
        'FontSize', 9, 'Color', 'b', ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'w', 'Margin', 0.1);
end

hold off;