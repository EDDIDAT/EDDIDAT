function BatchFitXFlashCLI(SettingsFile, Input, OutDir, varargin)
% BATCHFITXFLASHCLI  Aufruf von BatchFitXFlash fuer die Kommandozeile bzw. als
% eigenstaendige Anwendung (MATLAB Compiler, Befehl "mcc -m"). Alle Argumente
% kommen dort als Text an und werden hier umgewandelt.
%
%   BatchFitXFlashCLI Einstellungen.mat Ordner_mit_Streifen Ausgabeordner
%   BatchFitXFlashCLI Einstellungen.mat Ordner Ausgabe MaxFiles 2
%   BatchFitXFlashCLI Einstellungen.mat Ordner Ausgabe Force true
%
%   BatchFitXFlashCLI Einstellungen.mat Ordner Ausgabe AnchorMean true
%   BatchFitXFlashCLI Einstellungen.mat Ordner Ausgabe AnchorMean true AnchorWindow 0.32,0.05,0.8
%
% Optionen (Name Wert): Force true|false, MaxFiles Zahl, UseParallel true|false,
% AnchorMean true|false, AnchorWindow "links,Abstand,rechts" (keV)
% Rueckgabewert: keiner (bei Fehlern Beendigung mit Fehlermeldung); Ergebnis
% steht in BatchLog.csv im Ausgabeordner.

if nargin < 3
    error('BatchFitXFlashCLI:Args','Aufruf: BatchFitXFlashCLI Einstellungen.mat Eingabe Ausgabeordner [MaxFiles N] [Force true] [UseParallel true]');
end
if mod(numel(varargin),2) ~= 0
    error('BatchFitXFlashCLI:Args','Optionen muessen als Paare "Name Wert" angegeben werden.');
end
opts = {};
for k = 1:2:numel(varargin)
    name = varargin{k}; val = varargin{k+1};
    switch lower(name)
        case {'force','useparallel','anchormean'}
            opts = [opts, {name, strcmpi(val,'true') || strcmp(val,'1')}]; %#ok<AGROW>
        case 'maxfiles'
            opts = [opts, {name, str2double(val)}]; %#ok<AGROW>
        case 'anchorwindow'          % z.B. "0.32,0.05,0.8" (Komma oder Leerzeichen)
            opts = [opts, {name, sscanf(strrep(val,',',' '),'%f')'}]; %#ok<AGROW>
        otherwise
            error('BatchFitXFlashCLI:Option','Unbekannte Option "%s".',name);
    end
end
R = BatchFitXFlash(SettingsFile, Input, OutDir, opts{:});
if any(strcmp({R.Status},'Fehler')) && ~isdeployed
    warning('BatchFitXFlashCLI:Errors','Mindestens eine Datei ist fehlgeschlagen, siehe BatchLog.csv.');
end
end
