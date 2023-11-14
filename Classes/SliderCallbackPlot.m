function SliderCallbackPlot(hObject, ~, data)

    value = get(hObject, 'Value');
   
    set(data.Plots, 'Visible', 'off');
    
    set(data.Texts, 'Visible', 'off');
            
    set(data.Plots(round(value),:), 'Visible', 'on');
    
    set(data.Texts(round(value),:), 'Visible', 'on');
    
    if (data.PlotSubstratePeaks)
        set(data.Textsubstrat, 'Visible', 'off');

        set(data.Textsubstrat(round(value),:), 'Visible', 'on');
    end
    
    axes = get(data.Plots(1), 'Parent');
    
    title(axes, data.Title{round(value)});
end