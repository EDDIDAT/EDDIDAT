function XRD2DStressAnalysis_modPV_pyFAI_Backup27032026()

% ---- Startgröße ermitteln ----
scr  = get(0,'ScreenSize');
figW = min(round(scr(3)*0.92), 2200);
figH = min(round(scr(4)*0.88), 1050);
figL = round((scr(3)-figW)/2);
figB = round((scr(4)-figH)/2);

h.myfig = figure(...
    'Name',           '2DXRD Stress Analysis', ...
    'MenuBar',        'none', ...
    'ToolBar',        'auto', ...
    'Units',          'pixels', ...
    'Position',       [figL figB figW figH], ...
    'SizeChangedFcn', @resizecallback);

% ---- Layout-Konstanten (normiert) ----
% Linke Spalte: x = 0 .. LW
% Mittlerer Bereich (Tabs): x = LW+GAP .. LW+GAP+MW
% Rechter Bereich: x = LW+GAP+MW+GAP .. 1
LW  = 0.230;   % linke Spaltenbreite
MW  = 0.515;   % mittlere Bereichsbreite
GAP = 0.006;   % Abstand zwischen Bereichen
RX  = LW + GAP;           % Startx Mitte
RX2 = LW + GAP + MW + GAP;% Startx rechts
RW  = 1 - RX2 - GAP;      % Breite rechts
P   = 0.004;   % inneres Padding links

% Zeilenhöhen (normiert)
RH  = 0.032;   % Standard Button/Edit
RH2 = 0.026;   % Text-Labels

% =========================================================
% KOPFZEILE  y = 0.955..0.988
% =========================================================
Files = dir(fullfile('Data','Materials','*.mpd'));
MPDFileNameList = cell(size(Files,1),1);
for i = 1:size(Files,1)
    [~,MPDFileNameList{i},~] = fileparts(Files(i).name);
end
MPDFileNameList = MPDFileNameList';

h.SampleFormulaeEditField = uicontrol('parent',h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[P 0.957 LW*0.40 RH],...
    'String','Elemental formula','HorizontalAlignment','center',...
    'Enable','inactive','Tag','FilenameSample',...
    'ButtonDownFcn',{@clearbuttondown});

h.popupmenumpd1 = uicontrol('Parent',h.myfig,...
    'Style','popupmenu','Units','normalized',...
    'Position',[LW*0.42 0.957 LW*0.32 RH],...
    'Tag','popupmenumpd1','String',MPDFileNameList,...
    'Value',1,'Callback',{@popupmenuCallback});

h.CreateSampleButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.76 0.957 LW*0.22 RH],...
    'String','Create Sample','Callback',@createsamplecallback);

% =========================================================
% BLOCK 1: Load 2D images   y=0.915..0.950
% =========================================================
h.LoadImageButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[P 0.918 LW*0.52 RH],...
    'String','Load 2D image(s)','Callback',@openfilecallback);

h.FileNameEditField = uicontrol(h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[P 0.884 LW-P RH2],...
    'String','File Name','HorizontalAlignment','center',...
    'Tag','FilenameData');

% =========================================================
% BLOCK 2: Load PONI + Alpha   y=0.845..0.878
% =========================================================
h.LoadGammaDataButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[P 0.848 LW*0.52 RH],...
    'String','Load PONI Files','Callback',@opengammafilecallback);

h.AlphaText1 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.54 0.851 LW*0.06 RH2],'String',char(945));
h.AlphaText2 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.60 0.851 LW*0.05 RH2],'String','=');
h.AlphaEditField = uicontrol(h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[LW*0.66 0.848 LW*0.32 RH2],...
    'String','alpha','HorizontalAlignment','center','Tag','AlphaEditField');

h.GammaFileNameEditField = uicontrol(h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[P 0.814 LW-P RH2],...
    'String','PONI File(s)','HorizontalAlignment','center','Tag','GammaFilename');

% =========================================================
% BLOCK 2b: Python-Konfiguration   y=0.748..0.808
% =========================================================
h.pythonExeText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.786 LW*0.24 RH2],...
    'HorizontalAlignment','left','String','Python exe');
h.pythonExeEdit = uicontrol(h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[LW*0.26 0.784 LW*0.72 RH2],...
    'String', "C:\Users\hrp\AppData\Local\Programs\Python\Python311\venv\Scripts\python.exe", ...
    'HorizontalAlignment','left','Tag','pythonExe');

h.scriptPathText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.754 LW*0.24 RH2],...
    'HorizontalAlignment','left','String','Script path');
h.scriptPathEdit = uicontrol(h.myfig,...
    'Style','edit','Units','normalized',...
    'Position',[LW*0.26 0.752 LW*0.72 RH2],...
    'String',fullfile(pwd,'pyfai_multigeom_run.py'),...
    'HorizontalAlignment','left','Tag','scriptPath');

% =========================================================
% BLOCK 3: pyFAI / Binning Parameter   y=0.648..0.746
% =========================================================
h.PyFAIParamText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.722 LW-P RH2],...
    'HorizontalAlignment','left','FontWeight','bold',...
    'String','pyFAI / Binning Parameter');

% Zeile 1: chi-Range
h.trackChiRangeMinText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.694 LW*0.24 RH2],'HorizontalAlignment','left',...
    'String',[char(967),'-min']);
h.trackChiRangeMinEdit = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.18 0.692 LW*0.20 RH2],...
    'String','-180','HorizontalAlignment','center','Tag','trackChiRangeMin');
h.trackChiRangeMaxText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.41 0.694 LW*0.24 RH2],'HorizontalAlignment','left',...
    'String',[char(967),'-max']);
h.trackChiRangeMaxEdit = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.58 0.692 LW*0.20 RH2],...
    'String','0','HorizontalAlignment','center','Tag','trackChiRangeMax');

% Zeile 2: Chi-Bin | Chi avg
h.trackChiBinText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.663 LW*0.24 RH2],'HorizontalAlignment','left',...
    'String','Chi-Bin step','Tooltip','trackChiBin: jeden n-ten chi-Bin verwenden');
h.trackChiBinEdit = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.18 0.661 LW*0.20 RH2],...
    'String','4','HorizontalAlignment','center','Tag','trackChiBin');
h.trackChiAvgBinsText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.41 0.663 LW*0.24 RH2],'HorizontalAlignment','left',...
    'String','Chi avg +/-','Tooltip','trackChiAvgBins: Mittelung +/- n chi-Bins');
h.trackChiAvgBinsEdit = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.58 0.661 LW*0.20 RH2],...
    'String','4','HorizontalAlignment','center','Tag','trackChiAvgBins');

% Zeile 3: Smooth | Baseline
h.smoothPointsText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.632 LW*0.24 RH2],'HorizontalAlignment','left','String','Smooth pts');
h.smoothPointsEdit = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.18 0.630 LW*0.20 RH2],...
    'String','5','HorizontalAlignment','center','Tag','smoothPoints');
h.baselineModeText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.41 0.632 LW*0.22 RH2],'HorizontalAlignment','left','String','Baseline');
h.baselineModePopup = uicontrol(h.myfig,'Style','popupmenu','Units','normalized',...
    'Position',[LW*0.58 0.630 LW*0.20 RH2],...
    'String',{'none','movmin'},'Value',2,'Tag','baselineMode');

h.RebinButton = uicontrol(h.myfig, ...
    'Style',    'Pushbutton', ...
    'Units',    'normalized', ...
    'Position', [LW*0.795 0.6885 LW*0.22 RH], ...
    'String',   'Rebin Data', ...
    'Enable',   'off', ...        % erst aktiv nach Load PONI
    'Tooltip',  'Binning mit aktuellen chi-Parametern neu ausführen', ...
    'Callback', @rebindatacallback);

% =========================================================
% BLOCK 4: 2theta range   y=0.578..0.622
% =========================================================
h.ChangetwothetaText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.600 LW*0.46 RH2],...
    'String',['Select 2',char(952),' range']);
h.twothetaminEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[P 0.572 LW*0.32 RH2],...
    'String',['2',char(952),' min'],'HorizontalAlignment','center',...
    'Enable','inactive','ButtonDownFcn',{@clearbuttondown},'Tag','twothetaminEditField');
h.twothetamaxEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.34 0.572 LW*0.32 RH2],...
    'String',['2',char(952),' max'],'HorizontalAlignment','center',...
    'Enable','inactive','ButtonDownFcn',{@clearbuttondown},'Tag','twothetamaxEditField');
h.ChangetwothetarangeButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.68 0.570 LW*0.30 RH],...
    'String',['Change 2',char(952),' range'],'Callback',@changetwothetarangecallback);

% =========================================================
% BLOCK 5: Peak search options   y=0.422..0.562
% =========================================================
h.PeakSearchOptionsText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.540 LW*0.60 RH2],'String','Peak search options');

% Prominence
h.PeakProminenceText1 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.511 LW*0.50 RH2],'HorizontalAlignment','left',...
    'String','Prominence threshold',...
    'Tooltip','Peak prominence relative to surroundings');
h.PeakProminenceEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.52 0.509 LW*0.18 RH2],...
    'String','0.2','HorizontalAlignment','center','Tag','PeakProminenceEditField');
h.DefinePeaksButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.72 0.507 LW*0.26 RH],...
    'String','Define peaks','Tooltip','Define peaks for analysis.',...
    'Callback',@definepeakscallback);

% Peak window
h.PeakWindowText1 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.480 LW*0.50 RH2],'HorizontalAlignment','left',...
    'String','Peak window',...
    'Tooltip','Interval around peak for data collection');
h.PeakWindowEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.52 0.478 LW*0.18 RH2],...
    'String','1','HorizontalAlignment','center','Tag','PeakWindowEditField');
% h.SearchPeaksButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
%     'Position',[LW*0.72 0.476 LW*0.26 RH],...
%     'String','Search peaks','Tooltip','Search peaks using options.',...
%     'Callback',@searchpeakscallback);

% Min height
h.PeakHeightText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.449 LW*0.50 RH2],'HorizontalAlignment','left',...
    'String','Min peak height');
h.PeakMinHeightEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.52 0.447 LW*0.18 RH2],...
    'String','3','HorizontalAlignment','center','Tag','PeakMinHeight');

% =========================================================
% BLOCK 6: User-defined peaks table   y=0.262..0.440
% =========================================================
datatmpUP = zeros(8,2);
h.tableUserDefinedPeaks = uitable(h.myfig,...
    'Units','normalized',...
    'Position',[P 0.262 LW-P 0.178],...
    'ColumnName',{'EPos-User','Peak count','Use'},...
    'Data',[num2cell(datatmpUP),num2cell(datatmpUP(:,1)>0)],...
    'Tag','tableUserDefinedPeaks',...
    'ColumnFormat',{'numeric','numeric','logical'},...
    'ColumnEditable',[false false true],...
    'ColumnWidth',{100 100 55});

% =========================================================
% BLOCK 7: Load DEC + Fit Peaks   y=0.226..0.258
% =========================================================
h.LoadDECdataButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[P 0.228 LW*0.46 RH],...
    'String','Load DEC data','Tooltip','Load DEC data manually.',...
    'Callback',@loadDECdatacallback);
