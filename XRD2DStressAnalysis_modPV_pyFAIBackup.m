function XRD2DStressAnalysis_modPV_pyFAIBackup()
h.myfig = figure('Name','2DXRD Stress Analysis','MenuBar','none','ToolBar','auto','Position', [50 100 1800 900]);

h.SampleFormulaeEditField = uicontrol(...
    'parent', h.myfig, ...
    'Style', 'edit', ...
    'Units', 'pixels', ...
    "Position",[15 843 120 25],...
    "String","Elemental formula",...
    "HorizontalAlignment", "center",...
    'Enable', 'inactive', ...
    "Tag", "FilenameSample",...
    'ButtonDownFcn', {@clearbuttondown});

Files = dir(fullfile('Data','Materials','*.mpd'));
% Load MPD file list
MPDFileNameList = cell(size(Files,1),1);
for i=1:size(Files,1)
    [~,MPDFileNameList{i},~] = fileparts(Files(i).name);
end
MPDFileNameList = MPDFileNameList';

h.popupmenumpd1 = uicontrol( ...
    'Parent', h.myfig, ...
    'Style', 'popupmenu', ...
    'Units', 'pixels', ...
    'Position', [143 843 100 25], ...
    'Tag', 'popupmenumpd1', ...
    'String', MPDFileNameList, ...
    'Value', 1, ...
    'Callback', {@popupmenuCallback} ...
);

h.CreateSampleButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Create Sample', ...
    'Position', [250 843 100 25], ...
    'Callback', @createsamplecallback);

% =========================================================
% BLOCK 1: Load 2D images  (y-Top = 815)
% =========================================================
h.LoadImageButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Load 2D image(s)', ...
    'Position', [10 815 150 25], ...
    'Callback', @openfilecallback);

h.FileNameEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [10 788 340 24], ...
    'String', 'File Name', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'FilenameData');

% =========================================================
% BLOCK 2: Load PONI + Alpha  (y-Top = 760)
% =========================================================
h.LoadGammaDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Load PONI Files', ...
    'Position', [10 760 150 25], ...
    'Callback', @opengammafilecallback);

h.AlphaText1 = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [168 764 15 18], ...
    'String', char(945));

h.AlphaText2 = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [183 764 12 18], ...
    'String', '=');

h.AlphaEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [197 760 153 24], ...
    'String', 'alpha', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'AlphaEditField');

h.GammaFileNameEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [10 733 340 24], ...
    'String', 'PONI File(s)', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'GammaFilename');

% =========================================================
% BLOCK 2b: Python-Konfiguration
% =========================================================
h.pythonExeText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 706 65 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Python exe');

h.pythonExeEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [78 704 272 22], ...
    'String', "C:\Users\hrp\AppData\Local\Programs\Python\Python311\venv\Scripts\python.exe", ...
    'HorizontalAlignment', 'left', ...
    'Tag', 'pythonExe');

h.scriptPathText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 678 65 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Script path');

h.scriptPathEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [78 676 272 22], ...
    'String', fullfile(pwd, 'pyfai_multigeom_run.py'), ...
    'HorizontalAlignment', 'left', ...
    'Tag', 'scriptPath');

% cfg.pythonExe = "C:\Users\hrp\AppData\Local\Programs\Python\Python311\venv\Scripts\python.exe";
% cfg.scriptPath = fullfile(pwd,"pyfai_multigeom_run.py");

% =========================================================
% BLOCK 3: pyFAI / Binning Parameter  (y-Top = 705)
%   Zeile 0 Header  : y = 705
%   Zeile 1 chi-Range: y = 678
%   Zeile 2 Bin/Avg  : y = 650
%   Zeile 3 Smooth/BL: y = 622
% =========================================================
h.PyFAIParamText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 650 340 18], ...
    'HorizontalAlignment', 'left', ...
    'FontWeight', 'bold', ...
    'String', 'pyFAI / Binning Parameter');

% --- Zeile 1: chi-Range ---
h.trackChiRangeMinText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 624 65 18], ...
    'HorizontalAlignment', 'left', ...
    'String', [char(967), '-Range min']);

h.trackChiRangeMinEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [78 622 50 22], ...
    'String', '-180', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'trackChiRangeMin');

h.trackChiRangeMaxText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [138 624 65 18], ...
    'HorizontalAlignment', 'left', ...
    'String', [char(967), '-Range max']);

h.trackChiRangeMaxEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [206 622 50 22], ...
    'String', '180', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'trackChiRangeMax');

% --- Zeile 2: Chi-Bin step | Chi avg +/- ---
h.trackChiBinText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 596 68 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Chi-Bin step', ...
    'Tooltip', 'trackChiBin: jeden n-ten chi-Bin verwenden');

h.trackChiBinEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [80 594 48 22], ...
    'String', '1', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'trackChiBin');

h.trackChiAvgBinsText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [138 596 68 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Chi avg +/-', ...
    'Tooltip', 'trackChiAvgBins: Mittelung ueber +/- n chi-Bins');

h.trackChiAvgBinsEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [209 594 48 22], ...
    'String', '4', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'trackChiAvgBins');

% --- Zeile 3: Smooth pts | Baseline ---
h.smoothPointsText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 624-56 68 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Smooth pts');

h.smoothPointsEdit = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [80 622-56 48 22], ...
    'String', '1', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'smoothPoints');

h.baselineModeText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [138 624-56 55 18], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Baseline');

h.baselineModePopup = uicontrol(h.myfig, ...
    'Style', 'popupmenu', ...
    'Position', [196 622-56 65 22], ...
    'String', {'none', 'movmin'}, ...
    'Value', 1, ...
    'Tag', 'baselineMode');

% =========================================================
% BLOCK 4: Change 2theta range  (y-Top = 594)
%   Header-Text : y = 567..594 (Hoehe 27)
%   Editfelder  : y = 567
%   Button      : y = 567
% =========================================================
h.ChangetwothetaText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 568-30 105 24], ...
    'String', ['Select 2', char(952), ' range']);

h.twothetaminEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [10 542-26 80 24], ...
    'String', ['2', char(952), ' min'], ...
    'HorizontalAlignment', 'center', ...
    'Enable', 'inactive', ...
    'ButtonDownFcn', {@clearbuttondown}, ...
    'Tag', 'twothetaminEditField');

h.twothetamaxEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [100 542-26 80 24], ...
    'String', ['2', char(952), ' max'], ...
    'HorizontalAlignment', 'center', ...
    'Enable', 'inactive', ...
    'ButtonDownFcn', {@clearbuttondown}, ...
    'Tag', 'twothetamaxEditField');

h.ChangetwothetarangeButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', ['Change 2', char(952), ' range'], ...
    'Position', [190 542-26 160 24], ...
    'Callback', @changetwothetarangecallback);

% =========================================================
% BLOCK 5: Peak search options  (y-Top = 514)
%   Header      : y = 490..514
%   Prominence  : y = 488
%   Peak window : y = 460
%   Min height  : y = 432
% =========================================================
h.PeakSearchOptionsText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 490 175 22], ...
    'String', 'Peak search options');

% Prominence
h.PeakProminenceText1 = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 462 145 24], ...
    'HorizontalAlignment', 'left', ...
    'Tooltip', ['The prominence threshold of a peak is a measure of how ' ...
                'much that peak stands out relative to its surroundings.'], ...
    'String', 'Prominence threshold');

h.PeakProminenceEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [158 462 50 24], ...
    'String', '0.2', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'PeakProminenceEditField');

h.DefinePeaksButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Define peaks', ...
    'Position', [220 462 130 24], ...
    'Tooltip', 'Define peaks that should be included in the analysis.', ...
    'Callback', @definepeakscallback);

% Peak window
h.PeakWindowText1 = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 434 145 24], ...
    'HorizontalAlignment', 'left', ...
    'Tooltip', ['Interval around the detected peak position that is used ' ...
                'to collect data points for the fit.'], ...
    'String', 'Peak window');

h.PeakWindowEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [158 434 50 24], ...
    'String', '1', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'PeakWindowEditField');

h.SearchPeaksButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Search peaks', ...
    'Position', [220 434 130 24], ...
    'Tooltip', 'Search for peaks using the options on the left.', ...
    'Callback', @searchpeakscallback);

% Min height
h.PeakHeightText = uicontrol(h.myfig, ...
    'Style', 'text', ...
    'Position', [10 406 145 24], ...
    'HorizontalAlignment', 'left', ...
    'String', 'Minimum peak height');

h.PeakMinHeightEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    'Position', [158 406 50 24], ...
    'String', '3', ...
    'HorizontalAlignment', 'center', ...
    'Tag', 'PeakMinHeight');

% =========================================================
% BLOCK 6: User-defined peaks table  (y-Top = 378, Hoehe 160)
% =========================================================
datatmpUP = zeros(8, 2);
h.tableUserDefinedPeaks = uitable(h.myfig, ...
    'Position', [10 218 340 160], ...
    'ColumnName', {'EPos-User', 'Peak count', 'Use'}, ...
    'Data', [num2cell(datatmpUP), num2cell(datatmpUP(:,1) > 0)], ...
    'Tag', 'tableUserDefinedPeaks', ...
    'ColumnFormat', {'numeric', 'numeric', 'logical'}, ...
    'ColumnEditable', [false, false, true], ...
    'ColumnWidth', {100, 100, 50});

% =========================================================
% BLOCK 7: Load DEC + Fit Peaks  (y-Top = 190)
% =========================================================
h.LoadDECdataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Load DEC data', ...
    'Position', [10 190 155 25], ...
    'Tooltip', 'Load DEC data in case no DEC datafile was found.', ...
    'Callback', @loadDECdatacallback);

h.FitPeaksButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    'String', 'Start Peak Fit', ...
    'Position', [175 190 175 25], ...
    'Tooltip', 'Start fitting of found peak positions.', ...
    'Callback', @fitpeakscallback);



h.AbscoeffText1 = uicontrol(h.myfig,...
    'Style','text',...
    "Position",[10 100 60 30],...
    "HorizontalAlignment", "left",...
    "String","Absorption coefficient");
	
h.AbscoeffText2 = uicontrol(h.myfig,...
    'Style','text',...
    "Position",[70 110 20 15],...
    "String",char(956));

h.AbscoeffText3 = uicontrol(h.myfig,...
    'Style','text',...
    "Position",[85 110 20 15],...
    "String","=");

h.AbscoeffEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    "Position",[110 106 60 25],...
    "String", 0,...
    "HorizontalAlignment", "center",...
    "Tag", "AbscoeffEditField");

h.SpannKompText1 = uicontrol(h.myfig,...
    'Style','text',...
    "Position",[10 50 100 40],...
    "HorizontalAlignment", "left",...
    "String","Define stress components to be analyzed");

h.SpannKompEditField = uicontrol(h.myfig, ...
    'Style', 'edit', ...
    "Position",[110 58 60 25],...
    "String", 1122,...
    "HorizontalAlignment", "center",...
    "Tag", "SpannKompEditField");

h.ModDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    "String","Modify Data", ...
    "Position",[200 110 120 40],...
    "Callback", @moddatacallback);

h.FitStessDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    "String","Fit Stress Data", ...
    "Position",[200 65 120 40],...
    "Callback", @fitstressdatacallback);

h.ModStessDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    "String","Modify Stress Data", ...
    "Position",[200 20 120 40],...
    "Callback", @modstressdatacallback);


h.plottab = uitabgroup(h.myfig,...
    "Units","pixels",...
    "Position",[380 250 800 600]);

h.plottab4 = uitab(h.plottab,"Title","Plot intensity data");
h.plottab1 = uitab(h.plottab,"Title","Stress factor method");
h.plottab2 = uitab(h.plottab,"Title","sin²psi method");
h.plottab3 = uitab(h.plottab,"Title","DEC data for fitted peaks");


h.axes = uiaxes(h.plottab1,...
    'Tag', 'AxesTwotheta',...
    "Position",[10 10 770 550]);

h.axes.XLim = [-90,90];
h.axes.YLim = [-Inf,Inf];
% h.axes.YLimMode = 'manual';
% h.axes.XLimMode = 'manual';
h.axes.YLabel.String = [char(949),'(',char(947),')'];
h.axes.YLabel.FontSize = 16;
h.axes.XLabel.String = [char(947),' [°]'];
h.axes.XLabel.FontSize = 16;
grid(h.axes,'on')
box(h.axes,'on')

h.axessin2psi = uiaxes(h.plottab2,...
    'Tag', 'AxesSin2psi',...
    "Position",[10 10 770 550]);

h.axessin2psi.XLim = [0 1];
h.axessin2psi.YLim = [0,Inf];
h.axessin2psi.YLimMode = 'auto';
h.axessin2psi.YLabel.String = [char(949),'(',char(947),')'];
h.axessin2psi.YLabel.FontSize = 16;
h.axessin2psi.XLabel.String = ['sin²',char(968)];
h.axessin2psi.XLabel.FontSize = 16;
grid(h.axessin2psi,'on')
box(h.axessin2psi,'on')

% Spaceholder data
datatmp = zeros(5,8);
datatmp1 = zeros(5,6);

% Table with information on fitted peaks
h.tableDECFittedPeaks = uitable(h.plottab3,...
    "Position",[10 10 428 530],...
    "ColumnName", {'E-fitted', 'E-theo', 'h', 'k', 'l', 'S1', '1/2 S2', char(945)},...
    "Data", datatmp,...
    "Tag", "tableDECFittedPeaks",...
    "ColumnFormat",{'numeric',(cellfun(@num2str,num2cell(datatmp(:,4)),'UniformOutput',false))','numeric','numeric','numeric','numeric','numeric','numeric'},...
    "ColumnEditable", [false, true, false, false, false, true, true, false], ...
    "ColumnWidth", {65 65 22 22 22 80 80 30}, ...
    "CellEditCallback", @celleditcallback ...
    );

    % "Data", [ones(size(data,1),1) data(:,4) data(:,1:3) data(:,5:6) ones(size(data,1),1)],...


h.plottabEtheo = uitabgroup(h.plottab3,...
    "Units","pixels",...
    "Position",[455 30 333 535]);

h.plottabEtheo1 = uitab(h.plottabEtheo,"Title","Ga k-alpha");
h.plottabEtheo2 = uitab(h.plottabEtheo,"Title","In k-alpha");
h.plottabEtheo3 = uitab(h.plottabEtheo,"Title","In k-beta");

% Table with theoretical peak data
h.dekdataGaKalpha = uitable(h.plottabEtheo1,...
    "Position",[5 500 - (27 + size(datatmp1,1)*22) 333 (27 + size(datatmp1,1)*22)],...
    "ColumnName", {'h', 'k', 'l', 'E-theo', 'S1', '1/2 S2'},...
    "Data", datatmp1(:,1:6),...
    "Tag", "dekdata",...
    "ColumnFormat",{'numeric','numeric','numeric','numeric','numeric','numeric'},...
    "ColumnEditable", [false, false, false, false, true, true], ...
    "ColumnWidth", {22 22 22 58 75 75}, ...
    "CellEditCallback", @celleditcallback ...
    );

h.dekdataInKalpha = uitable(h.plottabEtheo2,...
    "Position",[5 500 - (27 + size(datatmp1,1)*22) 333 (27 + size(datatmp1,1)*22)],...
    "ColumnName", {'h', 'k', 'l', 'E-theo', 'S1', '1/2 S2'},...
    "Data", datatmp1(:,1:6),...
    "Tag", "dekdata",...
    "ColumnFormat",{'numeric','numeric','numeric','numeric','numeric','numeric'},...
    "ColumnEditable", [false, false, false, false, true, true], ...
    "ColumnWidth", {22 22 22 58 75 75}, ...
    "CellEditCallback", @celleditcallback ...
    );

h.dekdataInKbeta = uitable(h.plottabEtheo3,...
    "Position",[5 500 - (27 + size(datatmp1,1)*22) 333 (27 + size(datatmp1,1)*22)],...
    "ColumnName", {'h', 'k', 'l', 'E-theo', 'S1', '1/2 S2'},...
    "Data", datatmp1(:,1:6),...
    "Tag", "dekdata",...
    "ColumnFormat",{'numeric','numeric','numeric','numeric','numeric','numeric'},...
    "ColumnEditable", [false, false, false, false, true, true], ...
    "ColumnWidth", {22 22 22 58 75 75}, ...
    "CellEditCallback", @celleditcallback ...
    );

h.radiobuttonwavelength = uibuttongroup(h.myfig,...
    "Units","pixels",...
    'BorderType','none',...
    'SelectionChangedFcn', @choosewavelengthcallback ,...
    'Position',[500 150 123 85]);  

h.rb1 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Position',[10 60 91 15],...
    'String', 'Ga K-alpha');
h.rb2 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Position',[10 38 91 15],...
    'String', 'In K-alpha');
h.rb3 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Position',[10 16 91 15],...
    'String', 'In K-beta');


h.axesPlotIntensityData = uiaxes(h.plottab4,...
    'Tag', 'AxesIntensity',...
    "Position",[10 10 770 550]);

h.axesPlotIntensityData.XLim = [0,60];
h.axesPlotIntensityData.YLim = [-Inf,Inf];
h.axesPlotIntensityData.YLimMode = 'auto';
h.axesPlotIntensityData.YLabel.String = 'Intensity [a.u.]';
h.axesPlotIntensityData.YLabel.FontSize = 16;
h.axesPlotIntensityData.XLabel.String = ['2',char(952),' °'];
h.axesPlotIntensityData.XLabel.FontSize = 16;
grid(h.axesPlotIntensityData,'off')
box(h.axesPlotIntensityData,'on')
hold(h.axesPlotIntensityData,'on')

h.checkboxplotall = uicontrol(h.myfig,...
    'Style', 'checkbox', ...
    'Position', [1030 250 200 25],...
    'String','Plot all Intensity profiles',...
    'Callback', @plotallprofilescallback);

% Slider erzeugen
h.Slider = uicontrol(...
'Style','slider',...
'Tag','Slider',...
'Parent', h.myfig,...
'Position', [685 200 200 25],...
'Min',0,...
'Max', 1,...
'Value',1,...
'Callback',{@SliderCallbackPlotRawData});

set(h.Slider,'Min',1);
set(h.Slider,'Max',1);
set(h.Slider,'SliderStep',[1/(2-1) 1/(2-1)]);

% Data for plot
x = 0;
y = 0;
err = 0;
% h.data = data;

% Create plot for intensity data
h.plotIntensityData = plot(h.axesPlotIntensityData,x,y,'-','Color','blue','Visible','off');

% Create plot for raw data
h.plotdata = errorbar(h.axes, x,y,err,'s','Visible','off');
hold(h.axes,'on')
h.fitcurvestress = plot(h.axes,0,0,'-',"Visible",'off');

% Create plot for sin²psi data
h.plotdatasin2psi = errorbar(h.axessin2psi, x,y,err,'s','Visible','off');
hold(h.axessin2psi,'on')
h.fitcurvestresssin2psi = plot(h.axessin2psi,0,0,'-',"Visible",'off');


% Axes for stress data
h.axesStressData = uiaxes(h.myfig,...
    'Tag', 'AxesStressdata',...
    "Position", [1200 450 550 400]);

h.axesStressData.XLim = [0,Inf];
h.axesStressData.YLim = [-Inf,Inf];
h.axesStressData.YLimMode = 'auto';
h.axesStressData.YLabel.String = [char(963),' [MPa]'];
h.axesStressData.YLabel.FontSize = 16;
h.axesStressData.XLabel.String = [char(964),' [',char(956),'m]'];
h.axesStressData.XLabel.FontSize = 16;
grid(h.axesStressData,'on')

h.plotstressdata = errorbar(h.axesStressData, x,y,err,'s'); 
hold(h.axesStressData,'on')
box(h.axesStressData,'on')

