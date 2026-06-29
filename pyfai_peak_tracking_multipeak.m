function res = pyfai_peak_tracking_multipeak(out, peakDef, opts)
%PYFAI_PEAK_TRACKING_MULTIPEAK
% Trackt ein fest vorgegebenes N-Peak-Modell über alle gamma/chi-Profile.
%
% VORAUSSETZUNG
%   fit_multipeak_profile.m muss im MATLAB-Pfad liegen.
%
% INPUT
%   out.I         : [nRad x nChi] oder [nChi x nRad]
%   out.radial    : radiale Achse (typ. 2theta)
%   out.azimuthal : chi/gamma-Achse
%
%   peakDef       : Struktur für Multi-Peak-Fit
%       peakDef.shape            = "gauss" | "pvoigt"
%       peakDef.nPeaks           = N
%       peakDef.peakGuessDeg     = [mu1 mu2 ... muN]
%       peakDef.fitRange         = [xmin xmax]
%       peakDef.bgLeftRange      = [xmin xmax]   (optional)
%       peakDef.bgRightRange     = [xmin xmax]   (optional)
%       peakDef.backgroundModel  = "constant" | "linear"
%
%   opts:
%       opts.profileChiRange     = [] oder [chiMin chiMax]
%       opts.trackChiRange       = [] oder [chiMin chiMax]
%       opts.trackChiBin         = 1
%       opts.trackChiAvgBins     = 1
%       opts.smoothPoints        = 1
%       opts.useLog              = false
%       opts.baselineMode        = "none" | "movmin"
%       opts.baselineWin         = 51
%       opts.doPlot              = true
%       opts.plotFits            = true
%       opts.fitSampleCount      = 9
%
%       opts.muBoundDeg          = 0.10
%       opts.fwhmMinDeg          = 0.01
%       opts.fwhmMaxDeg          = 0.80
%       opts.fixedEta            = [] oder z.B. 0.5
%       opts.maxIter             = 1000
%
% OUTPUT
%   res.profile
%   res.gamma_deg
%   res.peaks(k)
%       .mu_deg
%       .mu_err_deg
%       .fwhm_deg
%       .amp
%       .valid
%   res.global
%       .R2
%       .valid
%   res.fitStore(it)
%
% HINWEIS
%   Diese Funktion fitttet pro gamma/chi-Profil immer dieselbe Anzahl Peaks.

if nargin < 3 || isempty(opts)
    opts = struct();
end

opts = setd(opts, "profileChiRange", []);
opts = setd(opts, "trackChiRange", []);
opts = setd(opts, "trackChiBin", 1);
opts = setd(opts, "trackChiAvgBins", 1);

opts = setd(opts, "smoothPoints", 1);
opts = setd(opts, "useLog", false);
opts = setd(opts, "baselineMode", "none");
opts = setd(opts, "baselineWin", 51);

opts = setd(opts, "doPlot", true);
opts = setd(opts, "plotFits", true);
opts = setd(opts, "fitSampleCount", 9);

opts = setd(opts, "muBoundDeg", 0.10);
opts = setd(opts, "fwhmMinDeg", 0.01);
opts = setd(opts, "fwhmMaxDeg", 0.80);
opts = setd(opts, "fixedEta", []);
opts = setd(opts, "maxIter", 1000);

assert(isfield(peakDef, 'nPeaks') && peakDef.nPeaks >= 1, 'peakDef.nPeaks fehlt oder ist ungültig.');
assert(isfield(peakDef, 'peakGuessDeg') && numel(peakDef.peakGuessDeg) == peakDef.nPeaks, ...
    'peakDef.peakGuessDeg muss nPeaks Elemente haben.');

% ---------------- normalize input ----------------
I = out.I;
r = out.radial(:);
chi = out.azimuthal(:);

nRad = numel(r);
nChi = numel(chi);
sz = size(I);

if isequal(sz, [nRad nChi])
    % ok
elseif isequal(sz, [nChi nRad])
    I = I.';
else
    error("Dimension mismatch: size(out.I)=[%d %d], numel(radial)=%d, numel(azimuthal)=%d", ...
        sz(1), sz(2), nRad, nChi);
end

if nRad >= 2 && r(2) < r(1)
    r = flipud(r);
    I = flipud(I);
end
if nChi >= 2 && chi(2) < chi(1)
    chi = flipud(chi);
    I = fliplr(I);
end

% ---------------- global 1D profile for context ----------------
profileMask = true(nChi,1);
if ~isempty(opts.profileChiRange)
    profileMask = chi >= opts.profileChiRange(1) & chi <= opts.profileChiRange(2);
end
profileIdx = find(profileMask);
if isempty(profileIdx)
    error("opts.profileChiRange selects no chi bins.");
end

Iprof = mean(I(:, profileIdx), 2);
IprofSm = smooth1(Iprof, opts.smoothPoints);
[IprofProc, baseProf] = baseline_remove(IprofSm, opts.baselineMode, opts.baselineWin);

