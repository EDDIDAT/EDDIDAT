%% (* plot the fit results *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
T.Figure = figure('Toolbar', 'figure','units','normalized','OuterPosition',[0.125 0.125 0.75 0.75]);
% Daten fuer das Slider-Callback
T.Plots = zeros(length(Measurement),2);
T.Title = cell(length(Measurement),1);
hold on;

for c = 1:length(Measurement)
    T.X = DataTmp{c}(:, 1);
    T.Y = DataTmp{c}(:, 2);
    
    % Gefittete Parameter in die Summenfunktion aller Peaks einsetzen und
    % Werte ausrechnen
    T.XPlot = T.X(1):0.001:T.X(end);
    T.YPlot = zeros(size(T.XPlot));
    for d = 1:size(FittedPeaks{c}, 1)
        T.SinglePlot = Tools.Science.Math.FF_PseudoVoigt(T.XPlot, ...
            FittedPeaks{c}(d, 1), FittedPeaks{c}(d, 2), FittedPeaks{c}(d, 3),FittedPeaks{c}(d, 4));
        T.YPlot = T.YPlot + T.SinglePlot;
        
        T.Plots(c,3+d) = plot(T.XPlot, T.SinglePlot);
        set(T.Plots(c,3+d), 'LineWidth', 1);
        set(T.Plots(c,3+d), 'Color', 'black');
    end

    T.Plots(c,1) = plot(T.X, T.Y);
    set(T.Plots(c,1), 'Marker', 'o');
    set(T.Plots(c,1), 'MarkerSize', 2);
    set(T.Plots(c,1), 'Color', 'blue');
    set(T.Plots(c,1), 'LineStyle', 'none');
    
    T.Plots(c,2) = plot(T.XPlot, T.YPlot);
    set(T.Plots(c,2), 'LineWidth', 2);
    set(T.Plots(c,2), 'Color', 'red');
    
    T.Plots(c,3) = plot(T.X,(T.Y - interp1(T.XPlot,T.YPlot,T.X)) - (max(T.Y) .* 0.5));
    set(T.Plots(c,3), 'LineWidth', 1);
    set(T.Plots(c,3), 'Color', 'black');
        
    xlim([min(T.X) max(T.X)]);
%     legend({'measured profile', 'fitted profile', 'residual'});
    
    T.Title{c} = ['Fitted Data for ', Measurement(c).Name];
    xlabel('Energy [keV]');
    ylabel('Intensity [cts]');
    
end

% Slider erzeugen
T.Slider = uicontrol(...
        'Style','slider',...
        'Tag','Slider',...
        'Parent',T.Figure,...
        'Units','normalized',...
        'Position', [0.45 0.00625 0.1 0.03],...
        'Min',1,...
        'Max',length(Measurement),...
        'SliderStep',[1/(length(Measurement)-1) 1/(length(Measurement)-1)],...
        'Value',1,...
        'Callback',{@SliderCallback,T});
    
SliderCallback(T.Slider, 0, T);

if (P.CleanUpTemporaryVariables)
    clear('P');
%     clear('T');
    clear c d;
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++