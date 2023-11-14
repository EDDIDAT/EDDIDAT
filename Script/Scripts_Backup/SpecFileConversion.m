%% (* Convert the measurement spec-file *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% This script converts and reads the measurement spec file.
% Name of the spec-file stored in "/Data/Measurements" (with extension).
P.SpecFileName = 'Au_tth14_MV1';             % <--
% Name of the Diffractometer-file stored in "/Data/Diffractometers".
% EDDI_5axis_tth --> synchrotron measurements
% LEDDI_9axis_tth --> LEDDI measurements
P.DiffractometerFileName = 'EDDI_5axis_tth';                          % <--
% Which diffractometer has been used for the measurement: 
% 1 = EDDI
% 2 = LEDDI
P.Diffractometer = 1;                                                 % <--
% Type of measurement (standard, ascan/dscan)
% 1 = standard
% 2 = ascan, dscan ...
P.LoadFromSpecFile = 1;                                               % <--
% Choose the appropriate dead time correction for your measurements.
P.Calibration = '08.Januar 2018';                                        % <--
% Available: 'Januar 2015', 'April 2015', 'Januar 2016', 'Februar 2016', 
% 'August 2016', 'Januar 2017', '30.Januar 2017'
% Clean up all temporary variables.
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear Measurement;

% Create diffractometer object.
Diffractometer = Measurement.Diffractometer.LoadFromFile(P.DiffractometerFileName, Measurement.Diffractometer);
% Choose which file conversion has to be used.
if P.LoadFromSpecFile == 1
    Measurement = Measurement.Measurement.LoadFromSpecFile(P.SpecFileName, Diffractometer, P.Diffractometer, P.Calibration);   
else
    Measurement = Measurement.Measurement.LoadFromSpecFile2(P.SpecFileName, Diffractometer, P.Diffractometer);
end
% Assign properties.
set(Measurement, 'Sample', Sample);
MeasurementBackup = Measurement;
Substrate = T.Material.ShowSubstratePeaks;

ResetCurrentMeasData;

% Clean up all temporary variables.
if (P.CleanUpTemporaryVariables)
    clear('P');
end

disp('spec-file converted');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++