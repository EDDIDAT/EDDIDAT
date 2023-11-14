function kresetbutton_Callback(source,eventdata) 
    % Reset plot to the spectrum data.
    Plothandles = guidata(gcbo);
    hphase = Plothandles.hphase;
    delete(hphase)
    guidata(gcbo,Plothandles);
end