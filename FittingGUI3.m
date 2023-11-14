function [Measurement,DataTmp,FittedPeaks,CI,SE] = FittingGUI3(Measurement,DataTmp,PeakRegions,Peaks,Peakslb,Peaksub,FitFunc)
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
FittedPeaks = cell(1,length(Measurement));
CI = cell(1,length(Measurement));
SE = cell(1,length(Measurement));
for c = 1:length(Measurement)
    X = DataTmp{c}(:, 1);
    Y = DataTmp{c}(:, 2);

    % Energiewerte in Indizies umrechnen
    PeakRegions = [Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions{c}(1,:)); ...
        Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions{c}(2,:))];
    PeakRegions = Tools.LogicalRegions(PeakRegions,length(X));
    Index_Peaks = Tools.Data.DataSetOperations.FindNearestIndex(X,R.Index_Peaks{c});
    
    % Regionen zusammenfassen
    PeakRegions.Regions = PeakRegions.Regions;
    FittedPeaks{c} = cell(1,size(PeakRegions.Limits,2));
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
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, 0.25);
            elseif FitFunc == 3 %TCH
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_TCH(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, 0.05, 0.05);
            elseif FitFunc == 4 %Gauss
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_Gauss(...
                    X(a:b), Y(a:b), Index_PeaksInRegion);    
            end
            cnt = cnt+1;            
        % If two peaks exist in the current PeakRegion
        elseif length(Index_PeaksInRegion) == 2
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 0.5, 1, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 0.5, 1];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 2, 0.5];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            end
            cnt = cnt+2;
        elseif length(Index_PeaksInRegion) == 3
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 1, 1, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 1, 1, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 1, 1];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 2, 0.5];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            end
            cnt = cnt+3;
        elseif length(Index_PeaksInRegion) == 4
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{c}(cnt+4)-R.lb{c}(cnt+4), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 1, 1, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 1, 1, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 1, 1, Inf, R.Index_Peaks{c}(cnt+4)+R.ub{c}(cnt+4), 1, 1];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{c}(cnt+4)-R.lb{c}(cnt+4), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+4)+R.ub{c}(cnt+4), 2, 0.5];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            end
            cnt = cnt+4;
        elseif length(Index_PeaksInRegion) == 5
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            if FitFunc == 2 %(PV-Func)
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{c}(cnt+4)-R.lb{c}(cnt+4), 0, 0, R.Index_Peaks{c}(cnt+5)-R.lb{c}(cnt+5), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 1, 1, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 1, 1, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 1, 1, Inf, R.Index_Peaks{c}(cnt+4)+R.ub{c}(cnt+4), 1, 1, R.Index_Peaks{c}(cnt+5)+R.ub{c}(cnt+5), 1, 1];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            elseif FitFunc == 3 %TCH
                PeakPosBoundarys = [-Inf, R.Index_Peaks{c}(cnt+1)-R.lb{c}(cnt+1), 0, 0, -Inf, R.Index_Peaks{c}(cnt+2)-R.lb{c}(cnt+2), 0, 0, -Inf, R.Index_Peaks{c}(cnt+3)-R.lb{c}(cnt+3), 0, 0, -Inf, R.Index_Peaks{c}(cnt+4)-R.lb{c}(cnt+4), 0, 0, R.Index_Peaks{c}(cnt+5)-R.lb{c}(cnt+5), 0, 0;...
                                   Inf, R.Index_Peaks{c}(cnt+1)+R.ub{c}(cnt+1), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+2)+R.ub{c}(cnt+2), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+3)+R.ub{c}(cnt+3), 2, 0.5, Inf, R.Index_Peaks{c}(cnt+4)+R.ub{c}(cnt+4), 2, 0.5, R.Index_Peaks{c}(cnt+5)+R.ub{c}(cnt+5), 1, 1];
                [FittedPeaks{c}{i_c}, CI{c}{i_c}, SE{c}{i_c}] = Tools.Data.Fitting.FP_TCH_DoublePeak(...
                    X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.05, 0.05);
            end
            cnt = cnt+5;    
        end
    end
    
    % Form anpassen
    FittedPeaks{c} = reshape(cell2mat(FittedPeaks{c}),4,[])';
    CI{c} = reshape(cell2mat(CI{c}),4,[])';
    SE{c} = reshape(cell2mat(SE{c}),4,[])';
    
    disp([Measurement(c).Name, ' was successfully fitted']);
end

if (P.CleanUpTemporaryVariables)
    clear('P');
end

assignin('base','FittedPeaks',FittedPeaks)

% F.FitFehler = cell2mat(CI);
F.FitFehler = cell2mat(CI');
[F.row, F.col] = find(isnan(F.FitFehler));

    for i = 1:length(Measurement)
        CI{i}(isnan(CI{i}))=1;
    end
clear('F');
% clear Peaks;

disp('fitting performed');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% % "true", if you want to work automatically, "false" for manual reduction.
% P.AutoPeakFinding = false;
%     % To find the peak regions, Matlab uses a filter technique. Here you
%     % can specify the filter width an step size
%     P.PFFilterWidth = 5;
%     P.PFStepSize = 10;
%     % This conf is needed to find peak regions (not the peaks themselves)
%     P.PFDelta_min = 50000;
%     % The minimum difference between a peak an the background in cts 
%     P.PFMinPeakHeight = 50000;
%     % Background height, should be 0
%     P.PFBackgroundHeight = 0;
%     % Artificial enlargement of the found peak regions
%     P.PFEnlargementFactor = 1;
% % If AutoPeakFinding is set to "false", you can type in the peak regions
% % manually. This conf is a 2-lined vector. The upper line specifies the
% % left limit and the lower line the right limits. Example:
% % ... = [10, 15, 20.5; ...
% %        12, 15.8, 24];
% % Another comfortable way ist to set this conf to "Peaks.PeakRegionsFit",
% % in case you want to use "ImportULD".