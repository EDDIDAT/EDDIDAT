function FilterCrystalSystemsearchbut_Callback(source,~,data1,data2,data3)
    Plothandles = guidata(gcbo);
    % Load Table with results from SaM
    ElementsSaMtmp = data1.Data;
    ElementsSaM = {ElementsSaMtmp{:,6}}';
    % Load strings from edit field
    crystalsystem = data2.String;
    val = Plothandles.PopupValueFilter;
    % Run the name filter
    % List of strings that are searched for
    if strcmp('cubic',crystalsystem{val})
        % Cubic crystal systems. 
        tmp = (195:230)';
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);
    elseif strcmp('hexagonal',crystalsystem{val})
        % hexagonal crystal systems. 
        tmp = (168:194);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);
    elseif strcmp('trigonal',crystalsystem{val})
        % trigonal crystal systems. 
        tmp = (143:167);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);    
    elseif strcmp('tetragonal',crystalsystem{val})
        % tetragonal crystal systems. 
        tmp = (75:142);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);        
    elseif strcmp('orthorhombic',crystalsystem{val})
        % orthorhombic crystal systems. 
        tmp = (16:74);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);           
    elseif strcmp('monoclinic',crystalsystem{val})
        % monoclinic crystal systems. 
        tmp = (3:15);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);                
    elseif strcmp('triclinic',crystalsystem{val})
        % triclinic crystal systems. 
        tmp = (1:2);
        tmp1 = num2cell(tmp);
        strToFind = cellfun(@num2str,tmp1,'un',0);
        data = cellfun(@num2str,ElementsSaM,'un',0);
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(data,s));
            out = cellfun(fun,strToFind,'UniformOutput',false);
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);                
    end
        
    idx = find(idx==1);
    tabledata = ElementsSaMtmp(idx,:);
    set(data1,'Data',tabledata);
    set(data3,'String',num2str(length(idx)));
    guidata(gcbo,Plothandles);
end