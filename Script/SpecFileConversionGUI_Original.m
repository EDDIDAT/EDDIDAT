function [meas,MeasurementBackup,DataTmp,Substrate,Diffractometer,P,T] = SpecFileConversionGUI(P,SampleInput,T)
%% (* Convert the measurement spec-file *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% This script converts and reads the measurement spec file.
% Name of the spec-file stored in "/Data/Measurements" (with extension).
SpecFileName = P.SpecFileName;            % <--
% Name of the Diffractometer-file stored in "/Data/Diffractometers".
% EDDI_5axis_tth --> synchrotron measurements
% LEDDI_9axis_tth --> LEDDI measurements
DiffractometerType = P.DiffractometerType;
if DiffractometerType == 1
    DiffractometerFileName = 'EDDI_5axis_tth';                          % <--
elseif DiffractometerType == 2
	DiffractometerFileName = 'LEDDI_9axis_tth';
elseif DiffractometerType == 3
	DiffractometerFileName = 'MetalJet-LIMAX-160';
elseif DiffractometerType == 4
	DiffractometerFileName = 'MetalJet-LIMAX-70';
end
% Which diffractometer has been used for the measurement:
% 1 = EDDI
% 2 = LEDDI
% DiffractometerType = P.Diffractometer;                                                 % <--
% Type of measurement (standard, ascan/dscan)
% 1 = standard
% 2 = ascan, dscan ...
% LoadFromSpecFileScript = P.LoadFromSpecFile;
% Choose the appropriate dead time correction for your measurements.
Calibration = P.Calibration;
% Available: 'Januar 2015', 'April 2015', 'Januar 2016', 'Februar 2016', 
% 'August 2016', 'Januar 2017', '30.Januar 2017'
% Clean up all temporary variables.
CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear Measurement;

% Create diffractometer object.
Diffractometer = Measurement.Diffractometer.LoadFromFile(DiffractometerFileName, Measurement.Diffractometer);
% Choose which file conversion has to be used.
% if LoadFromSpecFileScript == 1
    meas = Measurement.Measurement.LoadFromSpecFile(SpecFileName, Diffractometer, DiffractometerType, Calibration);  
% else
%     meas = Measurement.Measurement.LoadFromSpecFile(SpecFileName, Diffractometer, DiffractometerType, Calibration);
% end
% Assign properties.
Sample = SampleInput;
set(meas, 'Sample', Sample);
MeasurementBackup = meas;
Substrate = T.Material.ShowSubstratePeaks;

DataTmp = cell(1, length(meas));
for c = 1:length(meas)
    DataTmp{c} = meas(c).EDSpectrum;
end

% Clean up all temporary variables.
if (CleanUpTemporaryVariables)
    clear('P');
end

disp('spec-file converted');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++