%% (* Select measurements to be analysed *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Vector of the measurement numbers which you want to select.
% For LEDDI: (1:2:end) = Det2(Primaerstrahl), (2:2:end) = Det1(rausgefahren))
P.WhichMeasurementsDetector = (1:1);                                 % <--
% If EDDI has been used, enter the same values before.
P.WhichMeasurements = (1:1);                                         % <--
% Specify the energy range (keV) which will be considered during the
% analysis ("[LowLimit, HighLimit]"). If you don't want to make any
% restrictions type "[]"
P.ShrinkEnergyRange = [17 90];  % TiCN [24 73], Al2O4 [14 66], WC [];                                      % <--
% Clean up all temporary variables.
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
MeasurementDetector = MeasurementBackup(P.WhichMeasurementsDetector);
Measurement = MeasurementDetector(P.WhichMeasurements);
% Substrate = T.Material.ShowSubstratePeaks;
% Assign energy HighLimit to the material and substrate properties.
Sample.Materials.EnergyMax = P.ShrinkEnergyRange(2);
if (Substrate)
    Sample.Substrate.EnergyMax = P.ShrinkEnergyRange(2);
end

% Reduction of the energy range.
if (~isempty(P.ShrinkEnergyRange))
    for c = 1:length(Measurement)
        % Reduce energy range
        T.EnergyRange = Tools.Data.DataSetOperations.FindNearestIndex(Measurement(c).EDSpectrum(:,1), P.ShrinkEnergyRange);
        Measurement(c).EDSpectrum = Measurement(c).EDSpectrum(T.EnergyRange(1):T.EnergyRange(2), :);
    end
end

ResetCurrentMeasData;

if (P.CleanUpTemporaryVariables)
    clear('P');
%     clear('T');
    clear c;
    clear MeasurementDetector;
end

disp('measurement selected');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++