function [Results,Info] = BatchFitXFlash(SettingsFile, Input, OutDir, varargin)
% BATCHFITXFLASH  Wendet die Fit-Einstellungen einer Referenzdatei auf viele
% Dateien an und schreibt je Eingabedatei eine psi-Datei (Diffraktometer
% "Xlab-IKZ", Dateien wie von bcf_zu_eddidat_streifen.py bzw. LoadXFlashFileGUI).
%
%   [Results,Info] = BatchFitXFlash(SettingsFile, Input, OutDir, ...)
%                  Info.Mode ('parallel'/'serial'), Info.NumWorkers, Info.ModeText: tatsaechlich
%                  verwendete Betriebsart (steht auch in BatchOptionen.txt im Ausgabeordner).
%                  Parallel wird nur genutzt, wenn mehr als 1 Datei zu rechnen ist.
%   Results = BatchFitXFlash(SettingsFile, Input)
%   Results = BatchFitXFlash(SettingsFile, Input, OutDir, 'Force',false, ...
%                            'UseParallel',false, 'MaxFiles',Inf)
%
% SettingsFile  .mat-Datei, erzeugt mit ExtractBatchSettingsFromGUI
% Input         Ordner (alle *.mat darin), Muster ('D:\...\strips\*.mat')
%               oder Zellarray mit Dateinamen
% OutDir        Ausgabeordner fuer die psi-Dateien (Standard:
%               Data\Results\<Diffraktometer>\batch_<Datum>\Psi_and_tau_File)
%
% Optionen:
%   'Force'        true: auch bereits fertige Dateien neu berechnen
%   'UseParallel'  true: Dateien parallel auf mehreren Workern (Parallel
%                  Computing Toolbox; experimentell)
%   'MaxFiles'     hoechstens so viele noch offene Dateien in diesem Lauf
%   'ProgressFcn'  Funktionshandle @(k,n,R), wird im seriellen Betrieb nach jeder
%                  fertigen Datei aufgerufen (k von n, R = Ergebnis der Datei)
%   'AnchorMean'   true: Untergrund in JEDEM Peakbereich als Gerade durch die
%                  Mittelwerte zweier Fenster links und rechts des Bereichs
%                  (statt durch zwei einzelne, verrauschte Randwerte). Standard
%                  false = Verhalten wie in der GUI. Getestet an Streifen 05:
%                  beim schwachen 448-Reflex deutlich weniger Rauschen.
%   'AnchorWindow' [Breite_links Abstand Breite_rechts (Abstand_links)] in keV,
%                  Standard [0.32 0.05 0.80 0]: linkes Fenster [a-0.32, a],
%                  rechtes Fenster [b+0.05, b+0.85] fuer einen Peakbereich [a,b].
%                  Der optionale 4. Wert verschiebt das linke Fenster um diesen
%                  Betrag weg vom Peak: [a-g-wl, a-g]. Das linke Fenster darf
%                  bis zur Mitte des vorherigen Peakbereichs reichen, das rechte
%                  bis zum Beginn des naechsten; beide werden auf den Datenbereich
%                  beschnitten;
%                  bleiben weniger als 5 Kanaele, bleibt der GUI-Untergrund.
%
% Zwischenspeichern und Fortsetzen:
%   Jede Datei wird einzeln ausgewertet; ihre psi-Datei entsteht zuerst als
%   <Name>.psi.tmp und wird erst nach vollstaendigem Schreiben in <Name>.psi
%   umbenannt. Existiert <Name>.psi schon, wird die Datei beim naechsten
%   Aufruf uebersprungen. Bei einem Fehler in einer Datei laeuft der Batch
%   mit der naechsten weiter; der Fehler steht in BatchLog.csv (im OutDir).
%   Ein erneuter Aufruf mit denselben Argumenten rechnet nur noch die
%   fehlenden bzw. fehlgeschlagenen Dateien.
%
% Der Ablauf je Datei entspricht der GUI: Laden (LoadXFlashFileGUI) ->
% Energiebereich (SelectMeasurementsGUI) -> Untergrund (SearchBKGPoints,
% SNIPBackgroundGUI, BackgroundReductionGUI) -> Fit (FittingGUI2) ->
% PrepareFitPeaksPlot -> FilterDiffLine -> PsiData*General -> psi-Datei
% (SaveToPsiFileNew). Es werden keine Plots und keine Einzelspektrum-Dateien
% (RawData, FittedSpectra) geschrieben. Nicht unterstuetzt: Corrections,
% "Integrate spectra", LEDDI.

