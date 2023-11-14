function tabChanged_Callback(source,eventdata)
    Plothandles = guidata(gcbo);
    table = Plothandles.tableSaM;
    str = Plothandles.matchedit.String;
    % Get the Title of the previous tab
    tabName = eventdata.OldValue.Title;
    % If 'Loan Data' was the previous tab, update the table and plot
    if strcmp(tabName, 'Search and Match')
        if strcmp(str, 'no')
            disp('No matches found.')
        else
            table_CreateFcn(table);
        end
    end
end
