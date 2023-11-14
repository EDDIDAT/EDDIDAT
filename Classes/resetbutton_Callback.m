function resetbutton_Callback(source,eventdata) 
    % Reset plot to the spectrum data.
    Plothandles = guidata(gcbo);
    h = Plothandles.h;
    delete(h)
    guidata(gcbo,Plothandles);
end