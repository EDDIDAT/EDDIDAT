TwoThetaReal = unique(TwoTheta);
indTwoThetaRealStart = find(TwoTheta==TwoThetaReal(1));
indTwoThetaRealEnd = find(TwoTheta==TwoThetaReal(end));
IndTwoThetaReal = [indTwoThetaRealStart; indTwoThetaRealEnd]';
Counts = sum(Intensity,2);

for k = 1:size(IndTwoThetaReal,1)
    ScanCounts{k} = Counts((IndTwoThetaReal(k,1):IndTwoThetaReal(k,2)));
end

MeasScanCounts = Measurement.Measurement();
for k = 1:size(IndTwoThetaReal,1)
    MeasScanCounts(k) = measLoad(IndTwoThetaReal(k,1));
end

for k = 1:size(IndTwoThetaReal,1)
    MeasScanCounts(k).EDSpectrum = [TwoThetaReal' ScanCounts{k}];
    MeasScanCounts(k).twotheta = TwoThetaReal;
    MeasScanCounts(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCounts(k).SCSAngles.psi), '°'];
end
for k = 1:size(IndTwoThetaReal,1)
    DataTmp{k} = MeasScanCounts(k).EDSpectrum;
end