h.FitPeaksButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.49 0.228 LW*0.49 RH],...
    'String','Start Peak Fit','Tooltip','Start fitting of found peaks.',...
    'Callback',@trackfitpeakscallback);

% NEU: Filter-Button
h.FilterPeaksButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.48 0.1864 LW*0.22 RH],...
    'String','Filter Peaks ...',...
    'Enable','off',...        % erst aktiv nach Track & Fit
    'FontSize', 9,...
    'Tooltip','Peaks nach R², Fehler und SNR filtern',...
    'Callback',@filterpeakscallback);


% =========================================================
% BLOCK 8: Absorption + Stress + Buttons   y=0.002..0.096
% =========================================================
h.AbscoeffText1 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.068 LW*0.32 RH2],'HorizontalAlignment','left',...
    'String','Abs. coeff.');
h.AbscoeffText2 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.34 0.071 LW*0.07 RH2],'String',char(956));
h.AbscoeffText3 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[LW*0.41 0.071 LW*0.06 RH2],'String','=');
h.AbscoeffEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.48 0.066 LW*0.22 RH2],...
    'String','0','HorizontalAlignment','center','Tag','AbscoeffEditField');

h.ModDataButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.72 0.1864 LW*0.26 RH],...
    'String','Modify Data','Callback',@moddatacallback);

h.SpannKompText1 = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.034 LW*0.46 RH2],'HorizontalAlignment','left',...
    'String','Stress components');
h.SpannKompEditField = uicontrol(h.myfig,'Style','edit','Units','normalized',...
    'Position',[LW*0.48 0.032 LW*0.22 RH2],...
    'String','1122','HorizontalAlignment','center','Tag','SpannKompEditField');

% Auswahl Peaklage für Stressfit
h.peakMethodGroup = uibuttongroup(h.myfig, ...
    'Units','normalized', ...
    'BorderType','none', ...
    'Position',[P 0.19 LW-P-0.13 0.028]);

h.rb_fitpv = uicontrol(h.peakMethodGroup, 'Style','radiobutton', ...
    'Units','normalized', ...
    'Position',[0.0 0.5 0.5 0.5], ...
    'String','fitPseudoVoigt', 'Value', 1);
h.rb_centroid = uicontrol(h.peakMethodGroup, 'Style','radiobutton', ...
    'Units','normalized', ...
    'Position',[0.5 0.5 0.5 0.5], ...
    'String','fitCentroid');

h.cb_showCentroid = uicontrol(h.myfig, ...
    'Style',    'checkbox', ...
    'Units',    'normalized', ...
    'Position', [P 0.162 LW-P-0.13 0.022], ...
    'String',   'Show fitCentroid', ...
    'Value',    0, ...                  % standardmäßig aus
    'FontSize', 8, ...
    'Callback', @showcentroidcallback);

h.FitStessDataButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.72 0.1532 LW*0.26 RH],...
    'String','Fit Stress Data','Callback',@fitstressdatacallback);

h.ModStessDataButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[LW*0.72 0.1202 LW*0.26 RH], ...  % war 0.002, jetzt 0.032
    'String','Modify Stress Data','Callback',@modstressdatacallback);

h.UndoStressButton = uicontrol(h.myfig, 'Style','Pushbutton', ...
    'Units','normalized', ...
    'Position',[LW*0.48 0.1464 LW*0.22 RH], ...
    'String','↩ Undo', ...
    'Enable','off', ...          % erst aktiv nach erstem Löschen
    'Tooltip','Letzten Löschvorgang rückgängig machen', ...
    'Callback', @undostresscallback);

% =========================================================
% MITTLERER BEREICH: Plot-Tabs   y=0.13..0.97
% =========================================================
h.plottab = uitabgroup(h.myfig,...
    'Units','normalized',...
    'Position',[RX 0.13 MW 0.84]);

h.plottab4 = uitab(h.plottab,'Title','Plot intensity data');
h.plottab1 = uitab(h.plottab,'Title','Stress factor method');
h.plottab2 = uitab(h.plottab,'Title','sin²psi method');
h.plottab3 = uitab(h.plottab,'Title','DEC data for fitted peaks');
h.plottab5 = uitab(h.plottab,'Title','Caked 2D Image');
h.plottab6 = uitab(h.plottab, 'Title', 'Ring Image (merged)');
h.plottab7 = uitab(h.plottab, 'Title', 'Raw 2D Image');

% h.axes = uiaxes(h.plottab1,'Units','normalized','Position',[0.01 0.01 0.98 0.97]);
h.axes = uiaxes(h.plottab1, 'Units', 'normalized', 'Position', [0.01 0.01 0.98 0.97]);

% NEU: wissenschaftliches Styling
h.axes.Color          = [1 1 1];
h.axes.Box            = 'on';
h.axes.LineWidth      = 0.8;
h.axes.FontSize       = 11;
h.axes.XColor         = [0.3 0.3 0.3];
h.axes.YColor         = [0.3 0.3 0.3];
h.axes.GridColor      = [0 0 0];
h.axes.GridAlpha      = 0.08;
h.axes.GridLineStyle  = '-';
h.axes.MinorGridAlpha = 0.05;

h.axes.XLim = [-90,90]; h.axes.YLim = [-Inf,Inf];
h.axes.YLabel.String = [char(949),'(',char(947),')']; h.axes.YLabel.FontSize = 14;
h.axes.XLabel.String = [char(947),' [°]']; h.axes.XLabel.FontSize = 14;
grid(h.axes,'on'); box(h.axes,'on');

h.axessin2psi = uiaxes(h.plottab2,'Units','normalized','Position',[0.01 0.01 0.98 0.97]);
h.axessin2psi.XLim = [0 1]; h.axessin2psi.YLim = [0,Inf]; h.axessin2psi.YLimMode = 'auto';
h.axessin2psi.YLabel.String = [char(949),'(',char(947),')']; h.axessin2psi.YLabel.FontSize = 14;
h.axessin2psi.XLabel.String = ['sin²',char(968)]; h.axessin2psi.XLabel.FontSize = 14;
grid(h.axessin2psi,'on'); box(h.axessin2psi,'on');

datatmp  = zeros(5,8);
datatmp1 = zeros(5,6);

h.tableDECFittedPeaks = uitable(h.plottab3,...
    'Units','normalized','Position',[0.01 0.01 0.54 0.97],...
    'ColumnName',{'E-fitted','E-theo','h','k','l','S1','1/2 S2',char(945)},...
    'Data',datatmp,'Tag','tableDECFittedPeaks',...
    'ColumnFormat',{'numeric',(cellfun(@num2str,num2cell(datatmp(:,4)),'UniformOutput',false))','numeric','numeric','numeric','numeric','numeric','numeric'},...
    'ColumnEditable',[false,true,false,false,false,true,true,false],...
    'ColumnWidth',{65 65 22 22 22 80 80 30},...
    'CellEditCallback',@celleditcallback);

h.plottabEtheo  = uitabgroup(h.plottab3,'Units','normalized','Position',[0.56 0.01 0.43 0.97]);
h.plottabEtheo1 = uitab(h.plottabEtheo,'Title','Ga k-alpha');
h.plottabEtheo2 = uitab(h.plottabEtheo,'Title','In k-alpha');
h.plottabEtheo3 = uitab(h.plottabEtheo,'Title','In k-beta');

tabHandles = {h.plottabEtheo1, h.plottabEtheo2, h.plottabEtheo3};
tabNames   = {'dekdataGaKalpha','dekdataInKalpha','dekdataInKbeta'};
for ti = 1:3
    h.(tabNames{ti}) = uitable(tabHandles{ti},...
        'Units','normalized','Position',[0.01 0.01 0.98 0.97],...
        'ColumnName',{'h','k','l','E-theo','S1','1/2 S2'},...
        'Data',datatmp1(:,1:6),'Tag','dekdata',...
        'ColumnFormat',{'numeric','numeric','numeric','numeric','numeric','numeric'},...
        'ColumnEditable',[false,false,false,false,true,true],...
        'ColumnWidth',{22 22 22 58 75 75},...
        'CellEditCallback',@celleditcallback);
end

h.axesPlotIntensityData = uiaxes(h.plottab4,'Units','normalized','Position',[0.01 0.01 0.98 0.97]);
h.axesPlotIntensityData.XLim = [0,60]; h.axesPlotIntensityData.YLimMode = 'auto';
h.axesPlotIntensityData.YLabel.String = 'Intensity [a.u.]'; h.axesPlotIntensityData.YLabel.FontSize = 14;
h.axesPlotIntensityData.XLabel.String = ['2',char(952),' °']; h.axesPlotIntensityData.XLabel.FontSize = 14;
grid(h.axesPlotIntensityData,'off'); box(h.axesPlotIntensityData,'on');
hold(h.axesPlotIntensityData,'on');

h.axesCaked2D = uiaxes(h.plottab5, 'Units','normalized', 'Position',[0.01 0.01 0.98 0.97]);
h.axesCaked2D.XLabel.String = '\chi (deg)';
h.axesCaked2D.YLabel.String = '2\theta (deg)';
h.axesCaked2D.YDir = 'normal';
box(h.axesCaked2D, 'on');

h.axesRingDet = uiaxes(h.plottab6, 'Units','normalized', 'Position',[0.01 0.01 0.98 0.97]);
h.axesRingDet.XLabel.String = 'x_{lab} (mm)';
h.axesRingDet.YLabel.String = 'y_{lab} (mm)';
h.axesRingDet.YDir = 'normal';
box(h.axesRingDet, 'on');

h.axesRawImage = uiaxes(h.plottab7, 'Units','normalized', 'Position',[0.01 0.06 0.98 0.93]);
h.axesRawImage.XLabel.String = 'x [px]';
h.axesRawImage.YLabel.String = 'y [px]';
h.axesRawImage.YDir = 'normal';
box(h.axesRawImage, 'on');

% Slider für Raw Image Tab (unter den Axes im Tab)
h.SliderRawImages = uicontrol(h.plottab7, ...
    'Style',      'slider', ...
    'Units',      'normalized', ...
    'Position',   [0.01 0.005 0.98 0.045], ...
    'Min',        1, ...
    'Max',        2, ...
    'Value',      1, ...
    'SliderStep', [1 1], ...
    'Enable',     'off', ...
    'Callback',   @SliderCallbackRawImage);

% Slider für Intensitäts-Tab (unter dem Tab)
h.Slider = uicontrol('Style','slider','Tag','Slider','Parent',h.myfig,...
    'Units','normalized',...
    'Position',[RX 0.095 MW*0.72 0.028],...
    'Min',1,'Max',2,'Value',1,'SliderStep',[1 1],...
    'Callback',{@SliderCallbackPlotRawData});

% Checkbox (rechts neben Slider)
h.checkboxplotall = uicontrol(h.myfig,'Style','checkbox','Units','normalized',...
    'Position',[RX+MW*0.74 0.097 MW*0.26 0.026],...
    'String','Plot all profiles','Callback',@plotallprofilescallback);

% Tau-Axes (unter Tab-Gruppe)
h.axesPlottauData = uiaxes(h.myfig,'Units','normalized',...
    'Position',[RX 0.002 MW 0.088]);
h.axesPlottauData.XLim = [-90,90]; h.axesPlottauData.YLimMode = 'auto';
h.axesPlottauData.YLabel.String = '\tau [µm]'; h.axesPlottauData.YLabel.FontSize = 12;
h.axesPlottauData.XLabel.String = [char(947),' °']; h.axesPlottauData.XLabel.FontSize = 12;
grid(h.axesPlottauData,'off'); box(h.axesPlottauData,'on');

% =========================================================
% RECHTER BEREICH
% =========================================================
% Wavelength radio buttons
h.radiobuttonwavelength = uibuttongroup(h.myfig,...
    'Units','normalized',...
    'BorderType','none',...
    'SelectionChangedFcn',@choosewavelengthcallback,...
    'Position',[RX2 0.88 RW 0.09]);
h.rb1 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Units','normalized',...
    'Position',[0.02 0.65 0.96 0.30],'String','Ga K-alpha');
