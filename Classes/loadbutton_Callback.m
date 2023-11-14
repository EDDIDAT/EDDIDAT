function loadbutton_Callback(source,~,data)
    % Define the table data.
    tabletmp = data;
    % Call function to load peak positions.
    uitable_CreateFcn(tabletmp)
end