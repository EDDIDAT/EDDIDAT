function FilterElementsearchbut_Callback(source,~,data1,data2,data3,data4,data5)
    Plothandles = guidata(gcbo);
    % Load Table with results from SaM.
    ElementsSaMtmp = data1.Data;
    ElementsSaM = {ElementsSaMtmp{:,3}}';
    % Load strings from edit field.
    strToFindtmp = data2.String;
    % List of strings that are searched for (comma separated).
    strToFind = strsplit(strToFindtmp,',');
    % Load value from checkbox for compound search.
    checkbox = data3.Value;
    checkbox1 = data4.Value;
    % Run the element filter.
    if checkbox == 1 && checkbox1 == 0
        % Search for single element.
        fun = @(s)~cellfun('isempty',strfind(ElementsSaM,s));
        out = cellfun(fun,strToFind,'UniformOutput',false);
        idx = all(horzcat(out{:}),2);
    elseif checkbox == 0 && checkbox1 == 1
        % Search for compound.
        idxtmp = cellfun(@(S) strcmp(strToFind,S),{ElementsSaM},'UniformOutput',false);
        idx1 = logical(cell2mat(idxtmp));
        idx = idx1;
    else
        % Search for multiple elements
        for k = 1:length(strToFind)
            fun = @(s)~cellfun('isempty',strfind(ElementsSaM,s));
            out = cellfun(fun,strToFind(k),'UniformOutput',false);
            idx(:,k) = all(horzcat(out{:}),2);
        end
        % Combine logical indices to one vector.
        idxnum = double(idx);
        idxsum = sum(idxnum,2);
        idx = logical(idxsum);
%         if length(strToFind) == 2
%             idx = bsxfun(@plus,idx(:,1),idx(:,2));
%             idx(find(idx>1)) = 1;
%             idx = logical(idx);
%         elseif length(strToFind) == 3
%             idx1 = bsxfun(@plus,idx(:,1),idx(:,2));
%             idx1(find(idx1>1)) = 1;
%             idx2 = bsxfun(@plus,idx1(:,1),idx(:,3));
%             idx2(find(idx2>1)) = 1;
%             idx2 = logical(idx2);
%             idx = idx2;
%         elseif length(strToFind) == 4
%             idx1 = bsxfun(@plus,idx(:,1),idx(:,2));
%             idx1(find(idx1>1)) = 1;
%             idx2 = bsxfun(@plus,idx1(:,1),idx(:,3));
%             idx2(find(idx2>1)) = 1;
%             idx3 = bsxfun(@plus,idx2(:,1),idx(:,4));
%             idx3(find(idx3>1)) = 1;
%             idx3 = logical(idx3);
%             idx = idx3;
%         end
    end
    
    idx = find(idx==1);
    tabledata = ElementsSaMtmp(idx,:);
    set(data1,'Data',tabledata);
    set(data5,'String',num2str(length(idx)));
    guidata(gcbo,Plothandles);
end

