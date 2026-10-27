function Settings = ExtractBatchSettingsFromGUI(h, varargin)
% EXTRACTBATCHSETTINGSFROMGUI  Liest die Fit-Einstellungen aus der GUI und
% speichert sie fuer BatchFitXFlash (Batch-Auswertung vieler Dateien).
%
% Ablauf:
%   1) In der GUI EINE Referenzdatei wie gewohnt auswerten: laden, Emin/Emax,
%      Untergrund (Define/Fit Background, ggf. ULD-Datei laden, ggf. SNIP),
%      Peaks definieren, Fit, und "Create Psi" / Diffraction Peaks erzeugen
%      (buttoncreatepsi1). Dabei legt die GUI ihren Zustand als Variable 'h'
%      im MATLAB-Workspace ab.
%   2) Im MATLAB-Command-Window aufrufen:
%         ExtractBatchSettingsFromGUI
%      oder mit Optionen:
%         ExtractBatchSettingsFromGUI([], 'File','D:\...\Si_Streifen.mat', ...
%                                     'ULDFile','D:\EDDIDAT_github\Data\ULD\Si_IKZ.mat')
%   3) Die erzeugte Datei an BatchFitXFlash uebergeben.
%
% Optionen (Name, Wert):
%   'File'       Zieldatei (.mat). Standard: Data\BatchSettings\<Diffractometer>_<Datum>.mat
%   'ULDFile'    ULD-Datei, aus der die Untergrundpunkte stammen (falls der
%                Untergrund per "Load File" geladen wurde; genauer als die
%                Punkte aus h, weil die GUI sie je Spektrum angepasst hat)
%   'UseSNIP'    true, wenn vor dem Untergrund-Fit der SNIP-Untergrund
%                angewendet wurde (Standard false)
%   'SNIPWindow' Fensterbreite fuer SNIP (Standard: Wert aus dem GUI-Feld)
%
% Nicht unterstuetzt (es wird gewarnt): "Integrate spectra", Corrections,
% LEDDI mit zwei Detektoren.

p = inputParser;
addParameter(p,'File','',@ischar);
addParameter(p,'ULDFile','',@ischar);
addParameter(p,'UseSNIP',false,@islogical);
addParameter(p,'SNIPWindow',[],@isnumeric);
parse(p,varargin{:});
opt = p.Results;

if nargin < 1 || isempty(h)
    try
        h = evalin('base','h');
    catch
        error('ExtractBatchSettingsFromGUI:NoH',['Variable h nicht im Base-Workspace gefunden. ' ...
            'Zuerst in der GUI die Referenzdatei fitten und "Create Psi" (Diffraction Peaks erzeugen) ausfuehren.']);
    end
end

%% Pflichtfelder pruefen
need = {'Diffsel','P','Peaks','Peakslb','Peaksub','PeakRegionsX','FilterOptions','hklDataPsiFile','SpecFileCheck'};
missing = need(~isfield(h,need));
if ~isempty(missing)
    error('ExtractBatchSettingsFromGUI:MissingFields','In h fehlen Felder: %s. Wurde der Fit und "Create Psi" ausgefuehrt?',strjoin(missing,', '));
end
needP = {'EnergyRange','PopupValueFitFunc','Calibration','ElementalFormula','MPDFileName'};
missingP = needP(~isfield(h.P,needP));
if ~isempty(missingP)
    error('ExtractBatchSettingsFromGUI:MissingFieldsP','In h.P fehlen Felder: %s.',strjoin(missingP,', '));
end
if strcmp(h.Diffsel,'LEDDI_KETEK_TWODET')
    error('ExtractBatchSettingsFromGUI:LEDDI','LEDDI (zwei Detektoren) wird vom Batch nicht unterstuetzt.');
end

Settings = struct();
Settings.Created = datestr(now,'yyyy-mm-dd HH:MM:SS');
Settings.Diffsel = h.Diffsel;
Settings.Calibration = h.P.Calibration;
Settings.EnergyRange = h.P.EnergyRange;
Settings.FitFunc = h.P.PopupValueFitFunc;
Settings.SpecFileCheck = h.SpecFileCheck;
Settings.Sample = struct('ElementalFormula',h.P.ElementalFormula,'MPDFileName',h.P.MPDFileName);
if isfield(h.P,'SpecFileName'), Settings.ReferenceFile = h.P.SpecFileName; else, Settings.ReferenceFile = ''; end

% Overlap-Modus (Popup in der GUI): 1 keiner, 2 gekoppelt, 3/4 Martensit
Settings.OverlapMode = 1;
try
    Settings.OverlapMode = get(h.popupmenuOverlapMode,'value');
catch
    warning('ExtractBatchSettingsFromGUI:Overlap','Overlap-Modus konnte nicht gelesen werden (GUI geschlossen?). Standard 1 (keiner) wird verwendet.');
end

%% Peaks
pk = h.Peaks; pklb = h.Peakslb; pkub = h.Peaksub;   % lokale Kopien: anonyme Funktionen fangen sonst das ganze (grosse) h ein
Settings.Peaks = pk{1};
Settings.Peakslb = pklb{1};
Settings.Peaksub = pkub{1};
p1 = pk{1}; p2 = pklb{1}; p3 = pkub{1};
if ~all(cellfun(@(x) isequal(x,p1),pk)) || ~all(cellfun(@(x) isequal(x,p2),pklb)) || ~all(cellfun(@(x) isequal(x,p3),pkub))
    warning('ExtractBatchSettingsFromGUI:PeaksDiffer','Peaks/Grenzen sind nicht fuer alle Spektren gleich. Es werden die Werte von Spektrum 1 verwendet.');
