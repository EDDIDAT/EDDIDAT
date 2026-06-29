function allRes = pyfai_peak_tracking_compare_methods_multi(out, peakListDeg, opts)
%PYFAI_PEAK_TRACKING_COMPARE_METHODS_MULTI
% Führt pyfai_peak_tracking_compare_methods für mehrere Peaks aus.
%
% INPUT
%   out         : pyFAI-Output mit Feldern out.I, out.radial, out.azimuthal
%   peakListDeg : Vektor mit Peak-Guess-Positionen, z.B. [26.34 31.72 44.18]
%   opts        : Optionen für pyfai_peak_tracking_compare_methods
%
% Zusätzliche Multi-Optionen:
%   opts.multiDoSummaryPlots    = true/false
%   opts.multiPlotRelative      = true/false
%   opts.multiPlotErrorbars     = true/false
%   opts.multiPlotSNR           = true/false
%   opts.multiPlotWindowUsage   = true/false
%   opts.multiSaveDir           = "" oder Zielordner
%   opts.multiMakeSubfolders    = true/false
%   opts.multiCloseSinglePlots  = false/true
%   opts.multiExportCSV         = true/false

if nargin < 3 || isempty(opts)
    opts = struct();
end

opts = setd(opts, "multiDoSummaryPlots", falsefalse);
opts = setd(opts, "multiPlotRelative", true);
opts = setd(opts, "multiPlotErrorbars", false);
opts = setd(opts, "multiPlotSNR", false);
opts = setd(opts, "multiPlotWindowUsage", false);
opts = setd(opts, "multiSaveDir", "");
opts = setd(opts, "multiMakeSubfolders", false);
opts = setd(opts, "multiCloseSinglePlots", false);
opts = setd(opts, "multiExportCSV", false);

peakListDeg = peakListDeg(:).';
nPeaks = numel(peakListDeg);

if nPeaks == 0
    error("peakListDeg ist leer.");
end

doSave = strlength(string(opts.multiSaveDir)) > 0;
if doSave
    rootDir = string(opts.multiSaveDir);
    if ~exist(rootDir, "dir")
        mkdir(rootDir);
    end
else
    rootDir = "";
end

allRes = struct();
allRes.peaksDeg = peakListDeg;
allRes.results = cell(nPeaks,1);
allRes.byPeak = struct();
allRes.opts = opts;

for k = 1:nPeaks
    pk = peakListDeg(k);
    localOpts = opts;

    if doSave && opts.multiMakeSubfolders
        subDir = fullfile(rootDir, sprintf("peak_%03d_%.4fdeg", k, pk));
        if ~exist(subDir, "dir")
            mkdir(subDir);
        end
    else
        subDir = rootDir;
    end

    beforeFigs = findall(groot, 'Type', 'figure');

    res = pyfai_peak_tracking_compare_methods(out, pk, localOpts);

    afterFigs = findall(groot, 'Type', 'figure');
    newFigs = setdiff(afterFigs, beforeFigs);

    if doSave
        save(fullfile(subDir, sprintf("peak_compare_%.4fdeg.mat", pk)), "res", "pk", "localOpts");

        for iFig = 1:numel(newFigs)
            fig = newFigs(iFig);
            fname = fullfile(subDir, sprintf("fig_%02d_peak_%.4fdeg.png", iFig, pk));
            save_fig(fig, fname);
        end
    end

    if opts.multiCloseSinglePlots && ~isempty(newFigs)
        close(newFigs);
    end

    allRes.results{k} = res;
    fld = sprintf("peak_%03d", k);
    allRes.byPeak.(fld) = res;
    allRes.byPeak.(fld).peakGuessDeg = pk;
end

if opts.multiDoSummaryPlots
    make_summary_plots(allRes, opts, rootDir);
end

if opts.multiExportCSV
    export_csv_tables(allRes, opts, rootDir);
end

