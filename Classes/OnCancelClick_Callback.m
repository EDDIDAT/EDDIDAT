function OnCancelClick_Callback(source,~,data1,data2,data3)
    Plothandles = guidata(gcbo);
    f = data1;
    tabledata = data3.Data;
    set(data3,'Data',tabledata);
    set(f, 'Visible', 'off');
    guidata(gcbo,Plothandles);
end