% ---------------- tracking chi selection ----------------
trackMask = true(nChi,1);
if ~isempty(opts.trackChiRange)
    trackMask = chi >= opts.trackChiRange(1) & chi <= opts.trackChiRange(2);
end
trackIdxAll = find(trackMask);
if isempty(trackIdxAll)
    error("opts.trackChiRange selects no chi bins.");
end

trackIdx = trackIdxAll(1:opts.trackChiBin:end);
g = chi(trackIdx);
nT = numel(trackIdx);
nPeaks = peakDef.nPeaks;

% ---------------- result containers ----------------
res = struct();
res.profile.radial = r;
res.profile.raw = Iprof;
res.profile.smoothed = IprofSm;
res.profile.processed = IprofProc;
res.profile.baseline = baseProf;
res.profile.profileChiRange = opts.profileChiRange;
res.profile.trackChiRange = opts.trackChiRange;
res.profile.peakGuessDeg = peakDef.peakGuessDeg(:).';
res.gamma_deg = g(:);
res.peakDef = peakDef;
res.opts = opts;

res.global.R2 = nan(nT,1);
res.global.valid = false(nT,1);
res.global.noise = nan(nT,1);
res.global.snr = nan(nT,1);

res.peaks = repmat(struct( ...
    'mu_deg', nan(nT,1), ...
    'mu_err_deg', nan(nT,1), ...
    'fwhm_deg', nan(nT,1), ...
    'amp', nan(nT,1), ...
    'valid', false(nT,1)), nPeaks, 1);

fitStore = repmat(struct( ...
    'gamma', nan, ...
    'xFull', [], ...
    'yFull', [], ...
    'yprocFull', [], ...
    'xFit', [], ...
    'yFitData', [], ...
    'yfit', [], ...
    'bg', [], ...
    'R2', nan, ...
    'ok', false, ...
    'noise', nan, ...
    'snr', nan, ...
    'peaks', []), nT, 1);

% ---------------- loop over gamma profiles ----------------
for it = 1:nT
    c0 = trackIdx(it);
    cLo = max(1, c0 - opts.trackChiAvgBins);
    cHi = min(nChi, c0 + opts.trackChiAvgBins);

    prof = mean(I(:, cLo:cHi), 2);
    profSm = smooth1(prof, opts.smoothPoints);

    if opts.useLog
        profSm = log10(max(profSm, 0) + 1);
    end

    [profProc, ~] = baseline_remove(profSm, opts.baselineMode, opts.baselineWin);

    [noiseVal, snrVal] = estimate_peak_quality_profile(r, profProc, peakDef);

    fitStore(it).gamma = g(it);
    fitStore(it).xFull = r;
    fitStore(it).yFull = prof;
    fitStore(it).yprocFull = profProc;
    fitStore(it).noise = noiseVal;
    fitStore(it).snr = snrVal;

    localPeakDef = peakDef;
    localOpts = struct();
    localOpts.muBoundDeg = opts.muBoundDeg;
    localOpts.fwhmMinDeg = opts.fwhmMinDeg;
    localOpts.fwhmMaxDeg = opts.fwhmMaxDeg;
    localOpts.fixedEta = opts.fixedEta;
    localOpts.maxIter = opts.maxIter;
    localOpts.doPlot = false;

    try
        fitRes = fit_multipeak_profile(r, profProc, localPeakDef, localOpts);

        fitStore(it).xFit = fitRes.x;
        fitStore(it).yFitData = fitRes.y;
        fitStore(it).yfit = fitRes.yfit;
        fitStore(it).bg = fitRes.bg.y;
        fitStore(it).R2 = fitRes.R2;
        fitStore(it).ok = fitRes.ok;
        fitStore(it).peaks = fitRes.peaks;

        res.global.R2(it) = fitRes.R2;
        res.global.valid(it) = fitRes.ok;
        res.global.noise(it) = noiseVal;
        res.global.snr(it) = snrVal;

        for k = 1:nPeaks
            res.peaks(k).mu_deg(it) = fitRes.peaks(k).mu;
            res.peaks(k).mu_err_deg(it) = fitRes.peaks(k).muErr;
            res.peaks(k).fwhm_deg(it) = fitRes.peaks(k).fwhm;
            res.peaks(k).amp(it) = fitRes.peaks(k).A;
            res.peaks(k).valid(it) = isfinite(fitRes.peaks(k).mu);
        end

    catch
        res.global.noise(it) = noiseVal;
        res.global.snr(it) = snrVal;
    end
end

res.fitStore = fitStore;

