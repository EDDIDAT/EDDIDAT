Spectra = analysis.computeSpectrum;
Xdata_sim = repmat(dataX,1,32);
SimData_1 = [Xdata_sim; Spectra];
SimData=reshape(SimData_1,6501,[]);
for i = 1:32
data = [Xdata_sim(:,i), Spectra(:,i)];
save(['SimData_triaxial_Phi90_', num2str(i), '.dat'], 'data', '-ascii');
end