if doSave
    save(fullfile(rootDir, "all_peak_compare_results.mat"), "allRes", "peakListDeg", "opts");
end

end

% =====================================================================
% summary plots
% =====================================================================

function make_summary_plots(allRes, opts, rootDir)
nPeaks = numel(allRes.peaksDeg);

useGauss = true;
if isfield(opts, "useGauss")
    useGauss = opts.useGauss;
end

% -------- absolute: one figure per method --------
fig1 = figure;
hold on; grid on;
for k = 1:nPeaks
    res = allRes.results{k};
    pk = allRes.peaksDeg(k);
    g = res.gamma_deg;

    plot(g(res.centroid.valid), ...
         res.centroid.tth_peak_deg(res.centroid.valid), ...
         '.-', 'DisplayName', sprintf('%.4f°', pk));
end
xlabel('\gamma / \chi (deg)');
ylabel('2\theta_{peak} (deg)');
title('Alle Peaks: centroid');
legend('Location','bestoutside');

fig2 = [];
if useGauss
    fig2 = figure;
    hold on; grid on;
    for k = 1:nPeaks
        res = allRes.results{k};
        pk = allRes.peaksDeg(k);
        g = res.gamma_deg;

        plot(g(res.gauss.valid), ...
             res.gauss.tth_peak_deg(res.gauss.valid), ...
             '.-', 'DisplayName', sprintf('%.4f°', pk));
    end
    xlabel('\gamma / \chi (deg)');
    ylabel('2\theta_{peak} (deg)');
    title('Alle Peaks: gauss');
    legend('Location','bestoutside');
end

fig3 = figure;
hold on; grid on;
for k = 1:nPeaks
    res = allRes.results{k};
    pk = allRes.peaksDeg(k);
    g = res.gamma_deg;

    plot(g(res.pvoigt.valid), ...
         res.pvoigt.tth_peak_deg(res.pvoigt.valid), ...
         '.-', 'DisplayName', sprintf('%.4f°', pk));
end
xlabel('\gamma / \chi (deg)');
ylabel('2\theta_{peak} (deg)');
title('Alle Peaks: pseudo-Voigt');
legend('Location','bestoutside');

% -------- method comparison per peak --------
fig4 = figure;
tiledlayout('flow');
for k = 1:nPeaks
    res = allRes.results{k};
    pk = allRes.peaksDeg(k);
    g = res.gamma_deg;

    nexttile; hold on; grid on;
    plot(g(res.centroid.valid), res.centroid.tth_peak_deg(res.centroid.valid), 'k.-', 'DisplayName', 'centroid');
    if useGauss
        plot(g(res.gauss.valid), res.gauss.tth_peak_deg(res.gauss.valid), 'r.-', 'DisplayName', 'gauss');
    end
    plot(g(res.pvoigt.valid), res.pvoigt.tth_peak_deg(res.pvoigt.valid), 'b.-', 'DisplayName', 'pVoigt');
    title(sprintf('Peak %.4f°', pk));
    xlabel('\gamma / \chi (deg)');
    ylabel('2\theta_{peak}');
    legend('Location','best');
end

% -------- relative comparison --------
fig5 = [];
if opts.multiPlotRelative
    fig5 = figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        res = allRes.results{k};
        pk = allRes.peaksDeg(k);
        g = res.gamma_deg;

        nexttile; hold on; grid on;
        plot_relative(g, res.centroid.tth_peak_deg, res.centroid.valid, 'k.-', 'centroid');
        if useGauss
            plot_relative(g, res.gauss.tth_peak_deg, res.gauss.valid, 'r.-', 'gauss');
        end
        plot_relative(g, res.pvoigt.tth_peak_deg, res.pvoigt.valid, 'b.-', 'pVoigt');
        title(sprintf('Peak %.4f° (rel.)', pk));
        xlabel('\gamma / \chi (deg)');
        ylabel('\Delta 2\theta');
        legend('Location','best');
    end
