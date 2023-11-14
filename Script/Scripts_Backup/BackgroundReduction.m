%% (* Correction of the background *)
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create background from datatips defined in figure (export cursor data to 
% workspace). Filename of exported data needs to be 'Background'.
% If there already exists a background file you can load and use it to
% correct background (use ULD file stored in folder \Data\ULD).
R.LoadULDFile = true;                                                 % <--
% Choose if the background information should be saved as an ULD file.
R.SaveBackgroundToFile = false;                                      %<--

if (R.LoadULDFile)
    % Name of the ULD file to be used to correct background
    R.ULDFilename = 'Au_tth14_MV1_29012018';            % <--
    % Load the corresponding ULD file.
    load(fullfile('Data','ULD', R.ULDFilename));    
else
    % If no ULD file exists/is used create background data from points
    % defined in the plot window (PlotCurrentMeasData). Define two
    % background points per peak (left and right of the peak). Press
    % "alt+left mouse button" to create a new datatip. If all background
    % points are defined, export them to the workspace as the variable    
    % 'Backround'.
    for k = 1:length(Background)
        bkg(:,k) = Background(k).Position(1);
    end
    % Arrange background data
    bkg = flip(bkg);
    bkg = reshape(bkg,2,size(bkg,2)/2);

    % The background information is saved as an ULD file (save as *.mat
    % file). The file is saved in the "Data\ULD\" folder.
    if (R.SaveBackgroundToFile)
        % Name of the ULD file.
        R.ULDFilename = 'Au_tth14_MV1_29012018';        % <--
        % Save the ULD file.
        save(fullfile('Data','ULD', R.ULDFilename), 'bkg');
    end
end
% bkg(1,1) = bkg(1,1)+0.3;
% bkg(1,2) = bkg(1,2)+0.3;
% bkg(2,1) = bkg(2,1)+0.3;
% bkg(2,2) = bkg(2,2)+0.3;
% bkg(1,6) = bkg(1,6)-0.32;
% bkg(2,6) = bkg(2,6)-0.5;
% bkg(2,7) = bkg(2,7)-0.65;

% If the peak regions change from spectrum to spectrum, using this loop 
% different peak regions can be used. 
R.PeakRegions = cell(size(Measurement,2));

for p = 1:size(Measurement,2)
    R.PeakRegions{1,p} = bkg((1:2),:);
end

% To find the background line, Matlab uses a filter technique. Here you
% can specify the filter width an step size
P.SmootFilterWidth = 0.1;
P.SmootStepSize = 4;
% Choose this option, if you want to see the results
P.PlotBackgroundLine = true;
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Choose this option to perform a discrete-cosine-smoothing. This tool
% vastly improves the results of the background reduction because the data
% noise is reduced.
P.DCTSmoothing = false;
    P.DCTSmoothFactor = 100;
% Automatic background reduction (not functioning!)   
P.AutoBkgReduction = false;  
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (P.PlotBackgroundLine)
    T.Figure = figure('Toolbar', 'figure','units','normalized','OuterPosition',[0.125 0.125 0.75 0.75]);
    % Daten fuer das Slider-Callback
    T.Plots = zeros(length(Measurement),2);
    T.Title = cell(length(Measurement),1);
%     T.PlotSubstratePeaks = Measurement(1).Sample.Materials.ShowSubstratePeaks;
    hold on;
end