h.rb2 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Units','normalized',...
    'Position',[0.02 0.33 0.96 0.30],'String','In K-alpha');
h.rb3 = uicontrol(h.radiobuttonwavelength,'Style','radiobutton','Units','normalized',...
    'Position',[0.02 0.02 0.96 0.30],'String','In K-beta');

% Stress-Axes oben rechts
h.axesStressData = uiaxes(h.myfig,'Units','normalized',...
    'Position',[RX2 0.50 RW 0.37]);
h.axesStressData.XLim = [0,Inf]; h.axesStressData.YLimMode = 'auto';
h.axesStressData.YLabel.String = [char(963),' [MPa]']; h.axesStressData.YLabel.FontSize = 14;
h.axesStressData.XLabel.String = [char(964),' [',char(956),'m]']; h.axesStressData.XLabel.FontSize = 14;
grid(h.axesStressData,'on'); box(h.axesStressData,'on');

% Export Buttons
h.ExportFitDataButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[RX2 0.458 RW*0.47 0.035],...
    'String','Export Fit Data','Callback',@exportfitdatacallback);
h.ExportStressDataButton = uicontrol(h.myfig,'Style','Pushbutton','Units','normalized',...
    'Position',[RX2+RW*0.50 0.458 RW*0.50 0.035],...
    'String','Export Stress Data','Callback',@exportstressdatacallback);

% FittedPeaks-Axes unten rechts
h.axesFittedPeaks = uiaxes(h.myfig,'Units','normalized',...
    'Position',[RX2 0.13 RW 0.32]);
h.axesFittedPeaks.YLimMode = 'auto'; h.axesFittedPeaks.XLimMode = 'auto';
h.axesFittedPeaks.YLabel.String = 'Intensity [a.u.]'; h.axesFittedPeaks.YLabel.FontSize = 14;
h.axesFittedPeaks.XLabel.String = ['2',char(952),' [°]']; h.axesFittedPeaks.XLabel.FontSize = 14;
box(h.axesFittedPeaks,'on');

% SliderFittedPeaks
h.SliderFittedPeaks = uicontrol('Style','slider','Tag','SliderFittedPeaks',...
    'Parent',h.myfig,'Units','normalized',...
    'Position',[RX2 0.092 RW 0.028],...
    'Min',1,'Max',2,'Value',1,'SliderStep',[1 1],...
    'Callback',{@SliderCallbackFittedPeaks});

% =========================================================
% Plot-Objekte initialisieren
% =========================================================
x = 0; y = 0; err = 0;

h.plotIntensityData     = plot(h.axesPlotIntensityData,x,y,'-','Color','blue','Visible','off');
% h.plotdata              = errorbar(h.axes,x,y,err,'s','Visible','off');
% 
% % fitCentroid Peaklagen (lila, Kreis)
% h.plotdataCentFit = errorbar(h.axes, 0, 0, 0, 'o', ...
%     'Color', [1 0 0], 'Visible', 'off');

% NEU:
h.plotdata = errorbar(h.axes, x, y, err, 's', ...
    'MarkerSize',       4, ...
    'MarkerFaceColor',  [0.094 0.373 0.647], ...
    'MarkerEdgeColor',  [0.094 0.373 0.647], ...
    'Color',            [0.094 0.373 0.647], ...
    'LineWidth',        0.8, ...
    'Visible',          'off');

h.plotdataCentFit = errorbar(h.axes, 0, 0, 0, 'o', ...
    'MarkerSize',       4.5, ...
    'MarkerFaceColor',  'none', ...
    'MarkerEdgeColor',  [0.60 0.75 0.90], ...
    'Color',            [0.60 0.75 0.90], ...
    'LineWidth',        0.9, ...
    'Visible',          'off');

hold(h.axes,'on');
h.fitcurvestress        = plot(h.axes,0,0,'-','Visible','off');
h.plotdatasin2psi       = errorbar(h.axessin2psi,x,y,err,'s','Visible','off');
hold(h.axessin2psi,'on');
h.fitcurvestresssin2psi = plot(h.axessin2psi,0,0,'-','Visible','off');
h.plotstressdata        = errorbar(h.axesStressData,x,y,err,'s');
hold(h.axesStressData,'on');
h.plotsin2psistressdata = errorbar(h.axesStressData,x,y,err,'o');
h.highlightstressplot   = plot(h.axesStressData,x,y,'s','Color','g',...
    'MarkerFaceColor','g','Visible','off','MarkerSize',12);
h.highlightpeakdata     = plot(h.axes,x,y,'s','Color','g',...
    'MarkerFaceColor','g','Visible','off','MarkerSize',10);
h.plotRawData           = plot(h.axesFittedPeaks,x,y,'o','Color','black',...
    'MarkerFaceColor','black','MarkerSize',6,'Visible','off');
hold(h.axesFittedPeaks,'on');
h.plotFitData           = plot(h.axesFittedPeaks,x,y,'-','Color','red','Visible','off');
h.plottaudata           = plot(h.axesPlottauData,0,0,'s');
hold(h.axesPlottauData,'on');
h.plottaudatamean       = plot(h.axesPlottauData,0,0,'Color','r');

% Initialise default opts in guidata after guidata(h.myfig, h)
% -----------------------------------------------------------------------
% h.trackFitOpts = openTrackFitSettings();   % load defaults silently
% (If you want to pre-fill from a saved file, load it here instead.)

h.trackFitOpts = struct( ...
    'useGauss',                   false,                              ...
    'gaussMinR2',                 0.98,                               ...
    'gaussSigmaRangeDeg',         [0.10  0.80],                       ...
    'windowDeg',                  0.6,                                ...
    'pvoigtFixedEta',             0.5,                                ...
    'pvoigtFallbackToCentroid',   true,                               ...
    'pvoigtMinR2',                0.90,                               ...
    'pvMinR2Auto',                0.85,                               ... % 'Mindest-R² für automatischen Filter (0 = deaktiviert)'
    'pvoigtFwhmRangeDeg',         [0.10  0.80],                       ...
    'pvoigtMuBoundDeg',           0.10,                               ...
    'centroidKBins',              12,                                 ...
    'pvoigtAdaptiveWindow',       false,                              ...
    'pvoigtAdaptiveWindowFactor', 2.5,                                ...
    'pvoigtAdaptiveWindowMinDeg', 0.20,                               ...
    'pvoigtAdaptiveWindowMaxDeg', 0.80,                               ...
    'pvoigtAutoWindow',           false,                              ...
    'pvoigtWindowCandidates',     [0.30 0.35 0.40 0.50 0.55 0.60 0.65 0.70 0.75 0.80],   ...
    'pvoigtAutoWindowUseBestR2',  false                                ...
);

% The call will open the dialog at startup – to AVOID that, initialise
% with the struct directly:
%
%   h.trackFitOpts = struct( ...
%       'profileChiRange',  [-150 -80], ...
%       'trackChiBin',      4,          ...
%       ...                             );
%
% Or simply call openTrackFitSettings with no display by reading the
% defaults from the function without showing the dialog (see STEP 4).


% ---- RECOMMENDED: silent default init --------------------------------
% Add this helper at the bottom of the main GUI function (before callbacks):

% h.trackFitOpts = getTrackFitDefaults();   % see STEP 4


guidata(h.myfig, h);

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

% --- Dateiauswahl: CBF und TIF unterstützen ---
[file, location] = uigetfile( ...
    {'*.cbf;*.tif;*.tiff', 'Detector images (*.cbf, *.tif)'; ...
     '*.cbf',              'CBF files (*.cbf)'; ...
     '*.tif;*.tiff',       'TIF files (*.tif, *.tiff)'}, ...
    'Select 2D XRD image(s)', ...
    'MultiSelect', 'on', ...
    'D:\EDDIDAT_github\Data\Results\Pilatus-2DXRD\');

if isequal(file, 0)
    disp('User selected Cancel');
    return
end

% Normalisieren auf Cell-Array
if ~iscell(file)
    file = {file};
end

% Button-Feedback
col = get(hObj, 'backg');
set(hObj, 'String', 'Loading images ...', 'backg', [1 .6 .6]);
pause(0.01);

total_images_selected = numel(file);

% Vollpfade speichern
imgPaths = cell(total_images_selected, 1);
for k = 1:total_images_selected
    imgPaths{k} = fullfile(location, file{k});
end

h.FileNameLoad = file;
h.imgPaths     = imgPaths;
h.imgLocation  = location;
h.BinSize      = str2double(get(h.trackChiBinEdit, 'String'));

set(h.FileNameEditField, 'String', strjoin(string(file), ', '));

% guidata speichern BEVOR SliderCallback aufgerufen wird
guidata(hObj, h);

% --- Slider konfigurieren ---
if total_images_selected > 1
    set(h.SliderRawImages, ...
        'Min',        1, ...
        'Max',        total_images_selected, ...
        'Value',      1, ...
        'SliderStep', [1/max(total_images_selected-1, 1) ...
                       1/max(total_images_selected-1, 1)], ...
        'Enable',     'on');
else
    set(h.SliderRawImages, ...
        'Min',        1, ...
        'Max',        2, ...
        'Value',      1, ...
        'SliderStep', [1 1], ...
        'Enable',     'off');
end

% --- Erstes Bild anzeigen (über SliderCallback) ---
set(h.SliderRawImages, 'Value', 1);
SliderCallbackRawImage(h.SliderRawImages, []);

% Tab aktivieren
h.plottab.SelectedTab = h.plottab7;

fprintf('Geladen: %d Bild(er) aus %s\n', total_images_selected, location);

% Button zurücksetzen
set(hObj, 'String', 'Load 2D image(s)', 'backg', col);

guidata(hObj, h);

function opengammafilecallback(hObj, ~)
h = guidata(hObj);

% =====================================================================
% Sicherheitscheck
% =====================================================================
if ~isfield(h, 'imgPaths') || isempty(h.imgPaths)
    errordlg('Please load 2D images first.', 'No images loaded');
    return
end

% =====================================================================
% PONI-Files auswählen
% =====================================================================
[poniFiles, poniLocation] = uigetfile('*.poni', ...
    'Select PONI files (same order as images)', ...
    'MultiSelect', 'on', ...
    'D:\EDDIDAT_github\Data\Results\Pilatus-2DXRD\');

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
        numel(poniFiles), numel(h.imgPaths)), 'Count mismatch');
    return
end

% Vollpfade PONI
poniPaths = cell(numel(poniFiles), 1);
for k = 1:numel(poniFiles)
    poniPaths{k} = fullfile(poniLocation, poniFiles{k});
