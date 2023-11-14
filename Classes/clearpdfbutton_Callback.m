function clearpdfbutton_Callback(source,~,data1,data2)
        % Load handles from figure.
        Plothandles = guidata(gcbo);
        % Load plots.
        plots = Plothandles.PDFPlots;
        leg = Plothandles.PDFPlotsleg;
        % Load table data.
        tableSaM = data2.Data;
        % Load checkbox values.
        checkboxSaM = {tableSaM{:,1}}';
        assignin('base','checkbox',checkboxSaM);
        % Set selected plots visible/invisible.
        for k = 1:length(checkboxSaM)
            if checkboxSaM{k} == 0
               set(plots(k),'Visible','off');
            elseif checkboxSaM{k} == 1
               set(plots(k),'Visible','on'); 
            end
        end
        % Load pdf cardnumbers.
        PDFCardNo = {tableSaM{:,2}}';
        for k = 1:length(checkboxSaM)
            cardnumber{k,1} = PDFCardNo{k};
        end
        % Check which plot is to be cleared.
        checkplot = [checkboxSaM{:}]';
        % Clear plot from legend or delete legend if no plot is plotted.
        if all(checkplot==0)
            set(leg,'visible','off')
        else
            name = cardnumber(logical(cell2mat(checkboxSaM)));
%             leg = 0;
            index = find([checkboxSaM{:}] == 1);
            leg = legend(plots(index),name);
        end
        % Save plots to plothandles.
        Plothandles.PDFPlots = plots;
        Plothandles.PDFPlotsleg = leg;
        guidata(gcbo,Plothandles)
end