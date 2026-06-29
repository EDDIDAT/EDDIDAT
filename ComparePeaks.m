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

%% Neue Variante vom 13.05.2025
% Compare peaks verbesserung code
PeakDiff_tmp = cell2mat(PeakDiff{1});
% Finde alle Werte kleiner 0.55
idx = PeakDiff_tmp <= 0.55;
% Behalte nur Werte kleiner 0.55
PeakDiff_tmp1 = PeakDiff_tmp.*idx;
% Setze alle 0 auf inf
PeakDiff_tmp1(PeakDiff_tmp1==0) = inf;
% Finde das Minimum jeder Reihe
[MinValPeakDiff IdxValPeakDiff] = min(PeakDiff_tmp1,[],2);
% Erstelle Matrix der gleichen Groesse wie PeakDiff_tmp1 aus Nullen
PeakDiff_tmp2 = zeros(size(PeakDiff_tmp1));
% Setze Minima an entsprechende Stellen in der Matrix
for k = 1:length(IdxValPeakDiff)
    PeakDiff_tmp2(k,IdxValPeakDiff(k)) = MinValPeakDiff(k);
end
% Summiere über jeder Spalte
PeakDiff_tmp3 = sum(PeakDiff_tmp2,1);
% Setzte alle Werte ungleich Null auf 1
PeakDiff_tmp3(PeakDiff_tmp3~=0) = 1;
%
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

