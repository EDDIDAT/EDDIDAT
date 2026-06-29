opts = struct;
opts.profileChiRange = [-160 0];
opts.trackChiRange   = [-160 -80];
opts.trackChiAvgBins = 4;
opts.trackChiBin     = 2;

B = pyfai_extract_binned_tracking_data(out, opts);