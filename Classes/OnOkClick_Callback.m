function OnOkClick_Callback(source,~,data1,data2,data3)
    Plothandles = guidata(gcbo);
    f = data1;
    tabledata = data2.Data;
    set(data3,'Data',tabledata);
    set(f, 'Visible', 'off');
    guidata(gcbo,Plothandles);
end

