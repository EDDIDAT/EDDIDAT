function ModifyStressplots(t,XlimMinnew,XlimMaxnew,XlimXTicknew,YlimMinnew,YlimMaxnew,YlimYTicknew,FolderName)


taudatatmp = t.sin2psi.taupsizeromean';

Colors = {[0,0,0],[1,0,0],[0,0,1],[0,1,0],[1,0.8398,0],[1,0,1],[0 1 1],[0 .4 .8],[.6 .2 .8],[.8 .4 .4],[.2 .4 .2],[1,.5469,0],[.2 .4 .6],[1,.4102,.7031],[.2 .8 .6],[0.6445,0.1641,0.1641],[0 .7461 1]};
% Get current stress data 
taudata = [t.PeaksforLabel(:,1:3) t.sin2psi.sigmataulist];
sigmataulist_tmp = t.sin2psi.sigmataulist;
dzero_tmp = t.sin2psi.dzero;

% Get phi angles
PhiWinkel = cell(1,size(t.Params.Phi_Winkel,2));
ia = cell(1,size(t.Params.Phi_Winkel,2));
for k = 1:size(t.Params.Phi_Winkel,2)
	[PhiWinkel{k},ia{k},~] = unique(sort(t.Params.Phi_Winkel{k}));
end

if strcmp(t.Diffsel,'LEDDI')
    if strcmp(t.Detsel,'Detector 1')
        % Save taudata to file
        FileName = [strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det1'];
    elseif strcmp(t.Detsel,'Detector 2')
        FileName = [strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det2'];
    end
else
    % Save taudata to file
    FileName = [strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name];
end

formatOut = 'ddmmyyyy';
d = datestr(now, formatOut);
Folder = '\Modified_Stress_Plots\';

% name = strtrim(t.Measurement(1).MeasurementSeries);
PathName = pwd;
t.PathName = [PathName, '\',[FolderName,'_','new_plots','_',d]];

Path = fullfile(t.PathName,Folder);
        
if exist(Path,'dir') ~= 7
    mkdir(Path);
end

% Add phi angle to file name
phiangles = (PhiWinkel{1}(:));
phianglesstr_tmp = arrayfun(@num2str, phiangles, 'UniformOutput', 0);

if size(phianglesstr_tmp,1) > 1
    phianglesstr = strjoin(phianglesstr_tmp,'-');
else
    phianglesstr = phianglesstr_tmp{:};
end

fid = fopen([[Path,'\'],FileName,'_phi',phianglesstr,'_',d,'.tau'],'w');

fprintf(fid,'Filename: %s.\n\n',strrep(t.Measurement(1).MeasurementSeries,' ',''));

fprintf(fid, ['2Theta [Degree]:', ' ', num2str(t.Measurement(1).twotheta),'\n']);
fprintf(fid, ['Measured azimuths [Degree]:', ' ', '{',strrep(strrep(num2str(PhiWinkel{1}'),'  ',','),',,',','),'}','\n\n']);
% Create table header, depending on the azimuths measured
fprintf(fid, ['hkl   ', 'd0[nm]'  ,'    tau0    ','Sigma11  ','Error  ','Sigma22  ','Error  ','Sigma13  ','Error  ','Sigma23  ','Error  ','\n']);

% Add table data
if size(taudata,2)-5 == 2
    for k = 1:size(taudata,1)
        if PhiWinkel{1}(1) == 0 || PhiWinkel{1}(1) == 180
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8s %6s %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            '--',...
            '--',...
            '--',...
            '--',...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 90 || PhiWinkel{1}(1) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7s %6s %8d %6d %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            '--',...
            '--',...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            '--',...
            '--',...
            '--',...
            '--');
        end
    end
    ExportData{1,1} = [taudatatmp,sigmataulist_tmp(:,2:3)]; 
elseif size(taudata,2)-5 == 4
    for k = 1:size(taudata,1)
        if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8s %6s %8d %6d %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            '--',...
            '--',...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7s %6s %8d %6d %8s %6s %8d %6d\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            '--',...
            '--',...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            '--',...
            '--',...
            round(taudata(k,7)),...
            round(taudata(k,8)));
        elseif PhiWinkel{1}(1) == 180 && PhiWinkel{1}(2) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            '--',...
            '--');
        end
    end
    ExportData{1,1} = [taudatatmp,sigmataulist_tmp(:,2:3)];
    ExportData{1,2} = [taudatatmp,sigmataulist_tmp(:,4:5)];
elseif size(taudata,2)-5 == 6
    for k = 1:size(taudata,1)
        if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8d %6d %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            round(taudata(k,9)),...
            round(taudata(k,10)),...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8d %6d\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            round(taudata(k,9)),...
            round(taudata(k,10)));
        elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8d %6d %8s %6s\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            round(taudata(k,9)),...
            round(taudata(k,10)),...
            '--',...
            '--');
        elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
            fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8s %6s %8d %6d\n',...
            strrep(num2str(taudata(k,1:3)),' ',''),...
            dzero_tmp(k),...
            taudatatmp(k,1),...
            round(taudata(k,5)),...
            round(taudata(k,6)),...
            round(taudata(k,7)),...
            round(taudata(k,8)),...
            '--',...
            '--',...
            round(taudata(k,9)),...
            round(taudata(k,10)));
        end
        
    end
    ExportData{1,1} = [taudatatmp,sigmataulist_tmp(:,2:3)];
    ExportData{1,2} = [taudatatmp,sigmataulist_tmp(:,4:5)];
    ExportData{1,3} = [taudatatmp,sigmataulist_tmp(:,6:7)];
elseif size(taudata,2)-5 == 8
    for k = 1:size(taudata,1)
        fprintf(fid,'%-5s %-9.5f %-7.2f %7d %6d %8d %6d %8d %6d %8d %6d\n',...
        strrep(num2str(taudata(k,1:3)),' ',''),...
        dzero_tmp(k),...
        taudatatmp(k,1),...
        round(taudata(k,5)),...
        round(taudata(k,6)),...
        round(taudata(k,7)),...
        round(taudata(k,8)),...
        round(taudata(k,9)),...
        round(taudata(k,10)),...
        round(taudata(k,11)),...
        round(taudata(k,12)));
    end
    ExportData{1,1} = [taudatatmp,sigmataulist_tmp(:,2:3)];
    ExportData{1,2} = [taudatatmp,sigmataulist_tmp(:,4:5)];
    ExportData{1,3} = [taudatatmp,sigmataulist_tmp(:,6:7)];
    ExportData{1,4} = [taudatatmp,sigmataulist_tmp(:,8:9)];
end

% assignin('base','taudatatmp',taudatatmp)
% assignin('base','hsigmataulist',t.sin2psi.sigmataulist)
% assignin('base','ExportData',ExportData)

fclose(fid);
%--------------------------------------------------------------------------
% % Save data from tau file in case it should be loaded again
% t.PeaksforLabel = t.PeaksforLabel;
% t.sin2psi = t.sin2psi;
% t.Params.Phi_Winkel = t.Params.Phi_Winkel;
% t.taudata = taudata;
% t.taudatatmp = taudatatmp;
% t.Diffsel  = t.Diffsel;
% t.Detsel  = t.Detsel;
% t.Measurement  = t.Measurement(1);
% t.P.PopupValueMpd1  = t.P.PopupValueMpd1;
% ColorsUsedSorted = ColorsUsedSorted;
% t.Sample.Materials.Name = t.Sample.Materials.Name;
% 
% save(fullfile(Path, [FileName,'_taudata','_phi',phianglesstr,'_',d]), 't');
%--------------------------------------------------------------------------
% Create new folder in plot folder with name of measurement file
% formatOut = 'ddmmyyyy';
% d = datestr(now, formatOut);
% name = strtrim(t.Measurement(1).MeasurementSeries);
Folder = ['\StressPlots_phi',phianglesstr,'\'];
Path = fullfile(t.PathName,Folder);

if exist(Path,'dir') ~= 7
    mkdir(Path);
end

%% Create stress plots
for j = 1:(size(taudata,2)-5)/2
    figure

    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.085 1.025];

    set(fig, 'Visible', 'off');

    for k = 1:size(taudata,1)
        hkl(k,:) = strrep(num2str(taudata(k,1:3)),' ','');
    end

    for ii = length(ExportData{1,j}(:,2)):-1:1
        t.barplots = bar(ax, ExportData{1,j}(1:ii,2), 'FaceColor', Colors{ii});
        hold on;
    end

    t.barplots.BaseLine.LineWidth = 1.3;

    ax.XLim = ([0.25 length(ExportData{1,j}(:,2))+0.75]);
    ax.TickDir = 'in';
    labels = arrayfun(@(value) num2str(value,'%d'),round(ExportData{1,j}(:,3)),'UniformOutput',false);

    for k = 1:length(ExportData{1,j}(:,2))
        if ExportData{1,j}(k,2) < 0
            yPos(1,k) = -(max(abs(ExportData{1,j}(:,2)))/10)-5;
        else
            yPos(1,k) = 10;
        end
    end

    text((1:length(ExportData{1,j}(:,2))),yPos,labels,...
        'FontSize', 14,...
        'Color', 'k',...
        'EdgeColor', 'k',...
        'BackgroundColor', 'w',...
        'Margin', 2,...
        'HorizontalAlignment','center',...
        'VerticalAlignment','bottom');

    xlabel('Interference hkl','FontSize', 16)
    xl = get(gca,'XLabel');
    xlFontSize = get(xl,'FontSize');
    set(gca, 'xticklabel', hkl);
    xAX = get(gca,'XAxis');
    set(xAX, 'FontSize', 16)
    set(xl, 'FontSize', xlFontSize);

%     if length(PhiWinkel{1}) == 1
%         if PhiWinkel{1}(j) == 0 || PhiWinkel{1}(j) == 180
%             ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
%         elseif PhiWinkel{1}(j) == 90 || PhiWinkel{1}(j) == 270
%             ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
%         end
%     elseif length(PhiWinkel{1}) == 2
%         if PhiWinkel{1}(1) == 0
%             ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
%         elseif PhiWinkel{1}(j) == 90
%             ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
%         elseif PhiWinkel{1}(j) == 180
%             ylabel('<\sigma_{13} - \sigma_{33}> [MPa]','FontSize', 20)
%         elseif PhiWinkel{1}(j) == 270
%             ylabel('<\sigma_{23} - \sigma_{33}> [MPa]','FontSize', 20)
%         end
%     end
    
    if length(PhiWinkel{1}) == 1
        if PhiWinkel{1}(1) == 0 || PhiWinkel{1}(1) == 180
            ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif PhiWinkel{1}(1) == 90 || PhiWinkel{1}(1) == 270
            ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
        end
    elseif length(PhiWinkel{1}) == 2
        if j == 1
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 180 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 2
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 180 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        end
    elseif length(PhiWinkel{1}) == 3
        if j == 1
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 2
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 3
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            end
        end
    elseif length(PhiWinkel{1}) == 4
         if j == 1
            ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif j == 2
            ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif j == 3
            ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
        elseif j == 4
            ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
        end
    end

    yl = get(gca,'XLabel');
    ylFontSize = get(yl,'FontSize');
    yAX = get(gca,'YAxis');
    set(yAX, 'FontSize', 16)
    set(yl, 'FontSize', ylFontSize);
    set(gca, 'LineWidth', 1.3)

    title([strrep(strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',' '), ' ',t.Sample.Materials.Name])
    
    if strcmp(t.Diffsel,'LEDDI')
        if strcmp(t.Detsel,'Detector 1')
            % Save taudata to file
            FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det1_stress_barplot_','%d'],j);
        elseif strcmp(t.Detsel,'Detector 2')
            FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det2_stress_barplot_','%d'],j);
        end
    else
        % Save taudata to file
        FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_stress_barplot_','%d'],j);
    end
    
    print(fig,[Path,FileName],'-vector','-dtiff','-r300')

    figure
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPositionMode = 'auto';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.0625 1.025];
    ax.TickDir = 'out';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;

    ax.XLim = ([XlimMinnew XlimMaxnew]); 
    ax.XTick = XlimMinnew:XlimXTicknew:XlimMaxnew;

    ax.YLim = ([YlimMinnew YlimMaxnew]);
    ax.YTick = YlimMinnew:YlimYTicknew:YlimMaxnew;
    
    
    if length(PhiWinkel{1}) == 1
        if PhiWinkel{1}(1) == 0 || PhiWinkel{1}(1) == 180
            ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif PhiWinkel{1}(1) == 90 || PhiWinkel{1}(1) == 270
            ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
        end
    elseif length(PhiWinkel{1}) == 2
        if j == 1
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 180 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 2
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 180 && PhiWinkel{1}(2) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        end
    elseif length(PhiWinkel{1}) == 3
        if j == 1
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 2
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
            end
        elseif j == 3
            if PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 180
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 90 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 0 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
            elseif PhiWinkel{1}(1) == 90 && PhiWinkel{1}(2) == 180 && PhiWinkel{1}(3) == 270
                ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
            end
        end
    elseif length(PhiWinkel{1}) == 4
         if j == 1
            ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif j == 2
            ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)
        elseif j == 3
            ylabel('<\sigma_{13}> [MPa]','FontSize', 20)
        elseif j == 4
            ylabel('<\sigma_{23}> [MPa]','FontSize', 20)
        end
    end

    ax.YLabel.FontSize = 16;

    ax.XLabel.String = '\tau_{0} [µm]';

    ax.XLabel.FontSize = 16;
    ax.LabelFontSizeMultiplier = 1.3;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',16)
    hold on
    set(fig, 'Visible', 'off');
    
    x = ExportData{1,j}(:,1);
    y = ExportData{1,j}(:,2);
    err = ExportData{1,j}(:,3);

    errorbar(x,y,err,'Linestyle','--','Color','k','Marker','s','MarkerSize',1,'Clipping','off','Visible','on');

    for k=1:size(t.sin2psi.StressPlotDatatmpsorted,1)
        ScatterData(j).StressesPhi(:,k) = scatter(ExportData{1,j}(k,1),ExportData{1,j}(k,2),200,'Marker','s','MarkerFaceColor',Colors{k},'MarkerEdgeColor',Colors{k},'LineWidth',1.5);
    end
    
    Peaks = t.PeaksforLabel;
    Peaks = sortrows(Peaks,4,'descend');
    
    % Read hkl values from array
    for ii = 1:size(Peaks,1)
	    hkllabeltmp(ii,:) = mat2str(Peaks(ii,(1:3)));
    end
    % Remove '[' and ']' from character array
    for ii = 1:size(hkllabeltmp,1)
        hkllabeltmp1(ii,:) = regexprep(hkllabeltmp(ii,:),'[','');
    end
    
    for ii = 1:size(hkllabeltmp,1)
        hkllabeltmp2(ii,:) = regexprep(hkllabeltmp1(ii,:),']','');
    end
    % Final output with hkl values
    hkllabel = hkllabeltmp2;

    label = hkllabel;

    legstressdata = legend(ScatterData(j).StressesPhi,label);
    
    legstressdata.FontSize = 12;
    legstressdata.Location = 'northeast';
%     assignin('base','legstressdata',t.legstressdata)
%     if t.legstressdata.Position(1) < 0.4 && t.legstressdata.Position(2) > 0.4
%         legstressdata.Location = 'NorthWest';
%     elseif t.legstressdata.Position(1) > 0.4 && t.legstressdata.Position(2) > 0.4
%         legstressdata.Location = 'NorthEast';
%     elseif t.legstressdata.Position(1) < 0.4 && t.legstressdata.Position(2) < 0.4
%         legstressdata.Location = 'SouthWest';
%     elseif t.legstressdata.Position(1) > 0.4 && t.legstressdata.Position(2) < 0.4
%         legstressdata.Location = 'SouthEast';
%     end
    
    title([strrep(strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',' '), ' ',t.Sample.Materials.Name],'Fontsize', 11)
%     if valuecheckboxTauData == 0
    if strcmp(t.Diffsel,'LEDDI')
        if strcmp(t.Detsel,'Detector 1')
            % Save taudata to file
            FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det1_stressplot_','%d'],j);
        elseif strcmp(t.Detsel,'Detector 2')
            FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_','Det2_stressplot_','%d'],j);
        end
    else
        % Save taudata to file
        FileName = sprintf([strrep(t.Measurement(1).MeasurementSeries,' ',''),'_',t.Sample.Materials.Name,'_stressplot_','%d'],j);
    end


    print(fig,[Path,FileName],'-vector','-dtiff','-r300')
    print(fig,[Path,FileName],'-vector','-djpeg','-r600')

end

end