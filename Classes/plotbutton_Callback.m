function plotbutton_Callback(source,~,data)
        % Load handles from figure.
        Plothandles = guidata(gcbo);
        % Read selected element for which the fluorescence lines should be
        % plotted.
        Element = Plothandles.PopupValue;
        % Load fluorescence data.
        FluorElements = data.FluorCellArray;
        % Find index of the selected element.
        IndexFE = strfind(FluorElements{1,2}, Element);
        Index = find(not(cellfun('isempty', IndexFE)));
        % Selected fluorescence lines to plot (fixed, maybe make choosable
        % in future release).
        % Column names are:
        % No.;Element;Ka1;Ka2;Kb1;La1;La2;Lb1;Lb2;Lg1
        Ka1 = FluorElements{1,3}(Index);
        Ka2 = FluorElements{1,4}(Index);
        Kb1 = FluorElements{1,5}(Index);
        % Not yet included
        La1 = FluorElements{1,6}(Index);
        La2 = FluorElements{1,7}(Index);
        Lb1 = FluorElements{1,8}(Index);
        Lb2 = FluorElements{1,9}(Index);
        Lg1 = FluorElements{1,10}(Index);
        % Prepare data for line plot.
        EMax = data.EMax;
        % Save fluorescence lines into temporary vector.
        k_tmp = [Ka1 Ka2 Kb1 La1 La2 Lb1 Lb2 Lg1];
        % Check if E(k_tmp) < EMax and save into array.
        for k = 1:8
            if k_tmp(k) < EMax
                k_tmp1(k,:) = [k_tmp(k) k_tmp(k) nan];
            end
        end
        
        % Reshape array in order to plot as line plot.
        k_tmp2 = reshape(k_tmp1',size(k_tmp1,1)*size(k_tmp1,2),1);
        k_tmp2(size(k_tmp1,1)*size(k_tmp1,2),:) = [];
        % Create array with y values for the fluorescence line plot.
        y_tmp = repmat([0 min(data.Y1(:,2))+50 nan],1,size(k_tmp1,1))';
        y_tmp(size(k_tmp1,1)*size(k_tmp1,2),:) = [];

        % Line plot of the fluorescence lines.
        h = line(k_tmp2,y_tmp);
        % Set line properties.
        h.Color = 'cyan';
        h.LineWidth = 1.2;
        % Save line plot to handle. Needed when the plot should be deleted
        % from the figure.
        Plothandles.h = h;
        guidata(gcbo,Plothandles)
end