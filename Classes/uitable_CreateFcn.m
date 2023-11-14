 function uitable_CreateFcn(source, ~, ~)
 % Check to see if the 'Peaks' variable exists in the base workspace.
 if evalin('base','exist(''Peaks'',''var'')')
    % Get the variable from the base workspace and save it to the table.
    data = evalin('base','Peaks');
    % Load peak data from workspace variable 'Peaks'.
    for k = 1:length(data)
        Peaks(:,k) = data(k).Position(1);
    end
    % Sort Peak positions in ascending order.
    Peaks = flip(Peaks);
    % Set tabledata.
    tabledata = get(source,'Data');
    % Write peak positions to tabledata. 
    for k = 1:length(Peaks)
    tabledata{k,1} = Peaks(k);
    tabledata{k,2} = true;
    end
    % Set tabledata.
    set(source,'Data',tabledata);
 else
    % If no variable 'Peaks' exist in the workspace show warning message.
    warningMessage = sprintf('Warning: No peaks selected for search and match. Select peaks using the Data Cursor function.');
    uiwait(msgbox(warningMessage,'Error', 'error')); 
 end