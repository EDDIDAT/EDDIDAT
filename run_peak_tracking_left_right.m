% clear; clc;

% --- Lade die MATs aus dem Binning-Schritt ---
inDir = "raw_gamma_binning_out";
load(fullfile(inDir, "left_raw_gamma_binned.mat"), "out");  outL = out;
load(fullfile(inDir, "right_raw_gamma_binned.mat"), "out"); outR = out;

outDir = "peak_tracking_out";
if ~exist(outDir,"dir"), mkdir(outDir); end

% --- Peak (Startwert) ---
% peakGuessDeg = 38.6;

peakGuessDeg = 26.35;
% --- Welche Intensität verwenden?
% Für Spannungsanalyse meist besser: I_mean (vergleichbar zwischen gamma-Bins)
% Für reine Detektion: I_sum (SNR)
I_L = outL.I_mean;
I_R = outR.I_mean;

% --- Tracker Optionen ---
optsT = struct;
optsT.window_deg = 1.2;        % +/- um Peak
optsT.k_bins = 6;
optsT.smooth_points = 5;
optsT.useLog = false;
optsT.minCountOrSignal = 0;    % ggf. erhöhen wenn Rauschen Probleme macht

trkL = track_peak_from_gamma_binned(outL.tth_centers_deg, I_L, outL.gammaBinsDeg, peakGuessDeg, optsT);
trkR = track_peak_from_gamma_binned(outR.tth_centers_deg, I_R, outR.gammaBinsDeg, peakGuessDeg, optsT);

% --- Export CSV ---
TL = table(trkL.gamma_center_deg, trkL.tth_peak_deg, trkL.peak_rms_deg, trkL.peak_height, trkL.valid, ...
    'VariableNames', {'gamma_center_deg','twoThetaPeak_deg','rms_deg','height','valid'});
TR = table(trkR.gamma_center_deg, trkR.tth_peak_deg, trkR.peak_rms_deg, trkR.peak_height, trkR.valid, ...
    'VariableNames', {'gamma_center_deg','twoThetaPeak_deg','rms_deg','height','valid'});

writetable(TL, fullfile(outDir, "peaktrack_left.csv"));
writetable(TR, fullfile(outDir, "peaktrack_right.csv"));

% --- Plot: 2theta_peak vs gamma ---
figure; hold on; grid on;
plot(trkL.gamma_center_deg(trkL.valid), trkL.tth_peak_deg(trkL.valid), 'ro-');
plot(trkR.gamma_center_deg(trkR.valid), trkR.tth_peak_deg(trkR.valid), 'co-');
xlabel('\gamma (deg)'); ylabel('2\theta_{peak} (deg)');
title(sprintf('Peak tracking: 2\\theta_{peak}(\\gamma), guess %.2f°', peakGuessDeg));
legend('left','right','Location','best');
saveas(gcf, fullfile(outDir, "peaktrack_left_right.png"));

% --- Plot: Peak shift relativ zum Mittelwert (hilft zum Vergleich) ---
mL = mean(trkL.tth_peak_deg(trkL.valid), 'omitnan');
mR = mean(trkR.tth_peak_deg(trkR.valid), 'omitnan');

figure; hold on; grid on;
plot(trkL.gamma_center_deg(trkL.valid), trkL.tth_peak_deg(trkL.valid)-mL, 'r.-');
plot(trkR.gamma_center_deg(trkR.valid), trkR.tth_peak_deg(trkR.valid)-mR, 'c.-');
xlabel('\gamma (deg)'); ylabel('\Delta 2\theta (deg)');
title('Peak shift relative to mean (left/right)');
legend('left','right','Location','best');
saveas(gcf, fullfile(outDir, "peakshift_left_right.png"));

fprintf("Wrote: %s\n", outDir);