p = inputParser;
addParameter(p,'Force',false,@islogical);
addParameter(p,'UseParallel',false,@islogical);
addParameter(p,'MaxFiles',Inf,@isnumeric);
addParameter(p,'ProgressFcn',[],@(f) isempty(f) || isa(f,'function_handle'));
addParameter(p,'AnchorMean',false,@islogical);
addParameter(p,'AnchorWindow',[0.32 0.05 0.80 0],@(x) isnumeric(x) && (numel(x) == 3 || numel(x) == 4) && all(x >= 0));
parse(p,varargin{:});
opt = p.Results;

L = load(SettingsFile,'Settings'); S = L.Settings;
opt.AnchorWindow = [opt.AnchorWindow(:)' zeros(1,4 - numel(opt.AnchorWindow))];   % 4. Wert (Abstand links) optional
S.Bkg.AnchorMean = struct('Enabled',opt.AnchorMean,'Window',opt.AnchorWindow);
files = ResolveInput_(Input);
if isempty(files)
    error('BatchFitXFlash:NoFiles','Keine Eingabedateien gefunden.');
end
if nargin < 3 || isempty(OutDir)
    OutDir = fullfile(General.ProgramInfo.Path,'Data','Results',S.Diffsel,['batch_' datestr(now,'ddmmyyyy')],'Psi_and_tau_File');
end
if ~exist(OutDir,'dir'), mkdir(OutDir); end
logFile = fullfile(OutDir,'BatchLog.csv');

nF = numel(files);
done = false(1,nF);
for i = 1:nF
    [~,base] = fileparts(files{i});
    psiPath = fullfile(OutDir,[base '.psi']);
    if exist([psiPath '.tmp'],'file'), delete([psiPath '.tmp']); end        % Rest eines abgebrochenen Laufs
    done(i) = (exist(psiPath,'file') == 2) && ~opt.Force;
end
pend = find(~done);
if numel(pend) > opt.MaxFiles, pend = pend(1:opt.MaxFiles); end

Results = repmat(struct('File','','Status','','Spectra',0,'Seconds',0,'Message',''),1,nF);
for i = find(done)
    Results(i) = struct('File',files{i},'Status','uebersprungen (fertig)','Spectra',0,'Seconds',0,'Message','');
end
fprintf('BatchFitXFlash: %d Dateien, %d bereits fertig, %d werden gerechnet. Ausgabe: %s\n',nF,sum(done),numel(pend),OutDir);
if opt.AnchorMean
    fprintf('  Untergrund: Ankermittelung aktiv, Fenster [links %.2f, Abstand %.2f, rechts %.2f, Abstand links %.2f] keV\n',opt.AnchorWindow);
end

useParallel = opt.UseParallel && numel(pend) > 1;
if useParallel
    try
        gcp;
        if ~isdeployed
            % Nur unkompiliert: Suchpfad an die Worker geben. In der kompilierten Version liegen die
            % Funktionen im Paketarchiv, ein Suchpfad wird nicht gesetzt und nicht gebraucht.
            pctRunOnAll(['path(''' strrep(path,'''','''''') ''')']);
        end
    catch ME
        warning('BatchFitXFlash:NoParallel','Parallelbetrieb nicht moeglich (%s). Es wird seriell gerechnet.',ME.message);
        useParallel = false;
    end
end

% Betriebsart festhalten (Konsole, BatchOptionen.txt, zweiter Rueckgabewert Info)
nWorkers = 0;
if useParallel
    pPool = gcp('nocreate');
    if ~isempty(pPool), nWorkers = pPool.NumWorkers; end
    modeText = sprintf('parallel (%d Worker)',nWorkers);
elseif opt.UseParallel && numel(pend) <= 1
    modeText = 'seriell (Parallelbetrieb angefordert, aber nur 1 Datei zu rechnen)';
elseif opt.UseParallel
    modeText = 'seriell (Parallelbetrieb angefordert, aber nicht moeglich)';
else
    modeText = 'seriell';
end
Info = struct('Mode',ifelse_(useParallel,'parallel','serial'),'ModeText',modeText,'NumWorkers',nWorkers,'ParallelRequested',opt.UseParallel);
fprintf('  Modus: %s\n',modeText);
optFile = fullfile(OutDir,'BatchOptionen.txt');
fidO = fopen(optFile,'a');
fprintf(fidO,'%s  Settings=%s  AnchorMean=%d  AnchorWindow=[%g %g %g %g]  Modus=%s  Dateien=%d (offen %d)\n',datestr(now,'yyyy-mm-dd HH:MM:SS'),SettingsFile,opt.AnchorMean,opt.AnchorWindow,modeText,nF,numel(pend));
fclose(fidO);

tAll = tic;
if useParallel
    res = cell(1,numel(pend));
    parfor k = 1:numel(pend)
        res{k} = ProcessOneFile_(files{pend(k)},S,OutDir);
    end
    for k = 1:numel(pend)
        Results(pend(k)) = res{k}; AppendLog_(logFile,res{k});
        fprintf('  %s: %s (%d Spektren, %.0f s)\n',ShortName_(res{k}.File),res{k}.Status,res{k}.Spectra,res{k}.Seconds);
    end
else
    for k = 1:numel(pend)
        i = pend(k);
        fprintf('[%d/%d] %s ... ',k,numel(pend),ShortName_(files{i}));
        R = ProcessOneFile_(files{i},S,OutDir);
        Results(i) = R; AppendLog_(logFile,R);
        fprintf('%s (%d Spektren, %.0f s)\n',R.Status,R.Spectra,R.Seconds);
        if ~isempty(opt.ProgressFcn), opt.ProgressFcn(k,numel(pend),R); end    % z. B. Fortschrittsbalken der GUI (nur seriell)
        if ~strcmp(R.Status,'fertig'), fprintf('    %s\n',strtrim(R.Message)); end
    end
end

nOK = sum(strcmp({Results.Status},'fertig')); nSkip = sum(strncmp({Results.Status},'uebersprungen',13)); nErr = sum(strcmp({Results.Status},'Fehler'));
fprintf('Fertig: %d neu berechnet, %d uebersprungen, %d Fehler (%.0f s). Log: %s\n',nOK,nSkip,nErr,toc(tAll),logFile);
if nErr > 0
    fprintf('Fehlgeschlagen (erneut aufrufen, um nur diese zu wiederholen):\n');
    for i = find(strcmp({Results.Status},'Fehler')), fprintf('  %s\n',Results(i).File); end
end
end

%% ------------------------------------------------------------------------
function R = ProcessOneFile_(file,S,OutDir)
R = struct('File',file,'Status','Fehler','Spectra',0,'Seconds',0,'Message','');
t0 = tic;
try
    [~,base] = fileparts(file);
    psiPath = fullfile(OutDir,[base '.psi']); tmpPath = [psiPath '.tmp'];
    if exist(tmpPath,'file'), delete(tmpPath); end

    % Probe wie "Create sample" in der GUI
    [SampleObj,T] = CreateSampleGUI(struct('ElementalFormula',S.Sample.ElementalFormula,'MPDFileName',S.Sample.MPDFileName, ...
                                           'ShowSubstratePeaks',false,'CleanUpTemporaryVariables',false));
    P = struct();
    [meas,~,DT,~,P,~] = LoadXFlashFileGUI(file,P,SampleObj,T);
    n = numel(meas); R.Spectra = n;

    % Energiebereich (okbuttonselectmeas -> SelectMeasurementsGUI)
    P.Diffsel = S.Diffsel; P.WhichMeasurementsDetector = [1 n]; P.EnergyRange = S.EnergyRange; P.CleanUpTemporaryVariables = false;
    [meas,SampleObj,~,~] = SelectMeasurementsGUI(meas,SampleObj,P,cell(1,n)); %#ok<ASGLU>
    DT = arrayfun(@(m) m.EDSpectrum,meas,'UniformOutput',false);

    % Untergrundpunkte (wie "Define Background" bzw. "Load File" der GUI)
    switch S.Bkg.Method
        case 'fixed'
            PRX = repmat({S.Bkg.PeakRegionsX},1,n);
        case 'localmin'
            [PRX,~,~] = SearchBKGPoints(DT,S.Bkg.Points,1);
        otherwise
            error('Unbekannte Untergrundmethode: %s',S.Bkg.Method);
    end
    % Untergrund abziehen (optional zuerst SNIP, dann Fit Background)
    if isfield(S.Bkg,'UseSNIP') && S.Bkg.UseSNIP
        [meas,DT,~,~] = SNIPBackgroundGUI(meas,DT,P.Calibration,S.Bkg.SNIPWindow);
    end
    DTin = DT;
    [meas,DT,~,BK] = BackgroundReductionGUI(meas,DT,PRX,P.Calibration,S.Diffsel);
    if isfield(S.Bkg,'AnchorMean') && S.Bkg.AnchorMean.Enabled
        DT = ApplyAnchorMean_(DTin,DT,BK,PRX,S.Bkg.AnchorMean.Window);
    end

    % Peaks fitten (buttonselectpeak3)
    Pk = repmat({S.Peaks},1,n); Plb = repmat({S.Peakslb},1,n); Pub = repmat({S.Peaksub},1,n);
    CoupleOverlapPeaks = (S.OverlapMode == 2);
    MartensiteSplit = (S.OverlapMode == 3 || S.OverlapMode == 4);
    MartensiteFreeWidth = (S.OverlapMode == 4);
    [meas,DT,FP,CI,SE] = FittingGUI2(meas,DT,PRX,Pk,Plb,Pub,S.FitFunc,S.Diffsel,CoupleOverlapPeaks,MartensiteSplit,MartensiteFreeWidth);
    idx = cellfun(@isnan,SE,'UniformOutput',false);
    for k = 1:length(SE), SE{1,k}(idx{1,k}) = 0; CI{1,k}(idx{1,k}) = 0; end
    [FPc,~,~,~,~,~,~,~] = PrepareFitPeaksPlot(DT,FP,Pk,PRX,SE,S.FitFunc,1,S.Diffsel,1,1);

    % Diffraction lines und psi-Tabelle (buttoncreatepsi1, Zweig ohne LEDDI)
    DL = FilterDiffLine(meas,FPc,SE,S.FitFunc,S.FilterOptions);
    if isfield(S,'idxkeepPeaks') && isfield(S,'idxdeletePeaks') && size(DL{1},2) ~= size(S.idxkeepPeaks,1)
        for k = 1:length(DL), DL{k}(S.idxdeletePeaks) = []; end
    end
    switch S.FitFunc
        case {2,4,5}, Psidata = PsiDataPVGeneral(DL,S.SpecFileCheck);
        case 6,       Psidata = PsiDataAsymPVGeneral(DL,S.SpecFileCheck);
        case 7,       Psidata = PsiDataSplitPVGeneral(DL,S.SpecFileCheck);
        case 3,       Psidata = PsiDataTCHGeneral(DL,S.SpecFileCheck);
        otherwise,    error('Fitfunktion %d nicht unterstuetzt.',S.FitFunc);
    end
    nRow = size(Psidata.LineNumber,1); nPk = size(Psidata.LineNumber,2);
    if size(S.hkl,1) ~= nPk
        error('Anzahl hkl-Zeilen (%d) passt nicht zur Anzahl gefitteter Peaks (%d).',size(S.hkl,1),nPk);
    end
    LineCnt = repmat(1:nPk,nRow,1);
    h_ = repmat(S.hkl(:,1)',nRow,1); k_ = repmat(S.hkl(:,2)',nRow,1); l_ = repmat(S.hkl(:,3)',nRow,1);
    for k = 1:nPk
        for l = 1:nRow
            Psidata.LineNumber{l,k} = num2str(LineCnt(l,k));
            Psidata.h{l,k} = num2str(h_(l,k)); Psidata.k{l,k} = num2str(k_(l,k)); Psidata.l{l,k} = num2str(l_(l,k));
        end
    end
    Psidata_tmp = struct2cell(Psidata);
    PsiTab_tmp = cellfun(@(x) reshape(x,prod(size(Psidata_tmp{1})),[]),Psidata_tmp,'un',0); %#ok<PSIZE>
    PsiFileTableData = [PsiTab_tmp{:}];
    % Zeilen ohne Peak (Emax = 0, z.B. durch Filter) wie in der GUI entfernen
    PsiFileTableData(strcmp(PsiFileTableData(:,2),'0.0000'),:) = [];
    if S.SpecFileCheck == 1
        error('SpecFileCheck = 1 (Datumsspalte) wird vom Batch nicht unterstuetzt.');
    end
    DiffractionLinesNum = str2double(PsiFileTableData);

    SaveToPsiFileNew(DiffractionLinesNum,tmpPath,[base '.psi'],S.FitFunc,S.SpecFileCheck);
    movefile(tmpPath,psiPath,'f');
    R.Status = 'fertig';
catch ME
    R.Status = 'Fehler';
    R.Message = sprintf('%s: %s',ME.identifier,strrep(ME.message,newline,' '));
    if ~isempty(ME.stack), R.Message = sprintf('%s (in %s, Zeile %d)',R.Message,ME.stack(1).name,ME.stack(1).line); end
    try, if exist(tmpPath,'file'), delete(tmpPath); end, catch, end %#ok<NASGU>
end
R.Seconds = toc(t0);
end

%% ------------------------------------------------------------------------
function DT = ApplyAnchorMean_(DTin,DT,BK,PRX,win)
% Ersetzt den Untergrund in jedem Peakbereich [a,b] durch die Gerade durch die
% Fenstermittelwerte links [a-wl,a] und rechts [b+gap,b+gap+wr]. DTin = Spektren
% vor der Untergrundkorrektur, BK = von BackgroundReductionGUI abgezogener Untergrund.
wl = win(1); gap = win(2); wr = win(3);
if numel(win) >= 4, gl = win(4); else, gl = 0; end
minPts = 5;
for c = 1:numel(DT)
    x = DTin{c}(:,1); y = DTin{c}(:,2);
    R = PRX{c}; nR = size(R,2);
    for j = 1:nR
        a = R(1,j); b = R(2,j);
        if j > 1, lowL = mean(R(:,j-1)); else, lowL = x(1); end      % Mitte des vorherigen Peakbereichs
        if j < nR, highR = R(1,j+1); else, highR = x(end); end
        iL = x >= max(a - gl - wl,lowL) & x < a - gl;
        iR = x > b + gap & x <= min(b + gap + wr,highR);
        if sum(iL) < minPts || sum(iR) < minPts, continue; end
        xl = mean(x(iL)); xr = mean(x(iR));
        k = x >= a & x <= b;
        bnew = mean(y(iL)) + (mean(y(iR)) - mean(y(iL))) * (x(k) - xl) / (xr - xl);
        DT{c}(k,2) = DT{c}(k,2) + BK{c}(k,2) - bnew;
    end
end
end

%% ------------------------------------------------------------------------
function files = ResolveInput_(Input)
if iscell(Input)
    files = Input(:)';
elseif isstring(Input) && numel(Input) > 1
    files = cellstr(Input(:))';
else
    Input = char(Input);
    if isfolder(Input)
        d = dir(fullfile(Input,'*.mat'));
    else
        d = dir(Input);
    end
    d = d(~[d.isdir]);
    files = fullfile({d.folder},{d.name});
end
files = sort(files);
end

function AppendLog_(logFile,R)
newFile = ~exist(logFile,'file');
fid = fopen(logFile,'a');
if newFile, fprintf(fid,'Zeit;Datei;Status;Spektren;Sekunden;Meldung\n'); end
fprintf(fid,'%s;%s;%s;%d;%.1f;%s\n',datestr(now,'yyyy-mm-dd HH:MM:SS'),R.File,R.Status,R.Spectra,R.Seconds,strrep(R.Message,';',','));
fclose(fid);
end

function s = ifelse_(c,a,b)
if c, s = a; else, s = b; end
end

function s = ShortName_(f)
[~,s,e] = fileparts(f); s = [s e];
end
