% Enter Filename of measurement file
Path = 'D:\Profile\hrp\Eigene Dateien\MATLAB\Rietveld_ED\data\Measurements\';
Filename = ([Path,'Weninger_Probe_1-2_sin2psi_phi0_90_180_270_03032017']);

DiffractometerFileName = 'EDDI_5axis_tth';
% DiffractometerFileName = 'LEDDI_9axis_tth';
% DiffractometerFileName = 'MetalJet-LIMAX-160';

Diffractometer = Measurement.Diffractometer.LoadFromFile(DiffractometerFileName, Measurement.Diffractometer);

calib = '23.April 2018';
% Call convertion function
Measurement = ConvertSpecFile(Filename,DiffractometerFileName,calib);

% Create Rietveld data container
for i = 1:length(Measurement)
    RvData.DeadTime(:,i) = Measurement(i).DeadTime;
    RvData.RingCurrent(:,i) = Measurement(i).RingCurrent;
    RvData.Psi(:,i) = Measurement(i).SCSAngles.psi;
    RvData.Phi(:,i) = Measurement(i).SCSAngles.phi;
    RvData.Eta(:,i) = Measurement(i).SCSAngles.eta;
    RvData.alpha(:,i) = Measurement(i).SCSAngles.alpha;
    RvData.beta(:,i) = Measurement(i).SCSAngles.beta;
    RvData.EDSpectrum{i} = Measurement(i).EDSpectrum;
    RvData.Temp(:,i) = Measurement(i).Temperatures;
end

% Save data to folder
SavePath = 'D:\Profile\hrp\Eigene Dateien\MATLAB\Rietveld_ED\data\RietveldData\';
save([fullfile(SavePath),'RvData_',strrep(Measurement(1).MeasurementSeries,' ','')],'RvData');

clear ('Path', 'Filename', 'i', 'SavePath')

disp('File conversion finished')