end

% -------- errorbars --------
fig6 = [];
if opts.multiPlotErrorbars
    fig6 = figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        res = allRes.results{k};
        pk = allRes.peaksDeg(k);
        g = res.gamma_deg;

        nexttile; hold on; grid on;

        errC = get_err_field(res.centroid);
        errorbar(g(res.centroid.valid), ...
                 res.centroid.tth_peak_deg(res.centroid.valid), ...
                 errC(res.centroid.valid), ...
                 'k.-', 'DisplayName', 'centroid');

        if useGauss
            errG = get_err_field(res.gauss);
            errorbar(g(res.gauss.valid), ...
                     res.gauss.tth_peak_deg(res.gauss.valid), ...
                     errG(res.gauss.valid), ...
                     'r.-', 'DisplayName', 'gauss');
        end

        errP = get_err_field(res.pvoigt);
        errorbar(g(res.pvoigt.valid), ...
                 res.pvoigt.tth_peak_deg(res.pvoigt.valid), ...
                 errP(res.pvoigt.valid), ...
                 'b.-', 'DisplayName', 'pVoigt');

        title(sprintf('Peak %.4f° Fehlerbalken', pk));
        xlabel('\gamma / \chi (deg)');
        ylabel('2\theta_{peak}');
        legend('Location','best');
    end
end

% -------- SNR --------
fig7 = [];
if opts.multiPlotSNR
    fig7 = figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        res = allRes.results{k};
        pk = allRes.peaksDeg(k);
        g = res.gamma_deg;

        nexttile; hold on; grid on;
        plot(g, res.centroid.snr, 'k.-', 'DisplayName', 'centroid');
        if useGauss
            plot(g, res.gauss.snr, 'r.-', 'DisplayName', 'gauss');
        end
        plot(g, res.pvoigt.snr, 'b.-', 'DisplayName', 'pVoigt');
        title(sprintf('Peak %.4f° SNR', pk));
        xlabel('\gamma / \chi (deg)');
        ylabel('SNR');
        legend('Location','best');
    end
end

% -------- pVoigt window usage --------
fig8 = [];
fig9 = [];
if opts.multiPlotWindowUsage
    % windowDegUsed per peak
    fig8 = figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        res = allRes.results{k};
        pk = allRes.peaksDeg(k);
        g = res.gamma_deg;

        winUsed = get_window_field(res.pvoigt);
        autoUsed = get_auto_window_field(res.pvoigt);
        adaptUsed = get_adaptive_window_field(res.pvoigt);

        nexttile; hold on; grid on;
        plot(g(res.pvoigt.valid), ...
             winUsed(res.pvoigt.valid), ...
             'b.-', 'DisplayName', 'windowDegUsed');

        plot(g(res.pvoigt.valid & autoUsed), ...
             winUsed(res.pvoigt.valid & autoUsed), ...
             'ro', 'DisplayName', 'auto-window');

        plot(g(res.pvoigt.valid & adaptUsed), ...
             winUsed(res.pvoigt.valid & adaptUsed), ...
             'gs', 'DisplayName', 'adaptive-window');

        title(sprintf('Peak %.4f° Fenster', pk));
        xlabel('\gamma / \chi (deg)');
        ylabel('windowDeg used');
        legend('Location','best');
    end

    % counts of fallback/adaptive/auto
    fig9 = figure;
    hold on; grid on;
    nFallback = zeros(nPeaks,1);
    nAdaptive = zeros(nPeaks,1);
    nAuto = zeros(nPeaks,1);

    for k = 1:nPeaks
        res = allRes.results{k};
        nFallback(k) = nnz(get_fallback_field(res.pvoigt));
        nAdaptive(k) = nnz(get_adaptive_window_field(res.pvoigt));
        nAuto(k) = nnz(get_auto_window_field(res.pvoigt));
    end

    x = 1:nPeaks;
    plot(x, nFallback, 'ko-', 'DisplayName', 'fallback->centroid');
    plot(x, nAdaptive, 'gs-', 'DisplayName', 'adaptive-window');
    plot(x, nAuto, 'mo-', 'DisplayName', 'auto-window');
    xlabel('Peak index');
    ylabel('Anzahl Punkte');
    title('pVoigt: Fallback / Adaptive / Auto');
    legend('Location','best');
