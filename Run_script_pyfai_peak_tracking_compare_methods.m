opts = struct;
opts.profileChiRange = [-160 0];   % Bereich für 1D-Summenprofil zur Peakdefinition
opts.trackChiRange   = [-160 -80];   % Bereich, in dem getrackt wird
opts.trackChiAvgBins = 8;            % mittelt pro Trackingpunkt über +/-1 chi-bin
opts.trackChiBin = 4;
opts.centerMethodDummy = [];         % ungenutzt, nur Platzhalter falls du opts erweiterst

opts.windowDeg = 0.8;                % Suchfenster um Peakguess
opts.smoothPoints = 5;
opts.useLog = false;

opts.doPlot = true;
opts.plotFits = true;
opts.fitSampleCount = 9;             % wie viele Beispiel-Fits geplottet werden
opts.pvoigtFixedEta = 0.5;           % robuster als freies eta
opts.pvoigtFallbackToCentroid = true;

opts.useGauss = false;

peakGuessDeg = 33;

res1 = pyfai_peak_tracking_compare_methods(out, peakGuessDeg, opts);