function [Measurement,DataTmp,FittedPeaks,CI,SE] = FittingGUIQA(Measurement,DataTmp,PeakRegions,Peaks,Peakslb,Peaksub,FitFunc,valueSlider)
%% (* Fitting the data *)
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% For fitting the data information about background and peak positions is
% needed. If a ULD file exists, the background information and the peak
% positions are imported from the ULD file. If no ULD file exists, the peak
% positions have to be defined in the plot window.

% Use PeakRegions from variable bkg (defined manually or loaded from the 
% ULD file).
R.PeakRegions = PeakRegions;
% Read peak data from 'Peaks' variable in workspace or from ULD file.
R.Index_Peaks = Peaks;
% Options for fitting of multiple peaks. Parameter describe the
% energy range of the peak maximum
% R.lb = [0.3, 0.3, 0.3, 0.3, 0.3];
% R.ub = [0.3, 0.3, 0.3, 0.3, 0.3];
R.lb = Peakslb;
R.ub = Peaksub;
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FittedPeaks = cell(1,1);%length(Measurement));
CI = cell(1,length(Measurement));
SE = cell(1,length(Measurement));
for c = valueSlider
    X = DataTmp{valueSlider}(:, 1);
    Y = DataTmp{valueSlider}(:, 2);

    % Energiewerte in Indizies umrechnen
    PeakRegions = [Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions{1}(1,:)); ...
        Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions{1}(2,:))];
    PeakRegions = Tools.LogicalRegions(PeakRegions,length(X));
    Index_Peaks = Tools.Data.DataSetOperations.FindNearestIndex(X,R.Index_Peaks{1});
    
    % Regionen zusammenfassen
    PeakRegions.Regions = PeakRegions.Regions;
    FittedPeaks{1} = cell(1,size(PeakRegions.Limits,2));
    % Counter for number of peaks, in order to count correctly if double
    % peaks are fitted.
    cnt = 0;
    % Fitting of the chosen PeakRegions.
    for i_c = 1:size(PeakRegions.Limits,2)
        a = PeakRegions.Limits(1,i_c);
        b = PeakRegions.Limits(2,i_c);
        Index_PeaksInRegion = (intersect(a:b, Index_Peaks) - a + 1)';
        % If only one peak exists in the current PeakRegion
        if length(Index_PeaksInRegion) == 1
            if FitFunc == 2 %(PV-Func)
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, 0.25);
            elseif FitFunc == 3 %TCH
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss(...
                    X(a:b), Y(a:b), Index_PeaksInRegion);   
            elseif FitFunc == 5 %Lorentz
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz(...
                    X(a:b), Y(a:b), Index_PeaksInRegion);   
            end
            cnt = cnt+1;
        % If two peaks exist in the current PeakRegion
        elseif length(Index_PeaksInRegion) == 2
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{1}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{1}(cnt+2), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{1}(cnt+1), 100, 1, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{1}(cnt+2), 100, 1];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{1}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{1}(cnt+2), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            elseif FitFunc == 5 %Lorentz
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            end
            cnt = cnt+2;
        elseif length(Index_PeaksInRegion) == 3
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 1, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 1, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 1];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+3), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+3), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            elseif FitFunc == 5 %Lorentz
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            end
            cnt = cnt+3;
        elseif length(Index_PeaksInRegion) == 4
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 1, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 1, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 1, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 1];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            elseif FitFunc == 5 %Lorentz
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            end
            cnt = cnt+4;
        elseif length(Index_PeaksInRegion) == 5
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 1, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 1, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 1, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 1, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, 1];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 100, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            elseif FitFunc == 5 %Lorentz
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            end
            cnt = cnt+5;
        elseif length(Index_PeaksInRegion) == 6
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, 0, -Inf, R.Index_Peaks{1}(cnt+6)-R.lb{c}(cnt+6), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 1, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 1, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 1, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 1, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, 1, Inf, R.Index_Peaks{1}(cnt+6)+R.ub{c}(cnt+6), 100, 1];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, 0, -Inf, R.Index_Peaks{1}(cnt+6)-R.lb{c}(cnt+6), 0, 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, 100, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, 100, Inf, R.Index_Peaks{1}(cnt+6)+R.ub{c}(cnt+6), 100, 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, -Inf, R.Index_Peaks{1}(cnt+6)-R.lb{c}(cnt+6), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, Inf, R.Index_Peaks{1}(cnt+6)+R.ub{c}(cnt+6), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Gauss_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            elseif FitFunc == 5 %Lorentz
                PeakPosBoundarys = [-Inf, R.Index_Peaks{1}(cnt+1)-R.lb{c}(cnt+1), 0, -Inf, R.Index_Peaks{1}(cnt+2)-R.lb{c}(cnt+2), 0, -Inf, R.Index_Peaks{1}(cnt+3)-R.lb{c}(cnt+3), 0, -Inf, R.Index_Peaks{1}(cnt+4)-R.lb{c}(cnt+4), 0, -Inf, R.Index_Peaks{1}(cnt+5)-R.lb{c}(cnt+5), 0, -Inf, R.Index_Peaks{1}(cnt+6)-R.lb{c}(cnt+6), 0;...
                                   Inf, R.Index_Peaks{1}(cnt+1)+R.ub{c}(cnt+1), 100, Inf, R.Index_Peaks{1}(cnt+2)+R.ub{c}(cnt+2), 100, Inf, R.Index_Peaks{1}(cnt+3)+R.ub{c}(cnt+3), 100, Inf, R.Index_Peaks{1}(cnt+4)+R.ub{c}(cnt+4), 100, Inf, R.Index_Peaks{1}(cnt+5)+R.ub{c}(cnt+5), 100, Inf, R.Index_Peaks{1}(cnt+6)+R.ub{c}(cnt+6), 100];
                [FittedPeaks{1}{i_c}, CI{1}{i_c}, SE{1}{i_c}] = Tools.Data.Fitting.FP_Lorentz_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys);
            end
            cnt = cnt+6;    
        end
    end
    
    % Form anpassen
    if FitFunc == 2 || FitFunc == 3
        FittedPeaks{1} = reshape(cell2mat(FittedPeaks{1}),4,[])';
        CI{1} = reshape(cell2mat(CI{1}),4,[])';
        SE{1} = reshape(cell2mat(SE{1}),4,[])';
    elseif FitFunc == 4 || FitFunc == 5
        FittedPeaks{1} = reshape(cell2mat(FittedPeaks{1}),3,[])';
        CI{1} = reshape(cell2mat(CI{1}),3,[])';
        SE{1} = reshape(cell2mat(SE{1}),3,[])';        
    end
    
    disp([Measurement(c).Name, ' was successfully fitted']);
end

if (P.CleanUpTemporaryVariables)
    clear('P');
end

% assignin('base','FittedPeaks',FittedPeaks)

F.FitFehler = cell2mat(CI');
[F.row, F.col] = find(isnan(F.FitFehler));

    for i = 1:length(Measurement)
        CI{i}(isnan(CI{i}))=1;
    end
clear('F');

disp('fitting performed');