h.plotsin2psistressdata = errorbar(h.axesStressData, x,y,err,'o');

h.highlightstressplot = plot(h.axesStressData,x,y,'s','Color','g','MarkerFaceColor','g','Visible','off','MarkerSize',12);

h.highlightpeakdata = plot(h.axes,x,y,'s','Color','g','MarkerFaceColor','g','Visible','off','MarkerSize',10);

h.ExportFitDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    "String","Export Fit Data", ...
    "Position",[1250 400 110 30],...
    "Callback", @exportfitdatacallback);

h.ExportStressDataButton = uicontrol(h.myfig, ...
    'Style', 'Pushbutton', ...
    "String","Export Stress Data", ...
    "Position",[1380 400 120 30],...
    "Callback", @exportstressdatacallback);

% Axes for fitted peaks 
h.axesFittedPeaks = uiaxes(h.myfig,...
    'Tag', 'AxesFittedPeaks',...
    "Position", [1265 75 450 300]);

h.axesFittedPeaks.XLim = [0,50];
h.axesFittedPeaks.YLim = [-Inf,Inf];
h.axesFittedPeaks.YLimMode = 'auto';
h.axesFittedPeaks.XLimMode = 'auto';
h.axesFittedPeaks.YLabel.String = 'Intensity [a.u.]';
h.axesFittedPeaks.YLabel.FontSize = 16;
h.axesFittedPeaks.XLabel.String = ['2',char(952),' [°]'];
h.axesFittedPeaks.XLabel.FontSize = 16;
box(h.axesFittedPeaks,'on')

h.plotRawData = plot(h.axesFittedPeaks,x,y,'o','Color','black','MarkerFaceColor','black','MarkerSize',6,'Visible','off');
hold(h.axesFittedPeaks,'on')
h.plotFitData = plot(h.axesFittedPeaks,x,y,'-','Color','red','Visible','off');


h.axesPlottauData = uiaxes(h.myfig,...
    'Tag', 'AxestauData',...
    "Position", [380 50 800 100]);

h.axesPlottauData.XLim = [-90,90];
h.axesPlottauData.YLim = [-Inf,Inf];
h.axesPlottauData.YLimMode = 'auto';
h.axesPlottauData.YLabel.String = '\tau [µm]';
h.axesPlottauData.YLabel.FontSize = 14;
h.axesPlottauData.XLabel.String = [char(947),' °'];
h.axesPlottauData.XLabel.FontSize = 14;
grid(h.axesPlottauData,'off')
box(h.axesPlottauData,'on')
h.plottaudata = plot(h.axesPlottauData,0,0,'s');        
hold(h.axesPlottauData,'on')
h.plottaudatamean = plot(h.axesPlottauData,0,0,'Color','r');

h.SliderFittedPeaks = uicontrol(...
'Style','slider',...
'Tag','Slider',...
'Parent', h.myfig,...
'Position', [1460 30 100 20],...
'Min',0,...
'Max', 1,...
'Value',1,...
'Callback',{@SliderCallbackFittedPeaks});

set(h.SliderFittedPeaks,'Min',1);
set(h.SliderFittedPeaks,'Max',1);
set(h.SliderFittedPeaks,'SliderStep',[1/(2-1) 1/(2-1)]);

guidata(h.myfig, h)

function popupmenuCallback(hObj,~)
% Callback for "pop up menu" in create sample panel
h = guidata(hObj);
% Determine the selected data set.
str = get(hObj, 'String');
val = get(hObj, 'Value');

h.PopupValueMpd = str{val};

guidata(hObj,h);

function createsamplecallback(hObj,~)
% Callback for "Open File" pushbutton
h = guidata(hObj);

if strcmp(get(h.SampleFormulaeEditField,'Value'),'Elemental formula')
    errordlg('Please enter formula','Warning');
else
    h.ElementalFormula = get(h.SampleFormulaeEditField,'String');
    h.MPDFileName = h.PopupValueMpd;
    % Set FileName to string and ExPath to UserData of Edit-Field
    [Sample,T] = CreateSampleGUI(h);
    h.T = T;
    h.Sample = Sample;
    
    msgbox({'Sample Created'});
end

% Calculate theoretical peak positions
h.PeaksTheo = CalcPeakPositions2DXRD(h.Sample.Materials.ElementalFormula,h.MPDFileName,'ETA3000',100);

assignin('base','PeaksTheo',h.PeaksTheo)
% Calculate absorption coefficient
Energy{1} = 9.251674; % Gallium k-alpha
Energy{2} = 24.2097; % Indium k-alpha
Energy{3} = 27.2759; % Indium k-beta

h.Energy = Energy;

for k = 1:size(Energy,2)
    h.abscoeff{k} = Sample.Materials.LAC(Energy{k})/10000;
end

set(h.AbscoeffEditField,"String",num2str(round(h.abscoeff{1},6)))

% Wellenlänge speichern (für pyFAI)
% Ga K-alpha: E = 9.2517 keV → λ = hc/E [m]
% hc_eVm = 1.23984193e-6;
% h.lambda_m = hc_eVm / (h.Energy{1} * 1000);  % Energy in keV → eV
h.lambda_m = 1.34143847484e-10;
% h.Energy{1} = 9.251674 keV

guidata(hObj, h);

function openfilecallback(hObj, ~)
h = guidata(hObj);

[file, location] = uigetfile('*.tif', ...
    'Select 2D XRD image(s)', ...
    'MultiSelect', 'on');

if isequal(file, 0)
    disp('User selected Cancel');
    return
end

% Normalisieren auf Cell-Array
if ~iscell(file)
    file = {file};
end

total_images_selected = numel(file);

% Vollpfade speichern
imgPaths = cell(total_images_selected, 1);
for k = 1:total_images_selected
    imgPaths{k} = fullfile(location, file{k});
end

h.FileNameLoad   = file;
h.imgPaths       = imgPaths;
h.imgLocation    = location;

% % Alpha aus Dateinamen parsen (Regex wie bisher)
% for k = 1:total_images_selected
%     alphaTmp = str2double(cell2mat(...
%         regexp(file{k}, '(?<=alpha).*(?=-caked\.tif)', 'match')));
%     if isnan(alphaTmp)
%         % Fallback: weiterer Regex-Versuch mit anderer Namenskonvention
%         alphaTmp = str2double(cell2mat(...
%             regexp(file{k}, '(?<=chi_).*(?=-)', 'match', 'once')));
%     end
%     h.alpha(k) = alphaTmp;
% end

set(h.FileNameEditField, 'String', strjoin(string(file), ', '));
% set(h.AlphaEditField,    'String', strjoin(string(h.alpha), ', '));

% BinSize aus neuem trackChiBin-Feld lesen (für Kompatibilität)
h.BinSize = str2double(get(h.trackChiBinEdit, 'String'));

guidata(hObj, h);

function opengammafilecallback(hObj, ~)
h = guidata(hObj);

% Sicherheitscheck: Bilder müssen zuerst geladen sein
if ~isfield(h, 'imgPaths') || isempty(h.imgPaths)
    errordlg('Please load 2D images first.', 'No images loaded');
    return
end

% --- PONI-Files auswählen ---
[poniFiles, poniLocation] = uigetfile('*.poni', ...
    'Select PONI files (same order as images)', ...
    'MultiSelect', 'on');

if isequal(poniFiles, 0)
    disp('User selected Cancel');
    return
end

if ~iscell(poniFiles)
    poniFiles = {poniFiles};
end

if numel(poniFiles) ~= numel(h.imgPaths)
    errordlg(sprintf(...
        'Number of PONI files (%d) must match number of images (%d).', ...
        numel(poniFiles), numel(h.imgPaths)), ...
        'Count mismatch');
    return
end

% Vollpfade PONI
poniPaths = cell(numel(poniFiles), 1);
for k = 1:numel(poniFiles)
    poniPaths{k} = fullfile(poniLocation, poniFiles{k});
end

% Get list of alpha angles
for k = 1:size(poniFiles,2)
    alpha_tmp(k) = str2double(cell2mat(regexp(poniFiles{1},'(?<=alpha).*(?=.poni)','match')));
end

h.alpha = unique(alpha_tmp);
set(h.AlphaEditField,'String',strjoin(string(h.alpha),', '))

% Button-Feedback
col = get(hObj, 'backg');
set(hObj, 'String', 'Running pyFAI ...', 'backg', [1 .6 .6]);
pause(0.01);

set(h.GammaFileNameEditField, 'String', strjoin(string(poniFiles), ', '));

% --- pyFAI Konfiguration aus GUI-Feldern lesen ---
% Wellenlänge: aus AlphaEditField kann man nicht lesen — 
% als Fallback h.Energy{1} (Ga K-alpha) verwenden,
% oder ein eigenes Wellenlängen-Feld vorsehen.
% Hier: h.lambda_m muss gesetzt sein (z.B. beim CreateSample).
% Fallback: Ga K-alpha = 9.2517 keV → λ = hc/E
if isfield(h, 'lambda_m')
    lambda_m = h.lambda_m;
else
    % Ga K-alpha: E = 9.2517 keV
    hc_eVm = 1.23984193e-6;   % eV·m
    lambda_m = hc_eVm / (9251.7);  % in m
end

cfg = struct();
cfg.pythonExe  = 'python';   % ggf. anpassen
cfg.outBase    = fullfile(h.imgLocation, 'pyfai_SiSiC_Test_vor_WB2');
cfg.mode       = '2d';
cfg.unit       = '2th_deg';
cfg.npt_rad    = 3000;
cfg.npt_azim   = 360;
cfg.method     = 'csr';
cfg.pythonExe  = strtrim(get(h.pythonExeEdit,  'String'));
cfg.scriptPath = strtrim(get(h.scriptPathEdit, 'String'));
% cfg.pythonExe = "C:\Users\hrp\AppData\Local\Programs\Python\Python311\venv\Scripts\python.exe";
% cfg.scriptPath = fullfile(pwd,"pyfai_multigeom_run.py");

% --- pyFAI MultiGeometry ausführen ---
try
    out = run_pyfai_multigeometry_from_matlab(...
        h.imgPaths, poniPaths, lambda_m, cfg);
catch ME
    set(hObj, 'String', 'Load Gamma Data File', 'backg', col);
    errordlg(sprintf('pyFAI failed:\n%s', ME.message), 'pyFAI Error');
    return
end

h.pyfaiOut    = out;
h.poniPaths   = poniPaths;

% --- Binning-Parameter aus GUI lesen ---
chiMin = str2double(get(h.trackChiRangeMinEdit, 'String'));
chiMax = str2double(get(h.trackChiRangeMaxEdit, 'String'));
trackChiBin     = max(1, round(str2double(get(h.trackChiBinEdit,     'String'))));
trackChiAvgBins = max(0, round(str2double(get(h.trackChiAvgBinsEdit, 'String'))));
smoothPts       = max(1, round(str2double(get(h.smoothPointsEdit,    'String'))));

baselineModeList = get(h.baselineModePopup, 'String');
baselineModeVal  = get(h.baselineModePopup, 'Value');
baselineMode     = baselineModeList{baselineModeVal};

opts = struct();
opts.profileChiRange = [chiMin chiMax];
opts.trackChiRange   = [chiMin chiMax];
opts.trackChiBin     = trackChiBin;
opts.trackChiAvgBins = trackChiAvgBins;
opts.smoothPoints    = smoothPts;
opts.baselineMode    = baselineMode;

% --- Binning ausführen ---
try
    B = pyfai_extract_binned_tracking_data(out, opts);
catch ME
    set(hObj, 'String', 'Load Gamma Data File', 'backg', col);
    errordlg(sprintf('Binning failed:\n%s', ME.message), 'Binning Error');
    return
end

h.B = B;

% ----------------------------------------------------------------
% Ab hier: Datenstruktur so befüllen wie bisher nach
% opengammafilecallback, damit fitpeakscallback unverändert läuft.
%
% Mapping:
%   B.radial              → dataX (2theta-Achse, als Column-Vektor)
%   B.track.rawProfiles   → IntensityProfiles [nRad x nTrack]
%   B.gamma_deg           → BinnedGamma
%
% Der bisherige Code hatte:
%   h.dataX{k}            = [nRad x 1] column vector (2theta)
%   h.IntensityProfiles{k}= [nRad x nBins] matrix
%   h.BinnedGamma{k}      = [1 x nBins] gamma-Werte
%
% Da pyFAI alle Bilder zu EINEM kombinierten Out zusammenführt,
% gibt es jetzt genau eine "Messung" (k=1).
% Bei mehreren alpha-Winkeln: ein Cell-Eintrag pro alpha.
% ----------------------------------------------------------------

% Eindeutige alpha-Werte bestimmen
[uniqueAlpha, ~, alphaIdx] = unique(h.alpha);
nAlpha = numel(uniqueAlpha);

% Für jedes einzigartige alpha einen Eintrag anlegen.
% Da pyFAI alle Bilder kombiniert hat, teilen wir die
% gamma/chi-Achse anhand der trackChiRange nicht weiter auf —
% alle alpha teilen sich dasselbe B.
% Hinweis: Wenn verschiedene alpha verschiedene chi-Bereiche
% abdecken, können hier separate pyFAI-Runs nötig sein.
% Für den häufigsten Fall (gleicher chi-Bereich, verschiedene alpha)
% ist ein gemeinsamer Run korrekt.

for k = 1:nAlpha
    h.dataX{k}             = B.radial(:);           % [nRad x 1]
    h.IntensityProfiles{k} = B.track.rawProfiles;   % [nRad x nTrack]
    h.BinnedGamma{k}       = B.gamma_deg(:)';       % [1 x nTrack]
end

h.dataXBackup         = h.dataX;
h.BinSize             = trackChiBin;   % für Kompatibilität

% dataXPlot / dataYPlot für Plot-Tab (alle alpha zusammen)
dataX_expanded = cell(1, nAlpha);
for i = 1:nAlpha
    nCols = size(h.IntensityProfiles{i}, 2);
    dataX_expanded{i} = repmat(h.dataX{i}, 1, nCols);
end
h.dataXPlot        = cell2mat(dataX_expanded);
h.dataXPlotBackup  = h.dataXPlot;
h.dataY            = h.IntensityProfiles;
h.dataYPlot        = cell2mat(h.IntensityProfiles);
h.dataYPlotBackup  = h.dataYPlot;

% --- Slider aktualisieren ---
totalProfiles = nAlpha * size(h.IntensityProfiles{1}, 2);
set(h.Slider, 'Min', 1);
set(h.Slider, 'Max', max(totalProfiles, 2));
step = 1 / max(totalProfiles - 1, 1);
set(h.Slider, 'SliderStep', [step step]);
set(h.Slider, 'Value', 1);

% --- Plot erstes Profil ---
set(h.plotIntensityData, 'XData', h.dataXPlot(:,1));
set(h.plotIntensityData, 'YData', h.dataYPlot(:,1));
set(h.plotIntensityData, 'Visible', 'on');
set(h.axesPlotIntensityData, 'XLimMode', 'auto');

% --- Theoretische Peaks einzeichnen (wie bisher) ---
if isfield(h, 'PeaksTheo')
    for k = 1:size(h.PeaksTheo, 2)
        PeakPostmp = h.PeaksTheo{k}.Peaks(:, 5:6);
        PeakPostmp = mean(PeakPostmp, 2)';

        idx = (PeakPostmp >= round(min(h.dataX{1}))) & ...
              (PeakPostmp <= round(max(h.dataX{1})));

        PeakPos{k} = PeakPostmp(idx);

        hkl{k} = h.PeaksTheo{k}.Peaks(idx, 1:3);
        for i = 1:size(hkl{k}, 1)
            rowsAsStrings{k}{i} = strtrim(sprintf('%g %g %g', hkl{k}(i,:)));
        end
        hkltabledata{k} = [hkl{k} PeakPos{k}' ...
            zeros(length(PeakPos{k}), 1) ...
            zeros(length(PeakPos{k}), 1)];
    end

    h.PeakPos        = PeakPos;
    h.rowsAsStrings  = rowsAsStrings;

    if isfield(h, 'plotpeakstheo')
        delete(h.plotpeakstheo);
    end
    h.plotpeakstheo = xline(h.axesPlotIntensityData, ...
        PeakPos{1}, '--r', rowsAsStrings{1}, ...
        'LabelVerticalAlignment', 'middle', ...
        'LabelHorizontalAlignment', 'left');

    set(h.dekdataGaKalpha, 'data', hkltabledata{1});
    set(h.dekdataInKalpha, 'data', hkltabledata{2});
    set(h.dekdataInKbeta,  'data', hkltabledata{3});
end

% Button zurücksetzen
set(hObj, 'String', 'Load Gamma Data File', 'backg', col);

assignin('base', 'h',    h);
assignin('base', 'B',    B);
assignin('base', 'out',  out);