end

% -------- valid counts --------
fig10 = figure;
hold on; grid on;
nC = zeros(nPeaks,1);
nG = zeros(nPeaks,1);
nP = zeros(nPeaks,1);
nPAdapt = zeros(nPeaks,1);
nPAuto = zeros(nPeaks,1);

for k = 1:nPeaks
    res = allRes.results{k};
    nC(k) = nnz(res.centroid.valid);
    if useGauss
        nG(k) = nnz(res.gauss.valid);
    end
    nP(k) = nnz(res.pvoigt.valid);
    nPAdapt(k) = nnz(get_adaptive_window_field(res.pvoigt));
    nPAuto(k) = nnz(get_auto_window_field(res.pvoigt));
end

x = 1:nPeaks;
plot(x, nC, 'k.-', 'DisplayName', 'centroid');
if useGauss
    plot(x, nG, 'r.-', 'DisplayName', 'gauss');
end
plot(x, nP, 'b.-', 'DisplayName', 'pVoigt');
plot(x, nPAdapt, 'gs-', 'DisplayName', 'pVoigt adaptive-window');
plot(x, nPAuto, 'mo-', 'DisplayName', 'pVoigt auto-window');
xlabel('Peak index');
ylabel('Anzahl gültiger Trackingpunkte');
title('Valid-count Vergleich pro Peak');
legend('Location','best');

% -------- save summary figs --------
if strlength(string(rootDir)) > 0
    save_fig(fig1, fullfile(rootDir, "summary_all_centroid.png"));
    if useGauss && ~isempty(fig2) && isgraphics(fig2)
        save_fig(fig2, fullfile(rootDir, "summary_all_gauss.png"));
    end
    save_fig(fig3, fullfile(rootDir, "summary_all_pvoigt.png"));
    save_fig(fig4, fullfile(rootDir, "summary_method_compare_per_peak.png"));
    if ~isempty(fig5) && isgraphics(fig5)
        save_fig(fig5, fullfile(rootDir, "summary_method_compare_relative_per_peak.png"));
    end
    if ~isempty(fig6) && isgraphics(fig6)
        save_fig(fig6, fullfile(rootDir, "summary_method_compare_errorbars_per_peak.png"));
    end
    if ~isempty(fig7) && isgraphics(fig7)
        save_fig(fig7, fullfile(rootDir, "summary_method_compare_snr_per_peak.png"));
    end
    if ~isempty(fig8) && isgraphics(fig8)
        save_fig(fig8, fullfile(rootDir, "summary_pvoigt_window_usage_per_peak.png"));
    end
    if ~isempty(fig9) && isgraphics(fig9)
        save_fig(fig9, fullfile(rootDir, "summary_pvoigt_fallback_adaptive_auto_counts.png"));
    end
    save_fig(fig10, fullfile(rootDir, "summary_valid_counts.png"));
end

end

% =====================================================================
% CSV export
% =====================================================================

function export_csv_tables(allRes, opts, rootDir)
if strlength(string(rootDir)) == 0
    return;
end

useGauss = true;
if isfield(opts, "useGauss")
    useGauss = opts.useGauss;
end

nPeaks = numel(allRes.peaksDeg);

