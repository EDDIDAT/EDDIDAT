    function keditbutton_Callback(source,~)
        % Get user input
        str = get(source, 'String');
        val = get(source,'Value');
        % Check if MPD file exists
        if exist(fullfile('Data','Materials',[str '.mpd']),'file')
            % Load material parameter into file.
            Message = sprintf('\n%s.mpd file succesfully loaded.', str);
            uiwait(msgbox(Message,'Success'));
        else
            % If the MPD file does not exist, show warning message.
            warningMessage = sprintf('Warning: \n%s.mpd file does not exist! Check spelling or create a new file.', str);
            uiwait(msgbox(warningMessage,'Error', 'error')); 
        end
        Plothandles = guidata(gcbo);
        Plothandles.MPDFile = str;
        guidata(gcbo,Plothandles);
end