function [DiffractionLines] = FilterDiffLine(Measurement,FittedPeaks,SE,PopupValueFitFunc,FilterOptions)
% Filter applied to the diffraction line data
% Run filter procedure
for c = 1:length(Measurement)  
    % Create diffraction lines
    if PopupValueFitFunc == 2 %PV-Func
        DiffractionLines{c} = SpectraAnalysis.DiffractionLine.CreateFromFitParam_PV(FittedPeaks{c}, SE{c}, Measurement(c));
    elseif PopupValueFitFunc == 3 %TCH-Func
        DiffractionLines{c} = SpectraAnalysis.DiffractionLine.CreateFromFitParam_TCH(FittedPeaks{c}, SE{c}, Measurement(c));
    elseif PopupValueFitFunc == 4 %Gauss-Func
        DiffractionLines{c} = SpectraAnalysis.DiffractionLine.CreateFromFitParam_Gauss(FittedPeaks{c}, SE{c}, Measurement(c));
    elseif PopupValueFitFunc == 5 %Lorentz-Func
        DiffractionLines{c} = SpectraAnalysis.DiffractionLine.CreateFromFitParam_Lorentz(FittedPeaks{c}, SE{c}, Measurement(c));    
    end
    % Apply filter
    if (FilterOptions.EvaluateFits)
        DiffractionLines_tmp = [];
        for d = 1:length(DiffractionLines{c})
            % If filter conditions are satisfied ...
            if ischar(FilterOptions.Phi) && ischar(FilterOptions.Psi)
                if ~((DiffractionLines{c}(d).Energy_Max_Delta >= FilterOptions.MaxDeltaEnergy) ...
                    || (DiffractionLines{c}(d).Intensity_Max_Delta >= FilterOptions.MaxDeltaIntensity) ...
                    || (DiffractionLines{c}(d).Intensity_Int_calc <= FilterOptions.MinIntegralIntensity) ...
                    || (DiffractionLines{c}(d).IntegralWidth <= FilterOptions.MinIntegralWidth) ...
                    || (DiffractionLines{c}(d).IntegralWidth >= FilterOptions.MaxIntegralWidth) ...
                    )
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                else
                    % ... set peak data to zero
                    DiffractionLines{c}(d).Energy_Max = 0;
                    DiffractionLines{c}(d).Energy_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Max = 0;
                    DiffractionLines{c}(d).Intensity_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Int_calc = 0;
                    DiffractionLines{c}(d).IntegralWidth = 0;
                    DiffractionLines{c}(d).FWHM = 0;
                    DiffractionLines{c}(d).FWHM_Gauss = 0;
                    DiffractionLines{c}(d).FWHM_Lorentz = 0;
                    DiffractionLines{c}(d).WeightingFactor = 0;
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                end    
            elseif ~ischar(FilterOptions.Phi) && ischar(FilterOptions.Psi)
                if ~((DiffractionLines{c}(d).Energy_Max_Delta >= FilterOptions.MaxDeltaEnergy) ...
                        || (DiffractionLines{c}(d).Intensity_Max_Delta >= FilterOptions.MaxDeltaIntensity) ...
                        || (DiffractionLines{c}(d).Intensity_Int_calc <= FilterOptions.MinIntegralIntensity) ...
                        || (DiffractionLines{c}(d).IntegralWidth <= FilterOptions.MinIntegralWidth) ...
                        || (DiffractionLines{c}(d).IntegralWidth >= FilterOptions.MaxIntegralWidth) ...
                        || ~ismember(DiffractionLines{c}(d).SCSAngles.phi,FilterOptions.Phi) ...
                        )
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                else
                    % ... set peak data to zero
                    DiffractionLines{c}(d).Energy_Max = 0;
                    DiffractionLines{c}(d).Energy_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Max = 0;
                    DiffractionLines{c}(d).Intensity_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Int_calc = 0;
                    DiffractionLines{c}(d).IntegralWidth = 0;
                    DiffractionLines{c}(d).FWHM = 0;
                    DiffractionLines{c}(d).FWHM_Gauss = 0;
                    DiffractionLines{c}(d).FWHM_Lorentz = 0;
                    DiffractionLines{c}(d).WeightingFactor = 0;
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                end
            elseif ischar(FilterOptions.Phi) && ~ischar(FilterOptions.Psi)
                if ~((DiffractionLines{c}(d).Energy_Max_Delta >= FilterOptions.MaxDeltaEnergy) ...
                        || (DiffractionLines{c}(d).Intensity_Max_Delta >= FilterOptions.MaxDeltaIntensity) ...
                        || (DiffractionLines{c}(d).Intensity_Int_calc <= FilterOptions.MinIntegralIntensity) ...
                        || (DiffractionLines{c}(d).IntegralWidth <= FilterOptions.MinIntegralWidth) ...
                        || (DiffractionLines{c}(d).IntegralWidth >= FilterOptions.MaxIntegralWidth) ...
                        || (DiffractionLines{c}(d).SCSAngles.psi > FilterOptions.Psi) ...
                        )
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                else
                    % ... set peak data to zero
                    DiffractionLines{c}(d).Energy_Max = 0;
                    DiffractionLines{c}(d).Energy_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Max = 0;
                    DiffractionLines{c}(d).Intensity_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Int_calc = 0;
                    DiffractionLines{c}(d).IntegralWidth = 0;
                    DiffractionLines{c}(d).FWHM = 0;
                    DiffractionLines{c}(d).FWHM_Gauss = 0;
                    DiffractionLines{c}(d).FWHM_Lorentz = 0;
                    DiffractionLines{c}(d).WeightingFactor = 0;
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                end   
            elseif ~ischar(FilterOptions.Phi) && ~ischar(FilterOptions.Psi)
                if ~((DiffractionLines{c}(d).Energy_Max_Delta >= FilterOptions.MaxDeltaEnergy) ...
                        || (DiffractionLines{c}(d).Intensity_Max_Delta >= FilterOptions.MaxDeltaIntensity) ...
                        || (DiffractionLines{c}(d).Intensity_Int_calc <= FilterOptions.MinIntegralIntensity) ...
                        || (DiffractionLines{c}(d).IntegralWidth <= FilterOptions.MinIntegralWidth) ...
                        || (DiffractionLines{c}(d).IntegralWidth >= FilterOptions.MaxIntegralWidth) ...
                        || ~ismember(DiffractionLines{c}(d).SCSAngles.phi,FilterOptions.Phi) ...
                        || (DiffractionLines{c}(d).SCSAngles.psi > FilterOptions.Psi) ...
                        )
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                else
                    % ... set peak data to zero
                    DiffractionLines{c}(d).Energy_Max = 0;
                    DiffractionLines{c}(d).Energy_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Max = 0;
                    DiffractionLines{c}(d).Intensity_Max_Delta = 0;
                    DiffractionLines{c}(d).Intensity_Int_calc = 0;
                    DiffractionLines{c}(d).IntegralWidth = 0;
                    DiffractionLines{c}(d).FWHM = 0;
                    DiffractionLines{c}(d).FWHM_Gauss = 0;
                    DiffractionLines{c}(d).FWHM_Lorentz = 0;
                    DiffractionLines{c}(d).WeightingFactor = 0;
                    DiffractionLines_tmp = [DiffractionLines_tmp, DiffractionLines{c}(d)];
                end
            end
        end
        DiffractionLines{c} = DiffractionLines_tmp;
    end
end
% If filter options are not applied
if ~(FilterOptions.EvaluateFits)
    for k = 1:size(DiffractionLines,2)
        DiffractionLines{k} = DiffractionLines{k}';
    end
end
DiffractionLines = DiffractionLines';
assignin('base','DiffractionLinesFilterDiffLine',DiffractionLines)
end

