function allRes = pyfai_peak_tracking_multipeak_multiwindow(out, peakDefs, opts)
%PYFAI_PEAK_TRACKING_MULTIPEAK_MULTIWINDOW
% Führt Multi-Peak-Tracking für mehrere Peakfenster aus.
%
% VORAUSSETZUNG
%   pyfai_peak_tracking_multipeak.m muss im MATLAB-Pfad liegen.
%
% INPUT
%   out      : pyFAI-Output mit Feldern out.I, out.radial, out.azimuthal
%   peakDefs : Struct-Array oder Cell-Array von Peakdefinitionen
%              Jede peakDef-Struktur wird separat mit
%              pyfai_peak_tracking_multipeak(...) gefittet.
%   opts     : Optionen für pyfai_peak_tracking_multipeak
%
% Zusätzliche Multiwindow-Optionen:
%   opts.multiWindowDoSummaryPlots   = true/false
%   opts.multiWindowPlotRelative     = true/false
%   opts.multiWindowPlotR2SNR        = true/false
%   opts.multiWindowSaveDir          = "" oder Zielordner
%   opts.multiWindowMakeSubfolders   = true/false
%   opts.multiWindowCloseSinglePlots = false/true
%   opts.multiWindowExportCSV        = true/false
%
% OUTPUT
%   allRes.results{k}    : Ergebnis für Fenster k
%   allRes.peakDefs{k}   : zugehörige Peakdefinition
%   allRes.windowNames   : Namen der Fenster
%
% HINWEIS
%   Jedes Peakfenster wird unabhängig gefittet.

if nargin < 3 || isempty(opts)
    opts = struct();
end

opts = setd(opts, "multiWindowDoSummaryPlots", true);
opts = setd(opts, "multiWindowPlotRelative", true);
opts = setd(opts, "multiWindowPlotR2SNR", true);
opts = setd(opts, "multiWindowSaveDir", "");
opts = setd(opts, "multiWindowMakeSubfolders", true);
opts = setd(opts, "multiWindowCloseSinglePlots", false);
opts = setd(opts, "multiWindowExportCSV", true);

if isstruct(peakDefs)
    if numel(peakDefs) == 1
        peakDefs = {peakDefs};
    else
        peakDefs = squeeze(num2cell(peakDefs));
    end
elseif ~iscell(peakDefs)
    error("peakDefs muss struct oder cell sein.");
end

nW = numel(peakDefs);
if nW == 0
    error("peakDefs ist leer.");
end

doSave = strlength(string(opts.multiWindowSaveDir)) > 0;
if doSave
    rootDir = string(opts.multiWindowSaveDir);
    if ~exist(rootDir, "dir")
        mkdir(rootDir);
    end
else
    rootDir = "";
end

allRes = struct();
allRes.results = cell(nW,1);
allRes.peakDefs = peakDefs(:);
allRes.windowNames = strings(nW,1);
allRes.opts = opts;

for k = 1:nW
    pd = peakDefs{k};

    if isfield(pd, "name") && strlength(string(pd.name)) > 0
        wname = string(pd.name);
    else
        wname = "window_" + string(k);
    end
    allRes.windowNames(k) = wname;

    beforeFigs = findall(groot, 'Type', 'figure');

    res = pyfai_peak_tracking_multipeak(out, pd, opts);

    afterFigs = findall(groot, 'Type', 'figure');
    newFigs = setdiff(afterFigs, beforeFigs);

    if doSave
        if opts.multiWindowMakeSubfolders
            subDir = fullfile(rootDir, sprintf("%02d_%s", k, sanitize_filename(wname)));
            if ~exist(subDir, "dir")
                mkdir(subDir);
            end
        else
            subDir = rootDir;
        end

        save(fullfile(subDir, sprintf("%s_multipeak_tracking.mat", sanitize_filename(wname))), ...
            "res", "pd", "opts");

        for iFig = 1:numel(newFigs)
            fig = newFigs(iFig);
            fname = fullfile(subDir, sprintf("fig_%02d_%s.png", iFig, sanitize_filename(wname)));
            save_fig(fig, fname);
        end
    end

    if opts.multiWindowCloseSinglePlots && ~isempty(newFigs)
        close(newFigs);
    end

    allRes.results{k} = res;
end

if opts.multiWindowDoSummaryPlots
    make_summary_plots(allRes, opts, rootDir);
end

if opts.multiWindowExportCSV
    export_csv_tables(allRes, opts, rootDir);
end

if doSave
    save(fullfile(rootDir, "all_multipeak_multiwindow_results.mat"), "allRes", "peakDefs", "opts");
end

end

% =====================================================================
% summary plots
% =====================================================================

function make_summary_plots(allRes, opts, rootDir)
nW = numel(allRes.results);

% Plot pro Fenster: alle Teilpeaks absolut
fig1 = figure;
tiledlayout('flow');
for k = 1:nW
    res = allRes.results{k};
    wname = allRes.windowNames(k);
    g = res.gamma_deg(:);
    nPeaks = numel(res.peaks);

    nexttile; hold on; grid on;
    for p = 1:nPeaks
        v = res.peaks(p).valid;
        plot(g(v), res.peaks(p).mu_deg(v), '.-', 'DisplayName', sprintf('peak %d', p));
    end
    xlabel('\gamma / \chi (deg)');
    ylabel('\mu (deg)');
    title(sprintf('%s | absolute', wname), 'Interpreter', 'none');
    legend('Location', 'best');
end

