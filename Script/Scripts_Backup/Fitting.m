%% (* Fitting the data *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Choose this option to perform a discrete-cosine-smoothing. This tool
% vastly improves the results of auto-peak-finding because the data
% noise is reduced
P.DCTSmoothing = false;
    P.DCTSmoothFactor = 100;
% "true", if you want to work automatically, "false" for manual reduction.
P.AutoPeakFinding = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% For fitting the data information about background and peak positions is
% needed. If a ULD file exists, the background information and the peak
% positions are imported from the ULD file. If no ULD file exists, the peak
% positions have to be defined in the plot window.

% Use PeakRegions from variable bkg (defined manually or loaded from the 
% ULD file).
R.PeakRegions = bkg((1:2),:);

% If a ULD file is used to correct the background, the peak information
% stored in the ULD file is used. 
% If no ULD file is available, the peak positions can be obtained from 
% 'PlotCurrentMeasData' via the export of the Datatips. Click on the 
% peak(s) you want to fit and export the Datatips to the file 'Peaks'. 
R.LoadBackgroundAndPeakFile = R.LoadULDFile;                          % <--

% Read peak data from 'Peaks' variable in workspace or from ULD file.
if (R.LoadBackgroundAndPeakFile)
    R.Index_Peaks = peaks;
else
        % Load peak positions from "Peaks" file.
        for k = 1:length(Peaks)
            R.Index_Peaks(:,k) = Peaks(k).Position(1);
        end
end

% Arrange peak data in descending order.
if (R.LoadBackgroundAndPeakFile)
    R.Index_Peaks;
else
    R.Index_Peaks = flip(R.Index_Peaks);
end

% Options for fitting of double or triple peaks.
R.lb = [0.25, 0.25, 0.25];
R.ub = [0.25, 0.25, 0.25];

% R.Index_Peaks(1) = R.Index_Peaks(1)-0.6;
% R.Index_Peaks(2) = R.Index_Peaks(2)-0.55;
% R.Index_Peaks = R.Index_Peaks(1:2);

% Save peak data to ULD file (only if no ULD file is used). The file name
% from the background file is used.
if ~(R.LoadBackgroundAndPeakFile) && (R.SaveBackgroundToFile)
    % Save the ULD file;
    peaks = R.Index_Peaks;
    save(fullfile('Data','ULD', R.ULDFilename), 'bkg', 'peaks');
end
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
FittedPeaks = cell(1,length(Measurement));
CI = cell(1,length(Measurement));
for c = 1:length(Measurement)
    X = DataTmp{c}(:, 1);
    Y = DataTmp{c}(:, 2);
    
    % DCT-Glaettung
    if (P.DCTSmoothing)
        [~, Y_smoothed] = Tools.Data.Filtering.DCTSmoothing(X, Y, P.DCTSmoothFactor);
    else
        Y_smoothed = Y;
    end
    
    % Auto-Peak-Finding
    if (P.AutoPeakFinding)
        [~, ~, PeakRegions, Index_Peaks] = ...
            Tools.Data.Fitting.SearchPeakRegions_BR(X, Y, Y_smoothed, ...
            'FilterWidth', P.PFFilterWidth, ...
            'StepSize', P.PFStepSize, ...
            'Delta_min', P.PFDelta_min, ...
            'MinPeakHeight', P.PFMinPeakHeight, ...
            'BackgroundHeight', P.PFBackgroundHeight, ...
            'EnlargementFactor', P.PFEnlargementFactor);
    else
        % Energiewerte in Indizies umrechnen
        PeakRegions = [Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions(1,:)); ...
            Tools.Data.DataSetOperations.FindNearestIndex(X,R.PeakRegions(2,:))];
        PeakRegions = Tools.LogicalRegions(PeakRegions,length(X));
        Index_Peaks = Tools.Data.DataSetOperations.FindNearestIndex(X,R.Index_Peaks);
    end
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
        if length(Index_PeaksInRegion) == 1;
            [FittedPeaks{c}{i_c}, CI{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt(...
                X(a:b), Y(a:b), Index_PeaksInRegion, 0.25);
            cnt = cnt+1;
        % If two peaks exist in the current PeakRegion
        elseif length(Index_PeaksInRegion) == 2;
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            PeakPosBoundarys = [-Inf, R.Index_Peaks(cnt+1)-R.lb(1), 0, 0, -Inf, R.Index_Peaks(cnt+2)-R.lb(2), 0, 0;...
                               Inf, R.Index_Peaks(cnt+1)+R.ub(1), Inf, 1, Inf, R.Index_Peaks(cnt+2)+R.ub(2), Inf, 1];
            [FittedPeaks{c}{i_c}, CI{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            cnt = cnt+2;
        elseif length(Index_PeaksInRegion) == 3;
        % For fitting with fixed peak position boundarys. lb and ub can be
        % changed according to the needs of the user.
            PeakPosBoundarys = [-Inf, R.Index_Peaks(cnt+1)-R.lb(1), 0, 0, -Inf, R.Index_Peaks(cnt+2)-R.lb(2), 0, 0, -Inf, R.Index_Peaks(cnt+3)-R.lb(3), 0, 0;...
                               Inf, R.Index_Peaks(cnt+1)+R.ub(1), Inf, 1, Inf, R.Index_Peaks(cnt+2)+R.ub(2), Inf, 1, Inf, R.Index_Peaks(cnt+3)+R.ub(3), Inf, 1];
            [FittedPeaks{c}{i_c}, CI{c}{i_c}] = Tools.Data.Fitting.FP_PseudoVoigt_DoublePeak(...
                X(a:b), Y(a:b), Index_PeaksInRegion, PeakPosBoundarys, 0.25);
            cnt = cnt+3;
        end
    end
    
    % Form anpassen
    FittedPeaks{c} = reshape(cell2mat(FittedPeaks{c}),4,[])';
    CI{c} = reshape(cell2mat(CI{c}),4,[])';
    
    disp([Measurement(c).Name, ' was successfully fitted']);
end

if (P.CleanUpTemporaryVariables)
    clear('P');
end

F.FitFehler = cell2mat(CI);
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