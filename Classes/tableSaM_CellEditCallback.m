function tableSaM_CellEditCallback(source, eventdata, handles)
% This callback follows the user input in the table with the peak
% information. If the user changes the checkboxes, the callback will save
% the changes.
data=get(source,'Data'); % get the data cell array of the table
cols=get(source,'ColumnFormat'); % get the column formats
if strcmp(cols(eventdata.Indices(2)),'logical') % if the column of the edited cell is logical
    if eventdata.EditData % if the checkbox was set to true
        data{eventdata.Indices(1),eventdata.Indices(2)}=true; % set the data value to true
    else % if the checkbox was set to false
        data{eventdata.Indices(1),eventdata.Indices(2)}=false; % set the data value to false
    end
end
set(source,'Data',data); % now set the table's data to the updated data cell array
