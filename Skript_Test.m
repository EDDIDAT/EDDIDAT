h          = guidata(gcf);
value      = round(get(h.SliderTimeSeries, 'Value'));
ds         = h.dataset(value);

poniFiles  = dir(fullfile(h.dataDir, '*.poni'));
poniPath   = fullfile(h.dataDir, poniFiles(1).name);
pythonExe  = strtrim(get(h.pythonExeEdit, 'String'));
guiFile    = which('XRD2DStressAnalysis_modPV_pyFAI');
scriptPath = fullfile(fileparts(guiFile), 'pyfai_multigeom_run.py');
cacheDir   = fullfile(h.dataDir, 'caked_cache');
if ~exist(cacheDir, 'dir'), mkdir(cacheDir); end

az_range = [min(ds.caked.azimuthal), max(ds.caked.azimuthal)];

% =========================================================
% Basis-Job-Struct (gemeinsame Parameter)
% =========================================================
baseJob               = struct();
baseJob.img_paths     = {ds.cbfPath};
baseJob.poni_paths    = {poniPath};
baseJob.wavelength_m  = h.datasetLambda_m;
baseJob.azimuth_range = az_range;

% =========================================================
% Referenz: 1d_standard (Pilatus-Maske, SA=True, kein Pol)
% =========================================================
job_ref               = baseJob;
job_ref.mode          = '1d_standard';
job_ref.npt_std       = 1000;
job_ref.out_npz       = fullfile(cacheDir, 'ref_std.npz');
job_ref.out_mat       = fullfile(cacheDir, 'ref_std.mat');
job_ref.out_json      = fullfile(cacheDir, 'ref_std_meta.json');

jobPath = fullfile(cacheDir, 'ref_std_job.json');
fid = fopen(jobPath, 'w'); fprintf(fid, '%s', jsonencode(job_ref)); fclose(fid);
[~, cmdout] = system(sprintf('"%s" "%s" "%s" 2>&1', pythonExe, scriptPath, jobPath));
fprintf('Referenz 1d_standard: %s\n', strtrim(cmdout));
ref = load(job_ref.out_mat);

% =========================================================
% Vergleich 1: npt_rad
% =========================================================
npt_vals = [500, 1000, 1500, 3000];
res_npt  = cell(numel(npt_vals), 1);

for k = 1:numel(npt_vals)
    npt           = npt_vals(k);
    job           = baseJob;
    job.mode      = '1d_batch_standard';
    job.npt_rad   = npt;
    job.out_npz   = fullfile(cacheDir, sprintf('npt_%d.npz', npt));
    job.out_mat   = fullfile(cacheDir, sprintf('npt_%d.mat', npt));
    job.out_json  = fullfile(cacheDir, sprintf('npt_%d_meta.json', npt));

    jobPath = fullfile(cacheDir, sprintf('npt_%d_job.json', npt));
    fid = fopen(jobPath, 'w'); fprintf(fid, '%s', jsonencode(job)); fclose(fid);
    [~, cmdout] = system(sprintf('"%s" "%s" "%s" 2>&1', pythonExe, scriptPath, jobPath));
    fprintf('npt=%d: %s\n', npt, strtrim(cmdout));
    res_npt{k} = load(job.out_mat);
end

% =========================================================
% Vergleich 2: Korrekturfunktionen
% =========================================================
variants = {
    'A',  false, [];      % kein SA, kein Pol
    'B',  true,  [];      % SA=True, kein Pol (pyFAI-Default)
    'C',  true,  0;       % SA=True, Pol=0 (Labor, unpolarisiert)
    'D',  true,  0.95;    % SA=True, Pol=0.95 (Synchrotron)
};
corr_labels = {
    'A: SA=False, Pol=–';
    'B: SA=True,  Pol=– (Default)';
    'C: SA=True,  Pol=0 (Labor)';
    'D: SA=True,  Pol=0.95 (Synchrotron)';
};
res_corr = cell(size(variants,1), 1);

