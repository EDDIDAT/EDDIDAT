opts = struct;
opts.profileChiRange = [-180 -80];
opts.smoothPoints = 5;
opts.useLog = false;
opts.baselineMode = "none";
opts.defaultShape = "pvoigt";
opts.defaultBackgroundModel = "linear";

opts.snapToLocalMax = true;
opts.snapSearchRadiusDeg = 0.08;
opts.minPeakDistanceDeg = 0.02;

peakDefs = interactive_define_peak_windows(out, opts);