for c = 1:length(Measurement)
    T.X = DataTmp{c}(:, 1);
    T.Y = DataTmp{c}(:, 2);
    
    % DCT-Glaettung
    if (P.DCTSmoothing)
        [~, T.Y_smoothed] = Tools.Data.Filtering.DCTSmoothing(T.X, T.Y, P.DCTSmoothFactor);
    else
        T.Y_smoothed = T.Y;
    end
    
    % Auto-Peak-Finding
    if (P.AutoBkgReduction)
        [~, ~, P.PeakRegions] = Tools.Data.Fitting.SearchPeakRegions(T.X, T.Y_smoothed, ...
            'FilterWidth', P.SPRFilterWidth, ...
            'StepSize', P.SPRStepSize, ...
            'Delta_min', P.SPRDelta_min, ...
            'EnlargementFactor', P.SPREnlargementFactor);
    else
        % Energiewerte in Indizies umrechnen
        T.PeakRegions = [Tools.Data.DataSetOperations.FindNearestIndex(T.X,R.PeakRegions{1,c}(1,:)); ...
            Tools.Data.DataSetOperations.FindNearestIndex(T.X,R.PeakRegions{1,c}(2,:))];
        T.PeakRegions = Tools.LogicalRegions(T.PeakRegions,length(T.X));
    end
    
    % Untergrundlinie berechnen und abziehen
    [~, T.Y_smoothed] = Tools.Data.Filtering.MinMaxLineMean(T.X, T.Y, ...
        P.SmootFilterWidth, P.SmootStepSize);
    [T.X, T.Y, T.Bkg] = Tools.Data.Fitting.BackgroundReduction(T.X, T.Y, ...
        T.PeakRegions, T.Y_smoothed);
    
    % Plot
    if (P.PlotBackgroundLine)
        T.Plots(c,2) = plot(DataTmp{c}(:, 1), DataTmp{c}(:, 2));
        T.Plots(c,1) = plot(T.X, T.Bkg);
        box on
        set(T.Plots(c,2), 'Color', 'blue');
        set(T.Plots(c,1),'Color','red');
        set(T.Plots(c,1),'LineWidth',3);        
        T.Title{c} = ['Background-line for ', Measurement(c).Name];
        xlabel('Energy [keV]');
        ylabel('Intensity [cts]');
    end
        
    DataTmp{c} = [T.X, T.Y];
    xlim([min(T.X) max(T.X)]);
    
    disp([Measurement(c).Name, ' is now successfully background reduced']);
end

if (P.PlotBackgroundLine)
    % Slider erzeugen
    T.Slider = uicontrol(...
            'Style','slider',...
            'Tag','Slider',...
            'Parent',T.Figure,...
            'Units','normalized',...
            'Position', [0.45 0.00625 0.1 0.03],...
            'Min',1,...
            'Max',length(Measurement),...
            'SliderStep',[1/(length(Measurement)-1) 1/(length(Measurement)-1)],...
            'Value',1,...
            'Callback',{@SliderCallback,T});

    SliderCallback(T.Slider, 0, T);
end

if (P.CleanUpTemporaryVariables)
%     clear('P');
%     clear('T');
    clear c;
    clear p;
    clear Background;
end

disp('background reduction performed');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% % Automatic background reduction
% % "true", if you want to work automatically, "false" for manual reduction.
% P.AutoBkgReduction = false;
%     % To find the peak regions, Matlab uses a filter technique. Here you
%     % can specify the filter width an step size
%     P.SPRFilterWidth = 4.5;
%     P.SPRStepSize = 4;
%     % The minimum difference between a peak an the background in cts 
%     P.SPRDelta_min = 15000;
%     % Artificial enlargement of the found peak regions
%     P.SPREnlargementFactor = 1;
% % If AutoBkgReduction is set to "false", you can type in the peak regions
% % manually. This conf should be 2-lined vector. The upper line specifies the
% % left limit and the lower line the right limits. Example:
% % ... = [10, 15, 20.5; ...
% %        12, 15.8, 24];
% % Another comfortable way is to set this conf to "Peaks.PeakRegionsBkg",
% % in case you want to use "ImportULD".
% % PeakRegions is saved as a cell array in order to be able to correct
% % different backgrounds in the spectra. Each background needs to be
% % assigned to the proper spectra number (for p = 1:spectra_number).
% % P.PeakRegions = [16.25, 23.6, 29.46, 34.2, 38.35, 45.39;...  % RT
% %                  18.39, 25.66, 31.33, 35.79, 39.94, 47.45];