end

% Alpha-Winkel aus Dateinamen parsen
alpha_tmp = zeros(1, numel(poniFiles));
for k = 1:numel(poniFiles)
    tok = regexp(poniFiles{k}, '(?<=alpha)([\d.+-]+)(?=.poni)', 'match');
    if ~isempty(tok)
        alpha_tmp(k) = str2double(tok{1});
    else
        alpha_tmp(k) = 0;
    end
end
h.alpha = unique(alpha_tmp);
set(h.AlphaEditField,        'String', strjoin(string(h.alpha),    ', '));
set(h.GammaFileNameEditField,'String', strjoin(string(poniFiles),  ', '));

% Button-Feedback
col = get(hObj, 'backg');
set(hObj, 'String', 'Running pyFAI ...', 'backg', [1 .6 .6]);
pause(0.01);

% =====================================================================
% Wellenlänge
% =====================================================================
if isfield(h, 'lambda_m')
    lambda_m = h.lambda_m;
else
    hc_eVm   = 1.23984193e-6;
    lambda_m = hc_eVm / 9251.7;
end

% =====================================================================
% Wellenlängen-Index bestimmen
% =====================================================================
selectedWL = get(h.radiobuttonwavelength.SelectedObject, 'String');
if strcmp(selectedWL, 'Ga K-alpha'),     wlIdx = 1;
elseif strcmp(selectedWL, 'In K-alpha'), wlIdx = 2;
else,                                    wlIdx = 3;
end

% =====================================================================
% pyFAI Konfiguration
% =====================================================================
cfg = struct();
% Basisname aus erstem Bilddateinamen ableiten
% Trailing filesep entfernen falls vorhanden
imgLoc = h.imgLocation;
if imgLoc(end) == filesep
    imgLoc = imgLoc(1:end-1);
end
[~, folderName, ~] = fileparts(imgLoc);

% Aktuelles Datum als Präfix + automatische Nummerierung
dateStr = char(datetime('now', 'Format', 'yyyyMMdd'));
runNum  = 1;
while exist(fullfile(h.imgLocation, ...
        sprintf('%s_pyfai_%s_%02d', dateStr, folderName, runNum)), 'dir') || ...
      ~isempty(dir(fullfile(h.imgLocation, ...
        sprintf('%s_pyfai_%s_%02d*', dateStr, folderName, runNum))))
    runNum = runNum + 1;
end
cfg.outBase = fullfile(h.imgLocation, ...
    sprintf('%s_pyfai_%s_%02d', dateStr, folderName, runNum));
cfg.mode             = '2d';
cfg.unit             = '2th_deg';
cfg.npt_rad          = 3000;
cfg.npt_azim         = 360;
cfg.method           = 'csr';
cfg.pythonExe        = strtrim(get(h.pythonExeEdit,  'String'));
cfg.scriptPath       = strtrim(get(h.scriptPathEdit, 'String'));
cfg.mask_path        = '';
cfg.save_raw_stack   = false;
cfg.save_ring_image  = false;
cfg.save_ring_det    = true;
cfg.ring_npt_tth     = 1500;
cfg.ring_npt_chi     = 360;
cfg.ring_tth_max_deg = 60.0;
cfg.ring_chi_min_deg = -180.0;
cfg.ring_chi_max_deg =  180.0;
cfg.ring_output_size = 2000;    % oberes Limit – wird automatisch begrenzt

% Peaklagen aus letztem Durchlauf für Ring-Peak-Berechnung
% Beim ersten Durchlauf leer – beim zweiten werden Ringe direkt berechnet
if isfield(h, 'PeakPos') && ~isempty(h.PeakPos)
    cfg.peak_pos_deg = h.PeakPos{wlIdx};
    cfg.peak_tol_deg = 0.05;
    fprintf('Peaklagen verfügbar: %d Peaks → Ring-Peaks werden berechnet.\n', ...
        numel(cfg.peak_pos_deg));
else
    cfg.peak_pos_deg = [];
    fprintf('Keine Peaklagen verfügbar – Ring-Peaks beim zweiten Durchlauf.\n');
end

% =====================================================================
% pyFAI MultiGeometry ausführen
% =====================================================================
try
    out = run_pyfai_multigeometry_from_matlab(...
        h.imgPaths, poniPaths, lambda_m, cfg);
catch ME
    set(hObj, 'String', 'Load Gamma Data File', 'backg', col);
    errordlg(sprintf('pyFAI failed:\n%s', ME.message), 'pyFAI Error');
    return
end

h.pyfaiOut  = out;
h.poniPaths = poniPaths;
outBase     = cfg.outBase;