% Check if DEC data exists for the mpd file in use
MatName = h.Sample.Materials.Name;
FileName = ['DEKListe',MatName,'.mat'];
Path = fullfile('Data','Materials\');
if exist([Path,FileName], 'file')
    DEKMatFile = load([Path,FileName]);

    DEKdatatmp{1} = get(h.dekdataGaKalpha,'data');
    DEKdatatmp{2} = get(h.dekdataInKalpha,'data');
    DEKdatatmp{3} = get(h.dekdataInKbeta,'data');
    
    for m = 1:size(DEKdatatmp,2)
        hklDEKtmp = zeros();
        % Convert hkl from DEKtable to string
        for k = 1:length(DEKdatatmp{m}(:,1))
            hklDEKtmp(k) = DEKdatatmp{m}(k,1)*100 + DEKdatatmp{m}(k,2)*10 + DEKdatatmp{m}(k,3);
        end
        % Transpose vector
        hklDEKtmp = hklDEKtmp';
        IndexHittmp = cell(size(DEKMatFile.DEK,1),length(hklDEKtmp));
        % Compare hkl from DEKTable with DEK from file
        for l = 1:length(hklDEKtmp)
            for k = 1:size(DEKMatFile.DEK,1)
                    IndexHittmp{k,l} = strcmp(num2str(hklDEKtmp(l,1)),num2str(DEKMatFile.DEK(k,1)));
            end
        end
        % Convert cell array and create vector
        IndexHittmp = cell2mat(IndexHittmp);
        % Add DEK values to PeaksTmp, if Index returns empty cell, add
        % zeros. In this case, the User has to enter the DEK manually
        for k = 1:size(DEKdatatmp{m},1)
            if isempty(DEKMatFile.DEK(IndexHittmp(:,k),2:3))
                DEKdatatmp{m}(k,5:6) = [0 0];
            else
                DEKdatatmp{m}(k,5:6) = DEKMatFile.DEK(IndexHittmp(:,k),2:3);
            end
        end 
    end
    set(h.dekdataGaKalpha,'data',DEKdatatmp{1})
    set(h.dekdataInKalpha,'data',DEKdatatmp{2})
    set(h.dekdataInKbeta,'data',DEKdatatmp{3})

    UserMessage = sprintf('DEC data for MPD-file in use was found and loaded. Check if data is correct.\n%s', '.');
    uiwait(msgbox(UserMessage));
else
    warningMessage = sprintf('Warning: no DEC data found for this MPD file. Define manually or create new DEC data file.\n%s', '.');
    uiwait(msgbox(warningMessage,"Warning",'error'));
end

guidata(hObj, h);

function plotallprofilescallback(hObj,~)
% Callback for "pop up menu" in create sample panel
h = guidata(hObj);
% Determine the selected data set.
val = get(hObj, 'Value');

value = get(h.Slider,'value');
% assignin('base','h1',h)
if val == 1
    % ydata = h.dataY{:};
    % xdata = repmat(h.dataX{:},1,49);
    delete(h.plotIntensityData);
    h.plotIntensityData = plot(h.axesPlotIntensityData,h.dataXPlot,h.dataYPlot,'-','Color','blue','Visible','on');
    % set(h.plotIntensityData,'Xdata',h.dataXPlot)
    % set(h.plotIntensityData,'Ydata',h.dataYPlot)
elseif val == 0
    delete(h.plotIntensityData);
    h.plotIntensityData = plot(h.axesPlotIntensityData,h.dataXPlot(:,value),h.dataYPlot(:,value),'-','Color','blue','Visible','on');
    % set(h.plotIntensityData,'Xdata',h.dataXPlot(:,value))
    % set(h.plotIntensityData,'Ydata',h.dataYPlot(:,value))
end

guidata(hObj,h);

function changetwothetarangecallback(hObj,~)
h = guidata(hObj);

value = get(h.Slider,'value');

twothetamin = str2double(get(h.twothetaminEditField,'String'));
twothetamax = str2double(get(h.twothetamaxEditField,'String'));

% --- Eingabe validieren ---
if isnan(twothetamin) || isnan(twothetamax)
    errordlg('Bitte gültige Zahlenwerte für den 2theta-Bereich eingeben.','Eingabefehler');
    return
end
if twothetamin >= twothetamax
    errordlg('2theta min muss kleiner als 2theta max sein.','Eingabefehler');
    return
end

dataXBackup = h.dataXBackup;

idxtwothetamin = Tools.Data.DataSetOperations.FindNearestIndex(dataXBackup{1}, twothetamin);
idxtwothetamax = Tools.Data.DataSetOperations.FindNearestIndex(dataXBackup{1}, twothetamax);

h.idxtwothetamin = idxtwothetamin;
h.idxtwothetamax = idxtwothetamax;

dataXplotmod = h.dataXPlotBackup(idxtwothetamin:idxtwothetamax,:);
dataYplotmod = h.dataYPlotBackup(idxtwothetamin:idxtwothetamax,:);

dataXmod = cellfun(@(x) x(idxtwothetamin:idxtwothetamax,:), h.dataXBackup,       'UniformOutput', false);
dataYmod = cellfun(@(x) x(idxtwothetamin:idxtwothetamax,:), h.IntensityProfiles,  'UniformOutput', false);

h.dataX     = dataXmod;
h.dataXPlot = dataXplotmod;
h.dataY     = dataYmod;
h.dataYPlot = dataYplotmod;

delete(h.plotIntensityData);

if get(h.checkboxplotall,'value') == 1
    h.plotIntensityData = plot(h.axesPlotIntensityData, dataXplotmod, dataYplotmod, '-', 'Color','blue','Visible','on');
else
    h.plotIntensityData = plot(h.axesPlotIntensityData, dataXplotmod(:,value), dataYplotmod(:,value), '-', 'Color','blue','Visible','on');
end

h.axesPlotIntensityData.XLim = [twothetamin twothetamax];

% -------------------------------------------------------
% BUG FIX: vorher war hier immer h.PeaksTheo{1} statt
% h.PeaksTheo{k} — dadurch wurden bei In K-alpha und
% In K-beta immer die falschen Peakpositionen angezeigt
% -------------------------------------------------------
for k = 1:size(h.PeaksTheo,2)
    PeakPostmp = h.PeaksTheo{k}.Peaks(:,5:6);   % <-- {k} statt {1}
    PeakPostmp = mean(PeakPostmp,2)';

    idx = (PeakPostmp >= round(min(h.dataX{1}))) & ...
          (PeakPostmp <= round(max(h.dataX{1})));

    PeakPos{k}       = PeakPostmp(idx);
    rowsAsStrings{k} = h.rowsAsStrings{k}(idx);
end

% Aktualisierte Werte in h speichern damit Slider-Callbacks
% ebenfalls die korrekten Positionen verwenden
h.PeakPos       = PeakPos;
h.rowsAsStrings = rowsAsStrings;

delete(h.plotpeakstheo)

selectedWavelength = get(h.radiobuttonwavelength.SelectedObject,'String');

if strcmp(selectedWavelength,'Ga K-alpha')
    h.plotpeakstheo = xline(h.axesPlotIntensityData, PeakPos{1}, '--r', rowsAsStrings{1}, ...
        'LabelVerticalAlignment','middle','LabelHorizontalAlignment','left');
elseif strcmp(selectedWavelength,'In K-alpha')
    h.plotpeakstheo = xline(h.axesPlotIntensityData, PeakPos{2}, '--r', rowsAsStrings{2}, ...
        'LabelVerticalAlignment','middle','LabelHorizontalAlignment','left');
elseif strcmp(selectedWavelength,'In K-beta')
    h.plotpeakstheo = xline(h.axesPlotIntensityData, PeakPos{3}, '--r', rowsAsStrings{3}, ...
        'LabelVerticalAlignment','middle','LabelHorizontalAlignment','left');
end

guidata(hObj, h);

function searchpeakscallback(hObj, ~)
h = guidata(hObj);

value = get(h.Slider,'Value');

minProm = str2double(get(h.PeakProminenceEditField,'String'));
window = str2double(get(h.PeakWindowEditField,'String'));
minHeight = str2double(get(h.PeakMinHeightEditField,"String"));

dataX = h.dataX;
dataY = h.dataY;

for k = 1:size(dataY,2)
    results = findPeaksFromStartValuesMatrix1(dataX{k}, movmean(movmean(dataY{k}, 7), 7), h.UserPeaks, minHeight, minProm, window);

    [nRows, nCols] = size(results);
    for r = 1:nRows
        for c = 1:nCols
            if isempty(results(r,c).peakX)
                results(r,c).peakX = NaN;
            end
            if isempty(results(r,c).peakY)
                results(r,c).peakY = NaN;
            end
            if isempty(results(r,c).index)
                results(r,c).index = NaN;
            end
        end
    end

    results_tmp{k} = results;
end

h.results = results_tmp;

% figure;
% for c = 1:size(dataY{1},2)
%     subplot(size(dataY{1},2),1,c);
%     plot(dataX{1}(:,1), dataY{1}(:,c)); hold on;
%     px = [results(c,:).peakX];
%     py = [results(c,:).peakY];
%     plot(px, py, 'ro', 'MarkerSize', 8, 'LineWidth', 2);
%     title(sprintf('Signal Spalte %d', c));
% end


% Get peak locations and peak amplitudes
for k = 1:size(h.results,2)
    [M, nPeaks] = size(h.results{k});
    peakXCell{k} = cell(M,1);
    peakYCell{k} = cell(M,1);

    for c = 1:M
        xVals = [];
        yVals = [];
        for p = 1:nPeaks
            R = h.results{k}(c,p);
            if ~isnan(R.peakX) && ~isnan(R.peakY)
                xVals(end+1) = R.peakX; %#ok<AGROW>
                yVals(end+1) = R.peakY; %#ok<AGROW>
            end
        end

        % Sortieren nach Peakposition
        [xSorted, sortIdx] = sort(xVals);
        ySorted = yVals(sortIdx);

        peakXCell{k}{c} = xSorted(:);
        peakYCell{k}{c} = ySorted(:);
    end
end

h.Locations = peakXCell;
h.Amplitude = peakYCell;

h.LocationsPlot = vertcat(h.Locations{:});
h.AmplitudePlot = vertcat(h.Amplitude{:});

h.plotpeaklocations = plot(h.axesPlotIntensityData,h.LocationsPlot{value},h.AmplitudePlot{value},'s','Color','r','MarkerFaceColor','r');

% Check how many peaks where found for each defined peak position
for k = 1:size(h.results,2)
    PeakX = arrayfun(@(s) s.peakX, h.results{k});
    countNonNaN{k} = sum(~isnan(PeakX), 1);
end

UserPeaksdata = get(h.tableUserDefinedPeaks,'data');

UserPeaksdataTable = repmat(UserPeaksdata(:,1),size(h.results,2),1);

% PeakCountData = join(string(cell2mat(cellfun(@(x) x(:), countNonNaN, 'UniformOutput', false))), ",", 2);

UserPeaksdatanew = [num2cell(UserPeaksdataTable), num2cell([countNonNaN{:}]'), num2cell(logical(ones(length(UserPeaksdataTable),1)))];
% UserPeaksdatanew = [UserPeaksdata(:,1), countNonNaN{1}', ones(length(UserPeaksdata(:,1)),1)];

set(h.tableUserDefinedPeaks,'data',UserPeaksdatanew);

assignin('base','h',h)

guidata(hObj, h);

function loadDECdatacallback(hObj, ~)
h = guidata(hObj);

[baseFileName, folder] = uigetfile('*.mat','Load DEK data',[General.ProgramInfo.Path,'/Data/Materials/']);

% If user pressed cancel, abort saving process
if baseFileName == 0
  % user pressed cancel
  return
end

% Load user selected data
DEKDataFileName = fullfile(folder, baseFileName);
DEKdata = load(DEKDataFileName);

if strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'Ga K-alpha')
    DEKdatatmp = get(h.dekdataGaKalpha,"data");
elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-alpha')
    DEKdatatmp = get(h.dekdataInKalpha,"data");
elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-beta')
    DEKdatatmp = get(h.dekdataInKbeta,"data");
end
% DEKdatatmp = get(h.dekdata,'data');
% assignin('base','DEKdatatmp',DEKdatatmp)
hklDEKtmp = zeros(1,length(DEKdatatmp(:,1)));
% Get hkl that were fitted
for k = 1:length(DEKdatatmp(:,1))
    if length(num2str(DEKdatatmp(k,1:3))) > 7
        hklDEKtmp(k) = DEKdatatmp(k,1)*1000 + DEKdatatmp(k,2)*100 + DEKdatatmp(k,3);
    else
        hklDEKtmp(k) = DEKdatatmp(k,1)*100 + DEKdatatmp(k,2)*10 + DEKdatatmp(k,3);
    end
end
% assignin('base','hklDEKtmp',hklDEKtmp)
hklDEKtmp = hklDEKtmp';
a = cell(size(DEKdata.DEK,1),length(hklDEKtmp));
% Find matches between fitted hkl and hkl in data file
for l = 1:length(hklDEKtmp)
    for k = 1:size(DEKdata.DEK,1)
		a{k,l} = strcmp(num2str(hklDEKtmp(l,1)),num2str(DEKdata.DEK(k,1)));
    end
end

IndexHittmp = cell2mat(a);
% If fitted hkl matches hkl from DEK data, add DEK or add zeros, which the 
% user has to change manually 
for k = 1:size(DEKdatatmp,1)
    if isempty(DEKdata.DEK(IndexHittmp(:,k),2:3))
        DEKdatatmp(k,5:6) = [0 0];
    else
        DEKdatatmp(k,5:6) = DEKdata.DEK(IndexHittmp(:,k),2:3);
    end
end

set(h.dekdata,'data', DEKdatatmp)

guidata(hObj, h);

function fitpeakscallback(hObj, ~)
h = guidata(hObj);

col = get(hObj,'backg');
set(hObj,'String','Fitting peaks ...','backg',[1 .6 .6])
pause(.01)

UserPeaksdata = get(h.tableUserDefinedPeaks,'data');
assignin('base','UserPeaksdata',UserPeaksdata)

UserSelectedPeaks = reshape(logical(cell2mat(UserPeaksdata(:,3))), ...
    length(UserPeaksdata(:,3))/size(h.results,2),[]);

for k = 1:size(h.results,2)
    PeakX = arrayfun(@(s) s.peakX, h.results{k});
    PeakY = arrayfun(@(s) s.peakY, h.results{k});
    
    MX = PeakX(:,UserSelectedPeaks(:,k));
    PeaksXCorr = arrayfun(@(i) MX(i, ~isnan(MX(i,:))), 1:size(MX,1), 'UniformOutput', false);
    PeaksXCorr = PeaksXCorr(:);
    
    MY = PeakY(:,UserSelectedPeaks(:,k));
    PeaksYCorr = arrayfun(@(i) MY(i, ~isnan(MY(i,:))), 1:size(MY,1), 'UniformOutput', false);
    PeaksYCorr = PeaksYCorr(:);
    
    h.Locations{k} = PeaksXCorr;
    h.Amplitude{k} = PeaksYCorr;
    h.UserPeaksCorr{k} = h.UserPeaks(logical(UserSelectedPeaks(:,k)));
end

dataX = h.dataX;
dataY = h.dataY;

idxempty = cellfun(@(v) cellfun(@isempty, v), h.Locations, 'UniformOutput', false);
h.idxempty = idxempty;

for k = 1:size(idxempty,2)
    dataY{k}(:,idxempty{k}) = [];
    PeakPosStarttmp{k} = h.Locations{k}(~idxempty{k});
    AmplitudeStarttmp{k} = h.Amplitude{k}(~idxempty{k});
end

% ----------------------------------------------------------------
% NEU: BinnedGamma aus h.BinnedGamma (direkt von pyFAI/opengamma)
% statt CalcBinnedGamma(h.gamma, h.BinSize, h.ImageInfo.Height)
% ----------------------------------------------------------------
for k = 1:size(h.BinnedGamma, 2)
    BinnedGamma{k} = h.BinnedGamma{k};
end

h.BinnedGamma = BinnedGamma;

for k = 1:size(idxempty,2)
    BinnedGammatmp = BinnedGamma{k};
    BinnedGammatmp(idxempty{k}) = [];
    h.BinnedGammaFinal{k} = BinnedGammatmp;
end

% Fitting routine
fitrangepixel = 30;

pVoigtEqn = @(p, xdata) p(1) .* ( ...
    p(4) .* (1 ./ (1 + ((xdata - p(2))./(p(3)/2)).^2)) + ...
    (1 - p(4)) .* exp(-log(2) .* ((xdata - p(2))./(p(3)/2)).^2) ...
    );
h.gaussEqnFirst = pVoigtEqn;

for m = 1:size(dataY,2)

    PeakPosFiltered = h.UserPeaksCorr{m};
    h.PeakPosFiltered = h.UserPeaksCorr{m};

    fitresult = cell(size(dataY{m},2), length(PeakPosFiltered));
    gof       = cell(size(dataY{m},2), length(PeakPosFiltered));
    out_cell  = cell(size(dataY{m},2), length(PeakPosFiltered));
    PeakLocs  = zeros(size(dataY{m},2), length(PeakPosFiltered));
    PeakAmp   = zeros(size(dataY{m},2), length(PeakPosFiltered));
    PeakFWHM  = zeros(size(dataY{m},2), length(PeakPosFiltered));
    PeakEta   = zeros(size(dataY{m},2), length(PeakPosFiltered));
    StdError  = zeros(size(dataY{m},2), length(PeakPosFiltered));

    for l = 1:size(dataY{m},2)

        idxPeakPos   = ismembertol(PeakPosStarttmp{m}{l}, PeakPosFiltered, 0.015);
        PeakPosStart = PeakPosStarttmp{m}{l}(idxPeakPos);
        AmplitudeStart = AmplitudeStarttmp{m}{l}(idxPeakPos);
        WidthsStart  = 0.15;
        h.PeakPosStarttmp{l} = PeakPosStart;

        assignin('base','PeakPosStart',PeakPosStart)
        assignin('base','PeakPosFiltered',h.PeakPosFiltered)

        for k = 1:length(PeakPosStart)

            idxChannel_tmp = find(ismembertol(dataX{m}, PeakPosStart(k), 0.0005) == 1);
            idxChannel = idxChannel_tmp(1);

            if idxChannel <= fitrangepixel
                idxChannel = fitrangepixel + 5;
            end

            if idxChannel + fitrangepixel > length(dataX{m})
                X = dataX{m}((idxChannel-fitrangepixel):(length(dataX{m})));
                Y = dataY{m}((idxChannel-fitrangepixel):(length(dataX{m})), l);
            else
                X = dataX{m}((idxChannel-fitrangepixel):(idxChannel+fitrangepixel));
                Y = dataY{m}((idxChannel-fitrangepixel):(idxChannel+fitrangepixel), l);
            end

            Xleft  = X(2:6);
            Xright = X(end-6:end-1);
            idxleftmeantol  = ismembertol(Y(2:6),    mean(Y(2:6)),    0.1);
            idxrightmeantol = ismembertol(Y(end-6:end-1), mean(Y(end-6:end-1)), 0.1);

            if isempty(idxleftmeantol)  || all(idxleftmeantol==0),  idxleftmeantol  = logical([0 1]); end
            if isempty(idxrightmeantol) || all(idxrightmeantol==0), idxrightmeantol = logical([0 1]); end

            PeakRegions{1} = [Xleft(find(idxleftmeantol, 1,'first')); ...
                              Xright(find(idxrightmeantol,1,'first'))];
            SmootStepSize   = 5;
            SmootFilterWidth = 0.2;

            [~, Y_smoothed] = Tools.Data.Filtering.MinMaxLineMean(X, Y, ...
                SmootFilterWidth, SmootStepSize);

            PeakRegionsNew = [Tools.Data.DataSetOperations.FindNearestIndex(X, PeakRegions{1}(1,:)); ...
                              Tools.Data.DataSetOperations.FindNearestIndex(X, PeakRegions{1}(2,:))];
            PeakRegionsNew = Tools.LogicalRegions(PeakRegionsNew, length(X));

            [Xcorr, Ycorr, YBkg] = Tools.Data.Fitting.BackgroundReduction(X, Y, ...
                PeakRegionsNew, Y_smoothed);

            idxSort = find(ismembertol(h.PeakPosFiltered, PeakPosStart(k), 0.018), 1);
            h.idxSort{l}(k)       = idxSort;
            h.dataXcorr{m}{l,idxSort} = Xcorr;
            h.dataYcorr{m}{l,idxSort} = Ycorr;
            h.YBkg{m}{l,idxSort}      = YBkg;

            p0_pV = [AmplitudeStart(k), PeakPosStart(k), WidthsStart, 0.5];
            lb_pV = [0,   PeakPosStart(k)-2, 1e-6, 0];
            ub_pV = [Inf, PeakPosStart(k)+2, 3,    1];

            opts_pV = optimoptions('lsqcurvefit', ...
                'Display',                'off', ...
                'MaxFunctionEvaluations', 5000, ...
                'FunctionTolerance',      1e-10);

            try
                [fitresult{l,idxSort},~,residual{l,idxSort},~,~,~,jacobian{l,idxSort}] = ...
                    lsqcurvefit(pVoigtEqn, p0_pV, Xcorr, Ycorr, lb_pV, ub_pV, opts_pV);

                [~,R]     = qr(jacobian{l,idxSort}, 0);
                Rinv      = R \ eye(size(R));
                diag_info = sum(Rinv.*Rinv, 2);
                n_res     = length(residual{l,idxSort});
                p_res     = numel(fitresult{l,idxSort});
                rmse      = norm(residual{l,idxSort}) / sqrt(n_res - p_res);
                SE        = sqrt(diag_info) * rmse;

                StdError(l,idxSort) = SE(2);
                PeakLocs(l,idxSort) = fitresult{l,idxSort}(2);
                PeakAmp(l,idxSort)  = fitresult{l,idxSort}(1);
                PeakFWHM(l,idxSort) = fitresult{l,idxSort}(3);
                PeakEta(l,idxSort)  = fitresult{l,idxSort}(4);

            catch ME
                warning('[Peak-Fit] Bin %d, Peak %d fehlgeschlagen: %s', l, k, ME.message);
                fitresult{l,idxSort} = [];
                StdError(l,idxSort)  = NaN;
                PeakLocs(l,idxSort)  = NaN;
                PeakAmp(l,idxSort)   = NaN;
                PeakFWHM(l,idxSort)  = NaN;
                PeakEta(l,idxSort)   = NaN;
            end
        end
    end

    nanMask = isnan(PeakLocs) | isnan(StdError);
    if any(nanMask(:))
        warning('[fitpeakscallback] %d Peak-Fit(s) fehlgeschlagen.', sum(nanMask(:)));
    end
    PeakLocs(nanMask) = 0;  PeakAmp(nanMask)  = 0;
    PeakFWHM(nanMask) = 0;  PeakEta(nanMask)  = 0;
    StdError(nanMask) = 0;

    fitresultexport{m} = fitresult;

    % ----------------------------------------------------------------
    % NEU: BinnedGamma direkt aus h.BinnedGammaFinal —
    % kein h.thetafit / CalcBinnedGamma mehr nötig
    % ----------------------------------------------------------------
    BinnedGamma_m = h.BinnedGammaFinal{m}';

    BinnedGammaSortMat = repmat(BinnedGamma_m, 1, length(PeakPosFiltered));

    FittedPeakPosSortMat    = zeros(size(dataY{m},2), length(PeakPosFiltered));
    FittedPeakPosErrSortMat = zeros(size(dataY{m},2), length(PeakPosFiltered));
    FittedPeakAmpSortMat    = zeros(size(dataY{m},2), length(PeakPosFiltered));
    FittedPeakWidthSortMat  = zeros(size(dataY{m},2), length(PeakPosFiltered));
    FittedPeakEtaSortMat    = zeros(size(dataY{m},2), length(PeakPosFiltered));

    for k = 1:size(PeakLocs,2)
        for l = 1:length(PeakPosFiltered)
            idx = find(ismembertol(PeakLocs(:,k), PeakPosFiltered(l), 0.03));
            if ~isempty(idx)
                FittedPeakPosSortMat(idx,l)    = PeakLocs(idx,k);
                FittedPeakPosErrSortMat(idx,l) = StdError(idx,k);
                FittedPeakAmpSortMat(idx,l)    = PeakAmp(idx,k);
                FittedPeakWidthSortMat(idx,l)  = PeakFWHM(idx,k);
                FittedPeakEtaSortMat(idx,l)    = PeakEta(idx,k);
            end
        end
    end

    FitDatatmp = [BinnedGammaSortMat(:)+90 FittedPeakPosSortMat(:) ...
                  FittedPeakPosErrSortMat(:) FittedPeakAmpSortMat(:) ...
                  FittedPeakWidthSortMat(:)  FittedPeakEtaSortMat(:)];

    nCols   = size(FitDatatmp, 2);
    nRows   = size(FitDatatmp, 1) / length(PeakPosFiltered);
    FitData = mat2cell(FitDatatmp, nRows * ones(1, length(PeakPosFiltered)), nCols);

    h.FitDataRaw{m} = FitData;
end

% Alpha-Wert zu FitDataRaw hinzufügen
% NEU: h.alpha(k) — k läuft über nAlpha, nicht über Bilder
% Im neuen Workflow gibt es genau nAlpha Einträge in h.FitDataRaw
for k = 1:size(h.FitDataRaw,2)
    for l = 1:size(h.FitDataRaw{k},1)
        h.FitDataRaw{k}{l} = horzcat( ...
            h.FitDataRaw{k}{l}, ...
            repmat(h.alpha(min(k,numel(h.alpha))), size(h.FitDataRaw{k}{l},1), 1), ...
            (1:size(h.FitDataRaw{k}{l},1))');
    end
end

assignin('base','FitDataRaw',h.FitDataRaw)

FitDataModtmp = cat(1, h.FitDataRaw{:});
FitDataMod    = FitDataModtmp(~cellfun('isempty', FitDataModtmp));
h.FitDataModBkp = FitDataMod;

% Umsortieren fitresultexport
N = numel(fitresultexport);
K = size(fitresultexport{1}, 2);
fitresultexportmod_tmp = cell(1, N*K);
idx = 1;
for i = 1:N
    for j = 1:size(fitresultexport{i},2)
        fitresultexportmod_tmp{idx} = fitresultexport{i}(:, j);
        idx = idx + 1;
    end
end

[val,~,idxalpha] = unique(h.alpha);

if length(val) ~= length(idxalpha)
    fitresultexportmod = reshape(fitresultexportmod_tmp, size(fitresultexportmod_tmp,2)/2, []);
    fitresultexportmod = fitresultexportmod';
    h.fitresultexport  = cellfun(@(a,b) [a; b], ...
        fitresultexportmod(1,:), fitresultexportmod(2,:), 'UniformOutput', false);
else
    h.fitresultexport = fitresultexportmod_tmp;
end

% Umsortieren dataXcorr
N = numel(h.dataXcorr);
dataXcorr_tmp = cell(1, N * size(h.dataXcorr{1},2));
idx = 1;
for i = 1:N
    for j = 1:size(h.dataXcorr{i},2)
        dataXcorr_tmp{idx} = h.dataXcorr{i}(:, j);
        idx = idx + 1;
    end
end
if length(val) ~= length(idxalpha)
    dataXcorrtmod = reshape(dataXcorr_tmp, size(dataXcorr_tmp,2)/2, [])';
    h.dataXcorr   = cellfun(@(a,b) [a; b], dataXcorrtmod(1,:), dataXcorrtmod(2,:), 'UniformOutput', false);
else
    h.dataXcorr = dataXcorr_tmp;
end

% Umsortieren dataYcorr
N = numel(h.dataYcorr);
dataYcorr_tmp = cell(1, N * size(h.dataYcorr{1},2));
idx = 1;
for i = 1:N
    for j = 1:size(h.dataYcorr{i},2)
        dataYcorr_tmp{idx} = h.dataYcorr{i}(:, j);
        idx = idx + 1;
    end
end
if length(val) ~= length(idxalpha)
    dataYcorrtmod = reshape(dataYcorr_tmp, size(dataYcorr_tmp,2)/2, [])';
    h.dataYcorr   = cellfun(@(a,b) [a; b], dataYcorrtmod(1,:), dataYcorrtmod(2,:), 'UniformOutput', false);
else
    h.dataYcorr = dataYcorr_tmp;
end

% Merge bei mehreren Detektorpositionen
if length(val) ~= length(idxalpha)
    col1 = cell2mat(UserPeaksdata(:,1));
    [~, ~, peakIdx] = unique(col1);
    pos = accumarray(peakIdx, (1:numel(col1))', [], @(x){x});

    MergedFitData = cell(numel(pos), 1);
    for i = 1:numel(pos)
        idxPeak = pos{i};
        tmp = cell(numel(idxPeak), 1);
        for k = 1:numel(idxPeak)
            n = size(FitDataMod{idxPeak(k)}, 1);
            tmp{k} = [FitDataMod{idxPeak(k)}, idxPeak(k)*ones(n,1)];
        end
        MergedFitData{i} = vertcat(tmp{:});
    end

    NewFitData = cell(0);
    for l = 1:size(MergedFitData,1)
        A = MergedFitData{l};
        uniqueAlpha = unique(A(:,7));
        for k = 1:numel(uniqueAlpha)
            NewFitData_tmp = A(A(:,7) == uniqueAlpha(k), :);
            NewFitData{k,l} = sortrows(NewFitData_tmp, 1);
        end
    end

    FitDataModMerged = NewFitData.';
    FitDataModMerged = FitDataModMerged(:);
    % FitDataMod       = FitDataModMerged;
    h.FitDataMod     = FitDataModMerged;
else
    h.FitDataMod = FitDataMod;
end

% Nullzeilen entfernen
for k = 1:size(h.FitDataMod,1)
    idxDel = (h.FitDataMod{k}(:,2) == 0) & (h.FitDataMod{k}(:,4) == 0);
    if any(idxDel)
        h.fitresultexport{k}(idxDel) = {[]};
        h.fitresultexport{k}(cellfun(@isempty, h.fitresultexport{k})) = [];
        h.FitDataMod{k}(idxDel,:) = [];
    end
end

% DEK Tabelle auslesen
if strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'Ga K-alpha')
    DEK = get(h.dekdataGaKalpha,"data");
elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-alpha')
    DEK = get(h.dekdataInKalpha,"data");
else
    DEK = get(h.dekdataInKbeta,"data");
end

PeakPosData = cell2mat(cellfun(@(x) mean(x,1), h.FitDataMod, 'UniformOutput', false));

if size(PeakPosData,2) < 2
    errordlg('FitDataMod hat unerwartetes Format.','Fehler');
    set(hObj,'String','Start Peak Fit','backg',col)
    return
end

Peaks     = PeakPosData(:,2);
PeaksTheo = DEK(:,4);

for k = 1:length(PeaksTheo)
    idxPeakHit(:,k) = ismembertol(Peaks, PeaksTheo(k), 0.02);
end

DEKdataMatchedPeaks = zeros(size(PeakPosData,1), 6);
for k = 1:length(PeaksTheo)
    DEKdataMatchedPeaks = DEKdataMatchedPeaks + idxPeakHit(:,k) .* DEK(k,:);
end
DEKdataMatchedPeaks(:,7) = PeakPosData(:,6);
h.DEKdataMatchedPeaks = DEKdataMatchedPeaks;

set(h.tableDECFittedPeaks,'Data', ...
    [Peaks DEKdataMatchedPeaks(:,4) DEKdataMatchedPeaks(:,1:3) DEKdataMatchedPeaks(:,5:7)])

% Slider setzen
if size(h.FitDataMod,1) == 1
    set(h.Slider,'Min',0,'Max',1,'SliderStep',[1 1],'Value',1);
else
    set(h.Slider,'Max',size(h.FitDataMod,1));
    set(h.Slider,'SliderStep',[1/(size(h.FitDataMod,1)-1) 1/(size(h.FitDataMod,1)-1)]);
    set(h.Slider,'Value',1);
end

% Plotdata setzen
SliderValue = 1;
if length(val) ~= length(idxalpha)
    set(h.plotdata,'Xdata',h.FitDataMod{1}(:,1),'Ydata',h.FitDataMod{1}(:,2), ...
        'YNegativeDelta',h.FitDataMod{1}(:,3),'YPositiveDelta',h.FitDataMod{1}(:,3),'Visible','on')

    group   = h.FitDataMod{1}(:,8);
    classes = unique(group);
    idx1    = group == classes(1);
    h.plotdata1 = errorbar(h.axes, h.FitDataMod{1}(idx1,1), h.FitDataMod{1}(idx1,2), ...
        h.FitDataMod{1}(idx1,3),'s','Color','b');

    if length(classes) >= 2
        idx2 = group == classes(2);
        h.plotdata2 = errorbar(h.axes, h.FitDataMod{1}(idx2,1), h.FitDataMod{1}(idx2,2), ...
            h.FitDataMod{1}(idx2,3),'s','Color','r');
    else
        h.plotdata2 = errorbar(h.axes, NaN, NaN, NaN, 's','Color','r','Visible','off');
    end
else
    set(h.plotdata,'Xdata',h.FitDataMod{1}(:,1),'Ydata',h.FitDataMod{1}(:,2), ...
        'YNegativeDelta',h.FitDataMod{1}(:,3),'YPositiveDelta',h.FitDataMod{1}(:,3),'Visible','on')
end

nPoints = size(h.FitDataMod{1}, 1);
set(h.SliderFittedPeaks, 'Max', max(nPoints,2));
set(h.SliderFittedPeaks, 'SliderStep', [1/max(nPoints-1,1) 1/max(nPoints-1,1)]);
set(h.SliderFittedPeaks, 'Value', 1);

% Ersten Peak-Fit plotten
fitresultexportmod = h.fitresultexport{SliderValue};
fitresultexportmod(cellfun(@isempty, fitresultexportmod)) = [];
dataXcorrmod = h.dataXcorr{SliderValue};
dataXcorrmod(cellfun(@isempty, dataXcorrmod)) = [];
dataYcorrmod = h.dataYcorr{SliderValue};
dataYcorrmod(cellfun(@isempty, dataYcorrmod)) = [];

yPeakCalc = feval(h.gaussEqnFirst, fitresultexportmod{SliderValue}, dataXcorrmod{SliderValue});

set(h.plotRawData,'Xdata',dataXcorrmod{SliderValue},'Ydata',dataYcorrmod{SliderValue},'Visible','on')
set(h.plotFitData,'Xdata',dataXcorrmod{SliderValue},'Ydata',yPeakCalc,'Visible','on')

set(hObj,'String','Start Peak Fit','backg',col)
h.plottab.SelectedTab = h.plottab1;
h.axes.YLabel.String  = ['2',char(952),' [°]'];

assignin('base','h',h)
guidata(hObj, h);

function SliderCallbackPlotRawData(hObj, ~)
% This callback handles the changes when the slider button is pushed.
h = guidata(hObj);
% Get slider value
% value = get(hObj, 'Value');
% value = round(value);

try
    value = get(hObj, 'Value');
    value = round(value);

    % Slider-Wert gegen verfügbare Daten absichern
    if strcmp(h.plottab.SelectedTab.Title,'Stress factor method')
        maxAllowed = size(h.FitDataMod, 1);
    elseif strcmp(h.plottab.SelectedTab.Title,'sin²psi method')
        maxAllowed = size(h.FitDataMod, 1);
    else
        maxAllowed = size(h.IntensityProfiles,2) * size(h.IntensityProfiles{1},2);
    end
    
    if value > maxAllowed
        value = 1;
        set(hObj, 'Value', 1);
    end

    % Grenzen prüfen
    maxVal = get(hObj, 'Max');
    if value < 1 || value > maxVal
        warning('Slider:invalidValue', ...
            '[Slider] Ungültiger Wert %d (Max: %d), setze auf 1.', value, maxVal);
        value = 1;
        set(hObj, 'Value', 1);
    end

catch ME
    warning('Slider:generalError', '[Slider] Fehler: %s', ME.message);
    return
end

assignin('base','hexport',h)
% DEK = get(h.dekdata,"data");
[val,~,idxalpha] = unique(h.alpha);

if strcmp(h.plottab.SelectedTab.Title,'Stress factor method')

    % set(h.Slider,'Max',size(h.FitDataMod,1));
    % set(h.Slider,'SliderStep',[1/(size(h.FitDataMod,1)-1) 1/(size(h.FitDataMod,1)-1)]);
    nFit = size(h.FitDataMod, 1);
    set(h.Slider, 'Max',        max(nFit, 2));
    set(h.Slider, 'SliderStep', [1/max(nFit-1,1)  1/max(nFit-1,1)]);

    % set(h.plotdata,'Xdata',h.FitDataMod{value}(:,1))
    % set(h.plotdata,'Ydata',h.FitDataMod{value}(:,2))
    % set(h.plotdata,'YNegativeDelta',h.FitDataMod{value}(:,3))
    % set(h.plotdata,'YPositiveDelta',h.FitDataMod{value}(:,3))

    if length(val) ~= length(idxalpha)
        % Set plot data for fitted peak positions (all data points)
        set(h.plotdata,'Xdata',h.FitDataMod{value}(:,1))
        set(h.plotdata,'Ydata',h.FitDataMod{value}(:,2))
        set(h.plotdata,'YNegativeDelta',h.FitDataMod{value}(:,3))
        set(h.plotdata,'YPositiveDelta',h.FitDataMod{value}(:,3))

        group = h.FitDataMod{value}(:,8);
        classes = unique(group);

        idx1 = group == classes(1);

        set(h.plotdata1,'Xdata',h.FitDataMod{value}(idx1,1))
        set(h.plotdata1,'Ydata',h.FitDataMod{value}(idx1,2))
        set(h.plotdata1,'YNegativeDelta',h.FitDataMod{value}(idx1,3))
        set(h.plotdata1,'YPositiveDelta',h.FitDataMod{value}(idx1,3))

        idx2 = group == classes(2);

        set(h.plotdata2,'Xdata',h.FitDataMod{value}(idx2,1))
        set(h.plotdata2,'Ydata',h.FitDataMod{value}(idx2,2))
        set(h.plotdata2,'YNegativeDelta',h.FitDataMod{value}(idx2,3))
        set(h.plotdata2,'YPositiveDelta',h.FitDataMod{value}(idx2,3))

    else
        % Set plot data for fitted peak positions
        set(h.plotdata,'Xdata',h.FitDataMod{value}(:,1))
        set(h.plotdata,'Ydata',h.FitDataMod{value}(:,2))
        set(h.plotdata,'YNegativeDelta',h.FitDataMod{value}(:,3))
        set(h.plotdata,'YPositiveDelta',h.FitDataMod{value}(:,3))
    end
    
    % Set plot data
    if isfield(h,'epsfitdataexport')
        set(h.plotdata,'Xdata',h.epsfitdataexport{value}(:,1))
        set(h.plotdata,'Ydata',h.epsfitdataexport{value}(:,2))
        set(h.plotdata,'YNegativeDelta',h.epsfitdataexport{value}(:,3))
        set(h.plotdata,'YPositiveDelta',h.epsfitdataexport{value}(:,3))    
    
        set(h.fitcurvestress,'Xdata',h.epsfitdataexport{value}(:,1))
        set(h.fitcurvestress,'Ydata',h.epsgammaergfunc{value}')
    
        % set(h.plotdatasin2psi,'Xdata',h.epssin2psifitdaten{value}(:,1))
        % set(h.plotdatasin2psi,'Ydata',h.epssin2psifitdaten{value}(:,2))
        % set(h.plotdatasin2psi,'YNegativeDelta',h.epssin2psifitdaten{value}(:,3))
        % set(h.plotdatasin2psi,'YPositiveDelta',h.epssin2psifitdaten{value}(:,3))
        % 
        % set(h.fitcurvestresssin2psi,'Ydata',h.sin2psiregres{value})
    end
    
    h.axes.YLim = [-Inf,Inf];
    
    if isfield(h,'taumean')
        set(h.highlightstressplot,'xdata',h.taumean(value))
        set(h.highlightstressplot,'ydata',h.sigmaFinal(value,1))
        set(h.highlightstressplot,'Visible','on')
    end
    
    assignin('base','hfinal',h)
    
    % Set slider properties for fitted peak data
    % set(h.SliderFittedPeaks,'Max',size(h.FitDataMod{value},1));
    % set(h.SliderFittedPeaks,'SliderStep',[1/(size(h.FitDataMod{value},1)-1) 1/(size(h.FitDataMod{value},1)-1)]);
    nPts = size(h.FitDataMod{value}, 1);
    set(h.SliderFittedPeaks, 'Max',        max(nPts, 2));
    set(h.SliderFittedPeaks, 'SliderStep', [1/max(nPts-1,1)  1/max(nPts-1,1)]);
    
    % dataX = 0:999;
    % dataX = (1.07007 + 0.03952.*dataX)';
    dataY = h.IntensityProfiles;
    
    for k = 1:size(h.idxempty,2)
        dataY{k}(:,h.idxempty{k}) = [];
    end
        
    % fitresultexportmod = h.fitresultexport{value};
    % fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
    % 
    % dataXcorrmod = h.dataXcorr{value};
    % dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
    % 
    % dataYcorrmod = h.dataYcorr{value};
    % dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];

    % Sicherer Zugriff: dataXcorr/dataYcorr/fitresultexport haben
    % numel = nAlpha, FitDataMod hat numel = nAlpha * nPeaks
    % → korrekten Index berechnen
    nAlpha    = numel(h.dataXcorr);
    safeIdx   = mod(value - 1, nAlpha) + 1;   % zyklisch auf [1..nAlpha] abbilden
    
    fitresultexportmod = h.fitresultexport{safeIdx};
    fitresultexportmod(cellfun(@isempty, fitresultexportmod)) = [];
    
    dataXcorrmod = h.dataXcorr{safeIdx};
    dataXcorrmod(cellfun(@isempty, dataXcorrmod)) = [];
    
    dataYcorrmod = h.dataYcorr{safeIdx};
    dataYcorrmod(cellfun(@isempty, dataYcorrmod)) = [];
    
    if isempty(fitresultexportmod) || isempty(dataXcorrmod)
        guidata(hObj, h);
        return
    end
    
    yPeakCalc = feval(h.gaussEqnFirst, fitresultexportmod{1}, dataXcorrmod{1});
    
    set(h.plotRawData,'Xdata',dataXcorrmod{1},'Ydata',dataYcorrmod{1},'Visible','on')
    set(h.plotFitData,'Xdata',dataXcorrmod{1},'Ydata',yPeakCalc,'Visible','on')
    
    % yPeakCalc = feval(fitresultexportmod{1},dataXcorrmod{1});
    yPeakCalc = feval(h.gaussEqnFirst,fitresultexportmod{1},dataXcorrmod{1});

    % set(h.plotRawData,'Xdata',dataXcorrmod{1});
    set(h.plotRawData,'Ydata',dataYcorrmod{1});
    set(h.plotRawData,'Visible','on')
    % set(h.plotFitData,'Xdata',dataXcorrmod{1});
    set(h.plotFitData,'Ydata',yPeakCalc);
    set(h.plotFitData,'Visible','on')
    
    % if strcmp(h.plottab.SelectedTab.Title,'sin²psi method')
    %     h.axessin2psi.XLim = [0,1];
    %     h.axessin2psi.YLim = [-Inf,Inf];
    % else
        h.axes.YLim = [-Inf,Inf];
        % h.axes.XLim = [-90,40];
        h.axes.XLim = [-90,90];
    % end
    
    set(h.SliderFittedPeaks,'Value',1);
    
    set(h.highlightpeakdata,'Xdata',h.FitDataMod{value}(1,1))
    set(h.highlightpeakdata,'Ydata',h.FitDataMod{value}(1,2))
    set(h.highlightpeakdata,'Visible','on')
    
    if isfield(h,'epsfitdataexport')
        set(h.highlightpeakdata,'Visible','off')
        set(h.highlightpeakdata,'Xdata',h.epsfitdataexport{value}(1,1))
        set(h.highlightpeakdata,'Ydata',h.epsfitdataexport{value}(1,2))
    end
    
    if isfield(h,'tau')
        set(h.plottaudata,'Xdata',h.FitDataMod{value}(:,1))
        set(h.plottaudata,'Ydata',h.tau{value});

        set(h.plottaudatamean,'Xdata',h.FitDataMod{value}(:,1))
        set(h.plottaudatamean,'Ydata',repelem(mean(h.tau{value}),size(h.FitDataMod{value},1)));

        h.axesPlottauData.XLim = h.axes.XLim;
        h.axesPlottauData.YLim = [0,round(max(h.tau{value}))+1];
    end

    % Set sin2psi data also
    if isfield(h,'epssin2psifitdaten')
        set(h.plotdatasin2psi,'Xdata',h.epssin2psifitdaten{value}(:,1))
        set(h.plotdatasin2psi,'Ydata',h.epssin2psifitdaten{value}(:,2))
        set(h.plotdatasin2psi,'YNegativeDelta',h.epssin2psifitdaten{value}(:,3))
        set(h.plotdatasin2psi,'YPositiveDelta',h.epssin2psifitdaten{value}(:,3))

        set(h.fitcurvestresssin2psi,'Ydata',h.sin2psiregres{value})
    end
elseif strcmp(h.plottab.SelectedTab.Title,'sin²psi method')
    % set(h.Slider,'Max',size(h.FitDataMod,1));
    % set(h.Slider,'SliderStep',[1/(size(h.FitDataMod,1)-1) 1/(size(h.FitDataMod,1)-1)]);
    nFit = size(h.FitDataMod, 1);
    set(h.Slider, 'Max',        max(nFit, 2));
    set(h.Slider, 'SliderStep', [1/max(nFit-1,1)  1/max(nFit-1,1)]);
    if isfield(h,'epssin2psifitdaten')
        set(h.plotdatasin2psi,'Xdata',h.epssin2psifitdaten{value}(:,1))
        set(h.plotdatasin2psi,'Ydata',h.epssin2psifitdaten{value}(:,2))
        set(h.plotdatasin2psi,'YNegativeDelta',h.epssin2psifitdaten{value}(:,3))
        set(h.plotdatasin2psi,'YPositiveDelta',h.epssin2psifitdaten{value}(:,3))

        set(h.fitcurvestresssin2psi,'Ydata',h.sin2psiregres{value})
    end
    h.axessin2psi.XLim = [0,1];
    h.axessin2psi.YLim = [-Inf,Inf];

    % Set data for stress factor method
    if isfield(h,'epsfitdataexport')
        set(h.plotdata,'Xdata',h.epsfitdataexport{value}(:,1))
        set(h.plotdata,'Ydata',h.epsfitdataexport{value}(:,2))
        set(h.plotdata,'YNegativeDelta',h.epsfitdataexport{value}(:,3))
        set(h.plotdata,'YPositiveDelta',h.epsfitdataexport{value}(:,3))    
    
        set(h.fitcurvestress,'Xdata',h.epsfitdataexport{value}(:,1))
        set(h.fitcurvestress,'Ydata',h.epsgammaergfunc{value}')
    end

    if isfield(h,'taumean')
        set(h.highlightstressplot,'xdata',h.taumean(value))
        set(h.highlightstressplot,'ydata',h.sigmaFinal(value,1))
        set(h.highlightstressplot,'Visible','on')
    end

elseif strcmp(h.plottab.SelectedTab.Title,'Plot intensity data')
    % set(h.plotIntensityData,'Xdata',dataX{1})
    % set(h.Slider,'Max',size(h.IntensityProfiles,2)*size(h.IntensityProfiles{1},2));
    % set(h.Slider,'SliderStep',[1/(size(h.IntensityProfiles,2)*size(h.IntensityProfiles{1},2)-1) 1/(size(h.IntensityProfiles,2)*size(h.IntensityProfiles{1},2)-1)]);
    nProf = size(h.IntensityProfiles,2) * size(h.IntensityProfiles{1},2);
    set(h.Slider, 'Max',        max(nProf, 2));
    set(h.Slider, 'SliderStep', [1/max(nProf-1,1)  1/max(nProf-1,1)]);

    % if ~isfield(h,'idxtwothetamin')
    %     set(h.plotIntensityData,'Ydata',h.dataYPlot(:,value))
    % else
        set(h.plotIntensityData,'Xdata',h.dataXPlot(:,value))
        set(h.plotIntensityData,'Ydata',h.dataYPlot(:,value))
    % end

    if isfield(h,'LocationsPlot')
        % set(h.plotpeaklocations,'Xdata',h.peakXCell{value})
        % set(h.plotpeaklocations,'Ydata',h.peakYCell{value})
        set(h.plotpeaklocations,'Xdata',h.LocationsPlot{value})
        set(h.plotpeaklocations,'Ydata',h.AmplitudePlot{value})
    end


    PeakPostmp = h.PeaksTheo{1}.Peaks(:,5:6);
    PeakPostmp = mean(PeakPostmp,2)';
    
    idx = (PeakPostmp >= round(min(h.dataX{1}))) & (PeakPostmp <= round(max(h.dataX{1})));
    
    PeakPos = PeakPostmp(idx);
    
    hkl = h.PeaksTheo{1}.Peaks(idx,1:3);
    for i = 1:size(hkl, 1)
        % Jede Zeile in einen String umwandeln
        rowsAsStrings{i} = strtrim(sprintf('%g %g %g', hkl(i, :)));
    end
    
    delete(h.plotpeakstheo)
    
    if strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'Ga K-alpha')
        h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{1},'--r',h.rowsAsStrings{1}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-alpha')
        h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{2},'--r',h.rowsAsStrings{2}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-beta')
        h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{3},'--r',h.rowsAsStrings{3}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    end
end

guidata(hObj, h);

function SliderCallbackFittedPeaks(hObj, ~)
% This callback handles the changes when the slider button is pushed.
h = guidata(hObj);
% Get slider value
% value = get(hObj, 'Value');
% value = round(value);

try
    value = get(hObj, 'Value');
    value = round(value);

    % Grenzen prüfen
    maxVal = get(hObj, 'Max');
    if value < 1 || value > maxVal
        warning('Slider:invalidValue', ...
            '[Slider] Ungültiger Wert %d (Max: %d), setze auf 1.', value, maxVal);
        value = 1;
        set(hObj, 'Value', 1);
    end

catch ME
    warning('Slider:generalError', '[Slider] Fehler: %s', ME.message);
    return
end

SliderValue = get(h.Slider,'Value');

dataY = h.IntensityProfiles;

for k = 1:size(h.idxempty,2)
    dataY{k}(:,h.idxempty{k}) = [];
end


% fitresultexportmod = h.fitresultexport{SliderValue};
% fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% 
% dataXcorrmod = h.dataXcorr{SliderValue};
% dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
% 
% dataYcorrmod = h.dataYcorr{SliderValue};
% dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];

nAlpha  = numel(h.dataXcorr);
safeIdx = mod(SliderValue - 1, nAlpha) + 1;

fitresultexportmod = h.fitresultexport{safeIdx};
fitresultexportmod(cellfun(@isempty, fitresultexportmod)) = [];

dataXcorrmod = h.dataXcorr{safeIdx};
dataXcorrmod(cellfun(@isempty, dataXcorrmod)) = [];

dataYcorrmod = h.dataYcorr{safeIdx};
dataYcorrmod(cellfun(@isempty, dataYcorrmod)) = [];

if isempty(fitresultexportmod) || isempty(dataXcorrmod)
    guidata(hObj, h);
    return
end

% value ist der FittedPeaks-Slider — sicher auf verfügbare Fits begrenzen
safeVal = min(value, numel(fitresultexportmod));

yPeakCalc = feval(h.gaussEqnFirst, fitresultexportmod{safeVal}, dataXcorrmod{safeVal});

set(h.plotRawData,'Xdata',dataXcorrmod{safeVal},'Ydata',dataYcorrmod{safeVal},'Visible','on')
set(h.plotFitData,'Xdata',dataXcorrmod{safeVal},'Ydata',yPeakCalc,'Visible','on')


% yPeakCalc = feval(fitresultexportmod{value},dataXcorrmod{value});
% gaussEqnFirst = @(x,xdata)x(1).*exp(-((xdata-x(2))./x(3)).^2);
% yPeakCalc = feval(fitresultexportmod{1},dataXcorrmod{1});
yPeakCalc = feval(h.gaussEqnFirst,fitresultexportmod{value},dataXcorrmod{value});


% Set plot data
set(h.plotRawData,'Xdata',dataXcorrmod{value});
set(h.plotRawData,'Ydata',dataYcorrmod{value});
set(h.plotRawData,'Visible','on')
set(h.plotFitData,'Xdata',dataXcorrmod{value});
set(h.plotFitData,'Ydata',yPeakCalc);
set(h.plotFitData,'Visible','on')

h.axes.YLim = [-Inf,Inf];
h.axes.XLim = [-90,90];

if isfield(h,'epsfitdataexport')
    set(h.highlightpeakdata,'Visible','on')
    set(h.highlightpeakdata,'Xdata',h.epsfitdataexport{SliderValue}(value,1))
    set(h.highlightpeakdata,'Ydata',h.epsfitdataexport{SliderValue}(value,2))
else
    set(h.highlightpeakdata,'Xdata',h.FitDataMod{SliderValue}(value,1))
    set(h.highlightpeakdata,'Ydata',h.FitDataMod{SliderValue}(value,2))
    set(h.highlightpeakdata,'Visible','on')
end

guidata(hObj, h);

function celleditcallback(hObj, eventdata)
% Change entries for DEK data manually. User can also reallocate peaks if
% needed.
h = guidata(hObj);

h.SelectPeaktabledata = get(hObj,'data');

if strcmp(get(hObj,'Tag'),'tableDECFittedPeaks')
    % Get index of user entry
    idxdatanew = eventdata.Indices;
    % Find user selected entry of peak energy
    if strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'Ga K-alpha')
        datadek = get(h.dekdataGaKalpha,"data");
    elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-alpha')
        datadek = get(h.dekdataInKalpha,"data");
    elseif strcmp(get(h.radiobuttonwavelength.SelectedObject,'String'),'In K-beta')
        datadek = get(h.dekdataInKbeta,"data");
    end

    % datadek = h.dekdata.Data;
    idxchangedPeak = ismembertol(datadek(:,4),eventdata.NewData,0.0001);
    % Change DEK values accordingly
    h.SelectPeaktabledata(idxdatanew(1),3:7) = datadek(idxchangedPeak,[1:3,5:6]);
    set(hObj,'data',h.SelectPeaktabledata)
    % Update dek data for fitting of stress data
    h.DEKdataMatchedPeaks = [h.SelectPeaktabledata(:,3:5) h.SelectPeaktabledata(:,2) h.SelectPeaktabledata(:,6:end)];
end

% assignin('base','TableData',h.SelectPeaktabledata)
% assignin('base','datanew',datanew)

guidata(hObj, h);

function choosewavelengthcallback(hObj, eventdata)
% Change entries for DEK data manually. User can also reallocate peaks if
% needed.
h = guidata(hObj);

% disp("Previous: " + eventdata.OldValue.Text);
% disp("Current: " + eventdata.NewValue.Text);
delete(h.plotpeakstheo)

if strcmp(eventdata.NewValue.Text,'Ga K-alpha')
    h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{1},'--r',h.rowsAsStrings{1}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    % Set table data
    set(h.tableDECFittedPeaks,'ColumnFormat',{'numeric',(cellfun(@num2str,num2cell(h.PeakPos{1}'),'UniformOutput',false))','numeric','numeric','numeric','numeric','numeric','numeric'})
    set(h.AbscoeffEditField,"Value",round(h.abscoeff{1},6))
elseif strcmp(eventdata.NewValue.Text,'In K-alpha')
    h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{2},'--r',h.rowsAsStrings{2}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    % Set table data
    set(h.tableDECFittedPeaks,'ColumnFormat',{'numeric',(cellfun(@num2str,num2cell(h.PeakPos{2}'),'UniformOutput',false))','numeric','numeric','numeric','numeric','numeric','numeric'})
    set(h.AbscoeffEditField,"Value",round(h.abscoeff{2},6))
elseif strcmp(eventdata.NewValue.Text,'In K-beta')
    h.plotpeakstheo = xline(h.axesPlotIntensityData,h.PeakPos{3},'--r',h.rowsAsStrings{3}, 'LabelVerticalAlignment', 'middle', 'LabelHorizontalAlignment', 'left');
    % Set table data
    set(h.tableDECFittedPeaks,'ColumnFormat',{'numeric',(cellfun(@num2str,num2cell(h.PeakPos{3}'),'UniformOutput',false))','numeric','numeric','numeric','numeric','numeric','numeric'})
    set(h.AbscoeffEditField,"Value",round(h.abscoeff{3},6))
end

guidata(hObj, h);

function fitstressdatacallback(hObj, ~)
h = guidata(hObj);

col = get(hObj,'backg');
set(hObj,'String','Fitting stress data ...','backg',[1 .6 .6])
pause(.01)

my         = str2double(get(h.AbscoeffEditField, "String"));
spannkomp  = str2double(get(h.SpannKompEditField, "String"));
FitDataMod = h.FitDataMod;
DEK        = h.DEKdataMatchedPeaks;

% --- Stress für alle Peaks berechnen ---
for k = 1:size(FitDataMod, 1)
    r = calcStress(FitDataMod{k}, DEK(k,:), my, spannkomp);

    h.epsfitdataexport{k}   = r.epsfitdata;
    h.epsgammaergfunc{k}    = r.epsgammaergfunc;
    h.epssin2psifitdaten{k} = r.epssin2psifitdaten;
    h.sin2psifit{k}         = r.sin2psifit;
    h.sin2psiregres{k}      = r.sin2psiregres;
    h.tau{k}                = r.tau;
    h.psi{k}                = r.psi;
    h.phi{k}                = r.phi;

    sigma{k}           = r.sigma;
    sigmaerr{k}        = r.sigmaerr;
    sigmapardebye{k}   = r.sigmapardebye;
    deltasigmapardebye{k} = r.deltasigmapardebye;
    alphaexport{k}     = FitDataMod{k}(1,7);
end

% --- Ergebnisse in h speichern ---
h.taumean               = cellfun(@mean, h.tau)';
h.sigmaFinal            = cell2mat(sigma)';
h.sigmaerrFinal         = cell2mat(sigmaerr)';
h.sigmasin2psiFinal     = cell2mat(sigmapardebye)';
h.deltasigmasin2psiFinal = cell2mat(deltasigmapardebye)';
h.alphaexport           = cell2mat(alphaexport)';

% --- Plot aktualisieren ---
h = updateStressPlots(h, 1);

set(hObj,'String','Fit Stress Data','backg',col)
guidata(hObj, h);

% function fitstressdatacallback(hObj, ~)
% h = guidata(hObj);
% 
% col = get(hObj,'backg');  % Get the background color of the figure.
% set(hObj,'String','Fitting stress data ...','backg',[1 .6 .6]) % Change color of button. 
% % The pause (or drawnow) is necessary to make button changes appear.
% pause(.01)
% 
% % my = get(h.AbscoeffEditField, "value");
% my = str2double(get(h.AbscoeffEditField, "String"));
% spannkomp = str2double(get(h.SpannKompEditField, "String"));
% % DEK = get(h.dekdata,"data");
% 
% % % Prepare DEK data for all fitted peaks
% % % Create cell array with data from fitted peaks [gamma pos poserr amp width]
% % % FitDataMod = cat(1, h.FitData{:});
% FitDataMod = h.FitDataMod;
% 
% DEKdataMatchedPeaks = h.DEKdataMatchedPeaks;
% % DEKdataMatchedPeaks(5) = -9.6026e-06;
% % DEKdataMatchedPeaks(6) = 4.2715e-05;
% % assignin('base','DEKdataMatchedPeaks',DEKdataMatchedPeaks)
% assignin('base','DEK',DEKdataMatchedPeaks)
% % assignin('base','FitDataModFitStress',FitDataMod)
% 
% for k = 1:size(FitDataMod,1)
%     data = FitDataMod{k};
%     % theta0
%     theta0 = sum(data(:,2))./(2*length(data(:,2)));
%     % epsfitdaten [gamma, ln(sin(thtea0)/sin(theta(gamma))), cot(theta(gamma))*delta(theta)]
%     epsfitdata = [data(:,1), log((sind(theta0))./(sind(data(:,2)./2))), cotd(data(:,2)./2).*(data(:,3)./57.3)];
%     epsfitdataexport{k} = epsfitdata;
% 
%     % alpha from measurement
%     alpha = data(1,6);
%     alphaexport{k} = alpha;
%     % gamma max - Abschattung für gamma > gammamax - Anhand dieser Werte kann
%     % die Datenmatrix angepasst werden (meistens nicht nötig, da bei den hohen
%     % gamma Werten soweiso keine Peaks ausgewertet werden konnten)
%     gammamax = acosd(tand(alpha)./tand(data(:,2)));
%     psi = zeros(length(data(:,1)),1);
%     % psi
%     for l = 1:length(data(:,1))
%         if data(l,1) < 0
%             psi(l,:) = -acosd(sind(alpha)*sind(theta0) + cosd(alpha)*cosd(theta0)*cosd(data(l,1)));
%         else
%             psi(l,:) = acosd(sind(alpha)*sind(theta0) + cosd(alpha)*cosd(theta0)*cosd(data(l,1)));
%         end
%     end
%     h.psi{k} = psi;
% 
%     phi = zeros(length(data(:,1)),1);
%     % phi
%     for l = 1:length(data(:,1))
%         if data(l,1) < 0
%             phi(l,:) = acosd((cosd(theta0)*sind(data(l,1))) ./ sind(psi(l))) - 180;
%         else
%             phi(l,:) = -acosd((cosd(theta0)*sind(data(l,1))) ./ sind(psi(l)));
%         end
%     end
% 
%     h.phi{k} = phi;
% 
%     % beta
%     beta = asind(cosd(alpha) .* sind(2*theta0) .* cosd(data(:,1)) - sind(alpha) .* cosd(2*theta0));
% 
%     % Informationstiefe tau
%     h.tau{k} = 1./my .* ( (sind(alpha) .* (sind(2*theta0) .* cosd(alpha) .* cosd(data(:,1)) - cosd(2*theta0) .* sind(alpha)) ) ./ (sind(alpha) + (sind(2*theta0) .* cosd(alpha) .* cosd(data(:,1)) - cosd(2*theta0) .* sind(alpha))) );
% 
%     % Spannungsfaktoren für alle Spannungskomponenten
%     % DEK ist hkl abhaengig
%     sf11 = DEKdataMatchedPeaks(k,6) .* cosd(phi).^2 .* sind(psi).^2 + DEKdataMatchedPeaks(k,5);
%     sf22 = DEKdataMatchedPeaks(k,6) .* sind(phi).^2 .* sind(psi).^2 + DEKdataMatchedPeaks(k,5);
%     sf33 = DEKdataMatchedPeaks(k,6) .* cosd(psi).^2 + DEKdataMatchedPeaks(k,5);
%     sf12 = DEKdataMatchedPeaks(k,6) .* sind(2.*phi) .* sind(psi).^2;
%     sf13 = DEKdataMatchedPeaks(k,6) .* cosd(phi) .* 2 .* sqrt(sind(psi).^2 .* (1 - (sind(psi).^2)));
%     sf23 = DEKdataMatchedPeaks(k,6) .* sind(phi) .* 2 .* sqrt(sind(psi).^2 .* (1 - (sind(psi).^2)));
%     sfpar{k} = DEKdataMatchedPeaks(k,6) .* sind(psi).^2 + 2.*DEKdataMatchedPeaks(k,5);
% 
%     % sfmatrix = zeros(length(data(:,1)),2);
%     % Prepare data for fit
%     % sfmatrix - haengt von der Anzahl der Spannungskomponenten ab
%     if spannkomp == 11
%         sfmatrix{k} = sfpar{k};
%     elseif spannkomp == 1122
%         sfmatrix{k} = [sf11 sf22];
%     elseif spannkomp == 112213
%         sfmatrix{k} = [sf11 sf22 sf13];
%     elseif spannkomp == 112223
%         sfmatrix{k} = [sf11 sf22 sf23];
%     elseif spannkomp == 11221323
%         sfmatrix{k} = [sf11 sf22 sf13 sf23];
%     end
% 
%     assignin('base','sfmatrix',sfmatrix)
%     assignin('base','epsfitdata',epsfitdata)
%     assignin('base','phi',phi)
%     assignin('base','psi',psi)
%     assignin('base','DEKdataMatchedPeaks',DEKdataMatchedPeaks)
%     assignin('base','sfpar',sfpar)
% 
%     % Loesen des linearen Gleichungssystems - gewichteter Fit
%     [sigma{k},sigmaerr{k},mse{k},S] = lscov(sfmatrix{k},epsfitdata(:,2),epsfitdata(:,3));
% 
%     % Ergebnisfunktion
%     if spannkomp == 11
%         epsgammaergfunc{k} = sfpar*sigma{k};
%         epsgamma11func{k} = sf11*sigma{k};
%         epsgamma22func{k} = sf22*sigma{k};
%         epsgamma13func{k} = 0;
%         epsgamma23func{k} = 0;
%     elseif spannkomp == 1122
%         epsgammaergfunc{k} = sf11*sigma{k}(1) + sf22*sigma{k}(2);
%         epsgamma11func{k} = sf11*sigma{k}(1);
%         epsgamma22func{k} = sf22*sigma{k}(2);
%         epsgamma13func{k} = 0;
%         epsgamma23func{k} = 0;
%     elseif spannkomp == 112213
%         epsgammaergfunc{k} = sf11*sigma{k}(1) + sf22*sigma{k}(2) + sf13*sigma{k}(3);
%         epsgamma11func{k} = sf11*sigma{k}(1);
%         epsgamma22func{k} = sf22*sigma{k}(2);
%         epsgamma13func{k} = sf13*sigma{k}(3);
%         epsgamma23func{k} = 0;
%     elseif spannkomp == 112223
%         epsgammaergfunc{k} = sf11*sigma{k}(1) + sf22*sigma{k}(2) + sf23*sigma{k}(3);
%         epsgamma11func{k} = sf11*sigma{k}(1);
%         epsgamma22func{k} = sf22*sigma{k}(2);
%         epsgamma13func{k} = 0;
%         epsgamma23func{k} = sf23*sigma{k}(3);
%     elseif spannkomp == 11221323
%         epsgammaergfunc{k} = sf11*sigma{k}(1) + sf22*sigma{k}(2) + sf13*sigma{k}(3) + sf23*sigma{k}(4);
%         epsgamma11func{k} = sf11*sigma{k}(1);
%         epsgamma22func{k} = sf22*sigma{k}(2);
%         epsgamma13func{k} = sf13*sigma{k}(3);
%         epsgamma23func{k} = sf23*sigma{k}(4);
%     end
% 
% 
%     assignin('base','sigma1',sigma)
%     %% Spannungsanalyse mittelns sin²psi-Methode
%     epssin2psifitdaten{k} = [sind(psi).^2 epsfitdata(:,2) epsfitdata(:,3)];
% 
%     % weighted linear fit
%     sin2psifit{k} = fitlm(epssin2psifitdaten{k}(:,1),epssin2psifitdaten{k}(:,2),'Weights',epssin2psifitdaten{k}(:,3));
% 
%     % Stress evaluation (DEK abhaengig)
%     sigmapardebye{k} = sin2psifit{k}.Coefficients.Estimate(2)/DEKdataMatchedPeaks(k,6);
%     deltasigmapardebye{k} = sin2psifit{k}.Coefficients.SE(2)/DEKdataMatchedPeaks(k,6);
% 
%     % Calc sin²psi regress line
%     xdata = (0:0.05:1);
%     sin2psiregres{k} = sin2psifit{k}.Coefficients.Estimate(1) + sin2psifit{k}.Coefficients.Estimate(2).*xdata;
% 
% end
% 
% % Set plot data
% h.axes.YLabel.String = [char(949),'(',char(947),')'];
% h.axes.YLim = [-inf inf];
% set(h.plotdata,'Xdata',epsfitdataexport{1}(:,1))
% set(h.plotdata,'Ydata',epsfitdataexport{1}(:,2))
% set(h.plotdata,'YNegativeDelta',epsfitdataexport{1}(:,3))
% set(h.plotdata,'YPositiveDelta',epsfitdataexport{1}(:,3))
% 
% set(h.fitcurvestress,'Xdata',epsfitdataexport{1}(:,1))
% set(h.fitcurvestress,'Ydata',epsgammaergfunc{1}')
% set(h.fitcurvestress,'Visible','on')
% 
% set(h.plotdatasin2psi,'Xdata',epssin2psifitdaten{1}(:,1))
% set(h.plotdatasin2psi,'Ydata',epssin2psifitdaten{1}(:,2))
% set(h.plotdatasin2psi,'YNegativeDelta',epssin2psifitdaten{1}(:,3))
% set(h.plotdatasin2psi,'YPositiveDelta',epssin2psifitdaten{1}(:,3))
% 
% set(h.plotdatasin2psi,'Visible','on')
% 
% set(h.fitcurvestresssin2psi,'Xdata',(0:0.05:1))
% set(h.fitcurvestresssin2psi,'Ydata',sin2psiregres{1})
% set(h.fitcurvestresssin2psi,'Visible','on')
% 
% h.epsfitdataexport = epsfitdataexport;
% h.epsgammaergfunc = epsgammaergfunc;
% h.epssin2psifitdaten = epssin2psifitdaten;
% h.sin2psifit = sin2psifit;
% h.sin2psiregres = sin2psiregres;
% 
% assignin('base','tau',h.tau)
% assignin('base','sigma',sigma)
% assignin('base','sigmaerr',sigmaerr)
% assignin('base','epsfitdataexport',epsfitdataexport)
% assignin('base','sigmapardebye',sigmapardebye)
% assignin('base','deltasigmapardebye',deltasigmapardebye)
% assignin('base','epssin2psifitdaten',epssin2psifitdaten)
% 
% h.taumean = cellfun(@mean,h.tau)';
% h.sigmaFinal = cell2mat(sigma)';
% h.sigmaerrFinal = cell2mat(sigmaerr)';
% h.sigmasin2psiFinal = cell2mat(sigmapardebye)';
% h.deltasigmasin2psiFinal = cell2mat(deltasigmapardebye)';
% h.alphaexport = cell2mat(alphaexport)';
% 
% if spannkomp == 1122
%     h.StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmasin2psiFinal h.deltasigmasin2psiFinal h.alphaexport];
% elseif spannkomp == 112213
%     h.StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmaFinal(:,3) h.sigmaerrFinal(:,3) h.sigmasin2psiFinal h.deltasigmasin2psiFinal h.alphaexport];
% end
% 
% % assignin('base','StressResults',h.StressResults)
% 
% % Plot results
% set(h.plotstressdata,'Xdata',h.taumean)
% set(h.plotstressdata,'Ydata',h.sigmaFinal(:,1))
% set(h.plotstressdata,'YNegativeDelta',h.sigmaerrFinal(:,1))
% set(h.plotstressdata,'YPositiveDelta',h.sigmaerrFinal(:,1))
% 
% set(h.plotsin2psistressdata,'Xdata',h.taumean)
% set(h.plotsin2psistressdata,'Ydata',h.sigmasin2psiFinal)
% set(h.plotsin2psistressdata,'YNegativeDelta',h.deltasigmasin2psiFinal)
% set(h.plotsin2psistressdata,'YPositiveDelta',h.deltasigmasin2psiFinal)
% 
% set(h.plotstressdata,'Visible','on')
% set(h.plotsin2psistressdata,'Visible','on')
% 
% if isfield(h,'plotdata1')
%     set(h.plotdata1,'Visible','off')
%     set(h.plotdata2,'Visible','off')
% end
% 
% set(h.highlightpeakdata,'Visible','off')
% % set(h.highlightpeakdata,'Xdata',h.epsfitdataexport{value}(1,1))
% % set(h.highlightpeakdata,'Ydata',h.epsfitdataexport{value}(1,2))
% 
% % Plot tau data
% set(h.plottaudata,'Xdata',h.FitDataMod{1}(:,1))
% set(h.plottaudata,'Ydata',h.tau{1});
% 
% set(h.plottaudatamean,'Xdata',h.FitDataMod{1}(:,1))
% set(h.plottaudatamean,'Ydata',repelem(mean(h.tau{1}),size(h.FitDataMod{1},1)));
% 
% % h.plottaudata = plot(h.axesPlottauData,h.FitDataMod{1}(:,1),h.tau{1},'s');
% % hold(h.axesPlottauData,'on')
% % h.plottaudatamean = plot(h.axesPlottauData,h.FitDataMod{1}(:,1),repelem(mean(h.tau{1}),size(h.FitDataMod{1},1)),'Color','r');
% h.axesPlottauData.XLim = h.axes.XLim;
% 
% assignin('base','hfit',h)
% 
% % Reset the button color
% set(hObj,'String','Fit Stress Data','backg',col)  % Now reset the button features.
% 
% guidata(hObj, h);

function modstressdatacallback(hObj, ~)
h = guidata(hObj);

valueSlider            = get(h.Slider, 'Value');
valueSliderFittedPeaks = get(h.SliderFittedPeaks, 'Value');

CheckBoxesPhi = [1 0 0 0];
PhiWinkel     = {0};

[pointslist,~,~] = selectdatastressvalues( ...
    'Axes', h.axes, 'Handle', h.axes, ...
    'CheckBoxesPhi', CheckBoxesPhi, 'PhiWinkel', PhiWinkel, ...
    'sel','lasso','action','delete','verify','on');

% --- Datenpunkte löschen ---
h.FitDataMod{valueSlider}(pointslist,:) = [];

fitresultexportmod                        = h.fitresultexport{valueSlider};
fitresultexportmod(pointslist)            = {[]};
h.dataXcorr{valueSlider}(pointslist)     = {[]};
h.dataYcorr{valueSlider}(pointslist)     = {[]};
h.fitresultexport{valueSlider}            = fitresultexportmod;

fitresultexportmod(cellfun(@isempty, fitresultexportmod)) = [];
dataXcorrmod = h.dataXcorr{valueSlider};
dataXcorrmod(cellfun(@isempty, dataXcorrmod)) = [];
dataYcorrmod = h.dataYcorr{valueSlider};
dataYcorrmod(cellfun(@isempty, dataYcorrmod)) = [];

% --- Stress neu berechnen ---
my        = str2double(get(h.AbscoeffEditField, "String"));
spannkomp = str2double(get(h.SpannKompEditField, "String"));
DEK       = h.DEKdataMatchedPeaks;

r = calcStress(h.FitDataMod{valueSlider}, DEK(valueSlider,:), my, spannkomp);

h.epsfitdataexport{valueSlider}   = r.epsfitdata;
h.epsgammaergfunc{valueSlider}    = r.epsgammaergfunc;
h.epssin2psifitdaten{valueSlider} = r.epssin2psifitdaten;
h.sin2psifit{valueSlider}         = r.sin2psifit;
h.sin2psiregres{valueSlider}      = r.sin2psiregres;
h.tau{valueSlider}                = r.tau;
h.taumean(valueSlider)            = mean(r.tau);
h.sigmaFinal(valueSlider,:)       = r.sigma';
h.sigmaerrFinal(valueSlider,:)    = r.sigmaerr';
h.sigmasin2psiFinal(valueSlider)  = r.sigmapardebye;
h.deltasigmasin2psiFinal(valueSlider) = r.deltasigmapardebye;

% --- Plots aktualisieren ---
h = updateStressPlots(h, valueSlider);

% --- Peak-Plot aktualisieren ---
yPeakCalc = feval(h.gaussEqnFirst, fitresultexportmod{valueSliderFittedPeaks}, ...
                  dataXcorrmod{valueSliderFittedPeaks});
set(h.plotRawData, 'Xdata', dataXcorrmod{valueSliderFittedPeaks}, 'Ydata', dataYcorrmod{valueSliderFittedPeaks}, 'Visible','on')
set(h.plotFitData, 'Xdata', dataXcorrmod{valueSliderFittedPeaks}, 'Ydata', yPeakCalc, 'Visible','on')

set(h.SliderFittedPeaks, 'Max', size(h.FitDataMod{valueSlider},1));
set(h.SliderFittedPeaks, 'SliderStep', [1/(size(h.FitDataMod{valueSlider},1)-1) 1/(size(h.FitDataMod{valueSlider},1)-1)]);
set(h.SliderFittedPeaks, 'Value', 1);

guidata(hObj, h);

% function modstressdatacallback(hObj, ~)
% h = guidata(hObj);
% 
% valueSlider = get(h.Slider, 'Value');
% valueSliderFittedPeaks = get(h.SliderFittedPeaks, 'Value');
% 
% CheckBoxesPhi = [1 0 0 0];
% PhiWinkel = {0};
% 
% [pointslist,~,~] = selectdatastressvalues('Axes',h.axes,'Handle',h.axes,'CheckBoxesPhi',CheckBoxesPhi,'PhiWinkel',PhiWinkel,'sel','lasso','action','delete','verify','on');
% % [pointslist,~,~] = selectdatastressvalues('Handle',h.axes,'CheckBoxesPhi',CheckBoxesPhi,'PhiWinkel',PhiWinkel,'sel','closest','action','delete','verify','on');
% 
% % PointsToDelete = h.FitDataMod{valueSlider}(pointslist,7);
% 
% % Delete selected point from fit data
% h.FitDataMod{valueSlider}(pointslist,:) = [];
% % h.epsfitdataexport{valueSlider}(pointslist) = [];
% 
% % Redo fitting of stress data
% my = str2num(get(h.AbscoeffEditField, "String"));
% spannkomp = str2double(get(h.SpannKompEditField, "String"));
% DEK = h.DEKdataMatchedPeaks;
% 
% data = h.FitDataMod{valueSlider};
% % theta0
% theta0 = sum(data(:,2))./(2*length(data(:,2)));
% % epsfitdaten [gamma, ln(sin(thtea0)/sin(theta(gamma))), cot(theta(gamma))*delta(theta)]
% epsfitdata = [data(:,1), log((sind(theta0))./(sind(data(:,2)./2))), cotd(data(:,2)./2).*(data(:,3)./57.3)];
% % epsfitdataexport = epsfitdata;
% h.epsfitdataexport{valueSlider} = epsfitdata;
% 
% % alpha from measurement
% alpha = data(1,6);
% % gamma max - Abschattung für gamma > gammamax - Anhand dieser Werte kann
% % die Datenmatrix angepasst werden (meistens nicht nötig, da bei den hohen
% % gamma Werten soweiso keine Peaks ausgewertet werden konnten)
% % gammamax = acosd(tand(alpha)./tand(data(:,2)));
% psi = zeros(length(data(:,1)),1);
% % psi
% for l = 1:length(data(:,1))
%     if data(l,1) < 0
%         psi(l,:) = -acosd(sind(alpha)*sind(theta0) + cosd(alpha)*cosd(theta0)*cosd(data(l,1)));
%     else
%         psi(l,:) = acosd(sind(alpha)*sind(theta0) + cosd(alpha)*cosd(theta0)*cosd(data(l,1)));
%     end
% end
% 
% phi = zeros(length(data(:,1)),1);
% % phi
% for l = 1:length(data(:,1))
%     if data(l,1) < 0
%         phi(l,:) = acosd((cosd(theta0)*sind(data(l,1))) ./ sind(psi(l))) - 180;
%     else
%         phi(l,:) = -acosd((cosd(theta0)*sind(data(l,1))) ./ sind(psi(l)));
%     end
% end
% 
% % beta
% beta = asind(cosd(alpha) .* sind(2*theta0) .* cosd(data(:,1)) - sind(alpha) .* cosd(2*theta0));
% 
% % Informationstiefe tau
% tau = 1./my .* ( (sind(alpha) .* (sind(2*theta0) .* cosd(alpha) .* cosd(data(:,1)) - cosd(2*theta0) .* sind(alpha)) ) ./ (sind(alpha) + (sind(2*theta0) .* cosd(alpha) .* cosd(data(:,1)) - cosd(2*theta0) .* sind(alpha))) );
% 
% % Spannungsfaktoren für alle Spannungskomponenten
% % DEK ist hkl abhaengig
% sf11 = DEK(valueSlider,6) .* cosd(phi).^2 .* sind(psi).^2 + DEK(valueSlider,5);
% sf22 = DEK(valueSlider,6) .* sind(phi).^2 .* sind(psi).^2 + DEK(valueSlider,5);
% sf33 = DEK(valueSlider,6) .* cosd(psi).^2 + DEK(valueSlider,5);
% sf12 = DEK(valueSlider,6) .* sind(2.*phi) .* sind(psi).^2;
% sf13 = DEK(valueSlider,6) .* cosd(phi) .* 2 .* sqrt(sind(psi).^2 .* (1 - (sind(psi).^2)));
% sf23 = DEK(valueSlider,6) .* sind(phi) .* 2 .* sqrt(sind(psi).^2 .* (1 - (sind(psi).^2)));
% sfpar = DEK(valueSlider,6) .* sind(psi).^2 + 2.*DEK(valueSlider,5);
% 
% % sfmatrix = zeros(length(data(:,1)),2);
% % Prepare data for fit
% % sfmatrix - haengt von der Anzahl der Spannungskomponenten ab
% if spannkomp == 11
%     sfmatrix = sfpar;
% elseif spannkomp == 1122
%     sfmatrix = [sf11 sf22];
% elseif spannkomp == 112213
%     sfmatrix = [sf11 sf22 sf13];
% elseif spannkomp == 112223
%     sfmatrix = [sf11 sf22 sf23];
% elseif spannkomp == 11221323
%     sfmatrix = [sf11 sf22 sf13 sf23];
% end
% 
% % Loesen des linearen Gleichungssystems - gewichteter Fit
% [sigma,sigmaerr,mse,S] = lscov(sfmatrix,epsfitdata(:,2),epsfitdata(:,3));
% 
% % Ergebnisfunktion
% if spannkomp == 11
%     epsgammaergfunc = sfpar*sigma;
%     epsgamma11func = sf11*sigma;
%     epsgamma22func = sf22*sigma;
%     epsgamma13func = 0;
%     epsgamma23func = 0;
% elseif spannkomp == 1122
%     epsgammaergfunc = sf11*sigma(1) + sf22*sigma(2);
%     epsgamma11func = sf11*sigma(1);
%     epsgamma22func = sf22*sigma(2);
%     epsgamma13func = 0;
%     epsgamma23func = 0;
% elseif spannkomp == 112213
%     epsgammaergfunc = sf11*sigma(1) + sf22*sigma(2) + sf13*sigma(3);
%     epsgamma11func = sf11*sigma(1);
%     epsgamma22func = sf22*sigma(2);
%     epsgamma13func = sf13*sigma(3);
%     epsgamma23func = 0;
% elseif spannkomp == 112223
%     epsgammaergfunc = sf11*sigma(1) + sf22*sigma(2) + sf23*sigma(3);
%     epsgamma11func = sf11*sigma(1);
%     epsgamma22func = sf22*sigma(2);
%     epsgamma13func = 0;
%     epsgamma23func = sf23*sigma(3);
% elseif spannkomp == 11221323
%     epsgammaergfunc = sf11*sigma(1) + sf22*sigma(2) + sf13*sigma(3) + sf23*sigma(4);
%     epsgamma11func = sf11*sigma(1);
%     epsgamma22func = sf22*sigma(2);
%     epsgamma13func = sf13*sigma(3);
%     epsgamma23func = sf23*sigma(4);
% end
% 
% % Set plot data
% set(h.plotdata,'Xdata',epsfitdata(:,1))
% set(h.plotdata,'Ydata',epsfitdata(:,2))
% set(h.plotdata,'YNegativeDelta',epsfitdata(:,3))
% set(h.plotdata,'YPositiveDelta',epsfitdata(:,3))
% 
% set(h.fitcurvestress,'Xdata',epsfitdata(:,1))
% set(h.fitcurvestress,'Ydata',epsgammaergfunc')
% % set(h.fitcurvestress,'Visible','on')
% 
% %% Spannungsanalyse mittelns sin²psi-Methode
% epssin2psifitdaten = [sind(psi).^2 epsfitdata(:,2) epsfitdata(:,3)];
% % weighted linear fit
% sin2psifit = fitlm(epssin2psifitdaten(:,1),epssin2psifitdaten(:,2),'Weights',epssin2psifitdaten(:,3));
% 
% % Calc sin²psi regress line
% xdata = (0:0.05:1);
% sin2psiregres = sin2psifit.Coefficients.Estimate(1) + sin2psifit.Coefficients.Estimate(2).*xdata;
% 
% % Stress evaluation (DEK abhaengig)
% sigmapardebye = sin2psifit.Coefficients.Estimate(2)/DEK(valueSlider,6);
% deltasigmapardebye = sin2psifit.Coefficients.SE(2)/DEK(valueSlider,6);
% 
% % Prepare results
% % h.epsfitdataexport{valueSlider} = epsfitdataexport;
% h.epsgammaergfunc{valueSlider} = epsgammaergfunc;
% 
% % assignin('base','tau1',tau)
% 
% h.taumean(valueSlider) = mean(tau);
% h.tau{valueSlider} = tau;
% h.sigmaFinal(valueSlider,:) = sigma;
% h.sigmaerrFinal(valueSlider,:) = sigmaerr;
% h.sigmasin2psiFinal(valueSlider) = sigmapardebye;
% h.deltasigmasin2psiFinal(valueSlider) = deltasigmapardebye;
% h.epssin2psifitdaten{valueSlider} = epssin2psifitdaten;
% h.sin2psifit{valueSlider} = sin2psifit;
% h.sin2psiregres{valueSlider}  = sin2psiregres;
% 
% assignin('base','h',h)
% 
% % h.StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmasin2psiFinal h.deltasigmasin2psiFinal];
% % h.StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmasin2psiFinal h.deltasigmasin2psiFinal];
% % assignin('base','StressResults',h.StressResults)
% % Plot results
% set(h.plotstressdata,'Xdata',h.taumean)
% set(h.plotstressdata,'Ydata',h.sigmaFinal(:,1))
% set(h.plotstressdata,'YNegativeDelta',h.sigmaerrFinal(:,1))
% set(h.plotstressdata,'YPositiveDelta',h.sigmaerrFinal(:,1))
% 
% set(h.plotsin2psistressdata,'Xdata',h.taumean)
% set(h.plotsin2psistressdata,'Ydata',h.sigmasin2psiFinal)
% set(h.plotsin2psistressdata,'YNegativeDelta',h.deltasigmasin2psiFinal)
% set(h.plotsin2psistressdata,'YPositiveDelta',h.deltasigmasin2psiFinal)
% 
% set(h.highlightstressplot,'xdata',h.taumean(valueSlider))
% set(h.highlightstressplot,'ydata',h.sigmaFinal(valueSlider,1))
% set(h.highlightstressplot,'Visible','on')
% 
% % % Delete respective peaks from fitresultdata
% % % Get index of fit object for each peak when using slider
% % for k = 1:size(h.fitresultexport,2)
% %     steps1{k} = repmat(k,1,size(h.fitresultexport{k},2));
% %     steps2{k} = 1:size(h.fitresultexport{k},2);
% % end
% % 
% % Ind1FitObj = cell2mat(reshape(steps1,size(steps1,2),1)')';
% % Ind2FitObj = cell2mat(reshape(steps2,size(steps2,2),1)')';
% % 
% % % Delete entries
% % fitresultexportmod = h.fitresultexport{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% % % fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% % 
% % fitresultexportmod(PointsToDelete) = cell(1,1);
% % h.fitresultexport{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = fitresultexportmod;
% % 
% % dataXcorrmod = h.dataXcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% % dataXcorrmod(PointsToDelete) = cell(1,1);
% % h.dataXcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = dataXcorrmod;
% % 
% % dataYcorrmod = h.dataYcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% % dataYcorrmod(PointsToDelete) = cell(1,1);
% % h.dataYcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = dataYcorrmod;
% % 
% % fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% % dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
% % dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];
% 
% 
% 
% % Delete entries
% fitresultexportmod = h.fitresultexport{valueSlider};
% % fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% 
% fitresultexportmod(pointslist) = cell(1,1);
% h.fitresultexport{valueSlider} = fitresultexportmod;
% 
% dataXcorrmod = h.dataXcorr{valueSlider};
% dataXcorrmod(pointslist) = cell(1,1);
% h.dataXcorr{valueSlider} = dataXcorrmod;
% 
% dataYcorrmod = h.dataYcorr{valueSlider};
% dataYcorrmod(pointslist) = cell(1,1);
% h.dataYcorr{valueSlider} = dataYcorrmod;
% 
% fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
% dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];
% 
% 
% % Set slider properties for fitted peak data
% set(h.SliderFittedPeaks,'Max',size(h.FitDataMod{valueSlider},1));
% set(h.SliderFittedPeaks,'SliderStep',[1/(size(h.FitDataMod{valueSlider},1)-1) 1/(size(h.FitDataMod{valueSlider},1)-1)]);
% set(h.SliderFittedPeaks, 'Value', 1);
% % assignin('base','PointsToDelete',PointsToDelete)
% % assignin('base','dataXcorrmod',dataXcorrmod)
% % assignin('base','dataYcorrmod',dataYcorrmod)
% % assignin('base','fitresultexportmod',fitresultexportmod)
% % assignin('base','fitresultexportmod',fitresultexportmod{valueSlider})
% yPeakCalc = feval(h.gaussEqnFirst,fitresultexportmod{valueSliderFittedPeaks},dataXcorrmod{valueSliderFittedPeaks});
% % yPeakCalc = feval(h.fitresultexport{Ind1FitObj(value)}{h.FitDataMod{value}(1,7),Ind2FitObj(value)},dataX);
% 
% set(h.plotRawData,'Xdata',dataXcorrmod{valueSliderFittedPeaks});
% set(h.plotRawData,'Ydata',dataYcorrmod{valueSliderFittedPeaks});
% set(h.plotRawData,'Visible','on')
% set(h.plotFitData,'Xdata',dataXcorrmod{valueSliderFittedPeaks});
% set(h.plotFitData,'Ydata',yPeakCalc);
% set(h.plotFitData,'Visible','on')
% 
% set(h.highlightpeakdata,'Xdata',h.epsfitdataexport{valueSlider}(1,1))
% set(h.highlightpeakdata,'Ydata',h.epsfitdataexport{valueSlider}(1,2))
% 
% % Plot tau data
% set(h.plottaudata,'Xdata',h.FitDataMod{valueSlider}(:,1))
% set(h.plottaudata,'Ydata',h.tau{valueSlider});
% 
% set(h.plottaudatamean,'Xdata',h.FitDataMod{valueSlider}(:,1))
% set(h.plottaudatamean,'Ydata',repelem(mean(h.tau{valueSlider}),size(h.FitDataMod{valueSlider},1)));
% 
% guidata(hObj, h);

function moddatacallback(hObj, ~)
h = guidata(hObj);

valueSlider = get(h.Slider, 'Value');
valueSliderFittedPeaks = get(h.SliderFittedPeaks, 'Value');

CheckBoxesPhi = [1 0 0 0];
PhiWinkel = {0};
h.axes.XLim = [-90,90];
[pointslist,~,~] = selectdatastressvalues('Axes',h.axes,'Handle',h.axes,'CheckBoxesPhi',CheckBoxesPhi,'PhiWinkel',PhiWinkel,'sel','lasso','action','delete','verify','on');

% PointsToDelete = h.FitDataMod{valueSlider}(pointslist,7);
% Delete selected point from fit data
h.FitDataMod{valueSlider}(pointslist,:) = [];

% % Delete respective peaks from fitresultdata
% % Get index of fit object for each peak when using slider
% for k = 1:size(h.fitresultexport,2)
%     steps1{k} = repmat(k,1,size(h.fitresultexport{k},2));
%     steps2{k} = 1:size(h.fitresultexport{k},2);
% end
% 
% Ind1FitObj = cell2mat(reshape(steps1,size(steps1,2),1)')';
% Ind2FitObj = cell2mat(reshape(steps2,size(steps2,2),1)')';
% 
% % Delete entries
% fitresultexportmod = h.fitresultexport{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% % fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% 
% fitresultexportmod(PointsToDelete) = cell(1,1);
% h.fitresultexport{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = fitresultexportmod;
% 
% dataXcorrmod = h.dataXcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% dataXcorrmod(PointsToDelete) = cell(1,1);
% h.dataXcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = dataXcorrmod;
% 
% dataYcorrmod = h.dataYcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider));
% dataYcorrmod(PointsToDelete) = cell(1,1);
% h.dataYcorr{Ind1FitObj(valueSlider)}(:,Ind2FitObj(valueSlider)) = dataYcorrmod;
% 
% fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
% dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
% dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];

% Delete entries
fitresultexportmod = h.fitresultexport{valueSlider};
% fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];

fitresultexportmod(pointslist) = cell(1,1);


dataXcorrmod = h.dataXcorr{valueSlider};
dataXcorrmod(pointslist) = cell(1,1);


dataYcorrmod = h.dataYcorr{valueSlider};
dataYcorrmod(pointslist) = cell(1,1);


fitresultexportmod(cellfun(@isempty,fitresultexportmod)) = [];
dataXcorrmod(cellfun(@isempty,dataXcorrmod)) = [];
dataYcorrmod(cellfun(@isempty,dataYcorrmod)) = [];

h.fitresultexport{valueSlider} = fitresultexportmod;
h.dataXcorr{valueSlider} = dataXcorrmod;
h.dataYcorr{valueSlider} = dataYcorrmod;

% Set plot data for fitted peak positions
set(h.plotdata,'Xdata',h.FitDataMod{valueSlider}(:,1))
set(h.plotdata,'Ydata',h.FitDataMod{valueSlider}(:,2))
set(h.plotdata,'YNegativeDelta',h.FitDataMod{valueSlider}(:,3))
set(h.plotdata,'YPositiveDelta',h.FitDataMod{valueSlider}(:,3))

[val,~,idxalpha] = unique(h.alpha);

if length(val) ~= length(idxalpha)
    group = h.FitDataMod{valueSlider}(:,8);
    classes = unique(group);
    
    idx1 = group == classes(1);
    
    set(h.plotdata1,'Xdata',h.FitDataMod{valueSlider}(idx1,1))
    set(h.plotdata1,'Ydata',h.FitDataMod{valueSlider}(idx1,2))
    set(h.plotdata1,'YNegativeDelta',h.FitDataMod{valueSlider}(idx1,3))
    set(h.plotdata1,'YPositiveDelta',h.FitDataMod{valueSlider}(idx1,3))
    
    idx2 = group == classes(2);
    
    set(h.plotdata2,'Xdata',h.FitDataMod{valueSlider}(idx2,1))
    set(h.plotdata2,'Ydata',h.FitDataMod{valueSlider}(idx2,2))
    set(h.plotdata2,'YNegativeDelta',h.FitDataMod{valueSlider}(idx2,3))
    set(h.plotdata2,'YPositiveDelta',h.FitDataMod{valueSlider}(idx2,3))
end

% Set slider properties for fitted peak data
set(h.SliderFittedPeaks,'Max',size(h.FitDataMod{valueSlider},1));
set(h.SliderFittedPeaks,'SliderStep',[1/(size(h.FitDataMod{valueSlider},1)-1) 1/(size(h.FitDataMod{valueSlider},1)-1)]);
set(h.SliderFittedPeaks, 'Value', 1);

% yPeakCalc = feval(h.gaussEqnFirst,fitresultexportmod{valueSliderFittedPeaks},dataXcorrmod{valueSliderFittedPeaks});
yPeakCalc = feval(h.gaussEqnFirst,fitresultexportmod{1},dataXcorrmod{1});
% yPeakCalc = feval(h.fitresultexport{Ind1FitObj(value)}{h.FitDataMod{value}(1,7),Ind2FitObj(value)},dataX);

set(h.plotRawData,'Xdata',dataXcorrmod{1});
set(h.plotRawData,'Ydata',dataYcorrmod{1});
set(h.plotRawData,'Visible','on')
set(h.plotFitData,'Xdata',dataXcorrmod{1});
set(h.plotFitData,'Ydata',yPeakCalc);
set(h.plotFitData,'Visible','on')

set(h.highlightpeakdata,'Xdata',h.FitDataMod{valueSlider}(1,1))
set(h.highlightpeakdata,'Ydata',h.FitDataMod{valueSlider}(1,2))

guidata(hObj, h);

function exportfitdatacallback(hObj, ~)
h = guidata(hObj);

% Export stress reuslts in form of table
[FileName, PathName] = uiputfile('.txt','Save Fit data to file',[General.ProgramInfo.Path,'\Data\Results\Pilatus-2DXRD\']);

col = get(hObj,'backg');  % Get the background color of the figure.
set(hObj,'String','Exporting data ...','backg',[1 .6 .6]) % Change color of button. 
% The pause (or drawnow) is necessary to make button changes appear.
pause(.01)

PathNameExport = fullfile([PathName,['Bins_',num2str(h.BinSize)],'\']);

if exist(PathNameExport,'dir') ~= 7
    mkdir(PathNameExport);
end

if isequal(FileName, 0) || isequal(PathName, 0)
    disp('User canceled the save operation.')
else

    for k = 1:size(h.FitDataMod,1)
        % Open the file for writing
        FileNameExport = [FileName(1:end-4),'_Peak_',num2str(k),'.txt'];
        fileID = fopen(fullfile([PathNameExport, FileNameExport]), 'w');

        % Write the header
        % fprintf(fileID,'%5s\t %7s\t %11s\t %9s\t %5s\t %5s\t %10s\t \r\n','Gamma','2theta','2theta_err','Amplitude','Width','alpha','Peak count');
        % NEU:
        % fprintf(fileID,'%5s\t %7s\t %11s\t %9s\t %5s\t %5s\t %5s\t %10s\t \r\n',...
        %     'Gamma','2theta','2theta_err','Amplitude','FWHM','Eta','alpha','Peak count');
        % 
        % % Write the matrix
        % fclose(fileID); % Close and reopen to use writematrix

        % NEU:
        try
            fileID = fopen(fullfile(PathNameExport, FileName), 'w');
            if fileID == -1
                error('Datei konnte nicht geöffnet werden: %s', fullfile(PathNameExport, FileName));
            end
            fprintf(fileID,'%5s\t %7s\t %11s\t %9s\t %5s\t %5s\t %5s\t %10s\t \r\n',...
            'Gamma','2theta','2theta_err','Amplitude','FWHM','Eta','alpha','Peak count');
            fclose(fileID);
        catch ME
            if fileID ~= -1
                fclose(fileID);  % Datei auf jeden Fall schließen
            end
            errordlg(sprintf('Export fehlgeschlagen:\n%s', ME.message), 'Exportfehler');
            set(hObj, 'String', 'Export Fit Data', 'backg', col);
            return
        end
        writematrix(h.FitDataMod{k},fullfile([PathNameExport, FileNameExport]),'Delimiter','tab', 'WriteMode', 'append');
    end
end

FileNameGraph = [FileName(1:end-4),'_Peak_',num2str(k)];

% Export fit of epsilon data
for k = 1:size(h.FitDataMod,1)
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
    ax.YLabel.String = ['2',char(952),' [°]'];
    ax.YLabel.FontSize = 12;
    ax.XLabel.String = [char(947),' [°]'];
    ax.XLabel.FontSize = 12;
    ax.XLim = [-90 90];
    ax.YLim = [-Inf,Inf];
    xticks(-90:10:90)
    ax.LabelFontSizeMultiplier = 1;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',12)
    hold on
    set(fig, 'Visible', 'off');

    errorbar(h.FitDataMod{k}(:,1),h.FitDataMod{k}(:,2),h.FitDataMod{k}(:,3),'s'); 

    % Bereich inkl. Fehler
    y_min = min(h.FitDataMod{k}(:,2) - h.FitDataMod{k}(:,3));
    y_max = max(h.FitDataMod{k}(:,2) + h.FitDataMod{k}(:,3));

    % Abstände berechnen (10 % des Wertebereichs)
    y_range = y_max - y_min;
    margin = 0.2 * y_range;  % 5% Puffer oben und unten

    % Neue Limits setzen
    ylim([y_min - margin, y_max + margin]);

    LegLabeldata = [num2str(h.DEKdataMatchedPeaks(k,1:3))];
    % Create legend
    l = legend(LegLabeldata);

    l.FontSize = 10;
    l.LineWidth = 0.5;
    l.Location = 'northeast';

    FileName1 = [FileName(1:end-4),'_Peak_',num2str(k)];

    print(fig,[PathNameExport,FileName1],'-painters','-dtiff','-r300')
end

% Reset the button color
set(hObj,'String','Export Fit Data','backg',col)  % Now reset the button features.

guidata(hObj, h);

function exportstressdatacallback(hObj, ~)
h = guidata(hObj);

spannkomp = str2double(get(h.SpannKompEditField, "String"));

if spannkomp == 1122
    StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmasin2psiFinal h.deltasigmasin2psiFinal h.alphaexport];
elseif spannkomp == 112213
    StressResults = [h.taumean h.sigmaFinal(:,1) h.sigmaerrFinal(:,1) h.sigmaFinal(:,2) h.sigmaerrFinal(:,2) h.sigmaFinal(:,3) h.sigmaerrFinal(:,3) h.sigmasin2psiFinal h.deltasigmasin2psiFinal h.alphaexport];
end

% Export stress reuslts in form of table
[FileName, PathName] = uiputfile('*.txt','Save Stress data to file',[General.ProgramInfo.Path,'\Data\Results\Pilatus-2DXRD\']);

col = get(hObj,'backg');  % Get the background color of the figure.
set(hObj,'String','Exporting data ...','backg',[1 .6 .6]) % Change color of button. 
% The pause (or drawnow) is necessary to make button changes appear.
pause(.01)

PathNameExport = fullfile([PathName,['Bins_',num2str(h.BinSize)],'\']);

if exist(PathNameExport,'dir') ~= 7
    mkdir(PathNameExport);
end

if isequal(FileName, 0) || isequal(PathName, 0)
    disp('User canceled the save operation.')
else
    % Open the file for writing
    % fileID = fopen(fullfile([PathNameExport, FileName]), 'w');

    % NEU:
    try
        fileID = fopen(fullfile(PathNameExport, FileName), 'w');
        if fileID == -1
            error('Datei konnte nicht geöffnet werden: %s', fullfile(PathNameExport, FileName));
        end
        % Write the header
        if spannkomp == 1122
            fprintf(fileID,'%3s\t %7s\t %11s\t %7s\t %11s\t %15s\t %19s\t %5s\t %5s\t %5s\t %5s \r\n','tau','sigma11','sigma11_Err','sigma22','sigma22_Err','sigma11_sin2psi','sigma11_sin2psi_Err','alpha','h','k','l');
        elseif spannkomp == 112213
            fprintf(fileID,'%3s\t %7s\t %11s\t %7s\t %11s\t %7s\t %11s\t %15s\t %19s\t %5s \t %5s\t %5s\t %5s\r\n','tau','sigma11','sigma11_Err','sigma22','sigma22_Err','sigma13','sigma13_Err','sigma11_sin2psi','sigma11_sin2psi_Err','alpha','h','k','l');
        end
        fclose(fileID);
    catch ME
        if fileID ~= -1
            fclose(fileID);  % Datei auf jeden Fall schließen
        end
        errordlg(sprintf('Export fehlgeschlagen:\n%s', ME.message), 'Exportfehler');
        set(hObj, 'String', 'Export Fit Data', 'backg', col);
        return
    end
    
    % % Write the header
    % if spannkomp == 1122
    %     fprintf(fileID,'%3s\t %7s\t %11s\t %7s\t %11s\t %15s\t %19s\t %5s\t %5s\t %5s\t %5s \r\n','tau','sigma11','sigma11_Err','sigma22','sigma22_Err','sigma11_sin2psi','sigma11_sin2psi_Err','alpha','h','k','l');
    % elseif spannkomp == 112213
    %     fprintf(fileID,'%3s\t %7s\t %11s\t %7s\t %11s\t %7s\t %11s\t %15s\t %19s\t %5s \t %5s\t %5s\t %5s\r\n','tau','sigma11','sigma11_Err','sigma22','sigma22_Err','sigma13','sigma13_Err','sigma11_sin2psi','sigma11_sin2psi_Err','alpha','h','k','l');
    % end
    % 
    % % Write the matrix
    % fclose(fileID); % Close and reopen to use writematrix
    if spannkomp == 1122
        writematrix([round(StressResults(:,1),4) round(StressResults(:,[2:7]),0) StressResults(:,8) h.DEKdataMatchedPeaks(:,1:3)],fullfile([PathNameExport, FileName]),'Delimiter','tab', 'WriteMode', 'append')
    elseif spannkomp == 112213
        writematrix([round(StressResults(:,1),4) round(StressResults(:,[2:9]),0) StressResults(:,10) h.DEKdataMatchedPeaks(:,1:3)],fullfile([PathNameExport, FileName]),'Delimiter','tab', 'WriteMode', 'append')
    end
end

assignin('base','sin2psiData',h.epssin2psifitdaten)
assignin('base','sin2psiRegressData',h.sin2psiregres)
assignin('base','SFFitData',h.epsfitdataexport)
assignin('base','SFFitRegressData',h.epsgammaergfunc)

h.FileNameLoad{1} = strrep(h.FileNameLoad{1},'.','-');

% Export fit of epsilon data
for k = 1:size(h.epsfitdataexport,2)
    figure
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPositionMode = 'manual';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.085 1.025];
    ax.TickDir = 'out';
    ax.YAxis.TickLabelFormat = '%,.1f';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;
    ax.YLabel.String = [char(949),'(',char(947),')'];
    ax.YLabel.FontSize = 12;
    ax.XLabel.String = [char(947),' [°]'];
    ax.XLabel.FontSize = 12;
    ax.XLim = [-90 90];
    ax.YLim = [-Inf,Inf];
    xticks(-90:10:90)
    ax.LabelFontSizeMultiplier = 1;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',12)
    hold on
    set(fig, 'Visible', 'off');

    errorbar(h.epsfitdataexport{k}(:,1),h.epsfitdataexport{k}(:,2),h.epsfitdataexport{k}(:,3),'s'); 
    plot(h.epsfitdataexport{k}(:,1),h.epsgammaergfunc{k}','-');

    % Bereich inkl. Fehler
    y_min = min(h.epsfitdataexport{k}(:,2) - h.epsfitdataexport{k}(:,3));
    y_max = max(h.epsfitdataexport{k}(:,2) + h.epsfitdataexport{k}(:,3));

    % Abstände berechnen (10 % des Wertebereichs)
    y_range = y_max - y_min;
    margin = 0.05 * y_range;  % 5% Puffer oben und unten

    % Neue Limits setzen
    ylim([y_min - margin, y_max + margin]);

    LegLabeldata = [num2str(h.DEKdataMatchedPeaks(k,1:3)),' - ',char(945),' = ',num2str(h.StressResults(k,8)),'°'];
    % Create legend
    l = legend(LegLabeldata);

    l.FontSize = 10;
    l.LineWidth = 0.5;
    l.Location = 'northwest';

    FileName1 = sprintf([strrep(h.FileNameLoad{1}(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_epsilonfit_Line_','%d'],k);

    print(fig,[PathNameExport,FileName1],'-painters','-dtiff','-r300')
end

% Export fit of sin2psi data
for k = 1:size(h.epsfitdataexport,2)
    figure
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPositionMode = 'manual';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.085 1.025];
    ax.TickDir = 'out';
    ax.YAxis.TickLabelFormat = '%,.1f';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;
    ax.YLabel.String = [char(949),'(',char(947),')'];
    ax.YLabel.FontSize = 12;
    ax.XLabel.String = ['sin²',char(968)];
    ax.XLabel.FontSize = 12;

    ax.XLim = [0 1];
    % ax.YLim = [-Inf,Inf];

    ax.LabelFontSizeMultiplier = 1;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',12)
    hold on
    set(fig, 'Visible', 'off');

    errorbar(h.epssin2psifitdaten{k}(:,1),h.epssin2psifitdaten{k}(:,2),h.epssin2psifitdaten{k}(:,3),'s'); 
    plot((0:0.05:1),h.sin2psiregres{k},'-');

    % Bereich inkl. Fehler
    y_min = min(h.epssin2psifitdaten{k}(:,2) - h.epssin2psifitdaten{k}(:,3));
    y_max = max(h.epssin2psifitdaten{k}(:,2) + h.epssin2psifitdaten{k}(:,3));

    % Abstände berechnen (10 % des Wertebereichs)
    y_range = y_max - y_min;
    margin = 0.05 * y_range;  % 5% Puffer oben und unten

    % Neue Limits setzen
    ylim([y_min - margin, y_max + margin]);

    LegLabeldata = [num2str(h.DEKdataMatchedPeaks(k,1:3)),' - ',char(945),' = ',num2str(h.StressResults(k,8)),'°'];
    % Create legend
    l = legend(LegLabeldata);

    l.FontSize = 10;
    l.LineWidth = 0.5;

    FileName1 = sprintf([strrep(h.FileNameLoad{1}(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_sin2psifit_Line_','%d'],k);

    print(fig,[PathNameExport,FileName1],'-painters','-dtiff','-r300')
end

% Export plot of stress data
figure
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPositionMode = 'manual';
fig.PaperPosition = [0 0 18 12];
ax = gca;
ax.OuterPosition = [0 0 1.085 1.025];
ax.TickDir = 'out';
ax.YAxis.TickLabelFormat = '%.0f';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 0.3;
ax.YLabel.String = [char(963),' [MPa]'];
ax.YLabel.FontSize = 12;
ax.XLabel.String = [char(964),' [',char(956),'m]'];
ax.XLabel.FontSize = 12;

ax.XLim = [0 5];
% ax.YLim = [-Inf,Inf];

ax.LabelFontSizeMultiplier = 1;
ax.LineWidth = 1.3;
set(gca,'FontSize',12)
hold on
set(fig, 'Visible', 'off');

errorbar(h.taumean,h.sigmaFinal(:,1),h.sigmaerrFinal(:,1),'s');
errorbar(h.taumean,h.sigmasin2psiFinal,h.deltasigmasin2psiFinal,'o');

% --- Berechnung der Y-Grenzen ---
y_min = min(h.sigmaFinal(:,1) - h.sigmaerrFinal(:,1));
y_max = max(h.sigmaFinal(:,1) + h.sigmaerrFinal(:,1));

% Wertebereich bestimmen
range = y_max - y_min;

% --- Schrittweite automatisch bestimmen ---
% (Wenn Daten klein sind → 10er; mittel → 100er; groß → 1000er etc.)
if range < 100
    step = 10;
elseif range < 1000
    step = 100;
else
    step = 1000;
end

% --- Grenzen runden ---
y_lower = floor(y_min / step) * step;  % nach unten abrunden
y_upper = ceil(y_max / step) * step;   % nach oben aufrunden

% --- Neue Grenzen setzen ---
ylim([y_lower, y_upper]);


% --- Dynamische X-Achsenobergrenze ---
x_max_val = max(h.taumean);  % größter X-Wert

% Hier wird geprüft, in welchem Intervall x_max_val liegt:
if x_max_val <= 5
    x_upper = 5;
elseif x_max_val <= 10
    x_upper = 10;
elseif x_max_val <= 15
    x_upper = 15;
elseif x_max_val <= 20
    x_upper = 20;
elseif x_max_val <= 30
    x_upper = 30;
elseif x_max_val <= 50
    x_upper = 50;
else
    % falls größer, auf das nächste Vielfache von 10 runden
    x_upper = ceil(x_max_val/10)*10;
end

% Untere Grenze automatisch vom Minimum abhängig machen (optional)
% x_lower = min(x);
xlim([0, x_upper]);

LegLabeldata = {'Stressfactor-method','sin²psi-method'};
% Create legend
l = legend(LegLabeldata);
l.Location = 'northwest';

l.FontSize = 10;
l.LineWidth = 0.5;

FileName1 = sprintf([strrep(h.FileNameLoad{1}(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_stressdata']);

print(fig,[PathNameExport,FileName1],'-painters','-dtiff','-r300')


% Export plot of labeled stress data
figure
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPositionMode = 'manual';
fig.PaperPosition = [0 0 18 12];
ax = gca;
ax.OuterPosition = [0 0 1.085 1.025];
ax.TickDir = 'out';
ax.YAxis.TickLabelFormat = '%.0f';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 0.3;
ax.YLabel.String = [char(963),' [MPa]'];
ax.YLabel.FontSize = 12;
ax.XLabel.String = [char(964),' [',char(956),'m]'];
ax.XLabel.FontSize = 12;

ax.XLim = [0 5];
% ax.YLim = [-Inf,Inf];

ax.LabelFontSizeMultiplier = 1;
ax.LineWidth = 1.3;
set(gca,'FontSize',12)
hold on
set(fig, 'Visible', 'off');

errorbar(h.taumean,h.sigmaFinal(:,1),h.sigmaerrFinal(:,1),'s');
errorbar(h.taumean,h.sigmasin2psiFinal,h.deltasigmasin2psiFinal,'o');

% --- Berechnung der Y-Grenzen ---
y_min = min(h.sigmaFinal(:,1) - h.sigmaerrFinal(:,1));
y_max = max(h.sigmaFinal(:,1) + h.sigmaerrFinal(:,1));

% Wertebereich bestimmen
range = y_max - y_min;

% --- Schrittweite automatisch bestimmen ---
% (Wenn Daten klein sind → 10er; mittel → 100er; groß → 1000er etc.)
if range < 100
    step = 10;
elseif range < 1000
    step = 100;
else
    step = 1000;
end

% --- Grenzen runden ---
y_lower = floor(y_min / step) * step;  % nach unten abrunden
y_upper = ceil(y_max / step) * step;   % nach oben aufrunden

% --- Neue Grenzen setzen ---
ylim([y_lower, y_upper]);


% --- Dynamische X-Achsenobergrenze ---
x_max_val = max(h.taumean);  % größter X-Wert

% Hier wird geprüft, in welchem Intervall x_max_val liegt:
if x_max_val <= 5
    x_upper = 5;
elseif x_max_val <= 10
    x_upper = 10;
elseif x_max_val <= 15
    x_upper = 15;
elseif x_max_val <= 20
    x_upper = 20;
elseif x_max_val <= 30
    x_upper = 30;
elseif x_max_val <= 50
    x_upper = 50;
else
    % falls größer, auf das nächste Vielfache von 10 runden
    x_upper = ceil(x_max_val/10)*10;
end

% Untere Grenze automatisch vom Minimum abhängig machen (optional)
% x_lower = min(x);
xlim([0, x_upper]);

LegLabeldata = {'Stressfactor-method','sin²psi-method'};
% Create legend
l = legend(LegLabeldata);
l.Location = 'northwest';

l.FontSize = 10;
l.LineWidth = 0.5;

for k = 1:size(h.DEKdataMatchedPeaks,1)
   hkllabestressplot{k} = num2str(h.DEKdataMatchedPeaks(k,1:3));
end

% Label der Spannungswerte
hold on;

x = h.taumean(:,1);
y = h.sigmaFinal(:,1);
err = h.sigmaerrFinal(:,1);

base_dx = 0.075 * abs(abs(max(h.taumean(:,1))) - abs(min(h.taumean(:,1))));  % enger horizontaler Abstand
base_dy = 0.005 * abs(abs(max(h.sigmaFinal(:,1))) - abs(min(h.sigmaFinal(:,1))));   % kleiner vertikaler Schritt
min_dist = 0.025 * abs(abs(max(h.sigmaFinal(:,1))) - abs(min(h.sigmaFinal(:,1))));  % Mindestabstand zwischen Labels
max_iter = 150;

% --- Startpositionen ---
label_pos = zeros(length(x), 2);
for i = 1:length(x)
    side = (-1)^(i);  % abwechselnd rechts/links
    dx = side * base_dx * (1 + 0.3 * rand);
    label_pos(i,:) = [x(i) + dx, y(i)];
end

% --- Iterative Optimierung ---
for iter = 1:max_iter
    moved = false;
    for i = 1:length(x)
        % --- 1. Abstand zu anderen Labels prüfen ---
        for j = 1:length(x)
            if i == j, continue; end
            dist = sqrt((label_pos(i,1)-label_pos(j,1))^2 + (label_pos(i,2)-label_pos(j,2))^2);
            if dist < min_dist
                moved = true;
                % leicht vertikal verschieben, zufällige Richtung
                label_pos(i,2) = label_pos(i,2) + sign(rand-0.5) * base_dy;
            end
        end

        % --- 2. Vermeidung von Überdeckung mit Fehlerbalken ---
        for j = 1:length(x)
            y_low = y(j) - err(j);
            y_high = y(j) + err(j);

            if abs(label_pos(i,1) - x(j)) < 0.015 * abs(abs(max(h.taumean(:,1))) - abs(min(h.taumean(:,1))))
                if label_pos(i,2) > y_low && label_pos(i,2) < y_high
                    moved = true;
                    if label_pos(i,2) < y(j)
                        label_pos(i,2) = y_low - 0.3*base_dy;
                    else
                        label_pos(i,2) = y_high + 0.3*base_dy;
                    end
                end
            end
        end

        % --- 3. Vermeidung von Punktüberdeckung ---
        if abs(label_pos(i,2) - y(i)) < 0.3*base_dy
            label_pos(i,2) = y(i) + sign(rand-0.5)*base_dy;
        end
    end

    % Wenn in dieser Iteration keine Labels mehr verschoben wurden → fertig
    if ~moved
        break;
    end
end

% --- Zeichne Labels ---
for i = 1:length(x)
    halign = 'left';
    if label_pos(i,1) < x(i)
        halign = 'right';
    end
    text(label_pos(i,1), label_pos(i,2), hkllabestressplot{i}, ...
        'FontSize', 7, 'Color', 'b', ...
        'HorizontalAlignment', halign, ...
        'VerticalAlignment', 'middle', ...
        'BackgroundColor', 'w', 'Margin', 0.2);

    p = line([x(i), label_pos(i,1)], [y(i), label_pos(i,2)], 'Color','k', 'LineStyle','-', 'LineWidth',0.6);
    set(p, 'HandleVisibility', 'off');
end

hold off;

FileName1 = sprintf([strrep(h.FileNameLoad{1}(1:end-4),' ',''),'_',h.Sample.Materials.Name,'_stressdatalabeled']);

print(fig,[PathNameExport,FileName1],'-painters','-dtiff','-r300')

% Reset the button color
set(hObj,'String','Export Stress Data','backg',col)  % Now reset the button features.

guidata(hObj, h);

function definepeakscallback(hObj,~)
% Callback for "pop up menu" in create sample panel
h = guidata(hObj);

% Messagebox
k = msgbox('Please add the peaks you want to fit. Confirm by Enter.');
% Wait for user to press ok
uiwait(k);
% Show explanatory text for definitioin of background points
% textbkg = text(h.axesPlotIntensityData,'Units','normalized','Position',[0.3 0.95 0],...
%     'BackgroundColor',[1 1 1],'EdgeColor', [0 0 0], ...
%     'String','Push \textbf{enter} to resume | \textbf{return} to undo',...
%     'interpreter','latex','FontSize', 16);

% Get points selected from user
[UP,~] = getpts(h.axesPlotIntensityData);

% % Set explanatory text visible off
% set(textbkg,'Visible','off')

k = msgbox('Peaks for peak search successfully defined.');
% Wait for user to press ok
uiwait(k);

h.UserPeaks = UP;

% UserPeaksdata = get(h.tableUserDefinedPeaks,'data');

UserPeaksdatanew = [UP, zeros(length(UP),1), zeros(length(UP),1)];

set(h.tableUserDefinedPeaks,'data',UserPeaksdatanew);

guidata(hObj, h);

function clearbuttondown(hObj,~)
set(hObj, 'String','','Enable','on');
uicontrol(hObj);

guidata(hObj);