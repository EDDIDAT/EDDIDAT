function [PeakRegionsX,PeakRegionsXdata,PeakRegionsYdata] = SearchBKGPoints(DataTmp,BackgroundPoints,valueSlider)
% Find closest point to user selected point
UserSelectedPoints = ismembertol(DataTmp{valueSlider}(:,1),ceil(BackgroundPoints*1000)/1000,0.008,'DataScale',1);
% assignin('base', 'UserSelectedPoints', UserSelectedPoints);
% Find index of user selected bkg points
indexUSP = find(UserSelectedPoints == 1);
% assignin('base', 'indexUSP', indexUSP);

n = 0.0001;

while length(BackgroundPoints) ~= length(indexUSP)
    UserSelectedPoints = ismembertol(DataTmp{valueSlider}(:,1),ceil(BackgroundPoints*1000)/1000,(0.008-n),'DataScale',1);
%     assignin('base', 'UserSelectedPoints', UserSelectedPoints);
    % Find index of user selected bkg points
    indexUSP = find(UserSelectedPoints == 1);
%     assignin('base', 'indexUSP', indexUSP);
    n = n + 0.0001;
%     assignin('base', 'n', n);
end

% Get x and y data in the range of +/- 5 channels of user selected bkg point
indexUSP = find(UserSelectedPoints == 1);
for l = 1:size(DataTmp,2)
    for k = 1:length(indexUSP)
        indexBKG(:,k) = (indexUSP(k)-5):(indexUSP(k)+5);
        xBKG{l,k} = DataTmp{l}((indexUSP(k)-5):(indexUSP(k)+5),1);
        yBKG{l,k} = DataTmp{l}((indexUSP(k)-5):(indexUSP(k)+5),2);
    end
end
% Find min of yBKG
for l = 1:size(DataTmp,2)
    for k = 1:length(indexUSP)
        if all(yBKG{l,k} == 0)
            indexYmin{l,k} = 4;
        else
            indexYmin{l,k} = find(min(yBKG{l,k}(yBKG{l,k}>0)) == yBKG{l,k});
        end
    end
end
% Find and delete duplicate entries
for l = 1:size(DataTmp,2)
    for k = 1:length(indexUSP)
        if length(indexYmin{l,k}) ~= 1
            indexYmin{l,k} = indexYmin{l,k}(1);
        end
    end
end

% Get index of Ymin
for l = 1:size(DataTmp,2)
    for k = 1:length(indexUSP)
        indexYminDataTmp{l,k} = indexBKG(indexYmin{l,k},k); 
    end
end
% Get x and y data for Ymin and create PeakRegions data X and Y
for l = 1:size(DataTmp,2)
    for k = 1:length(indexUSP)
        PeakRegionsXdata{l,k} = DataTmp{l}(indexYminDataTmp{l,k},1);
        PeakRegionsYdata{l,k} = DataTmp{l}(indexYminDataTmp{l,k},2);
    end
end

% Create PeakregionsX data
for l = 1:size(DataTmp,2)
    PeakRegionsX{l} = reshape([PeakRegionsXdata{l,:}],2,size([PeakRegionsXdata{l,:}],2)/2);
end
end