% Plot pro Fenster: alle Teilpeaks relativ
fig2 = [];
if opts.multiWindowPlotRelative
    fig2 = figure;
    tiledlayout('flow');
    for k = 1:nW
        res = allRes.results{k};
        wname = allRes.windowNames(k);
        g = res.gamma_deg(:);
        nPeaks = numel(res.peaks);

        nexttile; hold on; grid on;
        for p = 1:nPeaks
            v = res.peaks(p).valid;
            if any(v)
                y = res.peaks(p).mu_deg;
                y0 = mean(y(v), 'omitnan');
                plot(g(v), y(v)-y0, '.-', 'DisplayName', sprintf('peak %d', p));
            end
        end
        xlabel('\gamma / \chi (deg)');
        ylabel('\Delta\mu (deg)');
        title(sprintf('%s | relative', wname), 'Interpreter', 'none');
        legend('Location', 'best');
    end
end

% Plot pro Fenster: R2 und SNR
fig3 = [];
if opts.multiWindowPlotR2SNR
    fig3 = figure;
    tiledlayout('flow');
    for k = 1:nW
        res = allRes.results{k};
        wname = allRes.windowNames(k);
        g = res.gamma_deg(:);

        nexttile;
        yyaxis left
        plot(g, res.global.R2, 'r.-', 'DisplayName', 'R2');
        ylabel('R^2');
        yyaxis right
        plot(g, res.global.snr, 'k.-', 'DisplayName', 'SNR');
        ylabel('SNR');
        xlabel('\gamma / \chi (deg)');
        title(sprintf('%s | R^2 + SNR', wname), 'Interpreter', 'none');
        grid on;
    end
end

% Vergleich valid counts über Fenster
fig4 = figure;
hold on; grid on;
x = 1:nW;
nValidGlobal = zeros(nW,1);
for k = 1:nW
    nValidGlobal(k) = nnz(allRes.results{k}.global.valid);
end
plot(x, nValidGlobal, 'ko-', 'DisplayName', 'global valid');
xlabel('Fenster index');
ylabel('Anzahl gültiger Profile');
title('Valid-count pro Peakfenster');
set(gca, 'XTick', x, 'XTickLabel', cellstr(allRes.windowNames));
xtickangle(30);
legend('Location', 'best');

if strlength(string(rootDir)) > 0
    save_fig(fig1, fullfile(rootDir, "summary_multiwindow_absolute.png"));
    if ~isempty(fig2) && isgraphics(fig2)
        save_fig(fig2, fullfile(rootDir, "summary_multiwindow_relative.png"));
    end
    if ~isempty(fig3) && isgraphics(fig3)
        save_fig(fig3, fullfile(rootDir, "summary_multiwindow_r2_snr.png"));
    end
    save_fig(fig4, fullfile(rootDir, "summary_multiwindow_valid_counts.png"));
end

end

% =====================================================================
% CSV export
% =====================================================================

function export_csv_tables(allRes, ~, rootDir)
if strlength(string(rootDir)) == 0
    return;
end

nW = numel(allRes.results);

for k = 1:nW
    res = allRes.results{k};
    wname = allRes.windowNames(k);
    g = res.gamma_deg(:);
    nPeaks = numel(res.peaks);

    T = table();
    T.gamma_deg = g;
    T.global_R2 = res.global.R2(:);
    T.global_valid = res.global.valid(:);
    T.global_noise = res.global.noise(:);
    T.global_snr = res.global.snr(:);

    for p = 1:nPeaks
        T.(sprintf('peak%d_mu_deg', p)) = res.peaks(p).mu_deg(:);
        T.(sprintf('peak%d_mu_err_deg', p)) = res.peaks(p).mu_err_deg(:);
        T.(sprintf('peak%d_fwhm_deg', p)) = res.peaks(p).fwhm_deg(:);
        T.(sprintf('peak%d_amp', p)) = res.peaks(p).amp(:);
        T.(sprintf('peak%d_valid', p)) = res.peaks(p).valid(:);
    end

    writetable(T, fullfile(rootDir, sprintf("%02d_%s_table.csv", k, sanitize_filename(wname))));
end

% kompakte Summary
windowIndex = (1:nW).';
windowName = allRes.windowNames(:);
nPeaksVec = zeros(nW,1);
nValidGlobal = zeros(nW,1);
meanR2 = nan(nW,1);
meanSNR = nan(nW,1);

for k = 1:nW
    res = allRes.results{k};
    nPeaksVec(k) = numel(res.peaks);
    nValidGlobal(k) = nnz(res.global.valid);
    meanR2(k) = mean(res.global.R2(res.global.valid), 'omitnan');
    meanSNR(k) = mean(res.global.snr(res.global.valid), 'omitnan');
end

S = table(windowIndex, windowName, nPeaksVec, nValidGlobal, meanR2, meanSNR, ...
    'VariableNames', {'window_index','window_name','n_peaks','n_global_valid','mean_R2','mean_SNR'});

writetable(S, fullfile(rootDir, "multiwindow_summary_table.csv"));

end

% =====================================================================
% helpers
% =====================================================================

function save_fig(fig, pathStr)
try
    exportgraphics(fig, pathStr, "Resolution", 150);
catch
    saveas(fig, pathStr);
end
end

function out = sanitize_filename(s)
s = char(string(s));
out = regexprep(s, '[^\w\-]+', '_');
end

function s = setd(s, f, v)
if ~isfield(s, f) || isempty(s.(f))
    s.(f) = v;
end
end