for k = 1:nPeaks
    res = allRes.results{k};
    pk = allRes.peaksDeg(k);

    T = table();
    T.gamma_deg = res.gamma_deg(:);

    T.centroid_tth_deg = res.centroid.tth_peak_deg(:);
    T.centroid_tth_err_deg = get_err_field(res.centroid);
    T.centroid_valid = res.centroid.valid(:);
    T.centroid_amp = res.centroid.amp(:);
    T.centroid_noise = get_noise_field(res.centroid);
    T.centroid_snr = get_snr_field(res.centroid);

    if useGauss
        T.gauss_tth_deg = res.gauss.tth_peak_deg(:);
        T.gauss_tth_err_deg = get_err_field(res.gauss);
        T.gauss_valid = res.gauss.valid(:);
        T.gauss_amp = res.gauss.amp(:);
        T.gauss_fwhm = res.gauss.fwhm(:);
        T.gauss_R2 = res.gauss.R2(:);
        T.gauss_noise = get_noise_field(res.gauss);
        T.gauss_snr = get_snr_field(res.gauss);
    end

    T.pvoigt_tth_deg = res.pvoigt.tth_peak_deg(:);
    T.pvoigt_tth_err_deg = get_err_field(res.pvoigt);
    T.pvoigt_valid = res.pvoigt.valid(:);
    T.pvoigt_amp = res.pvoigt.amp(:);
    T.pvoigt_fwhm = res.pvoigt.fwhm(:);
    T.pvoigt_R2 = res.pvoigt.R2(:);
    T.pvoigt_noise = get_noise_field(res.pvoigt);
    T.pvoigt_snr = get_snr_field(res.pvoigt);
    T.pvoigt_usedFallback = get_fallback_field(res.pvoigt);
    T.pvoigt_usedAdaptiveWindow = get_adaptive_window_field(res.pvoigt);
    T.pvoigt_usedAutoWindow = get_auto_window_field(res.pvoigt);
    T.pvoigt_windowDegUsed = get_window_field(res.pvoigt);

    fname = fullfile(rootDir, sprintf("peak_%03d_%.4fdeg_table.csv", k, pk));
    writetable(T, fname);
end

% compact summary
peakIdx = (1:nPeaks).';
peakDeg = allRes.peaksDeg(:);

nCentroid = zeros(nPeaks,1);
nGauss = zeros(nPeaks,1);
nPvoigt = zeros(nPeaks,1);
nPvoigtFallback = zeros(nPeaks,1);
nPvoigtAdaptive = zeros(nPeaks,1);
nPvoigtAuto = zeros(nPeaks,1);

meanErrCentroid = nan(nPeaks,1);
meanErrGauss = nan(nPeaks,1);
meanErrPvoigt = nan(nPeaks,1);

meanSNRCentroid = nan(nPeaks,1);
meanSNRGauss = nan(nPeaks,1);
meanSNRPvoigt = nan(nPeaks,1);

meanWindowPvoigt = nan(nPeaks,1);

for k = 1:nPeaks
    res = allRes.results{k};

    errC = get_err_field(res.centroid);
    snrC = get_snr_field(res.centroid);
    nCentroid(k) = nnz(res.centroid.valid);
    meanErrCentroid(k) = mean(errC(res.centroid.valid), 'omitnan');
    meanSNRCentroid(k) = mean(snrC(res.centroid.valid), 'omitnan');

    if useGauss
        errG = get_err_field(res.gauss);
        snrG = get_snr_field(res.gauss);
        nGauss(k) = nnz(res.gauss.valid);
        meanErrGauss(k) = mean(errG(res.gauss.valid), 'omitnan');
        meanSNRGauss(k) = mean(snrG(res.gauss.valid), 'omitnan');
    end

    errP = get_err_field(res.pvoigt);
    snrP = get_snr_field(res.pvoigt);
    winP = get_window_field(res.pvoigt);

    nPvoigt(k) = nnz(res.pvoigt.valid);
    nPvoigtFallback(k) = nnz(get_fallback_field(res.pvoigt));
    nPvoigtAdaptive(k) = nnz(get_adaptive_window_field(res.pvoigt));
    nPvoigtAuto(k) = nnz(get_auto_window_field(res.pvoigt));

    meanErrPvoigt(k) = mean(errP(res.pvoigt.valid), 'omitnan');
    meanSNRPvoigt(k) = mean(snrP(res.pvoigt.valid), 'omitnan');
    meanWindowPvoigt(k) = mean(winP(res.pvoigt.valid), 'omitnan');
