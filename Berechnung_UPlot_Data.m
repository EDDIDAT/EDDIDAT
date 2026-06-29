% Berechnung UPlot-data
psi = hfit.psi
epsdata = hfit.epsfitdataexport
tau = hfit.tau
DEKdata = hfit.DEKdataMatchedPeaks
for k = 1:size(epsdata,2)
sigmaUPlot{k} = epsdata{k}(:,2)./(DEKdata(k,6).*sind(psi{k}).^2 + 2*DEKdata(k,5));
end