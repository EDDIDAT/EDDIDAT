function FilterCrystalSystemopoup_Callback(source,event)
        Plothandles = guidata(gcbo);
        str = get(source, 'String');
        val = get(source, 'Value');
        Plothandles.PopupValueFilter = val;
        guidata(gcbo,Plothandles);
end