end

S = table(peakIdx, peakDeg, nCentroid, meanErrCentroid, meanSNRCentroid, ...
    'VariableNames', {'peak_index','peak_guess_deg','n_centroid_valid','mean_centroid_err_deg','mean_centroid_snr'});

if useGauss
    S.n_gauss_valid = nGauss;
    S.mean_gauss_err_deg = meanErrGauss;
    S.mean_gauss_snr = meanSNRGauss;
end

S.n_pvoigt_valid = nPvoigt;
S.n_pvoigt_fallback = nPvoigtFallback;
S.n_pvoigt_adaptive_window = nPvoigtAdaptive;
S.n_pvoigt_auto_window = nPvoigtAuto;
S.mean_pvoigt_err_deg = meanErrPvoigt;
S.mean_pvoigt_snr = meanSNRPvoigt;
S.mean_pvoigt_windowDegUsed = meanWindowPvoigt;

writetable(S, fullfile(rootDir, "all_peaks_summary_table.csv"));
end

% =====================================================================
% misc helpers
% =====================================================================

function plot_relative(g, y, valid, sty, labelTxt)
if ~any(valid), return; end
y0 = mean(y(valid), 'omitnan');
dy = y - y0;
plot(g(valid), dy(valid), sty, 'DisplayName', labelTxt);
end

function err = get_err_field(S)
if isfield(S, 'tth_peak_err_deg') && ~isempty(S.tth_peak_err_deg)
    err = S.tth_peak_err_deg(:);
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    err = nan(size(S.tth_peak_deg(:)));
else
    err = nan(0,1);
end
end

function noise = get_noise_field(S)
if isfield(S, 'noise') && ~isempty(S.noise)
    noise = S.noise(:);
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    noise = nan(size(S.tth_peak_deg(:)));
else
    noise = nan(0,1);
end
end

function snr = get_snr_field(S)
if isfield(S, 'snr') && ~isempty(S.snr)
    snr = S.snr(:);
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    snr = nan(size(S.tth_peak_deg(:)));
else
    snr = nan(0,1);
end
end

function f = get_fallback_field(S)
if isfield(S, 'usedFallback') && ~isempty(S.usedFallback)
    f = logical(S.usedFallback(:));
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    f = false(size(S.tth_peak_deg(:)));
else
    f = false(0,1);
end
end

function a = get_auto_window_field(S)
if isfield(S, 'usedAutoWindow') && ~isempty(S.usedAutoWindow)
    a = logical(S.usedAutoWindow(:));
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    a = false(size(S.tth_peak_deg(:)));
else
    a = false(0,1);
end
end

function a = get_adaptive_window_field(S)
if isfield(S, 'usedAdaptiveWindow') && ~isempty(S.usedAdaptiveWindow)
    a = logical(S.usedAdaptiveWindow(:));
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    a = false(size(S.tth_peak_deg(:)));
else
    a = false(0,1);
end
end

function w = get_window_field(S)
if isfield(S, 'windowDegUsed') && ~isempty(S.windowDegUsed)
    w = S.windowDegUsed(:);
elseif isfield(S, 'tth_peak_deg') && ~isempty(S.tth_peak_deg)
    w = nan(size(S.tth_peak_deg(:)));
else
    w = nan(0,1);
end
end

function save_fig(fig, pathStr)
try
    exportgraphics(fig, pathStr, "Resolution", 150);
catch
    saveas(fig, pathStr);
end
end

function s = setd(s, f, v)
if ~isfield(s, f) || isempty(s.(f))
    s.(f) = v;
end
end