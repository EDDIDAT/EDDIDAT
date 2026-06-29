% =========================================================================
%  tryGIWAXSTransform — transformiert CBF-Bilder ins Proben-Referenzsystem
% =========================================================================
function dataset = tryGIWAXSTransform(dataset, dataDir, pythonExe)

% ── Cache-Pfade ───────────────────────────────────────────────────────
cacheDir     = fullfile(dataDir, 'caked_cache');
cacheGIWAXS  = fullfile(cacheDir, 'giwaxs_srf.mat');

if ~exist(cacheDir, 'dir'), mkdir(cacheDir); end

% ── Script-Pfad ermitteln ─────────────────────────────────────────────
guiFile    = which('XRD2DStressAnalysis_modPV_pyFAI');
scriptPath = '';
if ~isempty(guiFile)
    candidate = fullfile(fileparts(guiFile), 'giwaxs_transform.py');
    if isfile(candidate), scriptPath = candidate; end
end
if isempty(scriptPath)
    candidate = fullfile(dataDir, 'giwaxs_transform.py');
    if isfile(candidate), scriptPath = candidate; end
end
if isempty(scriptPath)
    candidate = fullfile(pwd, 'giwaxs_transform.py');
    if isfile(candidate), scriptPath = candidate; end
end
if isempty(scriptPath)
    warning('tryGIWAXSTransform: giwaxs_transform.py nicht gefunden.');
    return
end

% ── Cache laden falls vorhanden ───────────────────────────────────────
if isfile(cacheGIWAXS)
    fprintf('tryGIWAXSTransform: Cache gefunden, lade ...\n');
    try
        res      = load(cacheGIWAXS);
        dataset  = fillGIWAXSFromResult(dataset, res);
        fprintf('tryGIWAXSTransform: %d GIWAXS-Bilder geladen.\n', ...
            sum(arrayfun(@(d) isfield(d,'giwaxs') && ...
            ~isempty(d.giwaxs.I), dataset)));
        return
    catch ME
        warning('tryGIWAXSTransform: Cache-Fehler: %s', ME.message);
    end
end

% ── PONI-Dateien und Alpha-Winkel sammeln ─────────────────────────────
cbfPaths  = {dataset.cbfPath};
hasCBF    = ~cellfun(@isempty, cbfPaths);
if ~any(hasCBF)
    fprintf('tryGIWAXSTransform: Keine CBF-Dateien.\n');
    return
end

% PONI-Dateien
poniFiles = dir(fullfile(dataDir, '*.poni'));
if isempty(poniFiles)
    fprintf('tryGIWAXSTransform: Keine PONI-Datei gefunden.\n');
    return
end

% Alpha-Winkel und PONI pro Messung
[~, sortIdx] = sort({poniFiles.name});
poniMap = struct('alpha', {}, 'path', {});
for k = 1:numel(poniFiles)
    fname = poniFiles(sortIdx(k)).name;
    tok   = regexp(fname, '(?<=alpha)([\d.+-]+)', 'match');
    if ~isempty(tok)
        poniMap(k).alpha = str2double(tok{1});
        poniMap(k).path  = fullfile(dataDir, fname);
    else
        poniMap(k).alpha = NaN;
        poniMap(k).path  = fullfile(dataDir, fname);
    end
end

% PONI und Alpha pro Bild zuordnen
poniPaths_all = cell(numel(dataset), 1);
alphaDeg_all  = zeros(numel(dataset), 1);
fallbackPoni  = poniMap(1).path;

for i = 1:numel(dataset)
    alpha_i = NaN;
    if isfield(dataset(i), 'meta') && ...
       isfield(dataset(i).meta, 'motorsChi_cor')
        val = dataset(i).meta.motorsChi_cor;
        if isnumeric(val) && isscalar(val) && isfinite(val)
            alpha_i = abs(val);
        end
    end
    alphaDeg_all(i) = alpha_i;

    if ~isnan(alpha_i)
        alphaVals = [poniMap.alpha];
        validIdx  = find(~isnan(alphaVals));
        if ~isempty(validIdx)
            [~, bestK]       = min(abs(alphaVals(validIdx) - alpha_i));
            poniPaths_all{i} = poniMap(validIdx(bestK)).path;
        else
            poniPaths_all{i} = fallbackPoni;
        end
    else
        poniPaths_all{i} = fallbackPoni;
        alphaDeg_all(i)  = 0;
    end
end

% ── Job zusammenbauen ─────────────────────────────────────────────────
validCBF   = cbfPaths(hasCBF);
validPONI  = poniPaths_all(hasCBF);
validAlpha = num2cell(alphaDeg_all(hasCBF));

job             = struct();
job.img_paths   = validCBF(:);
job.poni_paths  = validPONI(:);
job.alpha_i_deg = validAlpha(:);
job.q_range     = [0.5  4.0];   % Å^-1 — anpassen falls nötig
job.chi_range   = [-90.0  90.0];
job.npt_q       = 500;
job.npt_chi     = 360;
job.out_mat     = cacheGIWAXS;
job.out_npz     = fullfile(cacheDir, 'giwaxs_srf.npz');

jobPath = fullfile(cacheDir, 'giwaxs_job.json');
fid = fopen(jobPath, 'w');
fprintf(fid, '%s', jsonencode(job));
fclose(fid);

% ── Python aufrufen ───────────────────────────────────────────────────
fprintf('tryGIWAXSTransform: Starte GIWAXS-Transformation ...\n');
cmd = sprintf('"%s" "%s" "%s" 2>&1', pythonExe, scriptPath, jobPath);
[status, cmdout] = system(cmd);
if isfile(jobPath), delete(jobPath); end

fprintf('%s\n', cmdout);

if status ~= 0
    warning('tryGIWAXSTransform: Transformation fehlgeschlagen.');
    return
end

% ── Ergebnis laden ────────────────────────────────────────────────────
if isfile(cacheGIWAXS)
    try
        res     = load(cacheGIWAXS);
        dataset = fillGIWAXSFromResult(dataset, res);
        fprintf('tryGIWAXSTransform: Transformation abgeschlossen.\n');
    catch ME
        warning('tryGIWAXSTransform: Laden fehlgeschlagen: %s', ME.message);
    end
end

end  % tryGIWAXSTransform


% =========================================================================
%  fillGIWAXSFromResult — verteilt GIWAXS-Daten auf dataset(i).giwaxs
% =========================================================================
function dataset = fillGIWAXSFromResult(dataset, result)
I_stack = double(result.I);   % [N x npt_chi x npt_q]
q_axis  = double(result.q(:));
chi_axis = double(result.chi(:));
N = size(I_stack, 1);

cbfIdx = find(~cellfun(@isempty, {dataset.cbfPath}));
for ii = 1:min(N, numel(cbfIdx))
    ds_i = cbfIdx(ii);
    dataset(ds_i).giwaxs = struct(
        'I',   squeeze(I_stack(ii,:,:)), ...  % [npt_chi x npt_q]
        'q',   q_axis, ...
        'chi', chi_axis);
end
end  % fillGIWAXSFromResult