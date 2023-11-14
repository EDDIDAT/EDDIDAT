function plotpdfbutton_Callback(source,~,data1,data2)
        % Load figure handles.
        Plothandles = guidata(gcbo);
        % Load twotheta angle.
        TwoTheta = Plothandles.TwoTheta;
        % Load Y data from measurement.
        Ytmp = Plothandles.Yrawdata;
%         disp(Ytmp)
        Y_max = max(Ytmp(:,1));
%         disp(Y_max)
        % Load table datafrom search and match.
        tableSaM = data2.Data;
        % Load checkbox values.
        checkboxSaM = {tableSaM{:,1}}';
        assignin('base','checkbox',checkboxSaM);
        % Load pdf card numbers.
        PDFCardNo = {tableSaM{:,2}}';
        % Check if a phase was selected to be plotted. If not, warning
        % message appears.
        checkempty = cell2mat(checkboxSaM);
        if all(checkempty(:)==0)
            disp('No PDFcard selected to plot. Please select one.')
        else
            % Read cardnumbers from table.
    %         l = 1;
            for k = 1:length(checkboxSaM)
    %             if checkboxSaM{k} == 1
                    cardnumber{k,1} = PDFCardNo{k};
    %                 l = l+1;
    %             end
            end
            assignin('base','cardnumber',cardnumber);
            % Load Database
            PDFDataBasesorted = evalin('base','PDFDataBasesorted');
            % Find index of cardnumbers in database.
            for k = 1:length(cardnumber)
                idx(:,k) = find(strcmp({PDFDataBasesorted.PDFCardNumber},cardnumber(k)));
            end
            % Get d-spacing values.
            dspacing = {PDFDataBasesorted(idx).dSpacing};
            % Get relative intensity values.
            relativeIntensity = {PDFDataBasesorted(idx).RelativeIntensity};
            % Calculate energies from d-spacings.
            energy = cell(1,1);
            for k = 1:length(dspacing)
                energy{1,k} = 6.199/sind(TwoTheta./2).*1./dspacing{k};
            end
            % Prepare x and y data for plots. 
            % Energy.
            for m = 1:length(energy)
                for k = 1:length(energy{1,m})
                    xEnergy{:,m}(k,1) = {[energy{1,m}(k) energy{1,m}(k) nan]};
                end
            end
            % Intensity.
            for m = 1:length(relativeIntensity)
                for k = 1:length(relativeIntensity{1,m})
                    yIntensity{:,m}(k,1) = {[0 relativeIntensity{1,m}(k).*Y_max./100 nan]};
                end
            end
            % Create plot object containing all selected plots. The entries
            % checked and uncheckedate made visible/invisible.
            for k = 1:length(xEnergy)
                x1 = cell2mat(xEnergy{1,k});
                y1 = cell2mat(yIntensity{1,k});
                x2 = reshape(x1',(size(x1,1)*size(x1,2)),1);
                y2 = reshape(y1',(size(y1,1)*size(y1,2)),1);
                plots(k) = plot(x2(:),y2(:));
                set(plots(k),'linewidth',1.5);
                set(plots(k),'Visible','off');
                if checkboxSaM{k} == 1
                    set(plots(k),'Visible','on');
                elseif checkboxSaM{k} == 0
                    set(plots(k),'Visible','off');
                end
            end
            ax = plots;
            assignin('base','plots',plots);
            name = cardnumber(logical(cell2mat(checkboxSaM)));
            index = find([checkboxSaM{:}] == 1);
            leg = legend(plots(index),name);
            % Save plothandels.
            Plothandles.PDFPlots = plots;
            Plothandles.PDFPlotsleg = leg;
        end
        guidata(gcbo,Plothandles)
end