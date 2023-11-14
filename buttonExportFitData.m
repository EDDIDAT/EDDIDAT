function [h] = buttonExportFitData(h, PlotWindow, XDataStr, YDataStr)

dataforplotting = join(['dataforplotting',PlotWindow]);
maxValLatticeSpacing = join(['maxValLatticeSpacing',PlotWindow]);
minValLatticeSpacing = join(['minValLatticeSpacing',PlotWindow]);
maxValEnergy_Max = join(['maxValEnergy_Max',PlotWindow]);
minValEnergy_Max = join(['minValEnergy_Max',PlotWindow]);
maxValIntegralWidth = join(['maxValIntegralWidth',PlotWindow]);
minValIntegralWidth = join(['minValIntegralWidth',PlotWindow]);
maxValFWHM = join(['maxValFWHM',PlotWindow]);
minValFWHM = join(['minValFWHM',PlotWindow]);
% maxValIntegralInt = join(['maxValIntegralInt',PlotWindow]);
% minValIntegralInt = join(['minValIntegralInt',PlotWindow]);
LegendPlot = join(['legendplotfitdata',PlotWindow]);
LegLabelData = join(['LegLabelDataplotfitdata',PlotWindow]);
eta = join(['eta',PlotWindow]);
phi = join(['phi',PlotWindow]);