% =====================================================================
% Theoretische Peaks berechnen (vor Plot – aus pyFAI-Radialbereich)
% =====================================================================
if isfield(h, 'PeaksTheo')
    tthMin = double(min(out.radial));
    tthMax = double(max(out.radial));

    for k = 1:size(h.PeaksTheo, 2)
        PeakPostmp = mean(h.PeaksTheo{k}.Peaks(:, 5:6), 2)';
        idx        = (PeakPostmp >= tthMin) & (PeakPostmp <= tthMax);
        PeakPos{k} = PeakPostmp(idx);
        hkl{k}     = h.PeaksTheo{k}.Peaks(idx, 1:3);
        for i = 1:size(hkl{k}, 1)
            rowsAsStrings{k}{i} = strtrim(sprintf('%g %g %g', hkl{k}(i,:)));
        end
        hkltabledata{k} = [hkl{k} PeakPos{k}' zeros(length(PeakPos{k}), 2)];
    end
    h.PeakPos       = PeakPos;
    h.rowsAsStrings = rowsAsStrings;
end    
% =====================================================================
% Rohbild-Median für Normierung
% =====================================================================
rawMedian = [];
try
    [~, ~, ext] = fileparts(h.imgPaths{1});
    pythonExe   = strtrim(get(h.pythonExeEdit, 'String'));
    if strcmpi(ext, '.cbf')
        img1 = loadCBF(h.imgPaths{1}, pythonExe);
    else
        img1 = double(imread(h.imgPaths{1}));
    end
    imgLog1   = log10(1 + max(img1, 0));
    rawMedian = median(imgLog1(isfinite(imgLog1) & imgLog1 > 0), 'all');
    fprintf('Raw image Median (log): %.4f\n', rawMedian);
catch ME
    warning('Rohbild-Normierung fehlgeschlagen: %s', strrep(ME.message,'%', '%%'));
end

% =====================================================================
% Caked 2D Image plotten
% =====================================================================
try
    caked2dOpts             = struct();
    caked2dOpts.showAxis    = 'tth';
    caked2dOpts.useLog      = true;
    caked2dOpts.logStrength = 1;
    caked2dOpts.climPct     = [1 99];
    caked2dOpts.saveTif     = true;
    caked2dOpts.resolution  = 300;
    caked2dOpts.rawMedian   = rawMedian;

    [~, baseName, ~]    = fileparts(h.FileNameLoad{1});
    baseName            = strrep(baseName, ' ', '_');
    caked2dOpts.tifPath = fullfile(h.imgLocation, [baseName '_caked2D.tif']);

    if isfield(h, 'PeakPos') && ~isempty(h.PeakPos)
        caked2dOpts.peakPos    = h.PeakPos{wlIdx};
        caked2dOpts.peakLabels = h.rowsAsStrings{wlIdx};
    end

    plotCaked2DInAxes(h.axesCaked2D, out, caked2dOpts);
    % h.plottab.SelectedTab = h.plottab5;
    fprintf('Caked 2D Image gespeichert: %s\n', caked2dOpts.tifPath);
catch ME
    errordlg(sprintf('[Caked2D] %s', ME.message), 'Caked2D Error');
end

% =====================================================================
% Variante 1: Rohdaten-Stapel
% =====================================================================
rawStackPath = [outBase '_raw_stack.mat'];
if cfg.save_raw_stack && exist(rawStackPath, 'file')
    try
        raw    = load(rawStackPath);
        imgLog = log10(1 + max(raw.imgs_mean, 0));
        v      = imgLog(isfinite(imgLog) & imgLog > 0);
        clims  = prctile(v, [1 99]);
        figure('Name', 'Raw Mean Image');
        imagesc(imgLog); clim(clims); colorbar;
        axis image; colormap(gca, 'hot');
        title('Raw mean image (log_{10}(1+I))');
    catch ME
        warning('[RawStack] %s', strrep(ME.message,'%', '%%'));
    end
end

% =====================================================================
% Variante 2: Reassembled Ringbild
% =====================================================================
ringPath = [outBase '_ring.mat'];
if cfg.save_ring_image && exist(ringPath, 'file')
    try
        ring   = load(ringPath);
        imgLog = log10(1 + max(ring.ring_mean, 0));
        v      = imgLog(isfinite(imgLog) & imgLog > 0);
        clims  = prctile(v, [1 99]);
        figure('Name', 'Ring Image (Reassembled)');
        imagesc(ring.tth_centers, ring.chi_centers, imgLog);
        clim(clims); set(gca, 'YDir', 'normal');
        colorbar; colormap(gca, 'hot');
        xlabel('2\theta (deg)'); ylabel('\chi (deg)');
        title('Ring image – log_{10}(1+I)');
    catch ME
        warning('[RingImage] %s', strrep(ME.message,'%', '%%'));
    end
end

% =====================================================================
% Variante 3: Pixel-Ringbild (ring_det)
% =====================================================================
ringDetPath  = [outBase '_ring_det.mat'];
ringPeakPath = [outBase '_ring_peaks.mat'];

if exist(ringDetPath, 'file')
    try
        ringDet = load(ringDetPath);

        % % Debug-Info
        % fprintf('Bildbereich: x=[%.1f, %.1f] mm, y=[%.1f, %.1f] mm\n', ...
        %     min(ringDet.x_centers_mm), max(ringDet.x_centers_mm), ...
        %     min(ringDet.y_centers_mm), max(ringDet.y_centers_mm));
        % fprintf('Strahlmitte: x=%.2f mm, y=%.2f mm\n', ...
        %     ringDet.center_x_mm, ringDet.center_y_mm);
        % fprintf('SDD: %.2f mm\n', ringDet.sdd_mm);
        % if ringDet.center_x_mm < min(ringDet.x_centers_mm) || ...
        %    ringDet.center_x_mm > max(ringDet.x_centers_mm)
        %     fprintf('WARNUNG: Strahlmitte x liegt ausserhalb des Bildbereichs!\n');
        % end
        % if ringDet.center_y_mm < min(ringDet.y_centers_mm) || ...
        %    ringDet.center_y_mm > max(ringDet.y_centers_mm)
        %     fprintf('WARNUNG: Strahlmitte y liegt ausserhalb des Bildbereichs!\n');
        % end

        % ringDetOpts aufbauen
        ringDetOpts             = struct();
        ringDetOpts.useLog      = true;
        ringDetOpts.logStrength = 1;
        ringDetOpts.climPct     = [1 99];
        ringDetOpts.rawMedian   = rawMedian;
        % Geometrische Näherung erzwingen:
        ringDetOpts.useGeometricRings = false;

        % Geometrie aus MAT-Datei
        if isfield(ringDet, 'sdd_mm')
            ringDetOpts.sdd_mm      = ringDet.sdd_mm;
            ringDetOpts.center_x_mm = ringDet.center_x_mm;
            ringDetOpts.center_y_mm = ringDet.center_y_mm;
        end

        % Peaklagen für Fallback (geometrische Näherung)
        if isfield(h, 'PeakPos') && ~isempty(h.PeakPos)
            ringDetOpts.peakPos    = h.PeakPos{wlIdx};
            ringDetOpts.peakLabels = h.rowsAsStrings{wlIdx};
        end

        % Ringpositionen aus Pixeldaten laden (echte pyFAI-Geometrie)
        if exist(ringPeakPath, 'file')
            ringDetOpts.ringPeakData = load(ringPeakPath);
            fprintf('Ring peak positions geladen: %s\n', ringPeakPath);
        else
            ringDetOpts.ringPeakData = [];
            if isempty(cfg.peak_pos_deg)
                fprintf(['Ring-Peaks noch nicht verfügbar.\n' ...
                    'Beim zweiten Durchlauf werden sie automatisch berechnet.\n']);
            end
        end

        plotRingDetInAxes(h.axesRingDet, ringDet, ringDetOpts);
        h.plottab.SelectedTab = h.plottab6;
        fprintf('Ring detector image geladen: %s\n', ringDetPath);
    catch ME
        errordlg(sprintf('[RingDet] %s', ME.message), 'RingDet Error');
    end
end

% =====================================================================
% Ring-Peaks nachträglich berechnen (jetzt wo h.PeakPos verfügbar)
% =====================================================================
if cfg.save_ring_det && ~exist(ringPeakPath, 'file') && ...
   ~isempty(h.PeakPos) && ~isempty(ringDet)
    try
        fprintf('Berechne Ring-Peak-Positionen ...\n');
        pythonExe  = strtrim(get(h.pythonExeEdit, 'String'));
        scriptPath = strtrim(get(h.scriptPathEdit, 'String'));

        ringPeakJob              = struct();
        ringPeakJob.img_paths    = h.imgPaths;
        ringPeakJob.poni_paths   = poniPaths;
        ringPeakJob.wavelength_m = lambda_m;
        ringPeakJob.peak_pos_deg = h.PeakPos{wlIdx};
        ringPeakJob.peak_tol_deg = 0.05;
        ringPeakJob.out_mat      = [outBase '.mat'];
        ringPeakJob.out_npz      = [outBase '.npz'];

        jobPath = [outBase '_ring_peaks_job.json'];
        fid = fopen(jobPath, 'w');
        fprintf(fid, '%s', jsonencode(ringPeakJob));
        fclose(fid);

        cmd = sprintf('"%s" "%s" "%s" 2>&1', ...
            pythonExe, ...
            fullfile(fileparts(scriptPath), 'pyfai_ring_peaks_only.py'), ...
            jobPath);
        [status, cmdout] = system(cmd);

        if status ~= 0
            warning('[RingPeaks] %s', cmdout);
        else
            fprintf('Ring-Peaks berechnet: %s\n', ringPeakPath);
            % Plot sofort aktualisieren
            if exist(ringPeakPath, 'file') && ~isempty(ringDetOpts)
                ringDetOpts.ringPeakData = load(ringPeakPath);
                plotRingDetInAxes(h.axesRingDet, ringDet, ringDetOpts);
                fprintf('Ring-Plot aktualisiert mit echten Pixelpositionen.\n');
            end
        end
    catch ME
        warning('[RingPeaks] %s', strrep(ME.message,'%', '%%'));
    end
end

% =====================================================================
% Binning-Pausführen
% =====================================================================
h = runBinning(h, out);

% Rebin-Button aktivieren
if isfield(h,'RebinButton') && isvalid(h.RebinButton)
    set(h.RebinButton, 'Enable', 'on');
end


% =====================================================================
% Button zurücksetzen
% =====================================================================
set(hObj, 'String', 'Load Gamma Data File', 'backg', col);
% 
% assignin('base', 'h',   h);
% assignin('base', 'B',   B);
% assignin('base', 'out', out);

% =====================================================================
% DEC-Daten laden
% =====================================================================
MatName  = h.Sample.Materials.Name;
FileName = ['DEKListe' MatName '.mat'];
Path     = fullfile('Data', 'Materials\');
if exist([Path FileName], 'file')
    DEKMatFile    = load([Path FileName]);
    DEKdatatmp{1} = get(h.dekdataGaKalpha, 'data');
    DEKdatatmp{2} = get(h.dekdataInKalpha, 'data');
    DEKdatatmp{3} = get(h.dekdataInKbeta,  'data');

    for m = 1:size(DEKdatatmp, 2)
        hklDEKtmp = zeros(1, length(DEKdatatmp{m}(:,1)));
        for k = 1:length(DEKdatatmp{m}(:,1))
            hklDEKtmp(k) = DEKdatatmp{m}(k,1)*100 + ...
                           DEKdatatmp{m}(k,2)*10  + ...
                           DEKdatatmp{m}(k,3);
        end
        hklDEKtmp   = hklDEKtmp';
        IndexHittmp = cell(size(DEKMatFile.DEK,1), length(hklDEKtmp));
        for l = 1:length(hklDEKtmp)
            for k = 1:size(DEKMatFile.DEK, 1)
                IndexHittmp{k,l} = strcmp(num2str(hklDEKtmp(l,1)), ...
                                          num2str(DEKMatFile.DEK(k,1)));
            end
        end
        IndexHittmp = cell2mat(IndexHittmp);
        for k = 1:size(DEKdatatmp{m}, 1)
            if isempty(DEKMatFile.DEK(IndexHittmp(:,k), 2:3))
                DEKdatatmp{m}(k, 5:6) = [0 0];
            else
                DEKdatatmp{m}(k, 5:6) = DEKMatFile.DEK(IndexHittmp(:,k), 2:3);
            end
        end
    end
    set(h.dekdataGaKalpha, 'data', DEKdatatmp{1});
    set(h.dekdataInKalpha, 'data', DEKdatatmp{2});
    set(h.dekdataInKbeta,  'data', DEKdatatmp{3});
    uiwait(msgbox(sprintf('DEC data found and loaded. Check if data is correct.\n%s', '.')));
else
    uiwait(msgbox(sprintf('Warning: no DEC data found. Define manually.\n%s', '.'), ...
        'Warning', 'error'));
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

% dataXBackup = cellfun(@double, h.dataXBackup, 'UniformOutput', false);
% 
% idxtwothetamin = Tools.Data.DataSetOperations.FindNearestIndex(dataXBackup{1}, twothetamin);
% idxtwothetamax = Tools.Data.DataSetOperations.FindNearestIndex(dataXBackup{1}, twothetamax);

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

    FitDatatmp = [BinnedGammaSortMat(:) FittedPeakPosSortMat(:) ...
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

    % else
    %     % Set plot data for fitted peak positions
    %     set(h.plotdata,'Xdata',h.FitDataMod{value}(:,1))
    %     set(h.plotdata,'Ydata',h.FitDataMod{value}(:,2))
    %     set(h.plotdata,'YNegativeDelta',h.FitDataMod{value}(:,3))
    %     set(h.plotdata,'YPositiveDelta',h.FitDataMod{value}(:,3))
    % end
    else
        % pVoigt-Punkte (blau)
        pv    = h.FitDataMod{value};
        idxPV = isfinite(pv(:,2));
        set(h.plotdata, ...
            'XData', pv(idxPV,1), 'YData', pv(idxPV,2), ...
            'YNegativeDelta', pv(idxPV,3), 'YPositiveDelta', pv(idxPV,3));
        
        % fitCentroid (lila)
        if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= value
            if ~isfield(h,'plotdataCentFit') || ~isvalid(h.plotdataCentFit)
                h.plotdataCentFit = errorbar(h.axes, 0, 0, 0, 'o', ...
                    'Color', [0.55 0.00 0.75], 'Visible', 'off');
            end
            cf    = h.datacentFitMat{value};
            idxCF = isfinite(cf(:,2));
            showCent = isfield(h,'cb_showCentroid') && get(h.cb_showCentroid,'Value') == 1;
            if any(idxCF) && showCent
                set(h.plotdataCentFit, ...
                    'XData', cf(idxCF,1), 'YData', cf(idxCF,2), ...
                    'YNegativeDelta', cf(idxCF,3), 'YPositiveDelta', cf(idxCF,3), ...
                    'Visible', 'on');
            else
                set(h.plotdataCentFit, 'Visible', 'off');
            end
        end

        set(h.plotdata,       'DisplayName', 'fitPseudoVoigt');
        set(h.plotdataCentFit,'DisplayName', 'fitCentroid');
        legend(h.axes, 'Location', 'best', 'FontSize', 9);
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

    dataY = h.IntensityProfiles;
    if isfield(h, 'idxempty') && ~isempty(h.idxempty)
        for k = 1:min(size(h.idxempty,2), numel(dataY))
            idx = h.idxempty{k};
            if islogical(idx) && numel(idx) == size(dataY{k}, 2) && any(idx)
                dataY{k}(:, idx) = [];
            end
        end
    end

    % NEU: Fit-Plot über updateFittedPeakPlot aktualisieren
    h = updateFittedPeakPlot(h, value, 1);

    h.axes.YLim = [-Inf,Inf];
    % NEU:
    pv    = h.FitDataMod{value};
    xData = pv(isfinite(pv(:,1)), 1);
    if ~isempty(xData)
        xMin = min(xData);
        xMax = max(xData);
        margin = max(5, (xMax - xMin) * 0.05);
        h.axes.XLim = [xMin - margin, xMax + margin];
    end

    set(h.SliderFittedPeaks,'Value',1);

    % Highlight: je nach gewählter Methode Spalte 2 oder 9 verwenden
    if isfield(h,'rb_fitpv') && get(h.rb_fitpv,'Value') == 1 && ...
       size(h.FitDataMod{value},2) >= 9 && isfinite(h.FitDataMod{value}(1,9))
        set(h.highlightpeakdata, ...
            'XData', h.FitDataMod{value}(1,1), ...
            'YData', h.FitDataMod{value}(1,9), ...
            'Visible','on');
    else
        set(h.highlightpeakdata, ...
            'XData', h.FitDataMod{value}(1,1), ...
            'YData', h.FitDataMod{value}(1,2), ...
            'Visible','on');
    end

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

SliderValue = round(get(h.Slider, 'Value'));

dataY = h.IntensityProfiles;
if isfield(h, 'idxempty') && ~isempty(h.idxempty)
    for k = 1:min(size(h.idxempty,2), numel(dataY))
        idx = h.idxempty{k};
        if islogical(idx) && numel(idx) == size(dataY{k}, 2) && any(idx)
            dataY{k}(:, idx) = [];
        end
    end
end

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

% Mapping auf absoluten Bin-Index falls vorhanden
if isfield(h,'validBinIdxs') && numel(h.validBinIdxs) >= SliderValue && ...
   ~isempty(h.validBinIdxs{SliderValue})
    validIdxs = h.validBinIdxs{SliderValue};
    binIdx    = validIdxs(min(value, numel(validIdxs)));
else
    binIdx = value;
end

h = updateFittedPeakPlot(h, round(SliderValue), binIdx);
h.axes.YLim = [-Inf, Inf];
% NEU:
pv    = h.FitDataMod{value};
xData = pv(isfinite(pv(:,1)), 1);
if ~isempty(xData)
    xMin = min(xData);
    xMax = max(xData);
    margin = max(5, (xMax - xMin) * 0.05);
    h.axes.XLim = [xMin - margin, xMax + margin];
end

% Highlight auf gemappten Zeilenindex setzen
if isfield(h,'epsfitdataexport') && numel(h.epsfitdataexport) >= round(SliderValue) && ...
   size(h.epsfitdataexport{round(SliderValue)}, 1) >= binIdx
    set(h.highlightpeakdata, ...
        'XData',   h.epsfitdataexport{round(SliderValue)}(binIdx, 1), ...
        'YData',   h.epsfitdataexport{round(SliderValue)}(binIdx, 2), ...
        'Visible', 'on');
else
    mat = h.FitDataMod{round(SliderValue)};
    if size(mat, 1) >= binIdx && isfinite(mat(binIdx, 2))
        set(h.highlightpeakdata, ...
            'XData',   mat(binIdx, 1), ...
            'YData',   mat(binIdx, 2), ...
            'Visible', 'on');
    else
        set(h.highlightpeakdata, 'Visible', 'off');
    end
end

guidata(hObj, h);

function SliderCallbackRawImage(hObj, ~)
h = guidata(hObj);

value = round(get(hObj, 'Value'));
value = max(1, min(value, numel(h.imgPaths)));

[~, ~, ext] = fileparts(h.imgPaths{value});
pythonExe   = strtrim(get(h.pythonExeEdit, 'String'));

try
    if strcmpi(ext, '.cbf')
        img = loadCBF(h.imgPaths{value}, pythonExe);
    else
        img = double(imread(h.imgPaths{value}));
    end

    imgLog = log10(1 + max(img, 0));
    v      = imgLog(isfinite(imgLog) & imgLog > 0);
    clims  = prctile(v, [1 99]);

    cla(h.axesRawImage);
    imagesc(h.axesRawImage, imgLog);
    clim(h.axesRawImage, clims);
    colormap(h.axesRawImage, 'hot');
    colorbar(h.axesRawImage);
    axis(h.axesRawImage, 'image');
    h.axesRawImage.YDir = 'reverse'; % normal
    h.axesRawImage.Title.String = sprintf('[%d/%d]  %s  [%d × %d px]', ...
        value, numel(h.imgPaths), h.FileNameLoad{value}, ...
        size(img,1), size(img,2));
catch ME
    warning('Slider:generalError', '[SliderRawImage] %s', ME.message);
end

guidata(hObj, h);

function celleditcallback(hObj, eventdata)
% Change entries for DEK data manually. User can also reallocate peaks if
% needed. Supports dropdown menu for E-theo column.
 
h = guidata(hObj);
h.SelectPeaktabledata = get(hObj, 'data');
 
if strcmp(get(hObj, 'Tag'), 'tableDECFittedPeaks')
 
    % --- Aktuelle DEK-Daten laden ---
    if strcmp(get(h.radiobuttonwavelength.SelectedObject, 'String'), 'Ga K-alpha')
        datadek = get(h.dekdataGaKalpha, 'data');
    elseif strcmp(get(h.radiobuttonwavelength.SelectedObject, 'String'), 'In K-alpha')
        datadek = get(h.dekdataInKalpha, 'data');
    else
        datadek = get(h.dekdataInKbeta, 'data');
    end
 
    % --- NewData auslesen: kann String (Dropdown) oder numeric sein ---
    newData = eventdata.NewData;
    if ischar(newData) || isstring(newData)
        newVal = str2double(newData);
    elseif isnumeric(newData)
        newVal = newData;
    else
        newVal = NaN;
    end
 
    % --- Ungültige Eingabe: alten Wert wiederherstellen ---
    if isempty(newVal) || ~isfinite(newVal) || newVal == 0
        prevData = eventdata.PreviousData;
        if isnumeric(prevData) && isfinite(prevData) && prevData ~= 0
            h.SelectPeaktabledata(eventdata.Indices(1), eventdata.Indices(2)) = prevData;
            set(hObj, 'data', h.SelectPeaktabledata);
        end
        guidata(hObj, h);
        return
    end
 
    % --- Index der geänderten Zeile ---
    idxdatanew = eventdata.Indices;
 
    % --- Passenden Peak in DEK-Tabelle suchen ---
    idxchangedPeak = ismembertol(datadek(:,4), newVal, 0.0001);
    if ~any(idxchangedPeak)
        idxchangedPeak = ismembertol(datadek(:,4), newVal, 0.01);
    end
    if ~any(idxchangedPeak)
        warning('celleditcallback: Kein passender Peak für E-theo=%.4f gefunden.', newVal);
        % Alten Wert wiederherstellen
        prevData = eventdata.PreviousData;
        if isnumeric(prevData) && isfinite(prevData)
            h.SelectPeaktabledata(idxdatanew(1), idxdatanew(2)) = prevData;
            set(hObj, 'data', h.SelectPeaktabledata);
        end
        guidata(hObj, h);
        return
    end
 
    % --- DEK-Werte übernehmen (nur ersten Treffer) ---
    idxRow = find(idxchangedPeak, 1, 'first');
    h.SelectPeaktabledata(idxdatanew(1), 3:7) = datadek(idxRow, [1:3, 5:6]);
    set(hObj, 'data', h.SelectPeaktabledata);
 
    % --- DEKdataMatchedPeaks aktualisieren ---
    h.DEKdataMatchedPeaks = [h.SelectPeaktabledata(:,3:5) ...
                              h.SelectPeaktabledata(:,2)   ...
                              h.SelectPeaktabledata(:,6:end)];
 
end
 
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

% pVoigt-Tracking-Plot ausblenden
if isfield(h, 'plotdata') && isvalid(h.plotdata)
    set(h.plotdata, 'Visible', 'off');
end

% fitCentroid Peaklagen ausblenden
if isfield(h, 'plotdataCentFit') && isvalid(h.plotdataCentFit)
    set(h.plotdataCentFit, 'Visible', 'off');
end

% Highlight-Punkt ausblenden
if isfield(h, 'highlightpeakdata') && isvalid(h.highlightpeakdata)
    set(h.highlightpeakdata, 'Visible', 'off');
end

col = get(hObj,'backg');
set(hObj,'String','Fitting stress data ...','backg',[1 .6 .6])
pause(.01)

my         = str2double(get(h.AbscoeffEditField, "String"));
spannkomp  = str2double(get(h.SpannKompEditField, "String"));

% Peaklage-Quelle aus Radiobutton lesen
useFitPV    = true; %isfield(h, 'rb_fitpv')    && get(h.rb_fitpv,    'Value') == 1 ...
              %&& isfield(h, 'dataPVParams');
useCentroid = false; %isfield(h, 'rb_centroid') && get(h.rb_centroid, 'Value') == 1 ...
              %&& isfield(h, 'datacentFitParams');

FitDataMod = h.FitDataMod;

% Spalten 9+10: x0 und Fehler aus fitPseudoVoigt
for k = 1:numel(FitDataMod)
    mat = FitDataMod{k};
    if size(mat,2) >= 10
        idxValid = isfinite(mat(:,9));
        mat(idxValid, 2) = mat(idxValid, 9);
        mat(idxValid, 3) = mat(idxValid, 10);
    end
    FitDataMod{k} = mat;
end

DEK        = h.DEKdataMatchedPeaks;

% --- Stress für alle Peaks berechnen ---
for k = 1:size(FitDataMod, 1)
    % Zeilen mit NaN in Spalte 2 entfernen
    idxFinite     = isfinite(FitDataMod{k}(:,2));
    dataForCalc   = FitDataMod{k}(idxFinite, :);
    r = calcStress(dataForCalc, DEK(k,:), my, spannkomp);

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

% Sicherstellen dass plotdata die ε(γ)-Werte zeigt, nicht die Peaklagen
if isfield(h, 'epsfitdataexport') && ~isempty(h.epsfitdataexport)
    set(h.plotdata, ...
        'XData',          h.epsfitdataexport{1}(:,1), ...
        'YData',          h.epsfitdataexport{1}(:,2), ...
        'YNegativeDelta', h.epsfitdataexport{1}(:,3), ...
        'YPositiveDelta', h.epsfitdataexport{1}(:,3), ...
        'Visible', 'on');
end

% --- Plot aktualisieren ---
h = updateStressPlots(h, 1);

set(hObj,'String','Fit Stress Data','backg',col)
guidata(hObj, h);

function modstressdatacallback(hObj, ~)
h = guidata(hObj);

valueSlider            = round(get(h.Slider,            'Value'));
valueSliderFittedPeaks = round(get(h.SliderFittedPeaks, 'Value'));

% =====================================================================
% Peaklage-Quelle aus Radiobutton lesen
% =====================================================================
useFitPV    = true; %isfield(h, 'rb_fitpv')    && get(h.rb_fitpv,    'Value') == 1 ...
              %&& isfield(h, 'dataPVParams');
useCentroid = false; %isfield(h, 'rb_centroid') && get(h.rb_centroid, 'Value') == 1 ...
              %&& isfield(h, 'datacentFitParams');

% =====================================================================
% Undo-State sichern
% =====================================================================
h.undoState.FitDataMod         = h.FitDataMod;
h.undoState.FitDataModCentroid = h.FitDataModCentroid;
h.undoState.fitresultexport    = h.fitresultexport;
h.undoState.dataXcorr          = h.dataXcorr;
h.undoState.dataYcorr          = h.dataYcorr;
h.undoState.fitMethodUsed      = h.fitMethodUsed;
h.undoState.dataCentroidMu     = h.dataCentroidMu;
h.undoState.dataGaussFit       = h.dataGaussFit;
h.undoState.dataPVFitY         = h.dataPVFitY;
h.undoState.dataPVSuccess      = h.dataPVSuccess;
if isfield(h, 'dataPVFitMat')
    h.undoState.dataPVFitMat   = h.dataPVFitMat;
end
if isfield(h, 'datacentFitMat')
    h.undoState.datacentFitMat = h.datacentFitMat;
end
if isfield(h, 'epsfitdataexport')
    h.undoState.epsfitdataexport       = h.epsfitdataexport;
    h.undoState.epsgammaergfunc        = h.epsgammaergfunc;
    h.undoState.epssin2psifitdaten     = h.epssin2psifitdaten;
    h.undoState.sin2psifit             = h.sin2psifit;
    h.undoState.sin2psiregres          = h.sin2psiregres;
    h.undoState.tau                    = h.tau;
    h.undoState.taumean                = h.taumean;
    h.undoState.sigmaFinal             = h.sigmaFinal;
    h.undoState.sigmaerrFinal          = h.sigmaerrFinal;
    h.undoState.sigmasin2psiFinal      = h.sigmasin2psiFinal;
    h.undoState.deltasigmasin2psiFinal = h.deltasigmasin2psiFinal;
end
if isfield(h, 'validBinIdxs')
    h.undoState.validBinIdxs = h.validBinIdxs;
end
h.undoState.valueSlider = valueSlider;

if isfield(h, 'UndoStressButton') && isvalid(h.UndoStressButton)
    set(h.UndoStressButton, 'Enable', 'on');
end

% =====================================================================
% plotdata mit allen ε(γ)-Werten setzen (inkl. NaN) für Lasso-Selektion
% =====================================================================
eps = h.epsfitdataexport{valueSlider};
set(h.plotdata, ...
    'XData',          eps(:,1), ...
    'YData',          eps(:,2), ...
    'YNegativeDelta', abs(eps(:,3)), ...
    'YPositiveDelta', abs(eps(:,3)), ...
    'Visible', 'on');

% NEU:
pv    = h.FitDataMod{value};
xData = pv(isfinite(pv(:,1)), 1);
if ~isempty(xData)
    xMin = min(xData);
    xMax = max(xData);
    margin = max(5, (xMax - xMin) * 0.05);
    h.axes.XLim = [xMin - margin, xMax + margin];
end

% =====================================================================
% Punkte per Lasso auswählen
% selectStressPoints gibt Indizes in plotdata.XData zurück
% Da plotdata alle Zeilen enthält, entsprechen diese direkt eps-Zeilen
% =====================================================================
pointslist = selectStressPoints(h.axes, h.plotdata);

if isempty(pointslist)
    guidata(hObj, h);
    return
end

% =====================================================================
% Datenpunkte aus allen Strukturen löschen
% =====================================================================
% h.FitDataMod{valueSlider}(pointslist, :) = [];
% 
% if isfield(h,'FitDataModCentroid') && numel(h.FitDataModCentroid) >= valueSlider && ...
%    size(h.FitDataModCentroid{valueSlider},1) >= max(pointslist)
%     h.FitDataModCentroid{valueSlider}(pointslist, :) = [];
% end
% if isfield(h,'dataPVFitMat') && numel(h.dataPVFitMat) >= valueSlider && ...
%    size(h.dataPVFitMat{valueSlider},1) >= max(pointslist)
%     h.dataPVFitMat{valueSlider}(pointslist, :) = [];
% end
% if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider && ...
%    size(h.datacentFitMat{valueSlider},1) >= max(pointslist)
%     h.datacentFitMat{valueSlider}(pointslist, :) = [];
% end
% 
% if numel(h.fitresultexport{valueSlider}) >= max(pointslist)
%     h.fitresultexport{valueSlider}(pointslist) = {[]};
%     h.fitresultexport{valueSlider}(cellfun(@isempty, h.fitresultexport{valueSlider})) = [];
% end
% if numel(h.dataXcorr{valueSlider}) >= max(pointslist)
%     h.dataXcorr{valueSlider}(pointslist) = {[]};
%     h.dataXcorr{valueSlider}(cellfun(@isempty, h.dataXcorr{valueSlider})) = [];
% end
% if numel(h.dataYcorr{valueSlider}) >= max(pointslist)
%     h.dataYcorr{valueSlider}(pointslist) = {[]};
%     h.dataYcorr{valueSlider}(cellfun(@isempty, h.dataYcorr{valueSlider})) = [];
% end
% if isfield(h,'dataCentroidMu') && numel(h.dataCentroidMu{valueSlider}) >= max(pointslist)
%     h.dataCentroidMu{valueSlider}(pointslist) = {[]};
%     h.dataCentroidMu{valueSlider}(cellfun(@isempty, h.dataCentroidMu{valueSlider})) = [];
% end
% if isfield(h,'dataGaussFit') && numel(h.dataGaussFit{valueSlider}) >= max(pointslist)
%     h.dataGaussFit{valueSlider}(pointslist) = {[]};
%     h.dataGaussFit{valueSlider}(cellfun(@isempty, h.dataGaussFit{valueSlider})) = [];
% end
% if isfield(h,'dataPVFitY') && numel(h.dataPVFitY{valueSlider}) >= max(pointslist)
%     h.dataPVFitY{valueSlider}(pointslist) = {[]};
%     h.dataPVFitY{valueSlider}(cellfun(@isempty, h.dataPVFitY{valueSlider})) = [];
% end
% if isfield(h,'dataPVSuccess') && numel(h.dataPVSuccess{valueSlider}) >= max(pointslist)
%     h.dataPVSuccess{valueSlider}(pointslist) = [];
% end
% if isfield(h,'fitMethodUsed') && numel(h.fitMethodUsed{valueSlider}) >= max(pointslist)
%     h.fitMethodUsed{valueSlider}(pointslist) = [];
% end

% Statt löschen: NaN setzen (Zeilen bleiben erhalten)
h.FitDataMod{valueSlider}(pointslist, 2:3)   = NaN;
h.FitDataMod{valueSlider}(pointslist, 9:10)  = NaN;
h.FitDataMod{valueSlider}(pointslist, 11:12) = NaN;

if isfield(h,'dataPVFitMat') && numel(h.dataPVFitMat) >= valueSlider && ...
   size(h.dataPVFitMat{valueSlider},1) >= max(pointslist)
    h.dataPVFitMat{valueSlider}(pointslist, 2:3) = NaN;
end
if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider && ...
   size(h.datacentFitMat{valueSlider},1) >= max(pointslist)
    h.datacentFitMat{valueSlider}(pointslist, 2:3)   = NaN;
    h.datacentFitMat{valueSlider}(pointslist, 11:12) = NaN;
end
if isfield(h,'FitDataModCentroid') && numel(h.FitDataModCentroid) >= valueSlider && ...
   size(h.FitDataModCentroid{valueSlider},1) >= max(pointslist)
    h.FitDataModCentroid{valueSlider}(pointslist, 2:3) = NaN;
end

% dataXcorr leeren ohne entfernen
if numel(h.dataXcorr{valueSlider}) >= max(pointslist)
    h.dataXcorr{valueSlider}(pointslist) = {[]};
end
if numel(h.dataYcorr{valueSlider}) >= max(pointslist)
    h.dataYcorr{valueSlider}(pointslist) = {[]};
end
if numel(h.fitresultexport{valueSlider}) >= max(pointslist)
    h.fitresultexport{valueSlider}(pointslist) = {[]};
end
if isfield(h,'dataPVFitY') && numel(h.dataPVFitY{valueSlider}) >= max(pointslist)
    h.dataPVFitY{valueSlider}(pointslist) = {[]};
end
if isfield(h,'datacentFitParams') && numel(h.datacentFitParams{valueSlider}) >= max(pointslist)
    h.datacentFitParams{valueSlider}(pointslist) = {[]};
end

% =====================================================================
% Stress neu berechnen
% =====================================================================
my        = str2double(get(h.AbscoeffEditField, 'String'));
spannkomp = str2double(get(h.SpannKompEditField, 'String'));
DEK       = h.DEKdataMatchedPeaks;

dataForStress = h.FitDataMod{valueSlider};
if size(dataForStress, 2) >= 10
    idxValid = isfinite(dataForStress(:,9));
    dataForStress(idxValid, 2) = dataForStress(idxValid, 9);
    dataForStress(idxValid, 3) = dataForStress(idxValid, 10);
end
dataForStress = dataForStress(isfinite(dataForStress(:,2)), :);

r = calcStress(dataForStress, DEK(valueSlider,:), my, spannkomp);

h.epsfitdataexport{valueSlider}       = r.epsfitdata;
h.epsgammaergfunc{valueSlider}        = r.epsgammaergfunc;
h.epssin2psifitdaten{valueSlider}     = r.epssin2psifitdaten;
h.sin2psifit{valueSlider}             = r.sin2psifit;
h.sin2psiregres{valueSlider}          = r.sin2psiregres;
h.tau{valueSlider}                    = r.tau;
h.taumean(valueSlider)                = mean(r.tau);
h.sigmaFinal(valueSlider,:)           = r.sigma';
h.sigmaerrFinal(valueSlider,:)        = r.sigmaerr';
h.sigmasin2psiFinal(valueSlider)      = r.sigmapardebye;
h.deltasigmasin2psiFinal(valueSlider) = r.deltasigmapardebye;

% =====================================================================
% Plots aktualisieren
% =====================================================================
h = updateStressPlots(h, valueSlider);

% plotdata mit allen ε(γ)-Werten (inkl. NaN)
eps = h.epsfitdataexport{valueSlider};
if ~isempty(eps) && any(isfinite(eps(:,2)))
    set(h.plotdata, ...
        'XData',          eps(:,1), ...
        'YData',          eps(:,2), ...
        'YNegativeDelta', abs(eps(:,3)), ...
        'YPositiveDelta', abs(eps(:,3)), ...
        'Visible', 'on');
else
    set(h.plotdata, 'Visible', 'off');
end

for fn = {'plotdataCentFit','highlightpeakdata'}
    if isfield(h, fn{1}) && isvalid(h.(fn{1}))
        set(h.(fn{1}), 'Visible', 'off');
    end
end

% =====================================================================
% Slider anpassen – validBinIdxs aktualisieren
% =====================================================================
dc        = h.dataXcorr{valueSlider};
validIdxs = find(~cellfun(@isempty, dc));
nValid    = numel(validIdxs);
h.validBinIdxs{valueSlider} = validIdxs;

if nValid < 1
    set(h.SliderFittedPeaks, 'Min', 1, 'Max', 2, 'Value', 1, 'SliderStep', [1 1]);
    guidata(hObj, h);
    return
end

set(h.SliderFittedPeaks, ...
    'Min',        1, ...
    'Max',        max(nValid, 2), ...
    'Value',      1, ...
    'SliderStep', [1/max(nValid-1,1)  1/max(nValid-1,1)]);

% =====================================================================
% Peak-Fit-Plot aktualisieren
% =====================================================================
firstAbsBin = validIdxs(1);
h = updateFittedPeakPlot(h, valueSlider, firstAbsBin);

% highlightstressplot aktualisieren
if isfield(h,'highlightstressplot') && isvalid(h.highlightstressplot)
    set(h.highlightstressplot, ...
        'XData', h.taumean(valueSlider), ...
        'YData', h.sigmaFinal(valueSlider,1), ...
        'Visible', 'on');
end

guidata(hObj, h);

function moddatacallback(hObj, ~)
h = guidata(hObj);

valueSlider            = round(get(h.Slider,            'Value'));
valueSliderFittedPeaks = round(get(h.SliderFittedPeaks, 'Value'));

% =====================================================================
% Peaklage-Quelle aus Radiobutton lesen
% =====================================================================
useFitPV    = true; %isfield(h, 'rb_fitpv')    && get(h.rb_fitpv,    'Value') == 1 ...
              %&& isfield(h, 'dataPVParams');
useCentroid = false; %isfield(h, 'rb_centroid') && get(h.rb_centroid, 'Value') == 1 ...
              %&& isfield(h, 'datacentFitParams');

% =====================================================================
% Undo-State sichern
% =====================================================================
h.undoState.FitDataMod         = h.FitDataMod;
h.undoState.FitDataModCentroid = h.FitDataModCentroid;
h.undoState.fitresultexport    = h.fitresultexport;
h.undoState.dataXcorr          = h.dataXcorr;
h.undoState.dataYcorr          = h.dataYcorr;
h.undoState.fitMethodUsed      = h.fitMethodUsed;
h.undoState.dataCentroidMu     = h.dataCentroidMu;
h.undoState.dataGaussFit       = h.dataGaussFit;
h.undoState.dataPVFitY         = h.dataPVFitY;
h.undoState.dataPVSuccess      = h.dataPVSuccess;
if isfield(h, 'dataPVFitMat')
    h.undoState.dataPVFitMat   = h.dataPVFitMat;
end
if isfield(h, 'datacentFitMat')
    h.undoState.datacentFitMat = h.datacentFitMat;
end
if isfield(h, 'validBinIdxs')
    h.undoState.validBinIdxs = h.validBinIdxs;
end
h.undoState.valueSlider = valueSlider;

if isfield(h, 'UndoStressButton') && isvalid(h.UndoStressButton)
    set(h.UndoStressButton, 'Enable', 'on');
end

% =====================================================================
% plotdata mit ALLEN Zeilen setzen (inkl. NaN) für korrekte Indizes
% =====================================================================
dataForPlot = h.FitDataMod{valueSlider};
if size(dataForPlot, 2) >= 10
    idxV = isfinite(dataForPlot(:,9));
    dataForPlot(idxV, 2) = dataForPlot(idxV, 9);
    dataForPlot(idxV, 3) = dataForPlot(idxV, 10);
end

set(h.plotdata, ...
    'XData',          dataForPlot(:,1), ...
    'YData',          dataForPlot(:,2), ...
    'YNegativeDelta', abs(dataForPlot(:,3)), ...
    'YPositiveDelta', abs(dataForPlot(:,3)), ...
    'Visible', 'on');

xMin = min(dataForPlot(:,1));
xMax = max(dataForPlot(:,1));
if isfinite(xMin) && isfinite(xMax)
    h.axes.XLim = [xMin-5, xMax+5];
end

% =====================================================================
% Punkte per Lasso auswählen
% =====================================================================
pointslist = selectStressPoints(h.axes, h.plotdata);

if isempty(pointslist)
    guidata(hObj, h);
    return
end

% =====================================================================
% Datenpunkte aus allen Strukturen löschen
% =====================================================================
% h.FitDataMod{valueSlider}(pointslist, :) = [];
% 
% if isfield(h,'FitDataModCentroid') && numel(h.FitDataModCentroid) >= valueSlider && ...
%    size(h.FitDataModCentroid{valueSlider},1) >= max(pointslist)
%     h.FitDataModCentroid{valueSlider}(pointslist, :) = [];
% end
% if isfield(h,'dataPVFitMat') && numel(h.dataPVFitMat) >= valueSlider && ...
%    size(h.dataPVFitMat{valueSlider},1) >= max(pointslist)
%     h.dataPVFitMat{valueSlider}(pointslist, :) = [];
% end
% if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider && ...
%    size(h.datacentFitMat{valueSlider},1) >= max(pointslist)
%     h.datacentFitMat{valueSlider}(pointslist, :) = [];
% end
% 
% if numel(h.fitresultexport{valueSlider}) >= max(pointslist)
%     h.fitresultexport{valueSlider}(pointslist) = {[]};
%     h.fitresultexport{valueSlider}(cellfun(@isempty, h.fitresultexport{valueSlider})) = [];
% end
% if numel(h.dataXcorr{valueSlider}) >= max(pointslist)
%     h.dataXcorr{valueSlider}(pointslist) = {[]};
%     h.dataXcorr{valueSlider}(cellfun(@isempty, h.dataXcorr{valueSlider})) = [];
% end
% if numel(h.dataYcorr{valueSlider}) >= max(pointslist)
%     h.dataYcorr{valueSlider}(pointslist) = {[]};
%     h.dataYcorr{valueSlider}(cellfun(@isempty, h.dataYcorr{valueSlider})) = [];
% end
% if isfield(h,'dataCentroidMu') && numel(h.dataCentroidMu{valueSlider}) >= max(pointslist)
%     h.dataCentroidMu{valueSlider}(pointslist) = {[]};
%     h.dataCentroidMu{valueSlider}(cellfun(@isempty, h.dataCentroidMu{valueSlider})) = [];
% end
% if isfield(h,'dataGaussFit') && numel(h.dataGaussFit{valueSlider}) >= max(pointslist)
%     h.dataGaussFit{valueSlider}(pointslist) = {[]};
%     h.dataGaussFit{valueSlider}(cellfun(@isempty, h.dataGaussFit{valueSlider})) = [];
% end
% if isfield(h,'dataPVFitY') && numel(h.dataPVFitY{valueSlider}) >= max(pointslist)
%     h.dataPVFitY{valueSlider}(pointslist) = {[]};
%     h.dataPVFitY{valueSlider}(cellfun(@isempty, h.dataPVFitY{valueSlider})) = [];
% end
% if isfield(h,'dataPVSuccess') && numel(h.dataPVSuccess{valueSlider}) >= max(pointslist)
%     h.dataPVSuccess{valueSlider}(pointslist) = [];
% end
% if isfield(h,'fitMethodUsed') && numel(h.fitMethodUsed{valueSlider}) >= max(pointslist)
%     h.fitMethodUsed{valueSlider}(pointslist) = [];
% end

% Statt löschen: NaN setzen (Zeilen bleiben erhalten)
h.FitDataMod{valueSlider}(pointslist, 2:3)   = NaN;
h.FitDataMod{valueSlider}(pointslist, 9:10)  = NaN;
h.FitDataMod{valueSlider}(pointslist, 11:12) = NaN;

if isfield(h,'dataPVFitMat') && numel(h.dataPVFitMat) >= valueSlider && ...
   size(h.dataPVFitMat{valueSlider},1) >= max(pointslist)
    h.dataPVFitMat{valueSlider}(pointslist, 2:3) = NaN;
end
if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider && ...
   size(h.datacentFitMat{valueSlider},1) >= max(pointslist)
    h.datacentFitMat{valueSlider}(pointslist, 2:3)   = NaN;
    h.datacentFitMat{valueSlider}(pointslist, 11:12) = NaN;
end
if isfield(h,'FitDataModCentroid') && numel(h.FitDataModCentroid) >= valueSlider && ...
   size(h.FitDataModCentroid{valueSlider},1) >= max(pointslist)
    h.FitDataModCentroid{valueSlider}(pointslist, 2:3) = NaN;
end

% dataXcorr leeren ohne entfernen
if numel(h.dataXcorr{valueSlider}) >= max(pointslist)
    h.dataXcorr{valueSlider}(pointslist) = {[]};
end
if numel(h.dataYcorr{valueSlider}) >= max(pointslist)
    h.dataYcorr{valueSlider}(pointslist) = {[]};
end
if numel(h.fitresultexport{valueSlider}) >= max(pointslist)
    h.fitresultexport{valueSlider}(pointslist) = {[]};
end
if isfield(h,'dataPVFitY') && numel(h.dataPVFitY{valueSlider}) >= max(pointslist)
    h.dataPVFitY{valueSlider}(pointslist) = {[]};
end
if isfield(h,'datacentFitParams') && numel(h.datacentFitParams{valueSlider}) >= max(pointslist)
    h.datacentFitParams{valueSlider}(pointslist) = {[]};
end

% =====================================================================
% Plot aktualisieren
% =====================================================================
pv = h.FitDataMod{valueSlider};

if size(pv,2) >= 10
    set(h.plotdata, ...
        'XData',          pv(:,1), ...
        'YData',          pv(:,9), ...
        'YNegativeDelta', abs(pv(:,10)), ...
        'YPositiveDelta', abs(pv(:,10)), ...
        'Visible', 'on');
else
    set(h.plotdata, ...
        'XData',          pv(:,1), ...
        'YData',          pv(:,2), ...
        'YNegativeDelta', abs(pv(:,3)), ...
        'YPositiveDelta', abs(pv(:,3)), ...
        'Visible', 'on');
end

% fitCentroid aktualisieren
if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider
    cf    = h.datacentFitMat{valueSlider};
    idxCF = isfinite(cf(:,2));
    showCent = isfield(h,'cb_showCentroid') && get(h.cb_showCentroid,'Value') == 1;
    if isfield(h,'plotdataCentFit') && isvalid(h.plotdataCentFit)
        if any(idxCF) && showCent
            set(h.plotdataCentFit, ...
                'XData',          cf(idxCF,1), ...
                'YData',          cf(idxCF,2), ...
                'YNegativeDelta', cf(idxCF,3), ...
                'YPositiveDelta', cf(idxCF,3), ...
                'Visible', 'on');
        else
            set(h.plotdataCentFit, 'Visible', 'off');
        end
    end
end

% =====================================================================
% Slider anpassen – validBinIdxs aktualisieren
% =====================================================================
dc        = h.dataXcorr{valueSlider};
validIdxs = find(~cellfun(@isempty, dc));
nValid    = numel(validIdxs);
h.validBinIdxs{valueSlider} = validIdxs;

if nValid < 1
    set(h.SliderFittedPeaks, 'Min', 1, 'Max', 2, 'Value', 1, 'SliderStep', [1 1]);
    guidata(hObj, h);
    return
end

set(h.SliderFittedPeaks, ...
    'Min',        1, ...
    'Max',        max(nValid, 2), ...
    'Value',      1, ...
    'SliderStep', [1/max(nValid-1,1)  1/max(nValid-1,1)]);

% =====================================================================
% Peak-Fit-Plot aktualisieren
% =====================================================================
firstAbsBin = validIdxs(1);
h = updateFittedPeakPlot(h, valueSlider, firstAbsBin);

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

    print(fig,[PathNameExport,FileName1],'-vector','-dtiff','-r300')
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

    print(fig,[PathNameExport,FileName1],'-vector','-dtiff','-r300')
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

    print(fig,[PathNameExport,FileName1],'-vector','-dtiff','-r300')
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

print(fig,[PathNameExport,FileName1],'-vector','-dtiff','-r300')


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

print(fig,[PathNameExport,FileName1],'-vector','-dtiff','-r300')

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

function trackfitsettingscallback(hObj, ~)
h = guidata(hObj);

if isfield(h, 'trackFitOpts')
    newOpts = openTrackFitSettings(h.trackFitOpts);
else
    newOpts = openTrackFitSettings();
end

h.trackFitOpts = newOpts;

guidata(hObj, h);

function clearbuttondown(hObj,~)
set(hObj, 'String','','Enable','on');
uicontrol(hObj);

guidata(hObj);

function showcentroidcallback(hObj, ~)
h = guidata(hObj);

if ~isfield(h,'plotdataCentFit') || ~isvalid(h.plotdataCentFit)
    guidata(hObj, h);
    return
end

if get(hObj, 'Value') == 1
    % Centroid anzeigen falls Daten vorhanden
    valueSlider = round(get(h.Slider, 'Value'));
    showCent = isfield(h,'cb_showCentroid') && get(h.cb_showCentroid,'Value') == 1;
    if isfield(h,'datacentFitMat') && numel(h.datacentFitMat) >= valueSlider
        cf    = h.datacentFitMat{valueSlider};
        idxCF = isfinite(cf(:,2));
        if any(idxCF) && showCent
            set(h.plotdataCentFit, ...
                'XData',          cf(idxCF,1), ...
                'YData',          cf(idxCF,2), ...
                'YNegativeDelta', cf(idxCF,3), ...
                'YPositiveDelta', cf(idxCF,3), ...
                'Visible', 'on');
        end
    end
else
    set(h.plotdataCentFit, 'Visible', 'off');
end

guidata(hObj, h);