% ---------------- plots ----------------
if opts.doPlot
    % global context profile
    figure;
    hold on; grid on;
    plot(r, Iprof, '-', 'DisplayName', 'raw');
    plot(r, IprofSm, '-', 'DisplayName', 'smoothed');
    plot(r, IprofProc, '-', 'DisplayName', 'processed');
    for k = 1:nPeaks
        xline(peakDef.peakGuessDeg(k), '--', 'DisplayName', sprintf('guess %d', k));
    end
    xlabel('2\theta / radial');
    ylabel('intensity');
    title('\chi-integriertes Profil zur Multi-Peak-Definition');
    legend('Location', 'best');

    % mu tracking for each peak
    figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        nexttile; hold on; grid on;
        v = res.peaks(k).valid;
        plot(g(v), res.peaks(k).mu_deg(v), 'b.-');
        xlabel('\gamma / \chi (deg)');
        ylabel(sprintf('\\mu_%d (deg)', k));
        title(sprintf('Peak %d Tracking', k));
    end

    % relative mu tracking
    figure;
    tiledlayout('flow');
    for k = 1:nPeaks
        nexttile; hold on; grid on;
        v = res.peaks(k).valid;
        if any(v)
            y = res.peaks(k).mu_deg;
            y0 = mean(y(v), 'omitnan');
            plot(g(v), y(v) - y0, 'b.-');
        end
        xlabel('\gamma / \chi (deg)');
        ylabel(sprintf('\\Delta\\mu_%d (deg)', k));
        title(sprintf('Peak %d relativ', k));
    end

    % R2 + SNR
    figure;
    yyaxis left
    plot(g, res.global.R2, 'r.-', 'DisplayName', 'R2');
    ylabel('R^2');
    yyaxis right
    plot(g, res.global.snr, 'k.-', 'DisplayName', 'SNR');
    ylabel('SNR');
    xlabel('\gamma / \chi (deg)');
    title('Globaler Multi-Peak-Fit: R^2 und SNR');
    grid on;

    if opts.plotFits
        plot_fit_samples_multipeak(fitStore, g, opts);
    end
end

end

% =========================================================
% helpers
% =========================================================

function y = smooth1(x, w)
x = x(:);
w = max(1, round(w));
if mod(w,2)==0
    w = w + 1;
end
if w == 1
    y = x;
    return;
end
k = ones(w,1) / w;
y = conv(x, k, 'same');
end

function [yproc, base] = baseline_remove(y, mode, win)
y = y(:);
switch lower(string(mode))
    case "none"
        base = zeros(size(y));
        yproc = y;
    case "movmin"
        win = max(5, round(win));
        if mod(win,2)==0
            win = win + 1;
        end
        base = movmin(y, win);
        yproc = y - base;
        yproc(yproc < 0) = 0;
    otherwise
        error("Unknown baselineMode: %s", string(mode));
end
end

function [noise, snrVal] = estimate_peak_quality_profile(x, y, peakDef)
x = x(:);
y = y(:);

if isfield(peakDef, 'fitRange') && ~isempty(peakDef.fitRange)
    mask = x >= peakDef.fitRange(1) & x <= peakDef.fitRange(2);
else
    mask = true(size(x));
end

yy = y(mask);
if isempty(yy) || all(~isfinite(yy))
    noise = nan;
    snrVal = nan;
    return;
end

ym = median(yy, 'omitnan');
madVal = median(abs(yy - ym), 'omitnan');
noise = 1.4826 * madVal;

if ~isfinite(noise) || noise <= 0
    noise = std(yy, 'omitnan');
end
if ~isfinite(noise) || noise <= 0
    noise = eps;
end

snrVal = max(yy, [], 'omitnan') / noise;
end

function plot_fit_samples_multipeak(fitStore, g, opts)
idx = find([fitStore.ok]);
if isempty(idx)
    return;
end

nShow = min(opts.fitSampleCount, numel(idx));
pick = unique(round(linspace(1, numel(idx), nShow)));
idxShow = idx(pick);

figure;
tiledlayout('flow');
for j = 1:numel(idxShow)
    i = idxShow(j);
    nexttile; hold on; grid on;

    fs = fitStore(i);
    if ~isempty(fs.xFull) && ~isempty(fs.yprocFull) && numel(fs.xFull) == numel(fs.yprocFull)
        plot(fs.xFull, fs.yprocFull, 'k.-', 'DisplayName', 'processed');
    end
    
    if ~isempty(fs.xFit) && ~isempty(fs.bg) && numel(fs.xFit) == numel(fs.bg)
        plot(fs.xFit, fs.bg, 'b--', 'DisplayName', 'bg');
    end
    if ~isempty(fs.xFit) && ~isempty(fs.yfit) && numel(fs.xFit) == numel(fs.yfit)
        plot(fs.xFit, fs.yfit, 'r-', 'LineWidth', 1.2, 'DisplayName', 'fit');
    end

    if ~isempty(fs.peaks)
        for k = 1:numel(fs.peaks)
            if isfield(fs.peaks(k), 'mu') && isfinite(fs.peaks(k).mu)
                xline(fs.peaks(k).mu, ':', 'LineWidth', 1.0, ...
                    'DisplayName', sprintf('\\mu_%d', k));
            end
        end
    end

    title(sprintf('\\chi=%.2f°, R^2=%.4f, SNR=%.2f', g(i), fs.R2, fs.snr));
    xlabel('2\theta');
    ylabel('I');
end
end

function s = setd(s, f, v)
if ~isfield(s, f) || isempty(s.(f))
    s.(f) = v;
end
end