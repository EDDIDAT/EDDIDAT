function SliderCallback(hObject, ~, data)

    value = get(hObject, 'Value');
   
    set(data.Plots, 'Visible', 'off');
              
    set(data.Plots(round(value),:), 'Visible', 'on');
    
    axes = get(data.Plots(1), 'Parent');
    
    title(axes, data.Title{round(value)});
end