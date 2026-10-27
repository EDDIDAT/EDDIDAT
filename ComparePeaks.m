function [CompareFitPeaksLogical,MinValPeakDiff,IdxValPeakDiff,PeakDiff_tmp3] = ComparePeaks(Peaks_tmp,PeaksTheo)
% Function used to compare user defined peak position with theoretical peak
% positions.

%% Alte Berechnung von MinVal.
% Calculate differences between theoretical and user defined peaks.
% for k = 1:size(Peaks{1},2)
%     for l = 1:size(PeaksTheo,1)
%         PeakDiff{k,l} = abs(Peaks{1}(k)-PeaksTheo(l));
%     end
% end

% % Convert cell to matrix
% PeakDifftmp = cell2mat(PeakDiff);

% [MinVal, IndVal] = min(PeakDifftmp);
% assignin('base','Peaks_tmp',Peaks_tmp)
% assignin('base','PeaksTheo',PeaksTheo)
%% Hier neue Berechnung von MinVal. 
% Vorher wurden nur die Peaklagen der Messung bei psi = 0° bzw. des ersten 
% Psi-Winkels verwendet. Bei zu kleinen Reflexen oder vorliegender Textur, 
% kam es dabei vereinzelt zu Fehlern bei der hkl Indizierung. Nun werden 
% alle Peaklagen aus allen gemessenen Psi-Winkeln berücksichtigt.

% Fallunterscheidung ob nur Peaklagen oder FittedPeaks uebergeben wurde.
if size(Peaks_tmp{1},1) ~= 1
    for j = 1:size(Peaks_tmp,2)
        Peaks{j} = Peaks_tmp{j}(:,2);
    end
else
    Peaks = cellfun(@transpose,Peaks_tmp,'UniformOutput',false);
end

for j = 1:size(Peaks,2)
    for k = 1:size(Peaks{j},1)
        for l = 1:size(PeaksTheo,1)
            PeakDiff{j}{k,l} = abs(Peaks{j}(k)-PeaksTheo(l));
        end
    end
end

%% Neue Variante vom 30.09.2026: globale 1:1-Zuordnung statt zeilenweiser
% "naechster Nachbar"-Suche.
% Die alte Variante (siehe Kommentare unten) hat fuer jeden markierten/
% gefitteten Peak UNABHAENGIG den naechstgelegenen theoretischen Peak
% gesucht. Bei ungenauen, manuell gesetzten Klickpositionen kann das zu
% Konflikten fuehren: zwei Klicks konkurrieren um denselben theoretischen
% Peak (der zuerst verarbeitete "gewinnt" dann automatisch, unabhaengig
% davon, ob ein anderer Klick eigentlich besser passen wuerde), oder ein
% Klick wird bei eng benachbarten Linien dem falschen zugeordnet.
%
% matchpairs loest stattdessen die global optimale, eindeutige 1:1-
% Zuordnung (kleinste Gesamt-Energiedifferenz) zwischen allen Klicks/
% gefitteten Peaks und allen theoretischen Positionen. Differenzen ueber
% der Schwelle werden vorher auf Inf gesetzt, damit matchpairs sie nie
% waehlt; Peaks ohne zulaessigen Treffer (z.B. absichtlich markierte
% Fluoreszenzlinien, die mit einem Reflex ueberlappen) bleiben bewusst
% unzugeordnet, statt eine willkuerliche/fehlerhafte Zuordnung zu
% erzwingen (kein "kein Treffer"-Sonderfall wie beim alten min()-Ansatz
% noetig, da matchpairs Zeilen/Spalten ohne zulaessigen Partner einfach
% unmatched laesst).
% Adaptive Schwelle je theoretischem Peak: hoechstens die Haelfte des
% Abstands zum naechsten Nachbarn (links oder rechts in der sortierten
% Energieliste), nach oben weiterhin gedeckelt durch die bisherige feste
% Toleranz (0.55 keV) fuer isolierte Peaks. Verhindert, dass sich die
% Akzeptanzbereiche zweier eng benachbarter theoretischer Peaks
% ueberlappen (z.B. zwei Linien mit nur 0.55 keV Abstand zueinander).
% Nach unten mit MinThreshold gedeckelt: PeaksTheo enthaelt auch
% theoretische Linien, die nie als echter Peak auftreten (z.B. wegen
% verschwindender Intensitaet, entsprechend nicht "Use"-angehakt in der
% GUI) -- ohne diese Untergrenze wuerde ein solcher, energetisch sehr
% naher aber irrelevanter Nachbar die Schwelle eines echten, relevanten
% Peaks auf einen unbrauchbar kleinen Wert druecken (siehe Ruecksprache:
% "006" bei 13.5010 keV nur 0.02 keV von "102" bei 13.5213 keV entfernt).
MaxThreshold = 0.55;
MinThreshold = 0.15;
NumTheo = numel(PeaksTheo);
[SortedTheo, SortOrder] = sort(PeaksTheo(:));
SortedGapLeft = [inf; diff(SortedTheo)];
SortedGapRight = [diff(SortedTheo); inf];
SortedThresholdPerPeak = min(MaxThreshold, max(MinThreshold, min(SortedGapLeft, SortedGapRight)./2));
ThresholdPerPeak = zeros(NumTheo,1);
ThresholdPerPeak(SortOrder) = SortedThresholdPerPeak;

PeakDiff_tmp = cell2mat(PeakDiff{1});
CostMatrix = PeakDiff_tmp;
CostMatrix(CostMatrix > ThresholdPerPeak') = inf;
MatchedPairs = matchpairs(CostMatrix, MaxThreshold);

NumRows = size(CostMatrix,1);
NumCols = size(CostMatrix,2);
MinValPeakDiff = inf(NumRows,1);
IdxValPeakDiff = zeros(NumRows,1);
PeakDiff_tmp3 = zeros(1,NumCols);
for m = 1:size(MatchedPairs,1)
    RowIdx = MatchedPairs(m,1);
    ColIdx = MatchedPairs(m,2);
    MinValPeakDiff(RowIdx) = PeakDiff_tmp(RowIdx,ColIdx);
    IdxValPeakDiff(RowIdx) = ColIdx;
    PeakDiff_tmp3(ColIdx) = 1;
end

PeakDiff_tmp4 = repmat(PeakDiff_tmp3',1,3);
CompareFitPeaksLogical = logical(PeakDiff_tmp4);

%% Alte Variante
% for k = 1:size(PeakDiff,2)
%     [MinVal_tmp{k}, IndVal{k}] = min(cell2mat(PeakDiff{k}));
% end
% 
% if size(MinVal_tmp,2) ~= 1
%     MinVal = min(cell2mat(MinVal_tmp'));
% else
%     MinVal = cell2mat(MinVal_tmp);
% end
% 
% % Create PeakHit variable that is used to mark the matches in the GUI table
% PeakHit = zeros(size(PeaksTheo));
% % PeakHit(IndVal) = 1;
% % PeakHit = zeros(size(PeaksTheo,1),1);
% 
% for k = 1:length(MinVal)
%     if MinVal(k) <= 0.53
%         PeakHit(k) = 1;
%     else
%         PeakHit(k) = 0;
%     end
% end
% % assignin('base','PeakHit',PeakHit)
% % Create logical
% CompareFitPeaksLogical = repmat(PeakHit,1,3);
% CompareFitPeaksLogical = logical(CompareFitPeaksLogical);
end