for k = 1:size(variants,1)
    tag     = variants{k,1};
    corr_sa = variants{k,2};
    pol     = variants{k,3};

    job                   = baseJob;
    job.mode              = '1d_batch_standard';
    job.npt_rad           = 1000;
    job.correctSolidAngle = corr_sa;
    if ~isempty(pol)
        job.polarization_factor = pol;
    end
    job.out_npz  = fullfile(cacheDir, sprintf('corr_%s.npz', tag));
    job.out_mat  = fullfile(cacheDir, sprintf('corr_%s.mat', tag));
    job.out_json = fullfile(cacheDir, sprintf('corr_%s_meta.json', tag));

    jobPath = fullfile(cacheDir, sprintf('corr_%s_job.json', tag));
    fid = fopen(jobPath, 'w'); fprintf(fid, '%s', jsonencode(job)); fclose(fid);
    [~, cmdout] = system(sprintf('"%s" "%s" "%s" 2>&1', pythonExe, scriptPath, jobPath));
    fprintf('Variante %s: %s\n', tag, strtrim(cmdout));
    res_corr{k} = load(job.out_mat);
end

% =========================================================
% Plots
% =========================================================
colors_npt  = lines(numel(npt_vals));
colors_corr = lines(size(variants,1));

figure('Position', [50 50 1400 850]);

% --- npt: vollständig ---
subplot(2,2,1);
for k = 1:numel(npt_vals)
    plot(res_npt{k}.radial, res_npt{k}.I, '-', ...
        'Color', colors_npt(k,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('npt = %d', npt_vals(k)));
    hold on;
end
plot(ref.radial, ref.I, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Referenz (1d\_standard)');
xlabel('q (nm^{-1})'); ylabel('Intensität');
legend('show', 'Location', 'northeast', 'FontSize', 8);
grid on; title('npt\_rad — vollständiges Profil');

% --- npt: Zoom ---
subplot(2,2,2);
for k = 1:numel(npt_vals)
    plot(res_npt{k}.radial, res_npt{k}.I, '-', ...
        'Color', colors_npt(k,:), 'LineWidth', 1, ...
        'DisplayName', sprintf('npt = %d', npt_vals(k)));
    hold on;
end
plot(ref.radial, ref.I, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Referenz (1d\_standard)');
xlabel('q (nm^{-1})'); ylabel('Intensität');
legend('show', 'Location', 'northeast', 'FontSize', 8);
grid on; xlim([28 36]); title('npt\_rad — Zoom Peakbereich');

% --- Korrekturen: vollständig ---
subplot(2,2,3);
for k = 1:size(variants,1)
    plot(res_corr{k}.radial, res_corr{k}.I, '-', ...
        'Color', colors_corr(k,:), 'LineWidth', 1, ...
        'DisplayName', corr_labels{k});
    hold on;
end
plot(ref.radial, ref.I, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Referenz (1d\_standard)');
xlabel('q (nm^{-1})'); ylabel('Intensität');
legend('show', 'Location', 'northeast', 'FontSize', 8);
grid on; title('Korrekturfunktionen — vollständiges Profil');

% --- Korrekturen: Zoom ---
subplot(2,2,4);
for k = 1:size(variants,1)
    plot(res_corr{k}.radial, res_corr{k}.I, '-', ...
        'Color', colors_corr(k,:), 'LineWidth', 1, ...
        'DisplayName', corr_labels{k});
    hold on;
end
plot(ref.radial, ref.I, 'k--', 'LineWidth', 1.5, 'DisplayName', 'Referenz (1d\_standard)');
xlabel('q (nm^{-1})'); ylabel('Intensität');
legend('show', 'Location', 'northeast', 'FontSize', 8);
grid on; xlim([28 36]); title('Korrekturfunktionen — Zoom Peakbereich');

sgtitle(sprintf('Parameterstudie 1D-Integration  |  az: [%.1f°, %.1f°]', ...
    az_range(1), az_range(2)));