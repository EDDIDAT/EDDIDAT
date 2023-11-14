function popup_menu_Callback(source,eventdata) 
        % Determine the selected data set.
        Plothandles = guidata(gcbo);
        str = get(source, 'String');
        val = get(source, 'Value');
        Plothandles.PopupValue = str{val};
        guidata(gcbo,Plothandles);
end