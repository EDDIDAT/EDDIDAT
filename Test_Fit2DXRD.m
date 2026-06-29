BinsWithMatch = find(binCounts>=value);
AmpFromMatchedBin = binCounts(BinsWithMatch);
PeakSearchResult = [BinsWithMatch' binEdges(BinsWithMatch)' AmpFromMatchedBin'];
PeaksTheo = h.dekdata.Data(:,4);

for k = 1:length(PeaksTheo)
    idxPeakMatch{k} = ismembertol(PeakSearchResult(:,2),PeaksTheo(k),0.02);
    MeanPixelPeakPos(k) = round(mean(PeakSearchResult(idxPeakMatch{k},1)));
    MeanTwothetaPeakPos(k) = mean(PeakSearchResult(idxPeakMatch{k},2));
end








for k = 1:size(h.idxempty,1)
    PeakPosStarttmp{k} = h.Locations(k,~h.idxempty(k,:));
end