function [CompareFitPeaksLogical,MinVal,IndVal,PeakHit] = ComparePeaks(Peaks,PeaksTheo)
% Function used to compare user defined peak position with theoretical peak
% positions.

% Calculate differences between theoretical and user defined peaks.
for k = 1:size(Peaks{1},2)
    for l = 1:size(PeaksTheo,1)
        PeakDiff{k,l} = abs(Peaks{1}(k)-PeaksTheo(l));
    end
end

% Convert cell to matrix
PeakDifftmp = cell2mat(PeakDiff);
% assignin('base','Peaks',Peaks)
% assignin('base','PeaksTheo',PeaksTheo)
% assignin('base','PeakDifftmp',PeakDifftmp)
% Find index from minimum with condition diff < 2. (Value of "2" is an
% empirical value, might need to be adjusted.)
% for l = 1:size(PeakDifftmp,1)
%     % Find value and index of minimum
%     [M,I] = min(PeakDifftmp(l,:));
%     MinVal(l) = M;tabb
%     IndVal(l) = I; 
% end

[MinVal, IndVal] = min(PeakDifftmp);

% assignin('base','MinVal',MinVal)
% % Find index from minimum with condition diff < 1. (Value of "1" is an
% % empirical value, might need to be adjusted.)
% for l = 1:size(PeakDifftmp,1)
%     % Find value and index of minimum
%     MinVal{l} = find(PeakDifftmp(l,:) < 1);
% end
% % Check if more than one min was found. If, take the first value (in case
% % of, e.g. double peaks)
% for l = 1:size(MinVal,2)
%     % Find value and index of minimum
%     if length(MinVal{l}) == 1
%         IndVal(l) = MinVal{l};
%     elseif length(MinVal{l}) ~= 1
%         IndVal(l) = MinVal{l}(1);
%     end
% end

% Create PeakHit variable that is used to mark the matches in the GUI table
PeakHit = zeros(size(PeaksTheo));
% PeakHit(IndVal) = 1;
% PeakHit = zeros(size(PeaksTheo,1),1);

for k = 1:length(MinVal)
    if MinVal(k) <= 0.5
        PeakHit(k) = 1;
    else
        PeakHit(k) = 0;
    end
end
% assignin('base','PeakHit',PeakHit)
% Create logical
CompareFitPeaksLogical = repmat(PeakHit,1,3);
CompareFitPeaksLogical = logical(CompareFitPeaksLogical);
end

