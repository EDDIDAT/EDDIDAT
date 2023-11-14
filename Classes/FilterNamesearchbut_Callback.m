function FilterNamesearchbut_Callback(source,~,data1,data2,data3)
    Plothandles = guidata(gcbo);
    % Load Table with results from SaM
    ElementsSaMtmp = data1.Data;
    assignin('base','ElementsSaMtmp',ElementsSaMtmp)
    ElementsSaM = {ElementsSaMtmp{:,4}}';
    assignin('base','ElementsSaM',ElementsSaM)
    % Load strings from edit field
    strToFindtmp = data2.String;
    strToFind = strsplit(strToFindtmp,',');
    % Run the name filter
    % List of strings that are searched for
    fun = @(s)~cellfun('isempty',strfind(ElementsSaM,s));
    out = cellfun(fun,strToFind,'UniformOutput',false);
    idx = all(horzcat(out{:}),2);
    
    idx = find(idx==1);
    tabledata = ElementsSaMtmp(idx,:);
    set(data1,'Data',tabledata);
    set(data3,'String',num2str(length(idx)));
    guidata(gcbo,Plothandles);
end

