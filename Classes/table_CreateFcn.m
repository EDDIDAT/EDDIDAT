 function table_CreateFcn(source, ~, ~)
    Plothandles = guidata(gcbo);
    Results = Plothandles.ResultSaM;
    assignin('base','Results',Results)
    IndexHitCount = Plothandles.IndexHitCount;
    tabledata = get(source,'Data');
    tabledata = {[num2cell(false(1,1)), num2cell(zeros(1,1)), num2cell(zeros(1,1)), num2cell(zeros(1,1)), num2cell(zeros(1,1)), num2cell(zeros(1,1))]};
    
    for k = 1:length(IndexHitCount)
        tabledata{k,1} = false;
        tabledata{k,2} = Results{k,1};
        tabledata{k,3} = cell2mat(Results{k,2});
        tabledata{k,4} = cell2mat(Results{k,3});
        tabledata{k,5} = cell2mat(Results{k,4});
        tabledata{k,6} = Results{k,5};
%         tabledata{k,7} = cell2mat(Results{k,6});
    end
       
    set(source,'Data',tabledata);
 end