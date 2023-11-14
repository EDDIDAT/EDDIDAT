%% (* create a psi-file *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Name of the psi-file
P.PsiFileName = 'Au_tth14_MV1_29012018_new';   %Ti40Al60N_200_singlepeak
% You should activate this conf to check the fit results
P.EvaluateFits = true;                                                % <--
    % All peaks whose energy position confidence values are greater than
    % this one are removed for the following process
    P.MaxDeltaEnergy = 5;
    % All peaks whose max-intensity confidence values are greater than this
    % one are removed for the following process
    P.MaxDeltaIntensity = 10e08;
    % All peaks whose integral intensity values are less than this one are
    % removed for the following process
    P.MinIntegralIntensity = 0;
    % All peaks whose integral width values are less than this one are
    % removed for the following process
    P.MinIntegralWidth = 0.15;
    % All peaks whose integral width values are greater than this one are
    % removed for the following process
    P.MaxIntegralWidth = 4;
% If this conf is set to "true" Matlab will try to find peaks which occure
% in all spectrums. But be careful a missing peak in a certain spectrum
% might cause that the peak is not taken for the psi-file.
P.UseAutoMatching = false;
% Here you can specify the peak positions by hand (as if UseAutoMatching is
% "false"). A one lined vector is required. Example:
% ... = [10, 15, 20.5];

% P.PeakPositions = R.Index_Peaks(2);
P.PeakPositions = R.Index_Peaks;

% To create a rectangle matrix of peaks, Matlab compares the all found
% peak positions in each spectrum. A peak is grouped for a psi-file,
% when this peak exists in all spectrums. Here you can specify the
% tolerance in keV.
P.RangeWidth = 0.4;
% Dead-time-correction
P.CorrectDeadTime = false;
% Specifies, whether the dummy peaks are writen in the psi-file or not
P.WriteDummyPeaks = false;
% Measurement mode
% P.Mode = 3; 
% 1 = EDDI, LEDDI Konf1. DET1, LEDDI Konf2. DET2; 
% 2 = LEDDI Konf.1 DET1 (Theta1 <> Theta2); 
% 3 = LEDDI Konf.2 DET1 (Theta1 == Theta2)
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Linien aus dem Fits erzeugen und bewerten
T.DiffractionLines = cell(length(Measurement),1);
for c = 1:length(Measurement)  
    % Linien erzeugen
    T.DiffractionLines{c} = SpectraAnalysis.DiffractionLine.CreateFromFitParam_PV(FittedPeaks{c}, CI{c}, Measurement(c));
    
    % Linien bewerten
    if (P.EvaluateFits)
        T.DiffractionLines_tmp = [];
        for d = 1:length(T.DiffractionLines{c})
            % Falls die o.g. Kriterien erfuellt sind...
            if ~((T.DiffractionLines{c}(d).Energy_Max_Delta >= P.MaxDeltaEnergy) ...
                    || (T.DiffractionLines{c}(d).Intensity_Max_Delta >= P.MaxDeltaIntensity) ...
                    || (T.DiffractionLines{c}(d).Intensity_Int <= P.MinIntegralIntensity) ...
                    || (T.DiffractionLines{c}(d).IntegralWidth <= P.MinIntegralWidth) ...
                    || (T.DiffractionLines{c}(d).IntegralWidth >= P.MaxIntegralWidth) ...
                    )
                % ...behalte den Peak
                T.DiffractionLines_tmp = [T.DiffractionLines_tmp, T.DiffractionLines{c}(d)];
            end
        end
        if (isempty(T.DiffractionLines_tmp))
            warning(['You should delete the measurement ', Measurement(c).Name, ...
                ' because the fit results are bad.'])
        else
            T.DiffractionLines{c} = T.DiffractionLines_tmp;
        end
    end
end

% Suche nach Peaks fuer den psi-file
if (P.UseAutoMatching)
    % automatisch
    T.SelectedPeaks = SpectraAnalysis.SpectraAnalysis.FindPeakRanges(T.DiffractionLines, P.RangeWidth);
else
    % manuell
    T.SelectedPeaks = [P.PeakPositions - P.RangeWidth; P.PeakPositions + P.RangeWidth];
    T.SelectedPeaks = num2cell(T.SelectedPeaks);
end

% Auswertungs-Objekt erzeugen
T.PsiObject = SpectraAnalysis.SpectraAnalysis.CreateFromDL(T.DiffractionLines, T.SelectedPeaks);
%Totzeitkorrektur
if (P.CorrectDeadTime)
    for c = 1:numel(T.PsiObject.DiffractionLines)
        T.PsiObject.DiffractionLines(c).Energy_Max = T.PsiObject.DiffractionLines(c).Energy_Max - ...
            T.PsiObject.DiffractionLines(c).Measurement.Diffractometer.Detector.DTLineRefraction(...
            T.PsiObject.DiffractionLines(c).DeadTime);
    end
end
% Auswertungs-Objekt speichern
T.PsiObject.SaveToPsiFile(P.PsiFileName, P.WriteDummyPeaks); %, P.Mode);

if (P.CleanUpTemporaryVariables)
%     clear('P');
    clear('T');
    clear c d;
end
disp('psi-file created');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++