% Convert plot data from struct to cell array
DataExport = struct2cell(h.(dataforplotting));
assignin('base','DataExport',DataExport)
if ~isfield(h,'PathName')
    formatOut = 'ddmmyyyy';
    d = datestr(now, formatOut);
    name = strtrim(h.Measurement(1).MeasurementSeries);
    h.PathName = [General.ProgramInfo.Path,'\Data\Results\', h.Diffsel,'\',[name,'_','added_plots','_',d]];
end

Folder = '\Plots\';
Path = fullfile(h.PathName,Folder);

if exist(Path,'dir') ~= 7
    mkdir(Path);
end

if ~isfield(h,['eta', PlotWindow]) && ~isfield(h,['phi', PlotWindow])
    %% Create Plots
    Marker = {'s','o','d','p'};
    % Create plot for each reflection hkl
    for k = 1:size(DataExport{1}.X,2)
        figure
        fig = gcf;
        fig.PaperUnits = 'centimeters';
        fig.PaperPositionMode = 'manual';
        fig.PaperPosition = [0 0 18 12];
        ax = gca;
        ax.OuterPosition = [0 0 1.0725 1.025];
        ax.TickDir = 'out';
        ax.YAxis.TickLabelFormat = '%,.3f';
        ax.Box = 'on';
        ax.XGrid = 'on';
        ax.YGrid = 'on';
        ax.GridLineStyle = '-';
        ax.GridColor = 'k';
        ax.GridAlpha = 0.3;
        ax.YLabel.FontSize = 24;
        ax.XLabel.FontSize = 24;
        ax.LabelFontSizeMultiplier = 1.3;
        ax.LineWidth = 1.3;
        set(gca,'FontSize',18)
        hold on
        set(fig, 'Visible', 'off');

        % Plot data from each reflection hkl
        for l = 1:size(DataExport,1)
            % Differentiate in case of plot of d-spacings
            if strcmp(YDataStr,'d-spacing')
                errorbar(ax,DataExport{l}.X{k},DataExport{l}.Y{k}.*10,DataExport{l}.Yerror{k}.*10,'Linestyle','--','Color','k','Marker',Marker{l},'MarkerFaceColor',h.Colors{k},'MarkerEdgeColor','k','MarkerSize',12,'Clipping','off');
            else
                plot(ax,DataExport{l}.X{k},DataExport{l}.Y{k},'Linestyle','--','Color','k','Marker',Marker{l},'MarkerFaceColor',h.Colors{k},'MarkerEdgeColor','k','MarkerSize',12,'Clipping','off');
            end
        end

        % Set x-axes properties
        if strcmp(XDataStr,'Psi')
            xlabel(ax,'\psi [°]')
            Psimin = unique(cellfun(@min,DataExport{1}.X));
            Psimax = unique(cellfun(@max,DataExport{1}.X));
            if Psimin >= 0 && max(Psimax) <= 90
                ax.XLim = [0 90];
                ax.XTick = (0:10:90);
            else
                ax.XLim = [round(Psimin,-1) round(Psimax,-1)];
                if (abs(Psimin)+Psimax)/10 < 20
                    ax.XTick = (round(Psimin,-1):10:round(Psimax,-1));
                elseif (abs(Psimin)+Psimax)/10 > 20
                    ax.XTick = (round(Psimin,-1):20:round(Psimax,-1));
                end
                
            end
        elseif strcmp(XDataStr,'sin²Psi')
            xlabel(ax,'sin²\psi')
            ax.XLim = [0 1];
            ax.XTick = (0:0.1:1);
        elseif strcmp(XDataStr,'Eta')
            xlabel(ax,'\eta [°]')
            ax.XLim = [0 90];
            ax.XTick = (0:10:90);      
        elseif strcmp(XDataStr,'sin²Eta')
            xlabel(ax,'sin²\eta')
            ax.XLim = [0 1];
            ax.XTick = (0:0.1:1);
        elseif strcmp(XDataStr,'tau')
            xlabel(ax,'\tau [µm]')
            XLimtau = ceil(round(h.TauMaxAxesLimits{1}(k),1)/5)*5;
            ax.XLim = [0 XLimtau];
            if XLimtau <= 5
                ax.XTick = (0:0.5:XLimtau);
            elseif XLimtau > 5 && XLimtau <= 10
                ax.XTick = (0:1:XLimtau);
            elseif XLimtau > 10 && XLimtau <= 25
                ax.XTick = (0:2.5:XLimtau);
            elseif XLimtau > 25 && XLimtau <= 50
                ax.XTick = (0:5:XLimtau);    
            elseif XLimtau > 50 && XLimtau <= 100
                ax.XTick = (0:10:XLimtau);    
            end    
        elseif strcmp(XDataStr,'Energy')
            xlabel(ax,'Energy [keV]')
            ax.XLimMode = 'auto';
            xtickformat(ax,'auto')
            xticks(ax,'auto')
        elseif strcmp(XDataStr,'Temperature')
            xlabel(ax,'Temperature [°C]')
            Tempmax = cellfun(@max, h.TemperatureForPlot);
            ax.XLim = [0 round(max(Tempmax))];
            ax.XTick = (0:100:round(max(Tempmax)));
        elseif strcmp(XDataStr,'Scan number')
            xlabel(ax,'Scan number')
            ax.XLimMode = 'auto';
            xtickformat(ax,'auto')
            xticks(ax,'auto')
        end

        % Set y-axes properties
        if strcmp(YDataStr,'d-spacing')
            ylabel(ax,['d [',char(197),']'])        
%             ax.YLim = [floor(((h.(minValLatticeSpacing){k}.*10)-0.001)./0.002).*0.002 ceil(((h.(maxValLatticeSpacing){k}.*10)+0.001)/0.002).*0.002];
%             ax.YLim = [2.865 2.89];
%             ax.YTick = (2.865:0.005:2.89);
%             yticks(ax,'auto')
            % Find dmin and dmax values + d_errors
            for m = 1:size(DataExport,1)
                dmaxtmp(:,m) = cellfun(@max,cellfun(@plus,DataExport{m}.Y,DataExport{m}.Yerror,'UniformOutput',false));
                dmintmp(:,m) = cellfun(@min,cellfun(@minus,DataExport{m}.Y,DataExport{m}.Yerror,'UniformOutput',false));
            end
            
            if h.checkboxnorm.Value == 1
                dmax = max(reshape(dmaxtmp,size(dmaxtmp,1)*size(dmaxtmp,2),1));
                dmin = min(reshape(dmintmp,size(dmintmp,1)*size(dmintmp,2),1));
            else
                dmax = max(dmaxtmp(k,:));
                dmin = min(dmintmp(k,:));
            end
            dmaxYlim = ceil(dmax*10000)/1000;
%             dmaxYlim
            % Check if dmax is even, if odd add 1
            if mod(dmaxYlim*1000,2) == 1
               dmaxYlim = (dmaxYlim*1000 + 1)/1000;
            end
            
            dminYlim = floor(dmin*10000)/1000;
            % Check if dmin is even, if odd add 1
            if mod(dminYlim*1000,2) == 1
               dminYlim = (dminYlim*1000 - 1)/1000;
            end
%             dminYlim
%             dmaxYlim
            ax.YLim = [dminYlim dmaxYlim];
            % Define ticks, set ticks to 5
            ax.YTick = (dminYlim:(dmaxYlim - dminYlim)/5:dmaxYlim);
            
%             ax.YLim = [4.06 4.09];
%             ax.YTick = (4.06:0.005:4.09);
            
            ax.YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Energy')
            ylabel(ax,'Energy [keV]')
            ax.YLim = [floor(h.(minValEnergy_Max){k}./0.05).*0.05 ceil(h.(maxValEnergy_Max){k}/0.05).*0.05];
            if abs(ax.YLim(1) - h.(minValEnergy_Max){k}) < 0.005
                ax.YLim(1) = ax.YLim(1) - 0.05;
                Ymin = ax.YLim(1);
            else
                Ymin = ax.YLim(1);
            end
            
            if abs(ax.YLim(2) - h.(maxValEnergy_Max){k}) < 0.005
                ax.YLim(2) = ax.YLim(2) + 0.05;
                Ymax = ax.YLim(2);
            else
                Ymax = ax.YLim(2);
            end
            
%             Ymin = ax.YLim(1);
%             Ymax = ax.YLim(2);

            if (Ymax - Ymin) < 0.09
                ax.YTick = (Ymin:0.01:Ymax);
                ax.YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) >= 0.09 && (Ymax - Ymin) <= 0.11
                ax.YTick = (Ymin:0.02:Ymax);
                ax.YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.1 && (Ymax - Ymin) <= 0.19
                ax.YTick = (Ymin:0.025:Ymax);
                ax.YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.19 && (Ymax - Ymin) <= 0.41
                ax.YTick = (Ymin:0.05:Ymax);
                ax.YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.41
                ax.YTick = (Ymin:0.1:Ymax);
                ax.YAxis.TickLabelFormat = ' %.2f ';
            end

        elseif strcmp(YDataStr,'Integral Breadth')
            ylabel(ax,'IB [keV]')
            ax.YLim = [floor(h.(minValIntegralWidth){k}./0.05).*0.05 ceil(h.(maxValIntegralWidth){k}/0.05).*0.05];
            yticks(ax,'auto')
            ax.YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'FWHM')
            ylabel(ax,'FWHM [keV]')
            ax.YLim = [floor(h.(minValFWHM){k}./0.05).*0.05 ceil(h.(maxValFWHM){k}/0.05).*0.05];
            yticks(ax,'auto')
            ax.YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Weighting Factor')
            ylabel(ax,'Weighting Factor \eta')
            ax.YLim = [0 1];
            yticks(ax,'auto')
            ax.YAxis.TickLabelFormat = ' %.1f ';
        elseif strcmp(YDataStr,'Form Factor')
            ylabel(ax,'Form factor FWHM/IB')
            ax.YLim = [0.6 1];
            yticks(ax,'auto')
            ax.YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            ylabel(ax,'Int. Intensity [cts]')
            yticks(ax,'auto')
            ax.YLimMode = 'auto';
            ytickformat(ax,'auto')

            ax.OuterPosition = [0 0 1.085 1.01];

            for l = 1:size(DataExport,1)
                IntMaxtmp1{l} = cellfun(@max, DataExport{l}.Y);
            end

            IntMaxtmp = cell2mat(IntMaxtmp1);

            IntMaxtmp = reshape(IntMaxtmp,size(DataExport{1}.Y,2),size(DataExport,1));
            IntMax = max(IntMaxtmp,[],2);

            ExpInt = numel(num2str(round(IntMax(k))));

            if numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 7
                ax.YAxis.Exponent = 4;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 6
                ax.YAxis.Exponent = 3;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 5
                ax.YAxis.Exponent = 2;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 4
                ax.YAxis.Exponent = 1;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 3
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '    %3.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 2
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '     %2.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 1
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '      %1.f';
            end

            ax.YLim = [0 ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1))];

        elseif strcmp(YDataStr,'Max. Intensity')
            ylabel(ax,'Max. Intensity [cts]')
            ax.YLimMode = 'auto';
            ytickformat(ax,'auto')
            ax.OuterPosition = [0 0 1.085 1.01];

            for l = 1:size(DataExport,1)
                IntMaxtmp1{l} = cellfun(@max, DataExport{l}.Y);
            end

            IntMaxtmp = cell2mat(IntMaxtmp1);

            IntMaxtmp = reshape(IntMaxtmp,size(DataExport{1}.Y,2),size(DataExport,1));
            IntMax = max(IntMaxtmp,[],2);

            ExpInt = numel(num2str(round(IntMax(k))));

            if numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 7
                ax.YAxis.Exponent = 4;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 6
                ax.YAxis.Exponent = 3;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 5
                ax.YAxis.Exponent = 2;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 4
                ax.YAxis.Exponent = 1;
                ax.YAxis.TickLabelFormat = '   %4.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 3
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '    %3.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 2
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '     %2.f';
            elseif numel(num2str(ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 1
                ax.YAxis.Exponent = 0;
                ax.YAxis.TickLabelFormat = '      %1.f';
            end

            ax.YLim = [0 ceil(IntMax(k)/(10^(ExpInt-1))).*(10^(ExpInt-1))];

        end

        % Set legend
        l = legend(h.(LegLabelData));
        l.FontSize = 10;
        l.LineWidth = 0.5;    

        if h.(LegendPlot).Position(1) < 0.4 && h.(LegendPlot).Position(2) > 0.4
            l.Location = 'NorthWest';
        elseif h.(LegendPlot).Position(1) > 0.4 && h.(LegendPlot).Position(2) > 0.4
            l.Location = 'NorthEast';
        elseif h.(LegendPlot).Position(1) < 0.4 && h.(LegendPlot).Position(2) < 0.4
            l.Location = 'SouthWest';
        elseif h.(LegendPlot).Position(1) > 0.4 && h.(LegendPlot).Position(2) < 0.4
            l.Location = 'SouthEast';
        end

        title(l,[h.labelforplot(k,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
        set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
        % Save plots to file
        if h.checkboxnorm.Value == 1 && strcmp(YDataStr,'d-spacing')
            FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_norm_vs_',XDataStr,'_Line_','%d'],k);
            print(fig,[Path,FileName],'-painters','-dtiff','-r300')
        else
            FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr,'_Line_','%d'],k);
            print(fig,[Path,FileName],'-painters','-dtiff','-r300')
        end
    end
    
    %% Create data files from plotted data
    if h.checkboxnorm.Value == 1 && strcmp(YDataStr,'d-spacing')
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_norm_vs_',XDataStr],k);
    else
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr],k);
    end

    formatOut = 'ddmmyyyy';
    d = datestr(now, formatOut);
    % name = strtrim(h.Measurement(1).MeasurementSeries);
    Folder = '\Plots\Data_Files\';
    Path = fullfile(h.PathName,Folder);

    if exist(Path,'dir') ~= 7
        mkdir(Path);
    end
%     assignin('base','DataExport',DataExport)
    % Sort data according to hkl
    for k = 1:size(DataExport,1)
        for l = 1:size(DataExport{k}.X,2)
            if strcmp(YDataStr,'d-spacing')
                Datahkl{l}{k} = [DataExport{k}.X{l} DataExport{k}.Y{l} DataExport{k}.Yerror{l}];
            else
                Datahkl{l}{k} = [DataExport{k}.X{l} DataExport{k}.Y{l}];
            end
        end
    end
%     assignin('base','Datahkl',Datahkl)
    if size(DataExport,1) ~= 1
        % Find unequal cell arrays and pad cells with NaN values
        for k = 1:size(Datahkl,2)
            dims = max(cell2mat(cellfun(@(x)size(x), Datahkl{k}, 'uni', 0)'));
            Datahkltmp{k} = cellfun(@(x)[x,nan(size(x,1),dims(2)-size(x,2));nan(dims(1)-size(x,1),dims(2))], Datahkl{k},'uni', 0);
        end
    else
        Datahkltmp = Datahkl;
    end
%     assignin('base','Datahkltmp',Datahkltmp)
    % Ydata Column name
    if h.checkboxnorm.Value == 1 && strcmp(YDataStr,'d-spacing')
        YColName = [strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_norm_'];
    else
        YColName = strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_');
    end

    % Save data for different phi angles of one hkl value into one file
    if size(Datahkltmp{1},2) == 1
        for k = 1:size(Datahkltmp,2)

        fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

        fprintf(fid, [[XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(1)),'°)    '],[YColName,'_error','   '],'\n']);
            
            % In case measurements where performed under four different phi angles
            for m = 1:size(Datahkltmp{k}{1},1)
                if strcmp(YDataStr,'d-spacing')
                    str = sprintf('%.4f  %.6f  %.6f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2).*10,...
                    Datahkltmp{k}{1}(m,3).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Energy')
                    str = sprintf('%.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Integral Breadth')|| strcmp(YDataStr,'FWHM')
                    str = sprintf('%.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Weighting Factor')|| strcmp(YDataStr,'Form Factor')
                    str = sprintf('%.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);    
                elseif strcmp(YDataStr,'Int. Intensity')|| strcmp(YDataStr,'Max. Intensity')
                    str = sprintf('%.4f    %d\n',...
                    Datahkltmp{k}{1}(m,1),...
                    round(Datahkltmp{k}{1}(m,2)));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                end
            end

        fclose(fid);

        end
    elseif size(Datahkltmp{1},2) == 2
        for k = 1:size(Datahkltmp,2)

        fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

        fprintf(fid, [[XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(1)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(2)),'°)    '],'\n']);

            % In case measurements where performed under four different phi angles
            for m = 1:size(Datahkltmp{k}{1},1)
                if strcmp(YDataStr,'d-spacing')
                    str = sprintf('%.4f    %.6f    %.6f    %.4f    %.6f    %.6f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2).*10,...
                    Datahkltmp{k}{1}(m,3).*10,...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2).*10,...
                    Datahkltmp{k}{2}(m,3).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Energy')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Integral Breadth')|| strcmp(YDataStr,'FWHM')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Weighting Factor')|| strcmp(YDataStr,'Form Factor')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);    
                elseif strcmp(YDataStr,'Int. Intensity')|| strcmp(YDataStr,'Max. Intensity')
                    str = sprintf('%.4f    %d    %.4f    %d\n',...
                    Datahkltmp{k}{1}(m,1),...
                    round(Datahkltmp{k}{1}(m,2)),...
                    Datahkltmp{k}{2}(m,1),...
                    round(Datahkltmp{k}{2}(m,2)));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                end
            end

        fclose(fid);

        end
    elseif size(Datahkltmp{1},2) == 3
        for k = 1:size(Datahkltmp,2)

        fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

        fprintf(fid, [[XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(1)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(2)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(3)),'°)    '],'\n']);

            % In case measurements where performed under four different phi angles
            for m = 1:size(Datahkltmp{k}{1},1)
                if strcmp(YDataStr,'d-spacing')
                    str = sprintf('%.4f    %.6f    %.6f    %.4f    %.6f    %.6f    %.4f    %.6f    %.6f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2).*10,...
                    Datahkltmp{k}{1}(m,3).*10,...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2).*10,...
                    Datahkltmp{k}{2}(m,3).*10,...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2).*10,...
                    Datahkltmp{k}{3}(m,3).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Energy')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Integral Breadth')|| strcmp(YDataStr,'FWHM')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Weighting Factor')|| strcmp(YDataStr,'Form Factor')
                    str = sprintf('%.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);    
                elseif strcmp(YDataStr,'Int. Intensity')|| strcmp(YDataStr,'Max. Intensity')
                    str = sprintf('%.4f    %d     %.4f    %d    %.4f    %d\n',...
                    Datahkltmp{k}{1}(m,1),...
                    round(Datahkltmp{k}{1}(m,2)),...
                    Datahkltmp{k}{2}(m,1),...
                    round(Datahkltmp{k}{2}(m,2)),...
                    Datahkltmp{k}{3}(m,1),...
                    round(Datahkltmp{k}{3}(m,2)));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                end
            end

        fclose(fid);

        end
    elseif size(Datahkltmp{1},2) == 4
        for k = 1:size(Datahkltmp,2)

        fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

        fprintf(fid, [[XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(1)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(2)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(3)),'°)    '],...
            [XDataStr,'   '],[YColName,'(phi=',num2str(h.PhiWinkelForPlot{1}(4)),'°)    '],'\n']);

            % In case measurements where performed under four different phi angles
            for m = 1:size(Datahkltmp{k}{1},1)
                if strcmp(YDataStr,'d-spacing')
                    str = sprintf('%.4f    %.6f    %.6f     %.4f    %.6f    %.6f    %.4f    %.6f    %.6f    %.4f    %.6f    %.6f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2).*10,...
                    Datahkltmp{k}{1}(m,3).*10,...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2).*10,...
                    Datahkltmp{k}{2}(m,3).*10,...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2).*10,...
                    Datahkltmp{k}{3}(m,3).*10,...
                    Datahkltmp{k}{4}(m,1),...
                    Datahkltmp{k}{4}(m,2).*10,...
                    Datahkltmp{k}{4}(m,3).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Energy')
                    str = sprintf('%.4f    %.4f     %.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2),...
                    Datahkltmp{k}{4}(m,1),...
                    Datahkltmp{k}{4}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Integral Breadth')|| strcmp(YDataStr,'FWHM')
                    str = sprintf('%.4f    %.4f     %.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2),...
                    Datahkltmp{k}{4}(m,1),...
                    Datahkltmp{k}{4}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                elseif strcmp(YDataStr,'Weighting Factor')|| strcmp(YDataStr,'Form Factor')
                    str = sprintf('%.4f    %.4f     %.4f    %.4f    %.4f    %.4f    %.4f    %.4f\n',...
                    Datahkltmp{k}{1}(m,1),...
                    Datahkltmp{k}{1}(m,2),...
                    Datahkltmp{k}{2}(m,1),...
                    Datahkltmp{k}{2}(m,2),...
                    Datahkltmp{k}{3}(m,1),...
                    Datahkltmp{k}{3}(m,2),...
                    Datahkltmp{k}{4}(m,1),...
                    Datahkltmp{k}{4}(m,2));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);    
                elseif strcmp(YDataStr,'Int. Intensity')|| strcmp(YDataStr,'Max. Intensity')
                    str = sprintf('%.4f    %d     %.4f    %d    %.4f    %d    %.4f    %d\n',...
                    Datahkltmp{k}{1}(m,1),...
                    round(Datahkltmp{k}{1}(m,2)),...
                    Datahkltmp{k}{2}(m,1),...
                    round(Datahkltmp{k}{2}(m,2)),...
                    Datahkltmp{k}{3}(m,1),...
                    round(Datahkltmp{k}{3}(m,2)),...
                    Datahkltmp{k}{4}(m,1),...
                    round(Datahkltmp{k}{4}(m,2)));
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
                end
            end

        fclose(fid);

        end
    end
    
else
    if isfield(h,['eta', PlotWindow])
        %% Create Plots
        % Create plot for each reflection hkl in case of scattering vector
        % measurements
        for k = 1:size(h.(eta).psiIndex,2)
            figure
            fig = gcf;
            fig.PaperUnits = 'centimeters';
            fig.PaperPositionMode = 'manual';
            fig.PaperPosition = [0 0 18 12];
            ax = gca;
            ax.OuterPosition = [0 0 1.085 1.025];
            ax.TickDir = 'out';
            ax.YAxis.TickLabelFormat = '%,.3f';
            ax.Box = 'on';
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.GridLineStyle = '-';
            ax.GridColor = 'k';
            ax.GridAlpha = 0.3;
            ax.YLabel.FontSize = 24;
            ax.XLabel.FontSize = 24;
            ax.LabelFontSizeMultiplier = 1.3;
            ax.LineWidth = 1.3;
            set(gca,'FontSize',18)
            hold on
            set(fig, 'Visible', 'off');

            % Plot data from each reflection hkl
            for i = 1:length(h.(eta).psiIndex{k})
                if strcmp(XDataStr,'Eta') && strcmp(YDataStr,'d-spacing')
                    etaplot{i} = errorbar(ax,h.(eta).TableEta{k,i},h.(eta).Tabledspacing{k,i}.*10,h.(eta).Tabledspacingdelta{k,i}.*10,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'d-spacing')
                    etaplot{i} = errorbar(ax,sind(h.(eta).TableEta{k,i}).^2,h.(eta).Tabledspacing{k,i}.*10,h.(eta).Tabledspacingdelta{k,i}.*10,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Integral Breadth')
                    etaplot{i} = errorbar(ax,h.(eta).TableEta{k,i},h.(eta).TableIB{k,i},h.(eta).TableIB{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Integral Breadth')
                    etaplot{i} = errorbar(ax,sind(h.(eta).TableEta{k,i}).^2,h.(eta).TableIB{k,i},h.(eta).TableIB{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Int. Intensity')
                    etaplot{i} = errorbar(ax,h.(eta).TableEta{k,i},h.(eta).TableIntensity_Int{k,i},h.(eta).TableIntensity_Int{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Int. Intensity')
                    etaplot{i} = errorbar(ax,sind(h.(eta).TableEta{k,i}).^2,h.(eta).TableIntensity_Int{k,i},h.(eta).TableIntensity_Int{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i},'Clipping','off');
                end
            end

            % Set x-axes properties
            if strcmp(XDataStr,'Eta')
                xlabel(ax,'\eta [°]')
            elseif strcmp(XDataStr,'sin²Eta')
                xlabel(ax,'sin²\eta')
            end

            ax.XLimMode = 'auto';
            xtickformat(ax,'auto')
            xticks(ax,'auto')

            % Set y-axes properties
            if strcmp(YDataStr,'d-spacing')
                ylabel(ax,'d [nm]')        
                ax.YLim = [(floor(((h.(minValLatticeSpacing){k}.*10)-0.001)./0.002).*0.002) (ceil(((h.(maxValLatticeSpacing){k}.*10)+0.001)/0.002).*0.002)];
                yticks(ax,'auto')
                ax.YAxis.TickLabelFormat = ' %.4f ';
            elseif strcmp(YDataStr,'Integral Breadth')
                ylabel(ax,'IB [keV]')
                ax.YLim = [floor(h.(minValIntegralWidth){k}./0.05).*0.05 ceil(h.(maxValIntegralWidth){k}/0.05).*0.05];
                yticks(ax,'auto')
                ax.YAxis.TickLabelFormat = ' %.2f ';
            elseif strcmp(YDataStr,'Int. Intensity')
                ylabel(ax,'Int. Intensity [cts]')
                yticks(ax,'auto')
                ax.YLimMode = 'auto';
                ytickformat(ax,'auto')

                ax.OuterPosition = [0 0 1.085 1.01];
                % Find maximum intensity for each hkl
                IntMaxtmp1 = cellfun(@max, h.(eta).TableIntensity_Int,'UniformOutput',false);

                for l = 1:size(IntMaxtmp1,1)
                    IntMaxtmp(l) = max(cell2mat(IntMaxtmp1(l,:)));
                end

                ExpInt = numel(num2str(round(IntMaxtmp(k))));

                if numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 7
                    ax.YAxis.Exponent = 4;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 6
                    ax.YAxis.Exponent = 3;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 5
                    ax.YAxis.Exponent = 2;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 4
                    ax.YAxis.Exponent = 1;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 3
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '    %3.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 2
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '     %2.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 1
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '      %1.f';
                end

                ax.YLim = [0 ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1))];

            end

            % Set legend data
            for i = 1:length(h.(eta).psiIndex{k})
                % Create label data from psi angles
                leglabel{k}{i} = ['\psi = ',num2str(h.(eta).psiIndex{k}(i,:))];
            end

            % Create data matrix for legend entries.
            for m = 1:length(h.(eta).psiIndex{k})
                LegData{k}(m) = etaplot{m};
            end

            l = legend(ax,LegData{k},leglabel{k});
            % Add reflex hkl to plot legend
            title(l,[h.labelforplot(k,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')

            l.FontSize = 6;
            l.LineWidth = 0.5;    

            if h.(eta).legend.Position(1) < 0.4 && h.(eta).legend.Position(2) > 0.4
                l.Location = 'NorthWest';
            elseif h.(eta).legend.Position(1) > 0.4 && h.(eta).legend.Position(2) > 0.4
                l.Location = 'NorthEast';
            elseif h.(eta).legend.Position(1) < 0.4 && h.(eta).legend.Position(2) < 0.4
                l.Location = 'SouthWest';
            elseif h.(eta).legend.Position(1) > 0.4 && h.(eta).legend.Position(2) < 0.4
                l.Location = 'SouthEast';
            end

            set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
            % Save plots to file
            FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr,'_Line_','%d'],k);
            print(fig,[Path,FileName],'-painters','-dtiff','-r300')
        end

        %% Create data files from plotted data
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr],k);

        formatOut = 'ddmmyyyy';
        d = datestr(now, formatOut);
        % name = strtrim(h.Measurement(1).MeasurementSeries);
        Folder = '\Plots\Data_Files\';
        Path = fullfile(h.PathName,Folder);

        if exist(Path,'dir') ~= 7
            mkdir(Path);
        end

        % Sort data according to hkl
        for k = 1:size(h.(eta).TableEta,1)
            for l = 1:size(h.(eta).TableEta,2)
                if strcmp(XDataStr,'Eta') && strcmp(YDataStr,'d-spacing')
                    Datahkl{k}{l} = [h.(eta).TableEta{k,l}(:) h.(eta).Tabledspacing{k,l}(:).*10 h.(eta).Tabledspacingdelta{k,l}(:).*10];
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'d-spacing')
                    Datahkl{k}{l} = [sind(h.(eta).TableEta{k,l}(:)).^2 h.(eta).Tabledspacing{k,l}(:).*10 h.(eta).Tabledspacingdelta{k,l}(:).*10];
                elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Integral Breadth')
                    Datahkl{k}{l} = [h.(eta).TableEta{k,l}(:) h.(eta).TableIB{k,l}(:)];
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Integral Breadth')
                    Datahkl{k}{l} = [sind(h.(eta).TableEta{k,l}(:)).^2 h.(eta).TableIB{k,l}(:)];
                elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Int. Intensity')
                    Datahkl{k}{l} = [h.(eta).TableEta{k,l}(:) h.(eta).TableIntensity_Int{k,l}(:)];
                elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Int. Intensity')
                    Datahkl{k}{l} = [sind(h.(eta).TableEta{k,l}(:)).^2 h.(eta).TableIntensity_Int{k,l}(:)];
                end
            end
        end
        % Find unequal cell arrays and pad cells with NaN values
        for k = 1:size(Datahkl,2)
            dims = max(cell2mat(cellfun(@(x)size(x), Datahkl{k}, 'uni', 0)'));
            Datahkltmp{k} = cellfun(@(x)[x,nan(size(x,1),dims(2)-size(x,2));nan(dims(1)-size(x,1),dims(2))], Datahkl{k},'uni', 0);
        end
        % Prepare data for export
        for k = 1:size(Datahkltmp,2)
            DataExport{k} = horzcat(Datahkltmp{k}{:});
        end

        % Create file header
        PsiHeadertmp = h.(eta).psiIndex{1};

        for i=1:length(PsiHeadertmp)
            PsiHeader{i} = ['psi = ',num2str(PsiHeadertmp(i)),'°'];
        end

        for k = 1:size(h.(eta).psiIndex,2)

            fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

            % Create table header for export data
            if strcmp(XDataStr,'Eta') && strcmp(YDataStr,'d-spacing')
                fmt1 = repmat(['eta','  ','d-spacing','  ','d-spacing_error','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %.6f  %.6e  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'d-spacing')
                fmt1 = repmat(['sin²eta','  ','d-spacing','  ','d-spacing_error','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.5f  %.6f  %.6e  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Integral Breadth')
                fmt1 = repmat(['eta','  ','IntegralBreadth','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %.4f  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Integral Breadth')
                fmt1 = repmat(['sin²eta','  ','IntegralBreadth','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %.4f  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'Eta') && strcmp(YDataStr,'Int. Intensity')
                fmt1 = repmat(['eta','  ','Int.Intensity','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %d  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'sin²Eta') && strcmp(YDataStr,'Int. Intensity')
                fmt1 = repmat(['sin²eta','  ','Int.Intensity','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %d  ',1,size(DataExport{k},2)/3);
            end    
            % Print header
            fprintf(fid, '%s  ', PsiHeader{:});
            fprintf(fid, '\n');
            fprintf(fid, fmt1);
            fprintf(fid, '\n');

            for m = 1:size(DataExport{k},1)
                str = sprintf([fmt2,'\n'],...
                DataExport{k}(m,:));
                str = regexprep(str, 'NaN', '  --  ');
                fprintf(fid, '%s', str);
            end
        end
    elseif isfield(h,['phi', PlotWindow])
        %% Create Plots
        % Create plot for each reflection hkl in case of scattering vector
        % measurements
        assignin('base','hphiexport',h.(phi))
        for k = 1:size(h.(phi).psiIndex,2)
            figure
            fig = gcf;
            fig.PaperUnits = 'centimeters';
            fig.PaperPositionMode = 'manual';
            fig.PaperPosition = [0 0 18 12];
            ax = gca;
            ax.OuterPosition = [0 0 1.045 1.025];
            ax.TickDir = 'out';
            ax.YAxis.TickLabelFormat = '%,.3f';
            ax.Box = 'on';
            ax.XGrid = 'on';
            ax.YGrid = 'on';
            ax.GridLineStyle = '-';
            ax.GridColor = 'k';
            ax.GridAlpha = 0.3;
            ax.YLabel.FontSize = 24;
            ax.XLabel.FontSize = 24;
            ax.LabelFontSizeMultiplier = 1.3;
            ax.LineWidth = 1.3;
            set(gca,'FontSize',18)
            hold on
            set(fig, 'Visible', 'off');

            % Plot data from each reflection hkl
            for i = 1:length(h.(phi).psiIndex{k})
                if strcmp(XDataStr,'Phi') && strcmp(YDataStr,'d-spacing')
                    phiplot{i} = errorbar(ax,h.(phi).Tablephi{k,i},h.(phi).Tabledspacing{k,i}.*10,h.(phi).Tabledspacingdelta{k,i}.*10,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{k},'Clipping','off');
                elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Integral Breadth')
                    phiplot{i} = errorbar(ax,h.(phi).Tablephi{k,i},h.(phi).TableIB{k,i},h.(phi).TableIB{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{k},'Clipping','off');
                elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Int. Intensity')
                    phiplot{i} = errorbar(ax,h.(phi).Tablephi{k,i},h.(phi).TableIntensity_Int{k,i},h.(phi).TableIntensity_Int{k,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{k},'Clipping','off');
                end
            end

            % Set x-axes properties
            xlabel(ax,'\phi [°]')

            ax.XLimMode = 'auto';
            xtickformat(ax,'auto')
            xticks(ax,'auto')

            % Set y-axes properties
            if strcmp(YDataStr,'d-spacing')
                ylabel(ax,'d [nm]')        
%                 ax.YLim = [(floor(((h.(minValLatticeSpacing){k}.*10)-0.001)./0.002).*0.002) (ceil(((h.(maxValLatticeSpacing){k}.*10)+0.001)/0.002).*0.002)];
                yticks(ax,'auto')
                ax.YAxis.TickLabelFormat = ' %.4f ';
            elseif strcmp(YDataStr,'Integral Breadth')
                ylabel(ax,'IB [keV]')
                ax.YLim = [floor(h.(minValIntegralWidth){k}./0.05).*0.05 ceil(h.(maxValIntegralWidth){k}/0.05).*0.05];
                yticks(ax,'auto')
                ax.YAxis.TickLabelFormat = ' %.2f ';
            elseif strcmp(YDataStr,'Int. Intensity')
                ylabel(ax,'Int. Intensity [cts]')
                yticks(ax,'auto')
                ax.YLimMode = 'auto';
                ytickformat(ax,'auto')

                ax.OuterPosition = [0 0 1.085 1.01];
                % Find maximum intensity for each hkl
                IntMaxtmp1 = cellfun(@max, h.(phi).TableIntensity_Int,'UniformOutput',false);

                for l = 1:size(IntMaxtmp1,1)
                    IntMaxtmp(l) = max(cell2mat(IntMaxtmp1(l,:)));
                end

                ExpInt = numel(num2str(round(IntMaxtmp(k))));

                if numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 7
                    ax.YAxis.Exponent = 4;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 6
                    ax.YAxis.Exponent = 3;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 5
                    ax.YAxis.Exponent = 2;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 4
                    ax.YAxis.Exponent = 1;
                    ax.YAxis.TickLabelFormat = '   %4.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 3
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '    %3.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 2
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '     %2.f';
                elseif numel(num2str(ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1)))) == 1
                    ax.YAxis.Exponent = 0;
                    ax.YAxis.TickLabelFormat = '      %1.f';
                end

                ax.YLim = [0 ceil(IntMaxtmp(k)/(10^(ExpInt-1))).*(10^(ExpInt-1))];

            end

            % Set legend data
            for i = 1:length(h.(phi).psiIndex{k})
                % Create label data from psi angles
                leglabel{k}{i} = ['\psi = ',num2str(h.(phi).psiIndex{k}(i,:))];
            end

            % Create data matrix for legend entries.
            for m = 1:length(h.(phi).psiIndex{k})
                LegData{k}(m) = phiplot{m};
            end

            l = legend(ax,LegData{k},leglabel{k});
            % Add reflex hkl to plot legend
            title(l,[h.labelforplot(k,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')

            l.FontSize = 6;
            l.LineWidth = 0.5;    

            if h.(phi).legend.Position(1) < 0.4 && h.(phi).legend.Position(2) > 0.4
                l.Location = 'NorthWest';
            elseif h.(phi).legend.Position(1) > 0.4 && h.(phi).legend.Position(2) > 0.4
                l.Location = 'NorthEast';
            elseif h.(phi).legend.Position(1) < 0.4 && h.(phi).legend.Position(2) < 0.4
                l.Location = 'SouthWest';
            elseif h.(phi).legend.Position(1) > 0.4 && h.(phi).legend.Position(2) < 0.4
                l.Location = 'SouthEast';
            end

            set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
            % Save plots to file
            FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr,'_Line_','%d'],k);
            print(fig,[Path,FileName],'-painters','-dtiff','-r300')
        end

        %% Create data files from plotted data
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_',strrep(strrep(strrep(YDataStr,'.','_'),' ','_'),'__','_'),'_vs_',XDataStr],k);

        formatOut = 'ddmmyyyy';
        d = datestr(now, formatOut);
        % name = strtrim(h.Measurement(1).MeasurementSeries);
        Folder = '\Plots\Data_Files\';
        Path = fullfile(h.PathName,Folder);

        if exist(Path,'dir') ~= 7
            mkdir(Path);
        end

        % Sort data according to hkl
        for k = 1:size(h.(phi).Tablephi,1)
            for l = 1:size(h.(phi).Tablephi,2)
                if strcmp(XDataStr,'Phi') && strcmp(YDataStr,'d-spacing')
                    Datahkl{k}{l} = [h.(phi).Tablephi{k,l}(:) h.(phi).Tabledspacing{k,l}(:).*10 h.(phi).Tabledspacingdelta{k,l}(:).*10];
                elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Integral Breadth')
                    Datahkl{k}{l} = [h.(phi).Tablephi{k,l}(:) h.(phi).TableIB{k,l}(:)];
                elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Int. Intensity')
                    Datahkl{k}{l} = [h.(phi).Tablephi{k,l}(:) h.(phi).TableIntensity_Int{k,l}(:)];
                end
            end
        end
%         assignin('base','Datahkl',Datahkl)
%         % Find unequal cell arrays and pad cells with NaN values
%         for k = 1:size(Datahkl,2)
%             dims = max(cell2mat(cellfun(@(x)size(x), Datahkl{k}, 'uni', 0)'));
%             Datahkltmp{k} = cellfun(@(x)[x,nan(size(x,1),dims(2)-size(x,2));nan(dims(1)-size(x,1),dims(2))], Datahkl{k},'uni', 0);
%         end
%         % Prepare data for export
%         for k = 1:size(Datahkltmp,2)
%             DataExport{k} = horzcat(Datahkltmp{k}{:});
%         end
        
        for k = 1:size(Datahkl,2)
            DataExport{k} = horzcat(Datahkl{k}{:});
        end
        % Create file header
        PsiHeadertmp = h.(phi).psiIndex{1};

        for i=1:length(PsiHeadertmp)
            PsiHeader{i} = ['psi = ',num2str(PsiHeadertmp(i)),'°'];
        end

        for k = 1:size(h.(phi).psiIndex,2)

            fid = fopen([[Path,'\'],FileName,'_Line_',num2str(k),'_',d,'.txt'],'w');

            % Create table header for export data
            if strcmp(XDataStr,'Phi') && strcmp(YDataStr,'d-spacing')
                fmt1 = repmat(['phi','  ','d-spacing','  ','d-spacing_error','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %.6f  %.6e  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Integral Breadth')
                fmt1 = repmat(['phi','  ','IntegralBreadth','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %.4f  ',1,size(DataExport{k},2)/3);
            elseif strcmp(XDataStr,'Phi') && strcmp(YDataStr,'Int. Intensity')
                fmt1 = repmat(['phi','  ','Int.Intensity','  '],1,size(DataExport{k},2)/3);
                % Create formatspec for export data
                fmt2 = repmat('%.4f  %d  ',1,size(DataExport{k},2)/3);
            end    
            % Print header
            fprintf(fid, '%s  ', PsiHeader{:});
            fprintf(fid, '\n');
            fprintf(fid, fmt1);
            fprintf(fid, '\n');

            for m = 1:size(DataExport{k},1)
                str = sprintf([fmt2,'\n'],...
                DataExport{k}(m,:));
                str = regexprep(str, 'NaN', '  --  ');
                fprintf(fid, '%s', str);
            end
        end
    end
    
end

end

