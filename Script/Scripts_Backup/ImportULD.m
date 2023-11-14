%% (* import an uld-file *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Name of the uld-file stored in "/Data/ULD"
P.SpecFileName = 'Schaeffler-Fe-tth20.uld';
% Clean up all temporary variables
P.CleanUpTemporaryVariables = true;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Datei in ein Char-Array einlesen
T.Path = fullfile(General.ProgramInfo.Path, General.ProgramInfo.Path_Data, ... 
    'ULD', [P.SpecFileName '.uld']);
T.File = Tools.StringOperations.AsciiFile2Text(T.Path,'\n');

% Abschnitt finden
T.Index1 = Tools.StringOperations.SearchString(T.File, 'Untergrundliste:');
T.Index2 = Tools.StringOperations.SearchString(T.File, 'Linienlagenliste:');

% Peakregionen gem�� dem Aufbau der ULD herauslesen und entsprechend
% sortieren
T.RegionMatrix = T.File(T.Index1(1)+4:T.Index2(1)-2, :);
T.Regions = str2num(T.RegionMatrix);
Peaks.PeakRegionsBkg = T.Regions((1:end/2)*2-1,2)';
Peaks.PeakRegionsBkg = [Peaks.PeakRegionsBkg; T.Regions((1:end/2)*2,1)'];
Peaks.PeakRegionsFit = T.Regions((1:end/2)*2-1,1)';
Peaks.PeakRegionsFit = [Peaks.PeakRegionsFit; T.Regions((1:end/2)*2,2)'];

% Peakpositionen auslesen (s oder m)
T.IndexPeakPosSingle = Tools.StringOperations.SearchString(T.File, 's ');
T.IndexPeakPosMulti = Tools.StringOperations.SearchString(T.File, 'm ');

% Peakpositionen f�r Single-Peaks lesen
Peaks.PeakPositions = [];
for c = 1:size(T.IndexPeakPosSingle,1)
    Peaks.PeakPositions = [Peaks.PeakPositions, sscanf(T.File(T.IndexPeakPosSingle(c)+1,:), '%f %*f')];
end

% Peakpositionen f�r Multi-Peaks lesen
for c = 1:size(T.IndexPeakPosMulti,1)
    % Anzahl der Peaks 
    T.NumberOfMultiPeaks = sscanf(T.File(T.IndexPeakPosMulti(c)+1,:), '%d');
    for d = 1:T.NumberOfMultiPeaks
        Peaks.PeakPositions = [Peaks.PeakPositions, sscanf(T.File(T.IndexPeakPosMulti(c)+1+d,:), '%f %*f %*f')];
    end
end

Peaks.PeakPositions = sort(Peaks.PeakPositions);

if (P.CleanUpTemporaryVariables)
    clear('P');
    clear('T');
    clear c d;
end

disp('uld-file imported');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++