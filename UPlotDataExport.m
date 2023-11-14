% Create export data
dimssigma11 = max(cell2mat(cellfun(@(x)size(x), sigma11tmp, 'uni', 0)'));
tausigma11export = cellfun(@(x)[x,nan(size(x,1),dimssigma11(1,2)-size(x,2));nan(dimssigma11(1,1)-size(x,1),dimssigma11(1,2))], tausigma11tmp(1,:),'uni', 0);
sigma11export = cellfun(@(x)[x,nan(size(x,1),dimssigma11(1,2)-size(x,2));nan(dimssigma11(1,1)-size(x,1),dimssigma11(1,2))], sigma11tmp(1,:),'uni', 0);
sigma11deltaexport = cellfun(@(x)[x,nan(size(x,1),dimssigma11(1,2)-size(x,2));nan(dimssigma11(1,1)-size(x,1),dimssigma11(1,2))], sigma11deltatmp(1,:),'uni', 0);

for k = 1:size(tausigma11export,2)
    ExportMatrixsigma11tmp{k} = [tausigma11export{k}; sigma11export{k}; sigma11deltaexport{k}]';
end
ExportMatrixsigma11 = cell2mat(ExportMatrixsigma11tmp);

dimssigma22 = max(cell2mat(cellfun(@(x)size(x), sigma22tmp, 'uni', 0)'));
tausigma22export = cellfun(@(x)[x,nan(size(x,1),dimssigma22(1,2)-size(x,2));nan(dimssigma22(1,1)-size(x,1),dimssigma22(1,2))], tausigma22tmp(1,:),'uni', 0);
sigma22export = cellfun(@(x)[x,nan(size(x,1),dimssigma22(1,2)-size(x,2));nan(dimssigma22(1,1)-size(x,1),dimssigma22(1,2))], sigma22tmp(1,:),'uni', 0);
sigma22deltaexport = cellfun(@(x)[x,nan(size(x,1),dimssigma22(1,2)-size(x,2));nan(dimssigma22(1,1)-size(x,1),dimssigma22(1,2))], sigma22deltatmp(1,:),'uni', 0);

for k = 1:size(tausigma22export,2)
    ExportMatrixsigma22tmp{k} = [tausigma22export{k}; sigma22export{k}; sigma22deltaexport{k}]';
end
ExportMatrixsigma22 = cell2mat(ExportMatrixsigma22tmp);

dimssigma13 = max(cell2mat(cellfun(@(x)size(x), sigma13tmp, 'uni', 0)'));
tausigma13export = cellfun(@(x)[x,nan(size(x,1),dimssigma13(1,2)-size(x,2));nan(dimssigma13(1,1)-size(x,1),dimssigma13(1,2))], tausigma13tmp(1,:),'uni', 0);
sigma13export = cellfun(@(x)[x,nan(size(x,1),dimssigma13(1,2)-size(x,2));nan(dimssigma13(1,1)-size(x,1),dimssigma13(1,2))], sigma13tmp(1,:),'uni', 0);
sigma13deltaexport = cellfun(@(x)[x,nan(size(x,1),dimssigma13(1,2)-size(x,2));nan(dimssigma13(1,1)-size(x,1),dimssigma13(1,2))], sigma13deltatmp(1,:),'uni', 0);

for k = 1:size(tausigma13export,2)
    ExportMatrixsigma13tmp{k} = [tausigma13export{k}; sigma13export{k}; sigma13deltaexport{k}]';
end
ExportMatrixsigma13 = cell2mat(ExportMatrixsigma13tmp);

dimssigma23 = max(cell2mat(cellfun(@(x)size(x), sigma23tmp, 'uni', 0)'));
tausigma23export = cellfun(@(x)[x,nan(size(x,1),dimssigma23(1,2)-size(x,2));nan(dimssigma23(1,1)-size(x,1),dimssigma23(1,2))], tausigma23tmp(1,:),'uni', 0);
sigma23export = cellfun(@(x)[x,nan(size(x,1),dimssigma23(1,2)-size(x,2));nan(dimssigma23(1,1)-size(x,1),dimssigma23(1,2))], sigma23tmp(1,:),'uni', 0);
sigma23deltaexport = cellfun(@(x)[x,nan(size(x,1),dimssigma23(1,2)-size(x,2));nan(dimssigma23(1,1)-size(x,1),dimssigma23(1,2))], sigma23deltatmp(1,:),'uni', 0);

for k = 1:size(tausigma23export,2)
    ExportMatrixsigma23tmp{k} = [tausigma23export{k}; sigma23export{k}; sigma23deltaexport{k}]';
end
ExportMatrixsigma23 = cell2mat(ExportMatrixsigma23tmp);


if strcmp(h.Diffsel,'LEDDI')
    if strcmp(h.Detsel,'Detector 1')
        % Save taudata to file
        FileName = [strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_','Det1'];
    elseif strcmp(h.Detsel,'Detector 2')
        FileName = [strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_','Det2'];
    end
else
    % Save taudata to file
    FileName = [strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name];
end

formatOut = 'ddmmyyyy';
d = datestr(now, formatOut);
Folder = '\Psi_and_tau_File\';

if ~isfield(h,'PathName')
    name = strtrim(h.Measurement(1).MeasurementSeries);
    material = h.P.PopupValueMpd1;
    if strcmp(h.Diffsel,'LEDDI')
        h.PathName = [General.ProgramInfo.Path,'\Data\Results\LEDDI\',[name,'_',material,'_','added_plots','_',d]];
    elseif strcmp(h.Diffsel,'EDDI')
        h.PathName = [General.ProgramInfo.Path,'\Data\Results\EDDI\',[name,'_',material,'_','added_plots','_',d]];
    elseif strcmp(h.Diffsel,'LIMAX-160')
        h.PathName = [General.ProgramInfo.Path,'\Data\Results\MetalJet\',[name,'_',material,'_','added_plots','_',d]];    
    end
end

Path = fullfile(h.PathName,Folder);
        
if exist(Path,'dir') ~= 7
    mkdir(Path);
end

% Create file header
for k = 1:size(label,2)
    hkllabelemp1{k} = [['tau','   '],['sigma11(',strrep(label{k},' ', ''),')','    '],['deltasigma11(',strrep(label{k},' ', ''),')','    ']];
    hkllabelemp2{k} = [['tau','   '],['sigma22(',strrep(label{k},' ', ''),')','    '],['deltasigma22(',strrep(label{k},' ', ''),')','    ']];
    hkllabelemp3{k} = [['tau','   '],['sigma13(',strrep(label{k},' ', ''),')','    '],['deltasigma13(',strrep(label{k},' ', ''),')','    ']];
    hkllabelemp4{k} = [['tau','   '],['sigma23(',strrep(label{k},' ', ''),')','    '],['deltasigma23(',strrep(label{k},' ', ''),')','    ']];
end

hkllabel1 = join(hkllabelemp1);
hkllabel2 = join(hkllabelemp2);
hkllabel3 = join(hkllabelemp3);
hkllabel4 = join(hkllabelemp4);

% File format
format = '%.4f    %.6f    %.6f    ';

% Write data to file
fid = fopen([[Path,'\'],FileName,'_',d,'_','sigma11','.upl'],'w');

fprintf(fid,'Dateiname: %s.\n\n',strrep(h.Measurement(1).MeasurementSeries,' ',''));
fprintf(fid, ['2Theta [Degree]:', ' ', num2str(h.Measurement(1).twotheta),'\n']);
fprintf(fid, ['Gemessene Azimute [Degree]:', ' ', '{',strrep(strrep(num2str(PhiWinkel{1}'),'  ',','),',,',','),'}','\n\n']);

% Print file header
fprintf(fid, [hkllabel1{1},'\n']);

% Print data
for m = 1:size(tausigma11export{1},2)
    str = sprintf([repmat(format,1,size(label,2)),'\n'],...
    ExportMatrixsigma11(m,:));
    str = regexprep(str, 'NaN', '  --  ');
    fprintf(fid, '%s', str);
end

fclose(fid);

% Write data to file
fid = fopen([[Path,'\'],FileName,'_',d,'_','sigma22','.upl'],'w');

fprintf(fid,'Dateiname: %s.\n\n',strrep(h.Measurement(1).MeasurementSeries,' ',''));
fprintf(fid, ['2Theta [Degree]:', ' ', num2str(h.Measurement(1).twotheta),'\n']);
fprintf(fid, ['Gemessene Azimute [Degree]:', ' ', '{',strrep(strrep(num2str(PhiWinkel{1}'),'  ',','),',,',','),'}','\n\n']);

% Print file header
fprintf(fid, [hkllabel2{1},'\n']);

% Print data
for m = 1:size(tausigma22export{1},2)
    str = sprintf([repmat(format,1,size(label,2)),'\n'],...
    ExportMatrixsigma22(m,:));
    str = regexprep(str, 'NaN', '  --  ');
    fprintf(fid, '%s', str);
end

fclose(fid);

% Write data to file
fid = fopen([[Path,'\'],FileName,'_',d,'_','sigma13','.upl'],'w');

fprintf(fid,'Dateiname: %s.\n\n',strrep(h.Measurement(1).MeasurementSeries,' ',''));
fprintf(fid, ['2Theta [Degree]:', ' ', num2str(h.Measurement(1).twotheta),'\n']);
fprintf(fid, ['Gemessene Azimute [Degree]:', ' ', '{',strrep(strrep(num2str(PhiWinkel{1}'),'  ',','),',,',','),'}','\n\n']);

% Print file header
fprintf(fid, [hkllabel3{1},'\n']);

% Print data
for m = 1:size(tausigma13export{1},2)
    str = sprintf([repmat(format,1,size(label,2)),'\n'],...
    ExportMatrixsigma13(m,:));
    str = regexprep(str, 'NaN', '  --  ');
    fprintf(fid, '%s', str);
end

fclose(fid);

% Write data to file
fid = fopen([[Path,'\'],FileName,'_',d,'_','sigma23','.upl'],'w');

fprintf(fid,'Dateiname: %s.\n\n',strrep(h.Measurement(1).MeasurementSeries,' ',''));
fprintf(fid, ['2Theta [Degree]:', ' ', num2str(h.Measurement(1).twotheta),'\n']);
fprintf(fid, ['Gemessene Azimute [Degree]:', ' ', '{',strrep(strrep(num2str(PhiWinkel{1}'),'  ',','),',,',','),'}','\n\n']);

% Print file header
fprintf(fid, [hkllabel4{1},'\n']);

% Print data
for m = 1:size(tausigma23export{1},2)
    str = sprintf([repmat(format,1,size(label,2)),'\n'],...
    ExportMatrixsigma23(m,:));
    str = regexprep(str, 'NaN', '  --  ');
    fprintf(fid, '%s', str);
end

fclose(fid);




figure
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 18 12];
ax = gca;
ax.OuterPosition = [0 0 1.0725 1.025];
ax.TickDir = 'in';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 0.3;

% ax.XLim = ([h.XlimMinnew(j) h.XlimMaxnew(j)]); 
% ax.XTick = h.XlimMinnew(j):h.XlimXTicknew(j):h.XlimMaxnew(j);
% 
% ax.YLim = ([h.YlimMinnew(j) h.YlimMaxnew(j)]);
% ax.YTick = h.YlimMinnew(j):h.YlimYTicknew(j):h.YlimMaxnew(j);

ylabel('<\sigma_{11} [MPa]','FontSize', 20)
ax.YLabel.FontSize = 24;

ax.XLabel.String = '<\tau,z> [µm]';
ax.XLabel.FontSize = 24;
ax.LabelFontSizeMultiplier = 1.3;
ax.LineWidth = 1.3;

set(gca,'FontSize',18)
hold on
set(fig, 'Visible', 'off');

% Plot stress distributions of different stress compontens
for k = 1:size(h.UPlot.TauCalc.tau,2)
    sigma11uplotdata(k) = errorbar(h.UPlot.TauCalc.tau{1,k}(sin2psirange{1,k}), h.UPlot.sigma11{k}(sin2psirange{1,k}), h.UPlot.sigma11delta{k}(sin2psirange{1,k}),'Linestyle','none','Color','k','Marker','s','MarkerSize',14,'MarkerFaceColor',h.ColorsUsedSorted{k},'MarkerEdgeColor',h.ColorsUsedSorted{k},'Clipping','off');
    hold on
end
plotsigma11tau = plot(h.FitDatasigma11(:,1), h.Ypredsigma11,'r-','Linewidth',2);
hold on
plotsigma11z = plot(h.FitDatasigma11(:,1), h.Ypredsigma11z,'k-','Linewidth',2);

labeltmp = CreateHKLlabel(h);
for k = 1:5
    label{:,k} = labeltmp(k,:);
end

if get(h.uplotplotfitscheckbox,'value') == 0
    legstressdata = legend(sigma11uplotdata,label,'FontSize',12);
else
    legstressdata = legend([h.sigma11uplotdata,h.plotsigma11tau,h.plotsigma11z],[label,'\sigma_{11}(\tau)','\sigma_{11}(z)'],'FontSize',12);
end

legstressdata.FontSize = 12;

if h.legstressdata.Position(1) < 0.4 && h.legstressdata.Position(2) > 0.4
    legstressdata.Location = 'NorthWest';
elseif h.legstressdata.Position(1) > 0.4 && h.legstressdata.Position(2) > 0.4
    legstressdata.Location = 'NorthEast';
elseif h.legstressdata.Position(1) < 0.4 && h.legstressdata.Position(2) < 0.4
    legstressdata.Location = 'SouthWest';
elseif h.legstressdata.Position(1) > 0.4 && h.legstressdata.Position(2) < 0.4
    legstressdata.Location = 'SouthEast';
end

title([strrep(strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',' '), ' ',h.Sample.Materials.Name],'Fontsize', 11)
if strcmp(h.Diffsel,'LEDDI')
    if strcmp(h.Detsel,'Detector 1')
        % Save taudata to file
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_','Det1_UPlot_','%d','_',d]);
    elseif strcmp(h.Detsel,'Detector 2')
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_','Det2_UPlot_','%d','_',d]);
    end
else
    % Save taudata to file
    FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_UPlot_','%d','_',d]);
end
print(fig,[Path,FileName],'-painters','-dtiff','-r300')



































