%% (* general settings and cleaning *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Before starting a new analysis you should clean up all legacy variables
% by setting this conf to "true"
P.CleanUpBeforeStarting = true;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if (P.CleanUpBeforeStarting), clear all; end

% Prealloc der Peakdaten
Peaks.PeakPositions = [];
Peaks.PeakRegionsBkg = [];
Peaks.PeakRegionsFit = [];

clear('P');

disp('cleaned');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++