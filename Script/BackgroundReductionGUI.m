function [Measurement,DataTmp,T] = BackgroundReductionGUI(Measurement,DataTmp,PeakRegions,calib)
%% (* Correction of the background *)
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create background from datatips defined in figure (export cursor data to 
% workspace). 
R.PeakRegions = PeakRegions;
% To find the background line, Matlab uses a filter technique. Here you
% can specify the filter width an step size
if strcmp(calib,'Channel_scale')
    P.SmootFilterWidth = 0.5;
else
    P.SmootFilterWidth = 0.1;
end
P.SmootStepSize = 4;
% Choose this option, if you want to see the results
P.PlotBackgroundLine = true;
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Automatic background reduction (not functioning!)   
P.AutoBkgReduction = false;  
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for c = 1:length(Measurement)
    T.X = DataTmp{c}(:, 1);
    T.Y = DataTmp{c}(:, 2);
    
    T.Y_smoothed = T.Y;
    
    % Energiewerte in Indizies umrechnen. Bereiche innerhalb der
    % definierten Untergrundpunkte bekommen Index 1.
    T.PeakRegions = [Tools.Data.DataSetOperations.FindNearestIndex(T.X,R.PeakRegions{c}(1,:)); ...
        Tools.Data.DataSetOperations.FindNearestIndex(T.X,R.PeakRegions{c}(2,:))];
    T.PeakRegions = Tools.LogicalRegions(T.PeakRegions,length(T.X));
    
    % Untergrundlinie berechnen und abziehen
    [~, T.Y_smoothed] = Tools.Data.Filtering.MinMaxLineMean(T.X, T.Y, ...
        P.SmootFilterWidth, P.SmootStepSize);
    [T.X, T.Y, T.Bkg] = Tools.Data.Fitting.BackgroundReduction(T.X, T.Y, ...
        T.PeakRegions, T.Y_smoothed);
    
        
    DataTmp{c} = [T.X, T.Y];

end


if (P.CleanUpTemporaryVariables)
%     clear('P');
%     clear('T');
    clear c;
    clear p;
    clear Background;
end

disp('background reduction performed');