end

%% Untergrund
PR = h.PeakRegionsX; PR1 = PR{1};
Settings.Bkg = struct();
if ~isempty(opt.ULDFile)
    U = load(opt.ULDFile);
    Settings.Bkg.Method = 'localmin';                       % wie GUI "Load File" bei anderer Spektrenzahl (SearchBKGPoints)
    Settings.Bkg.Points = sort(U.PeakRegionsX{1}(:));
    Settings.Bkg.ULDFile = opt.ULDFile;
elseif all(cellfun(@(x) isequal(x,PR1),PR))
    Settings.Bkg.Method = 'fixed';                          % gleiche Punkte fuer alle Spektren
    Settings.Bkg.PeakRegionsX = PR{1};
else
    Settings.Bkg.Method = 'localmin';                       % je Spektrum lokales Minimum um die Punkte
    Settings.Bkg.Points = sort(PR{1}(:));
    warning('ExtractBatchSettingsFromGUI:BkgPerSpectrum',['Untergrundpunkte unterscheiden sich je Spektrum. ' ...
        'Es wird je Datei SearchBKGPoints mit den Punkten von Spektrum 1 verwendet. Genauer: Option ''ULDFile'' angeben.']);
end
Settings.Bkg.UseSNIP = opt.UseSNIP;
Settings.Bkg.SNIPWindow = opt.SNIPWindow;
if opt.UseSNIP && isempty(opt.SNIPWindow)
    try
        Settings.Bkg.SNIPWindow = str2double(get(h.editbkgSNIPWindow,'String'));
    catch
        error('ExtractBatchSettingsFromGUI:SNIP','SNIP-Fensterbreite nicht lesbar: Option ''SNIPWindow'' angeben.');
    end
end

%% Filter, hkl, abgewaehlte Peaks
Settings.FilterOptions = h.FilterOptions;
Settings.hkl = h.hklDataPsiFile;
if isfield(h,'idxkeepPeaks'), Settings.idxkeepPeaks = h.idxkeepPeaks; end
if isfield(h,'idxdeletePeaks'), Settings.idxdeletePeaks = h.idxdeletePeaks; end

%% Warnungen
% Anzahl der hkl-Zeilen muss zur Zahl der gefitteten Peaks passen, sonst bricht BatchFitXFlash
% je Datei mit "Anzahl hkl-Zeilen ... passt nicht zur Anzahl gefitteter Peaks" ab.
nPkFit = numel(Settings.Peaks); nHkl = size(Settings.hkl,1);
okCounts = nPkFit;
if isfield(Settings,'idxdeletePeaks'), okCounts = [nPkFit, nPkFit - numel(Settings.idxdeletePeaks)]; end
if ~any(nHkl == okCounts)
    warning('ExtractBatchSettingsFromGUI:HklCount',['Die hkl-Tabelle hat %d Zeilen, es wurden aber %d Peaks gefittet. BatchFitXFlash bricht dann mit ' ...
        '"Anzahl hkl-Zeilen passt nicht zur Anzahl gefitteter Peaks" ab. Meist wurde in der GUI "Select peaks" vor "Load fit data" nicht ausgefuehrt (dann gilt die Standardtabelle mit 10 Nullzeilen). Bitte "Select peaks", dann "Load fit data" und erneut die Einstellungen extrahieren.'],nHkl,nPkFit);
end
if isfield(h,'IsIntegrated') && h.IsIntegrated
    warning('ExtractBatchSettingsFromGUI:Integrated','"Integrate spectra" wurde verwendet: BatchFitXFlash unterstuetzt das nicht.');
end
if isfield(h,'corrcnt')
    warning('ExtractBatchSettingsFromGUI:Corrections','Corrections wurden angewendet: BatchFitXFlash fuehrt sie nicht aus.');
end
if h.SpecFileCheck ~= 0
    warning('ExtractBatchSettingsFromGUI:SpecFile','SpecFileCheck = %d: BatchFitXFlash ist nur fuer SpecFileCheck = 0 (Xlab-IKZ) getestet.',h.SpecFileCheck);
end

%% Speichern
file = opt.File;
if isempty(file)
    folder = fullfile(General.ProgramInfo.Path,'Data','BatchSettings');
    if ~exist(folder,'dir'), mkdir(folder); end
    file = fullfile(folder,[strrep(h.Diffsel,' ','_') '_' datestr(now,'yyyymmdd_HHMMSS') '.mat']);
else
    folder = fileparts(file);
    if ~isempty(folder) && ~exist(folder,'dir'), mkdir(folder); end
end
save(file,'Settings');

fprintf('Batch-Einstellungen gespeichert: %s\n',file);
fprintf('  Diffraktometer %s, Fitfunktion %d, Energiebereich [%g %g] keV, Overlap-Modus %d\n',Settings.Diffsel,Settings.FitFunc,Settings.EnergyRange(1),Settings.EnergyRange(2),Settings.OverlapMode);
fprintf('  Peaks (keV): %s | Grenzen -/+ : %s / %s\n',mat2str(Settings.Peaks,5),mat2str(Settings.Peakslb,3),mat2str(Settings.Peaksub,3));
fprintf('  Untergrund: %s%s, SNIP: %d | hkl-Zeilen: %d | Filter aktiv: %d\n',Settings.Bkg.Method,ifelse_(isfield(Settings.Bkg,'ULDFile'),[' (ULD ' opt.ULDFile ')'],''),Settings.Bkg.UseSNIP,size(Settings.hkl,1),Settings.FilterOptions.EvaluateFits);
end

function s = ifelse_(c,a,b)
if c, s = a; else, s = b; end
end
