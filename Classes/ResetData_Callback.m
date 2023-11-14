function ResetData_Callback(source,~,data1,data2,data3)
    Plothandles = guidata(gcbo);
    tabledata = data2.Data;
    set(data1,'Data',tabledata);
    set(data3,'String',num2str(length(tabledata)));
    guidata(gcbo,Plothandles);
end