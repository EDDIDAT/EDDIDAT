tic
peakList = [29.5 30.9 32.98 35.7];

opts = struct;
opts.profileChiRange = [-150 -80];
opts.trackChiRange = [-160 -80];
opts.trackChiBin = 4;
opts.trackChiAvgBins = 4;

% opts.windowDeg = 0.5;
opts.smoothPoints = 5;
opts.baselineMode = "movmin";
opts.useLog = false;

opts.useGauss = false;
opts.gaussMinR2 = 0.98;
opts.gaussSigmaRangeDeg = [0.1 0.80];

opts.pvoigtFixedEta = 0.5;   % oder 0.5 , []
opts.pvoigtFallbackToCentroid = true;
opts.pvoigtMinR2 = 0.9;
opts.pvoigtFwhmRangeDeg = [0.01 0.6];
opts.pvoigtMuBoundDeg = 0.1;

opts.pvoigtAdaptiveWindow = false;
opts.pvoigtAdaptiveWindowFactor = 2.5;
opts.pvoigtAdaptiveWindowMinDeg = 0.30;
opts.pvoigtAdaptiveWindowMaxDeg = 0.60;

opts.pvoigtAutoWindow = true;
opts.pvoigtWindowCandidates = [0.30 0.35 0.40 0.50 0.55 0.6];
opts.pvoigtAutoWindowUseBestR2 = true;

opts.doPlot = true;
opts.plotFits = true;
opts.fitSampleCount = 6;

opts.multiDoSummaryPlots = false;
opts.multiPlotRelative = false;
opts.multiPlotErrorbars = true;
opts.multiPlotSNR = false;
opts.multiPlotWindowUsage = false;
opts.multiSaveDir = fullfile(pwd, "SiSiC_vor_WB_alpha6_pyfai_peak_compare_multigeom");
opts.multiMakeSubfolders = false;
opts.multiCloseSinglePlots = false;
opts.multiExportCSV = false;

allRes = pyfai_peak_tracking_compare_methods_multi(out, peakList, opts);



% opts.windowDeg = 0.30;
% 
% opts.pvoigtAutoWindow = true;
% opts.pvoigtWindowCandidates = [0.20 0.25 0.30 0.35 0.40 0.50];
% opts.pvoigtAutoWindowUseBestR2 = true;
% 
% opts.pvoigtFixedEta = 0.5;
% opts.pvoigtMinR2 = 0.90;
% opts.pvoigtMuBoundDeg = 0.20;
% opts.pvoigtFwhmRangeDeg = [0.01 0.60];
% 
% opts.doPlot = true;
% opts.plotFits = true;
% opts.fitSampleCount = 6;
% 
% opts.multiDoSummaryPlots = false;
% opts.multiPlotRelative = false;
% opts.multiPlotErrorbars = false;
% opts.multiPlotSNR = false;
% opts.multiPlotWindowUsage = false;
% opts.multiSaveDir = fullfile(pwd, "SiSIC_vor_WB_alpha6_pyfai_peak_compare_multigeom");
% opts.multiMakeSubfolders = false;
% opts.multiCloseSinglePlots = false;
% opts.multiExportCSV = false;
% 
% allRes = pyfai_peak_tracking_compare_methods_multi(out, peakList, opts);
toc