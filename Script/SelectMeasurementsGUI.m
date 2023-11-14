function [meas,Sample,EnergyRange,SpectrumBackup] = SelectMeasurementsGUI(Measurement,Substrate,Sample,P,SpectrumBackup)
%% (* Select measurements to be analysed *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Vector of the measurement numbers which you want to select.
WhichMeasurementsDetector = (P.WhichMeasurementsDetector(1):P.WhichMeasurementsDetector(2));
% If EDDI has been used, enter the same values as before.
% WhichMeasurements = [1:length(P.WhichMeasurementsDetector(1):P.WhichMeasurementsDetector(2))];
% Specify the energy range (keV) which will be considered during the
% analysis ("[LowLimit, HighLimit]"). If you don't want to make any
% restrictions type "[]"
if strcmp(P.Diffsel,'LEDDI')
    if strcmp(P.Detsel,'Detector 1')
        ShrinkEnergyRange = [P.EnergyRangeDet1];
    elseif strcmp(P.Detsel,'Detector 2')
        ShrinkEnergyRange = [P.EnergyRangeDet2];
    end
else
    ShrinkEnergyRange = [P.EnergyRange];  % TiCN [24 73], Al2O4 [14 66], WC [];
end

% assignin('base','measGUIbefore',Measurement)
% assignin('base','SpectrumBackupGUIbefore',SpectrumBackup)
% ShrinkEnergyRange
% assignin('base','SpectrumBackup',SpectrumBackup)
% assignin('base','MeasurementBackupGUI',MeasurementBackup)
% Clean up all temporary variables.
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% MeasurementDetector = MeasurementBackup(WhichMeasurementsDetector)
% meas1 = MeasurementDetector(WhichMeasurements)
MeasurementDetector = Measurement(WhichMeasurementsDetector);
% meas1 = MeasurementDetector; %(P.WhichMeasurementsDetector(1):P.WhichMeasurementsDetector(2));
% assignin('base','MeasurementDetector',MeasurementDetector)
% Substrate = T.Material.ShowSubstratePeaks;
% Assign energy HighLimit to the material and substrate properties.
Sample.Materials.EnergyMax = ShrinkEnergyRange(2);
if (Substrate)
    Sample.Substrate.EnergyMax = ShrinkEnergyRange(2);
end
% assignin('base','ShrinkEnergyRange',ShrinkEnergyRange)
% assignin('base','SpectrumBackup',SpectrumBackup)
% assignin('base','MeasurementDetector',MeasurementDetector)
% Reduction of the energy range.
if (~isempty(ShrinkEnergyRange))
    for c = 1:length(MeasurementDetector)
        % Reduce energy range
        if isempty(SpectrumBackup{c})
            T.EnergyRange = Tools.Data.DataSetOperations.FindNearestIndex(MeasurementDetector(c).EDSpectrum(:,1), ShrinkEnergyRange);
            T.EDSpectrum{c} = MeasurementDetector(c).EDSpectrum;
            MeasurementDetector(c).EDSpectrum = MeasurementDetector(c).EDSpectrum(T.EnergyRange(1):T.EnergyRange(2), :);
        else
            T.EnergyRange = Tools.Data.DataSetOperations.FindNearestIndex(SpectrumBackup{c}(:,1), ShrinkEnergyRange);
            MeasurementDetector(c).EDSpectrum = SpectrumBackup{c}(T.EnergyRange(1):T.EnergyRange(2), :);
        end
    end
end

meas = MeasurementDetector;
EnergyRange = T.EnergyRange;
if isempty(SpectrumBackup{1})
    SpectrumBackup = T.EDSpectrum;
end
% assignin('base','SpectrumBackupGUIafter',SpectrumBackup)
% assignin('base','measGUIafter',meas)
ResetCurrentMeasData;

if (P.CleanUpTemporaryVariables)
    clear('P');
%     clear('T');
    clear c;
    clear MeasurementDetector;
end

disp('measurement selected');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++