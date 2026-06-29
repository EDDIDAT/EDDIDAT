function res = pyfai_peak_tracking_compare_methods(out, peakGuessDeg, opts)
%PYFAI_PEAK_TRACKING_COMPARE_METHODS
% Vergleicht centroid, gauss und pseudo-Voigt Peaktracking auf pyFAI-Output.
%
% INPUT
%   out.I         : [nRad x nChi] oder [nChi x nRad]
%   out.radial    : radiale Achse (typ. 2theta)
%   out.azimuthal : chi/gamma-Achse
%   peakGuessDeg  : erwartete Peaklage auf radialer Achse
%
% OPTIONS
%   opts.profileChiRange            = [] oder [chiMin chiMax]
%   opts.trackChiRange              = [] oder [chiMin chiMax]
  % opts.trackChiBin                = 4
  % opts.trackChiAvgBins            = 1
%   opts.windowDeg                  = 0.8
%   opts.smoothPoints               = 5
%   opts.useLog                     = false
%   opts.baselineMode               = "none" | "movmin"
%   opts.baselineWin                = 51
%
%   opts.doPlot                     = true
%   opts.plotFits                   = true
%   opts.fitSampleCount             = 9
%
%   opts.useGauss                   = true
%   opts.gaussMinR2                 = 0.98
%   opts.gaussSigmaRangeDeg         = [0.01 0.50]
%
%   opts.pvoigtFixedEta             = [] oder z.B. 0.5
%   opts.pvoigtFallbackToCentroid   = true
%   opts.pvoigtMinR2                = 0.98
%   opts.pvoigtFwhmRangeDeg         = [0.01 0.50]
%   opts.pvoigtMuBoundDeg           = 0.15
%
%   opts.pvoigtAdaptiveWindow       = false
%   opts.pvoigtAdaptiveWindowFactor = 2.5
%   opts.pvoigtAdaptiveWindowMinDeg = 0.20
%   opts.pvoigtAdaptiveWindowMaxDeg = 0.60
%
%   opts.pvoigtAutoWindow           = false
%   opts.pvoigtWindowCandidates     = []
%   opts.pvoigtAutoWindowUseBestR2  = true
%
% OUTPUT
%   res.profile
%   res.gamma_deg
%   res.centroid / res.gauss / res.pvoigt
%
% Zusatzfelder für pVoigt:
%   res.pvoigt.usedFallback
%   res.pvoigt.usedAdaptiveWindow
%   res.pvoigt.usedAutoWindow
%   res.pvoigt.windowDegUsed

if nargin < 3 || isempty(opts)
    opts = struct();
end

% opts = setd(opts, "profileChiRange", []);
% opts = setd(opts, "trackChiRange", []);
% opts = setd(opts, "trackChiBin", 4);
% opts = setd(opts, "trackChiAvgBins", 4);
% % 
% opts = setd(opts, "windowDeg", 0.6);
% opts = setd(opts, "smoothPoints", 5);
% opts = setd(opts, "useLog", false);
% opts = setd(opts, "baselineMode", "none");
% opts = setd(opts, "baselineWin", 51);
% % 
% opts = setd(opts, "doPlot", false);
% opts = setd(opts, "plotFits", false);
% opts = setd(opts, "fitSampleCount", 9);
% 
% opts = setd(opts, "useGauss", false);
% opts = setd(opts, "gaussMinR2", 0.98);
% opts = setd(opts, "gaussSigmaRangeDeg", [0.01 0.50]);
% 
% opts = setd(opts, "pvoigtFixedEta", []);
% opts = setd(opts, "pvoigtFallbackToCentroid", true);
% opts = setd(opts, "pvoigtMinR2", 0.9);
% opts = setd(opts, "pvoigtFwhmRangeDeg", [0.01 0.50]);
% opts = setd(opts, "pvoigtMuBoundDeg", 0.15);
% 
% opts = setd(opts, "pvoigtAdaptiveWindow", false);
% opts = setd(opts, "pvoigtAdaptiveWindowFactor", 2.5);
% opts = setd(opts, "pvoigtAdaptiveWindowMinDeg", 0.20);
% opts = setd(opts, "pvoigtAdaptiveWindowMaxDeg", 0.60);
% 
% opts = setd(opts, "pvoigtAutoWindow", false);
% opts = setd(opts, "pvoigtWindowCandidates", []);
% opts = setd(opts, "pvoigtAutoWindowUseBestR2", true);

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

% ---------------- 1D profile for peak context ----------------
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

% ---------------- result containers ----------------
nT = numel(trackIdx);

res = struct();
res.profile.radial = r;
res.profile.raw = Iprof;
res.profile.smoothed = IprofSm;
res.profile.processed = IprofProc;
res.profile.baseline = baseProf;
res.profile.peakGuessDeg = peakGuessDeg;
res.profile.profileChiRange = opts.profileChiRange;
res.profile.trackChiRange = opts.trackChiRange;
res.gamma_deg = g(:);

res.centroid = init_method_struct(nT);
res.gauss    = init_method_struct(nT);
res.pvoigt   = init_method_struct(nT);

res.centroid.method = "centroid";
res.gauss.method    = "gauss";
res.pvoigt.method   = "pvoigt";

fitStore = repmat(struct( ...
    "gamma", nan, ...
    "r", [], ...
    "y", [], ...
    "yproc", [], ...
    "noise", nan, ...
    "snr", nan, ...
    "xfit_gauss", [], ...
    "yfit_gauss", [], ...
    "xfit_pvoigt", [], ...
    "yfit_pvoigt", [], ...
    "x_centroid", nan, ...
    "x_gauss", nan, ...
    "x_pvoigt", nan, ...
    "valid_centroid", false, ...
    "valid_gauss", false, ...
    "valid_pvoigt", false, ...
    "usedPvoigtFallback", false, ...
    "usedPvoigtAdaptiveWindow", false, ...
    "usedPvoigtAutoWindow", false, ...
    "windowDegUsed", nan), nT, 1);

% ---------------- tracking loop ----------------
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
    % [profProc, ~] = baseline_remove(prof, opts.baselineMode, opts.baselineWin);

    % Qualitäts-/Darstellungsfenster immer aus Basis-windowDeg
    winMaskBase = r >= (peakGuessDeg - opts.windowDeg) & r <= (peakGuessDeg + opts.windowDeg);
    if nnz(winMaskBase) < 5
        continue;
    end

    rrBase = r(winMaskBase);
    yyBase = prof(winMaskBase);
    yyProcBase = profProc(winMaskBase);

    [noiseVal, snrVal] = estimate_peak_quality(yyProcBase);

    fitStore(it).gamma = g(it);
    fitStore(it).r = rrBase;
    fitStore(it).y = yyBase;
    fitStore(it).yproc = yyProcBase;
    fitStore(it).noise = noiseVal;
    fitStore(it).snr = snrVal;

    % ---------- centroid ----------
    [xc, ac, okc, errc] = fit_centroid(rrBase, yyProcBase);
    res.centroid.tth_peak_deg(it) = xc;
    res.centroid.tth_peak_err_deg(it) = errc;
    res.centroid.amp(it) = ac;
    res.centroid.noise(it) = noiseVal;
    res.centroid.snr(it) = snrVal;
    res.centroid.valid(it) = okc;
    fitStore(it).x_centroid = xc;
    fitStore(it).valid_centroid = okc;

    % ---------- gauss ----------
    if opts.useGauss
        [pg, okg, ygfit, R2g, errMuG] = fit_gauss_local(rrBase, yyProcBase);
        if okg
            sigmaOK = isfinite(pg.sigma) && ...
                      pg.sigma >= opts.gaussSigmaRangeDeg(1) && ...
                      pg.sigma <= opts.gaussSigmaRangeDeg(2);
            if ~(R2g >= opts.gaussMinR2 && sigmaOK)
                okg = false;
            end
        end

        if okg
            res.gauss.tth_peak_deg(it) = pg.mu;
            res.gauss.tth_peak_err_deg(it) = errMuG;
            res.gauss.amp(it) = pg.A;
            res.gauss.fwhm(it) = 2*sqrt(2*log(2))*pg.sigma;
            res.gauss.R2(it) = R2g;
            res.gauss.noise(it) = noiseVal;
            res.gauss.snr(it) = snrVal;
            res.gauss.valid(it) = true;

            fitStore(it).xfit_gauss = rrBase;
            fitStore(it).yfit_gauss = ygfit;
            fitStore(it).x_gauss = pg.mu;
            fitStore(it).valid_gauss = true;
        else
            res.gauss.R2(it) = R2g;
            res.gauss.noise(it) = noiseVal;
            res.gauss.snr(it) = snrVal;
        end
    end

    % ---------- pseudo-Voigt ----------
    usedAdaptiveWindow = false;
    usedAutoWindow = false;
    usedWindowDeg = opts.windowDeg;

    % adaptives Startfenster schätzen
    if opts.pvoigtAdaptiveWindow
        [windowDegAdapt, ~, okAdapt] = estimate_adaptive_window(r, profProc, peakGuessDeg, opts);
        if okAdapt
            usedAdaptiveWindow = true;
            usedWindowDeg = windowDegAdapt;
        end
    end

    winMaskPV = r >= (peakGuessDeg - usedWindowDeg) & r <= (peakGuessDeg + usedWindowDeg);
    if nnz(winMaskPV) >= 5
        rrPV = r(winMaskPV);
        yyProcPV = profProc(winMaskPV);
    else
        rrPV = rrBase;
        yyProcPV = yyProcBase;
        usedWindowDeg = opts.windowDeg;
        usedAdaptiveWindow = false;
    end

    [ppv, okpv, ypvfit, R2pv, errMuPV] = fit_pvoigt_local(rrPV, yyProcPV, peakGuessDeg, opts);
    xpvfit = rrPV;

    if okpv
        fwhmOK = isfinite(ppv.fwhm) && ...
                 ppv.fwhm >= opts.pvoigtFwhmRangeDeg(1) && ...
                 ppv.fwhm <= opts.pvoigtFwhmRangeDeg(2);
        muOK = abs(ppv.mu - peakGuessDeg) <= opts.pvoigtMuBoundDeg;
        if ~(R2pv >= opts.pvoigtMinR2 && fwhmOK && muOK)
            okpv = false;
        end
    end

    % Auto-window retry
    if ~okpv && opts.pvoigtAutoWindow && okc
        [bestRetry, foundRetry] = retry_pvoigt_with_windows(r, profProc, peakGuessDeg, opts);
        if foundRetry
            okpv = true;
            usedAutoWindow = true;
            usedAdaptiveWindow = false;
            usedWindowDeg = bestRetry.windowDeg;
            xpvfit = bestRetry.xfit;

            ppv.mu = bestRetry.mu;
            ppv.A = bestRetry.A;
            ppv.fwhm = bestRetry.fwhm;
            ppv.eta = bestRetry.eta;
            ppv.c = bestRetry.c;
            ppv.sigma = bestRetry.sigma;
            ppv.gamma = bestRetry.gamma;

            ypvfit = bestRetry.yfit;
            R2pv = bestRetry.R2;
            errMuPV = bestRetry.muErr;
        end
    end

    if ~okpv && opts.pvoigtFallbackToCentroid && okc
        res.pvoigt.tth_peak_deg(it) = xc;
        res.pvoigt.tth_peak_err_deg(it) = errc;
        res.pvoigt.amp(it) = ac;
        res.pvoigt.R2(it) = R2pv;
        res.pvoigt.noise(it) = noiseVal;
        res.pvoigt.snr(it) = snrVal;
        res.pvoigt.valid(it) = true;
        res.pvoigt.usedFallback(it) = true;
        res.pvoigt.usedAdaptiveWindow(it) = false;
        res.pvoigt.usedAutoWindow(it) = false;
        res.pvoigt.windowDegUsed(it) = nan;

        fitStore(it).x_pvoigt = xc;
        fitStore(it).valid_pvoigt = true;
        fitStore(it).usedPvoigtFallback = true;
        fitStore(it).usedPvoigtAdaptiveWindow = false;
        fitStore(it).usedPvoigtAutoWindow = false;
        fitStore(it).windowDegUsed = nan;

    elseif okpv
        res.pvoigt.tth_peak_deg(it) = ppv.mu;
        res.pvoigt.tth_peak_err_deg(it) = errMuPV;
        res.pvoigt.amp(it) = ppv.A;
        res.pvoigt.fwhm(it) = ppv.fwhm;
        res.pvoigt.R2(it) = R2pv;
        res.pvoigt.noise(it) = noiseVal;
        res.pvoigt.snr(it) = snrVal;
        res.pvoigt.valid(it) = true;
        res.pvoigt.usedAdaptiveWindow(it) = usedAdaptiveWindow;
        res.pvoigt.usedAutoWindow(it) = usedAutoWindow;
        res.pvoigt.windowDegUsed(it) = usedWindowDeg;

        fitStore(it).xfit_pvoigt = xpvfit;
        fitStore(it).yfit_pvoigt = ypvfit;
        fitStore(it).x_pvoigt = ppv.mu;
        fitStore(it).valid_pvoigt = true;
        fitStore(it).usedPvoigtFallback = false;
        fitStore(it).usedPvoigtAdaptiveWindow = usedAdaptiveWindow;
        fitStore(it).usedPvoigtAutoWindow = usedAutoWindow;
        fitStore(it).windowDegUsed = usedWindowDeg;

    else
        res.pvoigt.R2(it) = R2pv;
        res.pvoigt.noise(it) = noiseVal;
        res.pvoigt.snr(it) = snrVal;
    end
end

% ---------------- plots ----------------
if opts.doPlot
    figure;
    hold on; grid on;
    plot(r, Iprof, '-', 'DisplayName', 'raw');
    plot(r, IprofSm, '-', 'DisplayName', 'smoothed');
    plot(r, IprofProc, '-', 'DisplayName', 'processed');
    xline(peakGuessDeg, '--', 'DisplayName', 'peak guess');
    xlabel('2\theta / radial');
    ylabel('intensity');
    title('\chi-integriertes Profil zur Peakdefinition');
    legend('Location','best');

    figure;
    hold on; grid on;
    plot(g(res.centroid.valid), res.centroid.tth_peak_deg(res.centroid.valid), 'k.-', 'DisplayName', 'centroid');
    if opts.useGauss
        plot(g(res.gauss.valid), res.gauss.tth_peak_deg(res.gauss.valid), 'r.-', 'DisplayName', 'gauss');
    end
    plot(g(res.pvoigt.valid), res.pvoigt.tth_peak_deg(res.pvoigt.valid), 'b.-', 'DisplayName', 'pVoigt');
    xlabel('\gamma / \chi (deg)');
    ylabel('2\theta_{peak} (deg)');
    title(sprintf('Methodenvergleich Peaktracking (guess %.4f°)', peakGuessDeg));
    legend('Location','best');

    figure;
    hold on; grid on;
    plot_relative_series(g, res.centroid.tth_peak_deg, res.centroid.valid, 'k.-', 'centroid');
    if opts.useGauss
        plot_relative_series(g, res.gauss.tth_peak_deg, res.gauss.valid, 'r.-', 'gauss');
    end
    plot_relative_series(g, res.pvoigt.tth_peak_deg, res.pvoigt.valid, 'b.-', 'pVoigt');
    xlabel('\gamma / \chi (deg)');
    ylabel('\Delta 2\theta (deg)');
    title('Methodenvergleich relativ zum jeweiligen Mittelwert');
    legend('Location','best');

    figure;
    hold on; grid on;
    errorbar(g(res.centroid.valid), res.centroid.tth_peak_deg(res.centroid.valid), ...
             res.centroid.tth_peak_err_deg(res.centroid.valid), 'k.-', 'DisplayName', 'centroid');
    if opts.useGauss
        errorbar(g(res.gauss.valid), res.gauss.tth_peak_deg(res.gauss.valid), ...
                 res.gauss.tth_peak_err_deg(res.gauss.valid), 'r.-', 'DisplayName', 'gauss');
    end
    errorbar(g(res.pvoigt.valid), res.pvoigt.tth_peak_deg(res.pvoigt.valid), ...
             res.pvoigt.tth_peak_err_deg(res.pvoigt.valid), 'b.-', 'DisplayName', 'pVoigt');
    xlabel('\gamma / \chi (deg)');
    ylabel('2\theta_{peak} (deg)');
    title('Peaklagen mit Fehlerbalken');
    legend('Location','best');

    figure;
    hold on; grid on;
    plot(g, res.centroid.snr, 'k.-', 'DisplayName', 'centroid');
    if opts.useGauss
        plot(g, res.gauss.snr, 'r.-', 'DisplayName', 'gauss');
    end
    plot(g, res.pvoigt.snr, 'b.-', 'DisplayName', 'pVoigt');
    xlabel('\gamma / \chi (deg)');
    ylabel('SNR');
    title('Signal-zu-Rauschen pro Profil');
    legend('Location','best');

    if opts.plotFits
        plot_fit_samples(fitStore, res, opts);
    end
end

res.fitStore = fitStore;

end

% =====================================================================
% adaptive window
% =====================================================================

function [windowDegAdapt, fwhmEst, ok] = estimate_adaptive_window(r, profProc, peakGuessDeg, opts)
windowDegAdapt = nan;
fwhmEst = nan;
ok = false;

winMask = r >= (peakGuessDeg - opts.windowDeg) & r <= (peakGuessDeg + opts.windowDeg);
if nnz(winMask) < 7
    return;
end

xx = r(winMask);
yy = profProc(winMask);

[fwhmEst, ~, okF] = estimate_peak_width_local(xx, yy, peakGuessDeg);
if ~okF
    return;
end

windowDegAdapt = opts.pvoigtAdaptiveWindowFactor * fwhmEst;
windowDegAdapt = max(opts.pvoigtAdaptiveWindowMinDeg, windowDegAdapt);
windowDegAdapt = min(opts.pvoigtAdaptiveWindowMaxDeg, windowDegAdapt);

ok = isfinite(windowDegAdapt) && windowDegAdapt > 0;
end

function [fwhmEst, peakPosEst, ok] = estimate_peak_width_local(x, y, peakGuessDeg)
x = x(:);
y = y(:);
ok = false;
fwhmEst = nan;
peakPosEst = nan;

if numel(x) < 5 || numel(y) < 5 || all(~isfinite(y))
    return;
end

[~, idx0] = min(abs(x - peakGuessDeg));
lo = max(1, idx0 - 5);
hi = min(numel(x), idx0 + 5);

[peakAmp, im] = max(y(lo:hi));
im = lo + im - 1;

if ~isfinite(peakAmp) || peakAmp <= 0
    return;
end

peakPosEst = x(im);
halfLevel = 0.5 * peakAmp;

iL = im;
while iL > 1 && y(iL) > halfLevel
    iL = iL - 1;
end

iR = im;
while iR < numel(x) && y(iR) > halfLevel
    iR = iR + 1;
end

if iL == 1 || iR == numel(x) || iR <= iL
    return;
end

xL = interp_halfheight(x(iL), y(iL), x(iL+1), y(iL+1), halfLevel);
xR = interp_halfheight(x(iR-1), y(iR-1), x(iR), y(iR), halfLevel);

if ~isfinite(xL) || ~isfinite(xR) || xR <= xL
    return;
end

fwhmEst = xR - xL;
ok = isfinite(fwhmEst) && fwhmEst > 0;
end

function xh = interp_halfheight(x1, y1, x2, y2, yh)
if ~isfinite(x1) || ~isfinite(x2) || ~isfinite(y1) || ~isfinite(y2) || y2 == y1
    xh = nan;
    return;
end
xh = x1 + (yh - y1) * (x2 - x1) / (y2 - y1);
end

% =====================================================================
% auto-window retry
% =====================================================================

function [best, found] = retry_pvoigt_with_windows(r, profProc, peakGuessDeg, opts)
best = struct( ...
    "mu", nan, ...
    "muErr", nan, ...
    "A", nan, ...
    "fwhm", nan, ...
    "R2", nan, ...
    "xfit", [], ...
    "yfit", [], ...
    "windowDeg", nan, ...
    "eta", nan, ...
    "c", nan, ...
    "sigma", nan, ...
    "gamma", nan);

found = false;

cand = opts.pvoigtWindowCandidates(:).';
if isempty(cand)
    return;
end

bestScore = -inf;

for w = cand
    winMask = r >= (peakGuessDeg - w) & r <= (peakGuessDeg + w);
    if nnz(winMask) < 5
        continue;
    end

    xx = r(winMask);
    yy = profProc(winMask);

    [ppv, okpv, ypvfit, R2pv, errMuPV] = fit_pvoigt_local(xx, yy, peakGuessDeg, opts);
    if ~okpv
        continue;
    end

    fwhmOK = isfinite(ppv.fwhm) && ...
             ppv.fwhm >= opts.pvoigtFwhmRangeDeg(1) && ...
             ppv.fwhm <= opts.pvoigtFwhmRangeDeg(2);
    muOK = abs(ppv.mu - peakGuessDeg) <= opts.pvoigtMuBoundDeg;
    r2OK = isfinite(R2pv) && (R2pv >= opts.pvoigtMinR2);

    if ~(fwhmOK && muOK && r2OK)
        continue;
    end

    if opts.pvoigtAutoWindowUseBestR2
        score = R2pv;
    else
        score = -abs(ppv.mu - peakGuessDeg);
    end

    if score > bestScore
        bestScore = score;
        best.mu = ppv.mu;
        best.muErr = errMuPV;
        best.A = ppv.A;
        best.fwhm = ppv.fwhm;
        best.R2 = R2pv;
        best.xfit = xx;
        best.yfit = ypvfit;
        best.windowDeg = w;
        best.eta = ppv.eta;
        best.c = ppv.c;
        best.sigma = ppv.sigma;
        best.gamma = ppv.gamma;
        found = true;
    end
end
end

% =====================================================================
% helpers
% =====================================================================

function s = setd(s, f, v)
if ~isfield(s, f) || isempty(s.(f))
    s.(f) = v;
end
end

function S = init_method_struct(n)
S = struct();
S.tth_peak_deg = nan(n,1);
S.tth_peak_err_deg = nan(n,1);
S.amp = nan(n,1);
S.fwhm = nan(n,1);
S.R2 = nan(n,1);
S.noise = nan(n,1);
S.snr = nan(n,1);
S.valid = false(n,1);
S.usedFallback = false(n,1);
S.usedAdaptiveWindow = false(n,1);
S.usedAutoWindow = false(n,1);
S.windowDegUsed = nan(n,1);
end

function y = smooth1(x, w)
x = x(:);
w = max(1, round(w));
if mod(w,2)==0, w = w + 1; end
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
        if mod(win,2)==0, win = win + 1; end
        base = movmin(y, win);
        yproc = y - base;
        yproc(yproc < 0) = 0;
    otherwise
        error("Unknown baselineMode: %s", string(mode));
end
end

function idx = nearest_index(x, xq)
x = x(:);
xq = xq(:);
idx = zeros(size(xq));
for i = 1:numel(xq)
    [~, idx(i)] = min(abs(x - xq(i)));
end
end

function [noise, snrVal] = estimate_peak_quality(y)
y = y(:);
noise = nan;
snrVal = nan;

if isempty(y) || all(~isfinite(y))
    return;
end

ym = median(y, 'omitnan');
madVal = median(abs(y - ym), 'omitnan');

noise = 1.4826 * madVal;
if ~isfinite(noise) || noise <= 0
    noise = std(y, 'omitnan');
end
if ~isfinite(noise) || noise <= 0
    noise = eps;
end

peakHeight = max(y, [], 'omitnan');
snrVal = peakHeight / noise;
end

function [xc, amp, ok, err] = fit_centroid(x, y)
x = x(:); y = y(:);
ok = false;
xc = nan; amp = nan; err = nan;

if isempty(x) || isempty(y) || all(~isfinite(y))
    return;
end

[a, im] = max(y);
if ~isfinite(a) || a <= 0
    return;
end

thr = 0.5 * a;
msk = y >= thr;
if nnz(msk) >= 3
    yy = y(msk);
    xx = x(msk);
    xc = sum(xx .* yy) / sum(yy);

    varw = sum(yy .* (xx - xc).^2) / sum(yy);
    err = sqrt(max(varw,0)) / sqrt(nnz(msk));
else
    xc = x(im);
    dx = mean(diff(x), 'omitnan');
    if ~isfinite(dx), dx = 0; end
    err = abs(dx);
end
amp = a;
ok = isfinite(xc);
end

function [p, ok, yfit, R2, errMu] = fit_gauss_local(x, y)
x = x(:); y = y(:);
ok = false;
R2 = nan;
errMu = nan;
yfit = nan(size(y));
p = struct("A",nan,"mu",nan,"sigma",nan,"c",nan);

try
    if numel(x) < 5 || max(y) <= 0
        return;
    end

    c0 = max(0, min(y));
    y0 = y - c0;
    y0(y0 < 0) = 0;

    [A0, im] = max(y0);
    mu0 = x(im);

    half = 0.5 * A0;
    msk = y0 >= half;
    if nnz(msk) >= 3
        sigma0 = (max(x(msk)) - min(x(msk))) / 2.355;
    else
        sigma0 = max((max(x)-min(x))/8, eps);
    end
    sigma0 = max(sigma0, eps);

    model = @(b,xx) b(1) * exp(-(xx-b(2)).^2 ./ (2*b(3)^2)) + b(4);

    b0 = [A0, mu0, sigma0, c0];
    lb = [0, min(x), eps, 0];
    ub = [Inf, max(x), max(x)-min(x), Inf];

    lsqOpts = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxFunctionEvaluations', 5000, ...
        'MaxIterations', 500);

    [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);

    p.A = b(1);
    p.mu = b(2);
    p.sigma = b(3);
    p.c = b(4);

    yfit = model(b, x);
    R2 = calc_r2(y, yfit);
    ok = isfinite(p.mu) && isfinite(p.sigma) && p.sigma > 0;

    if ok
        errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
    end
catch
end
end

function [p, ok, yfit, R2, errMu] = fit_pvoigt_local(x, y, muExpected, opts)
x = x(:); y = y(:);
ok = false;
R2 = nan;
errMu = nan;
yfit = nan(size(y));
p = struct("A",nan,"mu",nan,"sigma",nan,"gamma",nan,"eta",nan,"c",nan,"fwhm",nan);

try
    if numel(x) < 5 || max(y) <= 0
        return;
    end

    c0 = max(0, min(y));
    y0 = y - c0;
    y0(y0 < 0) = 0;

    idxExp = nearest_index(x, muExpected);
    lo = max(1, idxExp-2);
    hi = min(numel(x), idxExp+2);
    [A0, im0] = max(y0(lo:hi));
    im0 = lo + im0 - 1;

    if ~isfinite(A0) || A0 <= 0
        [A0, im0] = max(y0);
        if ~isfinite(A0) || A0 <= 0
            return;
        end
    end

    mu0 = x(im0);
    xSpan = max(x) - min(x);
    fwhm0 = max(xSpan/6, eps);
    sigma0 = max(fwhm0 / (2*sqrt(2*log(2))), eps);
    gamma0 = max(fwhm0 / 2, eps);

    lsqOpts = optimoptions('lsqcurvefit', ...
        'Display','off', ...
        'MaxFunctionEvaluations', 8000, ...
        'MaxIterations', 800);

    fixedEta = [];
    if ~isempty(opts.pvoigtFixedEta)
        fixedEta = min(max(opts.pvoigtFixedEta, 0), 1);
    end

    muLo = max(min(x), muExpected - opts.pvoigtMuBoundDeg);
    muHi = min(max(x), muExpected + opts.pvoigtMuBoundDeg);

    if isempty(fixedEta)
        model = @(b,xx) b(6) + b(1) .* ...
            ( b(5) .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
             (1-b(5)) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );

        b0 = [A0, mu0, sigma0, gamma0, 0.5, c0];
        lb = [0, muLo, eps, eps, 0, 0];
        ub = [Inf, muHi, xSpan, xSpan, 1, Inf];

        [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);

        p.A = b(1);
        p.mu = b(2);
        p.sigma = b(3);
        p.gamma = b(4);
        p.eta = b(5);
        p.c = b(6);

        yfit = model(b, x);
        errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
    else
        etaFix = fixedEta;
        model = @(b,xx) b(5) + b(1) .* ...
            ( etaFix .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
             (1-etaFix) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );

        b0 = [A0, mu0, sigma0, gamma0, c0];
        lb = [0, muLo, eps, eps, 0];
        ub = [Inf, muHi, xSpan, xSpan, Inf];

        [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);

        p.A = b(1);
        p.mu = b(2);
        p.sigma = b(3);
        p.gamma = b(4);
        p.eta = etaFix;
        p.c = b(5);

        yfit = model(b, x);
        errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
    end

    % fwhmG = 2 * sqrt(2*log(2)) * p.sigma;
    % fwhmL = 2 * p.gamma;
    % p.fwhm = p.eta * fwhmL + (1-p.eta) * fwhmG;

    % NEU - Thompson-Cox-Hastings Näherung:
    fwhmG = 2 * sqrt(2*log(2)) * p.sigma;
    fwhmL = 2 * p.gamma;
    p.fwhm = (fwhmG^5 + ...
              2.69269 * fwhmG^4 * fwhmL + ...
              2.42843 * fwhmG^3 * fwhmL^2 + ...
              4.47163 * fwhmG^2 * fwhmL^3 + ...
              0.07842 * fwhmG   * fwhmL^4 + ...
              fwhmL^5)^0.2;
    
    % Sicherheitscheck falls Näherung numerisch instabil wird
    if ~isfinite(p.fwhm) || p.fwhm <= 0
        % Fallback auf lineare Näherung
        p.fwhm = p.eta * fwhmL + (1-p.eta) * fwhmG;
    end

    R2 = calc_r2(y, yfit);
    ok = isfinite(p.mu) && isfinite(p.fwhm) && p.fwhm > 0;
catch
end
end

% function errParam = stderr_from_jacobian(J, residual, nObs, nPar, parIdx)
% errParam = nan;
% try
%     if isempty(J) || size(J,1) <= nPar
%         return;
%     end
% 
%     mse = sum(residual.^2) / max(nObs - nPar, 1);
%     JTJ = J' * J;
%     if rcond(JTJ) < 1e-12
%         return;
%     end
% 
%     Cov = mse * inv(JTJ);
%     if parIdx <= size(Cov,1) && Cov(parIdx,parIdx) > 0
%         errParam = sqrt(Cov(parIdx,parIdx));
%     end
% catch
% end
% end

function errParam = stderr_from_jacobian(J, residual, nObs, nPar, parIdx)
errParam = nan;
try
    if isempty(J) || size(J,1) <= nPar
        return;
    end

    mse = sum(residual.^2) / max(nObs - nPar, 1);

    JTJ = full(J' * J);

    % pinv statt inv - robust gegen fast-singuläre Matrizen
    % rcond-Check entfällt dadurch
    Cov = mse * pinv(JTJ);

    if parIdx <= size(Cov,1) && Cov(parIdx,parIdx) > 0
        errParam = sqrt(Cov(parIdx,parIdx));
    end
catch
end
end

function R2 = calc_r2(y, yfit)
y = y(:); yfit = yfit(:);
ssRes = sum((y - yfit).^2);
ssTot = sum((y - mean(y,'omitnan')).^2);
if ssTot <= 0
    R2 = nan;
else
    R2 = 1 - ssRes / ssTot;
end
end

function plot_relative_series(g, y, valid, sty, labelTxt)
if ~any(valid), return; end
y0 = mean(y(valid), 'omitnan');
dy = y - y0;
plot(g(valid), dy(valid), sty, 'DisplayName', labelTxt);
end

function plot_fit_samples(fitStore, res, opts)
validAny = res.centroid.valid | res.pvoigt.valid;
if opts.useGauss
    validAny = validAny | res.gauss.valid;
end

idx = find(validAny);
if isempty(idx)
    return;
end

nShow = min(opts.fitSampleCount, numel(idx));
pick = unique(round(linspace(1, numel(idx), nShow)));
idxShow = idx(pick);

figure;
tiledlayout('flow');
for k = 1:numel(idxShow)
    i = idxShow(k);
    nexttile; hold on; grid on;
    plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
    if fitStore(i).valid_centroid
        xline(fitStore(i).x_centroid, 'r-');
    end
    xlabel('2\theta'); ylabel('I');
    title(sprintf('centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
end

if opts.useGauss
    figure;
    tiledlayout('flow');
    for k = 1:numel(idxShow)
        i = idxShow(k);
        nexttile; hold on; grid on;
        plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
        if fitStore(i).valid_gauss && ~isempty(fitStore(i).yfit_gauss)
            if ~isempty(fitStore(i).xfit_gauss) && numel(fitStore(i).xfit_gauss) == numel(fitStore(i).yfit_gauss)
                plot(fitStore(i).xfit_gauss, fitStore(i).yfit_gauss, 'r-');
            end
            xline(fitStore(i).x_gauss, 'b-');
        end
        xlabel('2\theta'); ylabel('I');
        title(sprintf('gauss, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
    end
end

figure;
tiledlayout('flow');
for k = 1:numel(idxShow)
    i = idxShow(k);
    nexttile; hold on; grid on;
    plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
    if fitStore(i).valid_pvoigt
        if ~fitStore(i).usedPvoigtFallback && ~isempty(fitStore(i).yfit_pvoigt)
            if ~isempty(fitStore(i).xfit_pvoigt) && numel(fitStore(i).xfit_pvoigt) == numel(fitStore(i).yfit_pvoigt)
                plot(fitStore(i).xfit_pvoigt, fitStore(i).yfit_pvoigt, 'r-');
            end
        end
        xline(fitStore(i).x_pvoigt, 'b-');
    end
    xlabel('2\theta'); ylabel('I');
    if fitStore(i).usedPvoigtFallback
        title(sprintf('pVoigt->centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
    elseif fitStore(i).usedPvoigtAutoWindow
        title(sprintf('pVoigt(auto w=%.3f), \\chi=%.1f°, SNR=%.2f', ...
            fitStore(i).windowDegUsed, fitStore(i).gamma, fitStore(i).snr));
    elseif fitStore(i).usedPvoigtAdaptiveWindow
        title(sprintf('pVoigt(adapt w=%.3f), \\chi=%.1f°, SNR=%.2f', ...
            fitStore(i).windowDegUsed, fitStore(i).gamma, fitStore(i).snr));
    else
        title(sprintf('pVoigt, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
    end
end
end


% function res = pyfai_peak_tracking_compare_methods(out, peakGuessDeg, opts)
% %PYFAI_PEAK_TRACKING_COMPARE_METHODS
% % Vergleicht centroid, gauss und pseudo-Voigt Peaktracking auf pyFAI-Output.
% %
% % INPUT
% %   out.I         : [nRad x nChi] oder [nChi x nRad]
% %   out.radial    : radiale Achse (typ. 2theta)
% %   out.azimuthal : chi/gamma-Achse
% %   peakGuessDeg  : erwartete Peaklage auf radialer Achse
% %
% % OPTIONS
% %   opts.profileChiRange          = [] oder [chiMin chiMax]
% %   opts.trackChiRange            = [] oder [chiMin chiMax]
% %   opts.trackChiBin              = 1
% %   opts.trackChiAvgBins          = 1
% %   opts.windowDeg                = 0.8
% %   opts.smoothPoints             = 5
% %   opts.useLog                   = false
% %   opts.baselineMode             = "none" | "movmin"
% %   opts.baselineWin              = 51
% %
% %   opts.doPlot                   = true
% %   opts.plotFits                 = true
% %   opts.fitSampleCount           = 9
% %
% %   opts.useGauss                 = true
% %   opts.gaussMinR2               = 0.98
% %   opts.gaussSigmaRangeDeg       = [0.01 0.50]
% %
% %   opts.pvoigtFixedEta           = [] oder z.B. 0.5
% %   opts.pvoigtFallbackToCentroid = true
% %   opts.pvoigtMinR2              = 0.98
% %   opts.pvoigtFwhmRangeDeg       = [0.01 0.50]
% %   opts.pvoigtMuBoundDeg         = 0.15
% %
% %   opts.pvoigtAutoWindow         = false
% %   opts.pvoigtWindowCandidates   = []
% %   opts.pvoigtAutoWindowUseBestR2 = true
% %
% % OUTPUT
% %   res.profile
% %   res.gamma_deg
% %   res.centroid / res.gauss / res.pvoigt
% %
% % Fehler der Peaklage:
% %   res.<method>.tth_peak_err_deg
% %
% % Qualitätsmaße:
% %   res.<method>.noise
% %   res.<method>.snr
% %
% % pVoigt Zusatzfelder:
% %   res.pvoigt.usedFallback
% %   res.pvoigt.usedAutoWindow
% %   res.pvoigt.windowDegUsed
% 
% if nargin < 3 || isempty(opts)
%     opts = struct();
% end
% 
% opts = setd(opts, "profileChiRange", []);
% opts = setd(opts, "trackChiRange", []);
% opts = setd(opts, "trackChiBin", 1);
% opts = setd(opts, "trackChiAvgBins", 1);
% 
% opts = setd(opts, "windowDeg", 0.8);
% opts = setd(opts, "smoothPoints", 5);
% opts = setd(opts, "useLog", false);
% opts = setd(opts, "baselineMode", "none");
% opts = setd(opts, "baselineWin", 51);
% 
% opts = setd(opts, "doPlot", true);
% opts = setd(opts, "plotFits", true);
% opts = setd(opts, "fitSampleCount", 9);
% 
% opts = setd(opts, "useGauss", true);
% opts = setd(opts, "gaussMinR2", 0.98);
% opts = setd(opts, "gaussSigmaRangeDeg", [0.01 0.50]);
% 
% opts = setd(opts, "pvoigtFixedEta", []);
% opts = setd(opts, "pvoigtFallbackToCentroid", true);
% opts = setd(opts, "pvoigtMinR2", 0.98);
% opts = setd(opts, "pvoigtFwhmRangeDeg", [0.01 0.50]);
% opts = setd(opts, "pvoigtMuBoundDeg", 0.15);
% 
% opts = setd(opts, "pvoigtAutoWindow", false);
% opts = setd(opts, "pvoigtWindowCandidates", []);
% opts = setd(opts, "pvoigtAutoWindowUseBestR2", true);
% 
% % ---------------- normalize input ----------------
% I = out.I;
% r = out.radial(:);
% chi = out.azimuthal(:);
% 
% nRad = numel(r);
% nChi = numel(chi);
% sz = size(I);
% 
% if isequal(sz, [nRad nChi])
%     % ok
% elseif isequal(sz, [nChi nRad])
%     I = I.';
% else
%     error("Dimension mismatch: size(out.I)=[%d %d], numel(radial)=%d, numel(azimuthal)=%d", ...
%         sz(1), sz(2), nRad, nChi);
% end
% 
% if nRad >= 2 && r(2) < r(1)
%     r = flipud(r);
%     I = flipud(I);
% end
% if nChi >= 2 && chi(2) < chi(1)
%     chi = flipud(chi);
%     I = fliplr(I);
% end
% 
% % ---------------- 1D profile for peak context ----------------
% profileMask = true(nChi,1);
% if ~isempty(opts.profileChiRange)
%     profileMask = chi >= opts.profileChiRange(1) & chi <= opts.profileChiRange(2);
% end
% profileIdx = find(profileMask);
% if isempty(profileIdx)
%     error("opts.profileChiRange selects no chi bins.");
% end
% 
% Iprof = mean(I(:, profileIdx), 2);
% IprofSm = smooth1(Iprof, opts.smoothPoints);
% [IprofProc, baseProf] = baseline_remove(IprofSm, opts.baselineMode, opts.baselineWin);
% 
% % ---------------- tracking chi selection ----------------
% trackMask = true(nChi,1);
% if ~isempty(opts.trackChiRange)
%     trackMask = chi >= opts.trackChiRange(1) & chi <= opts.trackChiRange(2);
% end
% trackIdxAll = find(trackMask);
% if isempty(trackIdxAll)
%     error("opts.trackChiRange selects no chi bins.");
% end
% trackIdx = trackIdxAll(1:opts.trackChiBin:end);
% g = chi(trackIdx);
% 
% % ---------------- result containers ----------------
% nT = numel(trackIdx);
% 
% res = struct();
% res.profile.radial = r;
% res.profile.raw = Iprof;
% res.profile.smoothed = IprofSm;
% res.profile.processed = IprofProc;
% res.profile.baseline = baseProf;
% res.profile.peakGuessDeg = peakGuessDeg;
% res.profile.profileChiRange = opts.profileChiRange;
% res.profile.trackChiRange = opts.trackChiRange;
% res.gamma_deg = g(:);
% 
% res.centroid = init_method_struct(nT);
% res.gauss    = init_method_struct(nT);
% res.pvoigt   = init_method_struct(nT);
% 
% res.centroid.method = "centroid";
% res.gauss.method    = "gauss";
% res.pvoigt.method   = "pvoigt";
% 
% fitStore = repmat(struct( ...
%     "gamma", nan, ...
%     "r", [], ...
%     "y", [], ...
%     "yproc", [], ...
%     "noise", nan, ...
%     "snr", nan, ...
%     "xfit_gauss", [], ...
%     "yfit_gauss", [], ...
%     "xfit_pvoigt", [], ...
%     "yfit_pvoigt", [], ...
%     "x_centroid", nan, ...
%     "x_gauss", nan, ...
%     "x_pvoigt", nan, ...
%     "valid_centroid", false, ...
%     "valid_gauss", false, ...
%     "valid_pvoigt", false, ...
%     "usedPvoigtFallback", false, ...
%     "usedPvoigtAutoWindow", false, ...
%     "windowDegUsed", nan), nT, 1);
% 
% % ---------------- tracking loop ----------------
% for it = 1:nT
%     c0 = trackIdx(it);
%     cLo = max(1, c0 - opts.trackChiAvgBins);
%     cHi = min(nChi, c0 + opts.trackChiAvgBins);
% 
%     prof = mean(I(:, cLo:cHi), 2);
%     profSm = smooth1(prof, opts.smoothPoints);
% 
%     if opts.useLog
%         profSm = log10(max(profSm, 0) + 1);
%     end
% 
%     [profProc, ~] = baseline_remove(profSm, opts.baselineMode, opts.baselineWin);
% 
%     winMask = r >= (peakGuessDeg - opts.windowDeg) & r <= (peakGuessDeg + opts.windowDeg);
%     if nnz(winMask) < 5
%         continue;
%     end
% 
%     rr = r(winMask);
%     yy = prof(winMask);
%     yyProc = profProc(winMask);
% 
%     [noiseVal, snrVal] = estimate_peak_quality(yyProc);
% 
%     fitStore(it).gamma = g(it);
%     fitStore(it).r = rr;
%     fitStore(it).y = yy;
%     fitStore(it).yproc = yyProc;
%     fitStore(it).noise = noiseVal;
%     fitStore(it).snr = snrVal;
% 
%     % ---------- centroid ----------
%     [xc, ac, okc, errc] = fit_centroid(rr, yyProc);
%     res.centroid.tth_peak_deg(it) = xc;
%     res.centroid.tth_peak_err_deg(it) = errc;
%     res.centroid.amp(it) = ac;
%     res.centroid.noise(it) = noiseVal;
%     res.centroid.snr(it) = snrVal;
%     res.centroid.valid(it) = okc;
%     fitStore(it).x_centroid = xc;
%     fitStore(it).valid_centroid = okc;
% 
%     % ---------- gauss ----------
%     if opts.useGauss
%         [pg, okg, ygfit, R2g, errMuG] = fit_gauss_local(rr, yyProc);
%         if okg
%             sigmaOK = isfinite(pg.sigma) && ...
%                       pg.sigma >= opts.gaussSigmaRangeDeg(1) && ...
%                       pg.sigma <= opts.gaussSigmaRangeDeg(2);
%             if ~(R2g >= opts.gaussMinR2 && sigmaOK)
%                 okg = false;
%             end
%         end
% 
%         if okg
%             res.gauss.tth_peak_deg(it) = pg.mu;
%             res.gauss.tth_peak_err_deg(it) = errMuG;
%             res.gauss.amp(it) = pg.A;
%             res.gauss.fwhm(it) = 2*sqrt(2*log(2))*pg.sigma;
%             res.gauss.R2(it) = R2g;
%             res.gauss.noise(it) = noiseVal;
%             res.gauss.snr(it) = snrVal;
%             res.gauss.valid(it) = true;
%             fitStore(it).xfit_gauss = rr;
%             fitStore(it).yfit_gauss = ygfit;
%             fitStore(it).x_gauss = pg.mu;
%             fitStore(it).valid_gauss = true;
%         else
%             res.gauss.R2(it) = R2g;
%             res.gauss.noise(it) = noiseVal;
%             res.gauss.snr(it) = snrVal;
%         end
%     end
% 
%     % ---------- pseudo-Voigt ----------
%     [ppv, okpv, ypvfit, R2pv, errMuPV] = fit_pvoigt_local(rr, yyProc, peakGuessDeg, opts);
%     xpvfit = rr;
% 
%     if okpv
%         fwhmOK = isfinite(ppv.fwhm) && ...
%                  ppv.fwhm >= opts.pvoigtFwhmRangeDeg(1) && ...
%                  ppv.fwhm <= opts.pvoigtFwhmRangeDeg(2);
%         muOK = abs(ppv.mu - peakGuessDeg) <= opts.pvoigtMuBoundDeg;
%         if ~(R2pv >= opts.pvoigtMinR2 && fwhmOK && muOK)
%             okpv = false;
%         end
%     end
% 
%     usedAutoWindow = false;
%     usedWindowDeg = opts.windowDeg;
% 
%     % Auto-window retry
%     if ~okpv && opts.pvoigtAutoWindow && okc
%         [bestRetry, foundRetry] = retry_pvoigt_with_windows(r, profProc, peakGuessDeg, opts);
%         if foundRetry
%             okpv = true;
%             usedAutoWindow = true;
%             usedWindowDeg = bestRetry.windowDeg;
%             xpvfit = bestRetry.xfit;
% 
%             ppv.mu = bestRetry.mu;
%             ppv.A = bestRetry.A;
%             ppv.fwhm = bestRetry.fwhm;
%             ppv.eta = bestRetry.eta;
%             ppv.c = bestRetry.c;
%             ppv.sigma = bestRetry.sigma;
%             ppv.gamma = bestRetry.gamma;
% 
%             ypvfit = bestRetry.yfit;
%             R2pv = bestRetry.R2;
%             errMuPV = bestRetry.muErr;
%         end
%     end
% 
%     if ~okpv && opts.pvoigtFallbackToCentroid && okc
%         res.pvoigt.tth_peak_deg(it) = xc;
%         res.pvoigt.tth_peak_err_deg(it) = errc;
%         res.pvoigt.amp(it) = ac;
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%         res.pvoigt.valid(it) = true;
%         res.pvoigt.usedFallback(it) = true;
%         res.pvoigt.usedAutoWindow(it) = false;
%         res.pvoigt.windowDegUsed(it) = nan;
% 
%         fitStore(it).x_pvoigt = xc;
%         fitStore(it).valid_pvoigt = true;
%         fitStore(it).usedPvoigtFallback = true;
%         fitStore(it).usedPvoigtAutoWindow = false;
%         fitStore(it).windowDegUsed = nan;
% 
%     elseif okpv
%         res.pvoigt.tth_peak_deg(it) = ppv.mu;
%         res.pvoigt.tth_peak_err_deg(it) = errMuPV;
%         res.pvoigt.amp(it) = ppv.A;
%         res.pvoigt.fwhm(it) = ppv.fwhm;
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%         res.pvoigt.valid(it) = true;
%         res.pvoigt.usedAutoWindow(it) = usedAutoWindow;
%         res.pvoigt.windowDegUsed(it) = usedWindowDeg;
% 
%         fitStore(it).xfit_pvoigt = xpvfit;
%         fitStore(it).yfit_pvoigt = ypvfit;
%         fitStore(it).x_pvoigt = ppv.mu;
%         fitStore(it).valid_pvoigt = true;
%         fitStore(it).usedPvoigtFallback = false;
%         fitStore(it).usedPvoigtAutoWindow = usedAutoWindow;
%         fitStore(it).windowDegUsed = usedWindowDeg;
% 
%     else
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%     end
% end
% 
% % ---------------- plots ----------------
% if opts.doPlot
%     figure;
%     hold on; grid on;
%     plot(r, Iprof, '-', 'DisplayName', 'raw');
%     plot(r, IprofSm, '-', 'DisplayName', 'smoothed');
%     plot(r, IprofProc, '-', 'DisplayName', 'processed');
%     xline(peakGuessDeg, '--', 'DisplayName', 'peak guess');
%     xlabel('2\theta / radial');
%     ylabel('intensity');
%     title('\chi-integriertes Profil zur Peakdefinition');
%     legend('Location','best');
% 
%     figure;
%     hold on; grid on;
%     plot(g(res.centroid.valid), res.centroid.tth_peak_deg(res.centroid.valid), 'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         plot(g(res.gauss.valid), res.gauss.tth_peak_deg(res.gauss.valid), 'r.-', 'DisplayName', 'gauss');
%     end
%     plot(g(res.pvoigt.valid), res.pvoigt.tth_peak_deg(res.pvoigt.valid), 'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('2\theta_{peak} (deg)');
%     title(sprintf('Methodenvergleich Peaktracking (guess %.4f°)', peakGuessDeg));
%     legend('Location','best');
% 
%     figure;
%     hold on; grid on;
%     plot_relative_series(g, res.centroid.tth_peak_deg, res.centroid.valid, 'k.-', 'centroid');
%     if opts.useGauss
%         plot_relative_series(g, res.gauss.tth_peak_deg, res.gauss.valid, 'r.-', 'gauss');
%     end
%     plot_relative_series(g, res.pvoigt.tth_peak_deg, res.pvoigt.valid, 'b.-', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('\Delta 2\theta (deg)');
%     title('Methodenvergleich relativ zum jeweiligen Mittelwert');
%     legend('Location','best');
% 
%     figure;
%     hold on; grid on;
%     errorbar(g(res.centroid.valid), ...
%              res.centroid.tth_peak_deg(res.centroid.valid), ...
%              res.centroid.tth_peak_err_deg(res.centroid.valid), ...
%              'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         errorbar(g(res.gauss.valid), ...
%                  res.gauss.tth_peak_deg(res.gauss.valid), ...
%                  res.gauss.tth_peak_err_deg(res.gauss.valid), ...
%                  'r.-', 'DisplayName', 'gauss');
%     end
%     errorbar(g(res.pvoigt.valid), ...
%              res.pvoigt.tth_peak_deg(res.pvoigt.valid), ...
%              res.pvoigt.tth_peak_err_deg(res.pvoigt.valid), ...
%              'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('2\theta_{peak} (deg)');
%     title('Peaklagen mit Fehlerbalken');
%     legend('Location','best');
% 
%     figure;
%     hold on; grid on;
%     plot(g, res.centroid.snr, 'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         plot(g, res.gauss.snr, 'r.-', 'DisplayName', 'gauss');
%     end
%     plot(g, res.pvoigt.snr, 'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('SNR');
%     title('Signal-zu-Rauschen pro Profil');
%     legend('Location','best');
% 
%     if opts.plotFits
%         plot_fit_samples(fitStore, res, opts);
%     end
% end
% 
% res.fitStore = fitStore;
% 
% end
% 
% % =====================================================================
% % Auto-window retry
% % =====================================================================
% 
% function [best, found] = retry_pvoigt_with_windows(r, profProc, peakGuessDeg, opts)
% best = struct( ...
%     "mu", nan, ...
%     "muErr", nan, ...
%     "A", nan, ...
%     "fwhm", nan, ...
%     "R2", nan, ...
%     "xfit", [], ...
%     "yfit", [], ...
%     "windowDeg", nan, ...
%     "eta", nan, ...
%     "c", nan, ...
%     "sigma", nan, ...
%     "gamma", nan);
% 
% found = false;
% 
% cand = opts.pvoigtWindowCandidates(:).';
% if isempty(cand)
%     return;
% end
% 
% bestScore = -inf;
% 
% for w = cand
%     winMask = r >= (peakGuessDeg - w) & r <= (peakGuessDeg + w);
%     if nnz(winMask) < 5
%         continue;
%     end
% 
%     xx = r(winMask);
%     yy = profProc(winMask);
% 
%     [ppv, okpv, ypvfit, R2pv, errMuPV] = fit_pvoigt_local(xx, yy, peakGuessDeg, opts);
%     if ~okpv
%         continue;
%     end
% 
%     fwhmOK = isfinite(ppv.fwhm) && ...
%              ppv.fwhm >= opts.pvoigtFwhmRangeDeg(1) && ...
%              ppv.fwhm <= opts.pvoigtFwhmRangeDeg(2);
%     muOK = abs(ppv.mu - peakGuessDeg) <= opts.pvoigtMuBoundDeg;
%     r2OK = isfinite(R2pv) && (R2pv >= opts.pvoigtMinR2);
% 
%     if ~(fwhmOK && muOK && r2OK)
%         continue;
%     end
% 
%     if opts.pvoigtAutoWindowUseBestR2
%         score = R2pv;
%     else
%         score = -abs(ppv.mu - peakGuessDeg);
%     end
% 
%     if score > bestScore
%         bestScore = score;
%         best.mu = ppv.mu;
%         best.muErr = errMuPV;
%         best.A = ppv.A;
%         best.fwhm = ppv.fwhm;
%         best.R2 = R2pv;
%         best.xfit = xx;
%         best.yfit = ypvfit;
%         best.windowDeg = w;
%         best.eta = ppv.eta;
%         best.c = ppv.c;
%         best.sigma = ppv.sigma;
%         best.gamma = ppv.gamma;
%         found = true;
%     end
% end
% end
% 
% % =====================================================================
% % helpers
% % =====================================================================
% 
% function s = setd(s, f, v)
% if ~isfield(s, f) || isempty(s.(f))
%     s.(f) = v;
% end
% end
% 
% function S = init_method_struct(n)
% S = struct();
% S.tth_peak_deg = nan(n,1);
% S.tth_peak_err_deg = nan(n,1);
% S.amp = nan(n,1);
% S.fwhm = nan(n,1);
% S.R2 = nan(n,1);
% S.noise = nan(n,1);
% S.snr = nan(n,1);
% S.valid = false(n,1);
% S.usedFallback = false(n,1);
% S.usedAutoWindow = false(n,1);
% S.windowDegUsed = nan(n,1);
% end
% 
% function y = smooth1(x, w)
% x = x(:);
% w = max(1, round(w));
% if mod(w,2)==0, w = w + 1; end
% if w == 1
%     y = x;
%     return;
% end
% k = ones(w,1) / w;
% y = conv(x, k, 'same');
% end
% 
% function [yproc, base] = baseline_remove(y, mode, win)
% y = y(:);
% switch lower(string(mode))
%     case "none"
%         base = zeros(size(y));
%         yproc = y;
%     case "movmin"
%         win = max(5, round(win));
%         if mod(win,2)==0, win = win + 1; end
%         base = movmin(y, win);
%         yproc = y - base;
%         yproc(yproc < 0) = 0;
%     otherwise
%         error("Unknown baselineMode: %s", string(mode));
% end
% end
% 
% function idx = nearest_index(x, xq)
% x = x(:);
% xq = xq(:);
% idx = zeros(size(xq));
% for i = 1:numel(xq)
%     [~, idx(i)] = min(abs(x - xq(i)));
% end
% end
% 
% function [noise, snrVal] = estimate_peak_quality(y)
% y = y(:);
% noise = nan;
% snrVal = nan;
% 
% if isempty(y) || all(~isfinite(y))
%     return;
% end
% 
% ym = median(y, 'omitnan');
% madVal = median(abs(y - ym), 'omitnan');
% 
% noise = 1.4826 * madVal;
% if ~isfinite(noise) || noise <= 0
%     noise = std(y, 'omitnan');
% end
% if ~isfinite(noise) || noise <= 0
%     noise = eps;
% end
% 
% peakHeight = max(y, [], 'omitnan');
% snrVal = peakHeight / noise;
% end
% 
% function [xc, amp, ok, err] = fit_centroid(x, y)
% x = x(:); y = y(:);
% ok = false;
% xc = nan; amp = nan; err = nan;
% 
% if isempty(x) || isempty(y) || all(~isfinite(y))
%     return;
% end
% 
% [a, im] = max(y);
% if ~isfinite(a) || a <= 0
%     return;
% end
% 
% thr = 0.5 * a;
% msk = y >= thr;
% if nnz(msk) >= 3
%     yy = y(msk);
%     xx = x(msk);
%     xc = sum(xx .* yy) / sum(yy);
% 
%     varw = sum(yy .* (xx - xc).^2) / sum(yy);
%     err = sqrt(max(varw,0)) / sqrt(nnz(msk));
% else
%     xc = x(im);
%     dx = mean(diff(x), 'omitnan');
%     if ~isfinite(dx), dx = 0; end
%     err = abs(dx);
% end
% amp = a;
% ok = isfinite(xc);
% end
% 
% function [p, ok, yfit, R2, errMu] = fit_gauss_local(x, y)
% x = x(:); y = y(:);
% ok = false;
% R2 = nan;
% errMu = nan;
% yfit = nan(size(y));
% p = struct("A",nan,"mu",nan,"sigma",nan,"c",nan);
% 
% try
%     if numel(x) < 5 || max(y) <= 0
%         return;
%     end
% 
%     c0 = max(0, min(y));
%     y0 = y - c0;
%     y0(y0 < 0) = 0;
% 
%     [A0, im] = max(y0);
%     mu0 = x(im);
% 
%     half = 0.5 * A0;
%     msk = y0 >= half;
%     if nnz(msk) >= 3
%         sigma0 = (max(x(msk)) - min(x(msk))) / 2.355;
%     else
%         sigma0 = max((max(x)-min(x))/8, eps);
%     end
%     sigma0 = max(sigma0, eps);
% 
%     model = @(b,xx) b(1) * exp(-(xx-b(2)).^2 ./ (2*b(3)^2)) + b(4);
% 
%     b0 = [A0, mu0, sigma0, c0];
%     lb = [0, min(x), eps, 0];
%     ub = [Inf, max(x), max(x)-min(x), Inf];
% 
%     lsqOpts = optimoptions('lsqcurvefit', ...
%         'Display','off', ...
%         'MaxFunctionEvaluations', 5000, ...
%         'MaxIterations', 500);
% 
%     [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%     p.A = b(1);
%     p.mu = b(2);
%     p.sigma = b(3);
%     p.c = b(4);
% 
%     yfit = model(b, x);
%     R2 = calc_r2(y, yfit);
%     ok = isfinite(p.mu) && isfinite(p.sigma) && p.sigma > 0;
% 
%     if ok
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     end
% catch
% end
% end
% 
% function [p, ok, yfit, R2, errMu] = fit_pvoigt_local(x, y, muExpected, opts)
% x = x(:); y = y(:);
% ok = false;
% R2 = nan;
% errMu = nan;
% yfit = nan(size(y));
% p = struct("A",nan,"mu",nan,"sigma",nan,"gamma",nan,"eta",nan,"c",nan,"fwhm",nan);
% 
% try
%     if numel(x) < 5 || max(y) <= 0
%         return;
%     end
% 
%     c0 = max(0, min(y));
%     y0 = y - c0;
%     y0(y0 < 0) = 0;
% 
%     idxExp = nearest_index(x, muExpected);
%     lo = max(1, idxExp-2);
%     hi = min(numel(x), idxExp+2);
%     [A0, im0] = max(y0(lo:hi));
%     im0 = lo + im0 - 1;
% 
%     if ~isfinite(A0) || A0 <= 0
%         [A0, im0] = max(y0);
%         if ~isfinite(A0) || A0 <= 0
%             return;
%         end
%     end
% 
%     mu0 = x(im0);
%     xSpan = max(x) - min(x);
%     fwhm0 = max(xSpan/6, eps);
%     sigma0 = max(fwhm0 / (2*sqrt(2*log(2))), eps);
%     gamma0 = max(fwhm0 / 2, eps);
% 
%     lsqOpts = optimoptions('lsqcurvefit', ...
%         'Display','off', ...
%         'MaxFunctionEvaluations', 8000, ...
%         'MaxIterations', 800);
% 
%     fixedEta = [];
%     if ~isempty(opts.pvoigtFixedEta)
%         fixedEta = min(max(opts.pvoigtFixedEta, 0), 1);
%     end
% 
%     muLo = max(min(x), muExpected - opts.pvoigtMuBoundDeg);
%     muHi = min(max(x), muExpected + opts.pvoigtMuBoundDeg);
% 
%     if isempty(fixedEta)
%         % b = [A mu sigma gamma eta c]
%         model = @(b,xx) b(6) + b(1) .* ...
%             ( b(5) .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
%              (1-b(5)) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );
% 
%         b0 = [A0, mu0, sigma0, gamma0, 0.5, c0];
%         lb = [0, muLo, eps, eps, 0, 0];
%         ub = [Inf, muHi, xSpan, xSpan, 1, Inf];
% 
%         [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%         p.A = b(1);
%         p.mu = b(2);
%         p.sigma = b(3);
%         p.gamma = b(4);
%         p.eta = b(5);
%         p.c = b(6);
% 
%         yfit = model(b, x);
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     else
%         % b = [A mu sigma gamma c], eta fixed
%         etaFix = fixedEta;
%         model = @(b,xx) b(5) + b(1) .* ...
%             ( etaFix .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
%              (1-etaFix) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );
% 
%         b0 = [A0, mu0, sigma0, gamma0, c0];
%         lb = [0, muLo, eps, eps, 0];
%         ub = [Inf, muHi, xSpan, xSpan, Inf];
% 
%         [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%         p.A = b(1);
%         p.mu = b(2);
%         p.sigma = b(3);
%         p.gamma = b(4);
%         p.eta = etaFix;
%         p.c = b(5);
% 
%         yfit = model(b, x);
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     end
% 
%     fwhmG = 2 * sqrt(2*log(2)) * p.sigma;
%     fwhmL = 2 * p.gamma;
%     p.fwhm = p.eta * fwhmL + (1-p.eta) * fwhmG;
% 
%     R2 = calc_r2(y, yfit);
%     ok = isfinite(p.mu) && isfinite(p.fwhm) && p.fwhm > 0;
% catch
% end
% end
% 
% function errParam = stderr_from_jacobian(J, residual, nObs, nPar, parIdx)
% errParam = nan;
% try
%     if isempty(J) || size(J,1) <= nPar
%         return;
%     end
% 
%     mse = sum(residual.^2) / max(nObs - nPar, 1);
%     JTJ = J' * J;
%     if rcond(JTJ) < 1e-12
%         return;
%     end
% 
%     Cov = mse * inv(JTJ);
%     if parIdx <= size(Cov,1) && Cov(parIdx,parIdx) > 0
%         errParam = sqrt(Cov(parIdx,parIdx));
%     end
% catch
% end
% end
% 
% function R2 = calc_r2(y, yfit)
% y = y(:); yfit = yfit(:);
% ssRes = sum((y - yfit).^2);
% ssTot = sum((y - mean(y,'omitnan')).^2);
% if ssTot <= 0
%     R2 = nan;
% else
%     R2 = 1 - ssRes / ssTot;
% end
% end
% 
% function plot_relative_series(g, y, valid, sty, labelTxt)
% if ~any(valid), return; end
% y0 = mean(y(valid), 'omitnan');
% dy = y - y0;
% plot(g(valid), dy(valid), sty, 'DisplayName', labelTxt);
% end
% 
% function plot_fit_samples(fitStore, res, opts)
% validAny = res.centroid.valid | res.pvoigt.valid;
% if opts.useGauss
%     validAny = validAny | res.gauss.valid;
% end
% 
% idx = find(validAny);
% if isempty(idx)
%     return;
% end
% 
% nShow = min(opts.fitSampleCount, numel(idx));
% pick = unique(round(linspace(1, numel(idx), nShow)));
% idxShow = idx(pick);
% 
% figure;
% tiledlayout('flow');
% for k = 1:numel(idxShow)
%     i = idxShow(k);
%     nexttile; hold on; grid on;
%     plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%     if fitStore(i).valid_centroid
%         xline(fitStore(i).x_centroid, 'r-');
%     end
%     xlabel('2\theta'); ylabel('I');
%     title(sprintf('centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
% end
% 
% if opts.useGauss
%     figure;
%     tiledlayout('flow');
%     for k = 1:numel(idxShow)
%         i = idxShow(k);
%         nexttile; hold on; grid on;
%         plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%         if fitStore(i).valid_gauss && ~isempty(fitStore(i).yfit_gauss)
%             if ~isempty(fitStore(i).xfit_gauss) && ...
%                     numel(fitStore(i).xfit_gauss) == numel(fitStore(i).yfit_gauss)
%                 plot(fitStore(i).xfit_gauss, fitStore(i).yfit_gauss, 'r-');
%             end
%             xline(fitStore(i).x_gauss, 'b-');
%         end
%         xlabel('2\theta'); ylabel('I');
%         title(sprintf('gauss, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     end
% end
% 
% figure;
% tiledlayout('flow');
% for k = 1:numel(idxShow)
%     i = idxShow(k);
%     nexttile; hold on; grid on;
%     plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%     if fitStore(i).valid_pvoigt
%         if ~fitStore(i).usedPvoigtFallback && ~isempty(fitStore(i).yfit_pvoigt)
%             if ~isempty(fitStore(i).xfit_pvoigt) && ...
%                     numel(fitStore(i).xfit_pvoigt) == numel(fitStore(i).yfit_pvoigt)
%                 plot(fitStore(i).xfit_pvoigt, fitStore(i).yfit_pvoigt, 'r-');
%             end
%         end
%         xline(fitStore(i).x_pvoigt, 'b-');
%     end
%     xlabel('2\theta'); ylabel('I');
%     if fitStore(i).usedPvoigtFallback
%         title(sprintf('pVoigt->centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     elseif fitStore(i).usedPvoigtAutoWindow
%         title(sprintf('pVoigt(auto w=%.3f), \\chi=%.1f°, SNR=%.2f', ...
%             fitStore(i).windowDegUsed, fitStore(i).gamma, fitStore(i).snr));
%     else
%         title(sprintf('pVoigt, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     end
% end
% end

% function res = pyfai_peak_tracking_compare_methods(out, peakGuessDeg, opts)
% %PYFAI_PEAK_TRACKING_COMPARE_METHODS
% % Vergleicht centroid, gauss und pseudo-Voigt Peaktracking auf pyFAI-Output.
% %
% % INPUT
% %   out.I         : [nRad x nChi] oder [nChi x nRad]
% %   out.radial    : radiale Achse (typ. 2theta)
% %   out.azimuthal : chi/gamma-Achse
% %   peakGuessDeg  : erwartete Peaklage auf radialer Achse
% %
% % OPTIONS
% %   opts.profileChiRange          = [] oder [chiMin chiMax]
% %   opts.trackChiRange            = [] oder [chiMin chiMax]
% %   opts.trackChiBin              = 1
% %   opts.trackChiAvgBins          = 1
% %   opts.windowDeg                = 0.8
% %   opts.smoothPoints             = 5
% %   opts.useLog                   = false
% %   opts.baselineMode             = "none" | "movmin"
% %   opts.baselineWin              = 51
% %
% %   opts.doPlot                   = true
% %   opts.plotFits                 = true
% %   opts.fitSampleCount           = 9
% %
% %   opts.useGauss                 = true
% %   opts.gaussMinR2               = 0.98
% %   opts.gaussSigmaRangeDeg       = [0.01 0.50]
% %
% %   opts.pvoigtFixedEta           = [] oder z.B. 0.5
% %   opts.pvoigtFallbackToCentroid = true
% %   opts.pvoigtMinR2              = 0.98
% %   opts.pvoigtFwhmRangeDeg       = [0.01 0.50]
% %   opts.pvoigtMuBoundDeg         = 0.15
% %
% % OUTPUT
% %   res.profile
% %   res.gamma_deg
% %   res.centroid / res.gauss / res.pvoigt
% %
% % Fehler der Peaklage:
% %   res.<method>.tth_peak_err_deg
% %
% % Qualitätsmaße:
% %   res.<method>.noise
% %   res.<method>.snr
% %
% % HINWEIS
% %   "gamma" und "chi" werden hier gleich behandelt; verwendet wird out.azimuthal.
% 
% if nargin < 3 || isempty(opts)
%     opts = struct();
% end
% 
% opts = setd(opts, "profileChiRange", []);
% opts = setd(opts, "trackChiRange", []);
% opts = setd(opts, "trackChiBin", 1);
% opts = setd(opts, "trackChiAvgBins", 1);
% 
% opts = setd(opts, "windowDeg", 0.8);
% opts = setd(opts, "smoothPoints", 5);
% opts = setd(opts, "useLog", false);
% opts = setd(opts, "baselineMode", "none");
% opts = setd(opts, "baselineWin", 51);
% 
% opts = setd(opts, "doPlot", true);
% opts = setd(opts, "plotFits", true);
% opts = setd(opts, "fitSampleCount", 9);
% 
% opts = setd(opts, "useGauss", true);
% opts = setd(opts, "gaussMinR2", 0.98);
% opts = setd(opts, "gaussSigmaRangeDeg", [0.01 0.50]);
% 
% opts = setd(opts, "pvoigtFixedEta", []);
% opts = setd(opts, "pvoigtFallbackToCentroid", true);
% opts = setd(opts, "pvoigtMinR2", 0.98);
% opts = setd(opts, "pvoigtFwhmRangeDeg", [0.01 0.50]);
% opts = setd(opts, "pvoigtMuBoundDeg", 0.15);
% 
% % ---------------- normalize input ----------------
% I = out.I;
% r = out.radial(:);
% chi = out.azimuthal(:);
% 
% nRad = numel(r);
% nChi = numel(chi);
% sz = size(I);
% 
% if isequal(sz, [nRad nChi])
%     % ok
% elseif isequal(sz, [nChi nRad])
%     I = I.';
% else
%     error("Dimension mismatch: size(out.I)=[%d %d], numel(radial)=%d, numel(azimuthal)=%d", ...
%         sz(1), sz(2), nRad, nChi);
% end
% 
% if nRad >= 2 && r(2) < r(1)
%     r = flipud(r);
%     I = flipud(I);
% end
% if nChi >= 2 && chi(2) < chi(1)
%     chi = flipud(chi);
%     I = fliplr(I);
% end
% 
% % ---------------- 1D profile for peak context ----------------
% profileMask = true(nChi,1);
% if ~isempty(opts.profileChiRange)
%     profileMask = chi >= opts.profileChiRange(1) & chi <= opts.profileChiRange(2);
% end
% profileIdx = find(profileMask);
% if isempty(profileIdx)
%     error("opts.profileChiRange selects no chi bins.");
% end
% 
% Iprof = mean(I(:, profileIdx), 2);
% IprofSm = smooth1(Iprof, opts.smoothPoints);
% [IprofProc, baseProf] = baseline_remove(IprofSm, opts.baselineMode, opts.baselineWin);
% 
% % ---------------- tracking chi selection ----------------
% trackMask = true(nChi,1);
% if ~isempty(opts.trackChiRange)
%     trackMask = chi >= opts.trackChiRange(1) & chi <= opts.trackChiRange(2);
% end
% trackIdxAll = find(trackMask);
% if isempty(trackIdxAll)
%     error("opts.trackChiRange selects no chi bins.");
% end
% trackIdx = trackIdxAll(1:opts.trackChiBin:end);
% g = chi(trackIdx);
% 
% % ---------------- result containers ----------------
% nT = numel(trackIdx);
% 
% res = struct();
% res.profile.radial = r;
% res.profile.raw = Iprof;
% res.profile.smoothed = IprofSm;
% res.profile.processed = IprofProc;
% res.profile.baseline = baseProf;
% res.profile.peakGuessDeg = peakGuessDeg;
% res.profile.profileChiRange = opts.profileChiRange;
% res.profile.trackChiRange = opts.trackChiRange;
% res.gamma_deg = g(:);
% 
% res.centroid = init_method_struct(nT);
% res.gauss    = init_method_struct(nT);
% res.pvoigt   = init_method_struct(nT);
% 
% res.centroid.method = "centroid";
% res.gauss.method    = "gauss";
% res.pvoigt.method   = "pvoigt";
% 
% % fit detail storage for later plotting
% fitStore = repmat(struct( ...
%     "gamma", nan, ...
%     "r", [], ...
%     "y", [], ...
%     "yproc", [], ...
%     "noise", nan, ...
%     "snr", nan, ...
%     "yfit_gauss", [], ...
%     "yfit_pvoigt", [], ...
%     "x_centroid", nan, ...
%     "x_gauss", nan, ...
%     "x_pvoigt", nan, ...
%     "valid_centroid", false, ...
%     "valid_gauss", false, ...
%     "valid_pvoigt", false, ...
%     "usedPvoigtFallback", false), nT, 1);
% 
% % ---------------- tracking loop ----------------
% for it = 1:nT
%     c0 = trackIdx(it);
%     cLo = max(1, c0 - opts.trackChiAvgBins);
%     cHi = min(nChi, c0 + opts.trackChiAvgBins);
% 
%     prof = mean(I(:, cLo:cHi), 2);
%     profSm = smooth1(prof, opts.smoothPoints);
% 
%     if opts.useLog
%         profSm = log10(max(profSm, 0) + 1);
%     end
% 
%     [profProc, ~] = baseline_remove(profSm, opts.baselineMode, opts.baselineWin);
% 
%     % window around peak guess
%     winMask = r >= (peakGuessDeg - opts.windowDeg) & r <= (peakGuessDeg + opts.windowDeg);
%     if nnz(winMask) < 5
%         continue;
%     end
% 
%     rr = r(winMask);
%     yy = prof(winMask);
%     yyProc = profProc(winMask);
% 
%     [noiseVal, snrVal] = estimate_peak_quality(yyProc);
% 
%     fitStore(it).gamma = g(it);
%     fitStore(it).r = rr;
%     fitStore(it).y = yy;
%     fitStore(it).yproc = yyProc;
%     fitStore(it).noise = noiseVal;
%     fitStore(it).snr = snrVal;
% 
%     % ---------- centroid ----------
%     [xc, ac, okc, errc] = fit_centroid(rr, yyProc);
%     res.centroid.tth_peak_deg(it) = xc;
%     res.centroid.tth_peak_err_deg(it) = errc;
%     res.centroid.amp(it) = ac;
%     res.centroid.noise(it) = noiseVal;
%     res.centroid.snr(it) = snrVal;
%     res.centroid.valid(it) = okc;
%     fitStore(it).x_centroid = xc;
%     fitStore(it).valid_centroid = okc;
% 
%     % ---------- gauss ----------
%     if opts.useGauss
%         [pg, okg, ygfit, R2g, errMuG] = fit_gauss_local(rr, yyProc);
%         if okg
%             sigmaOK = isfinite(pg.sigma) && ...
%                       pg.sigma >= opts.gaussSigmaRangeDeg(1) && ...
%                       pg.sigma <= opts.gaussSigmaRangeDeg(2);
%             if ~(R2g >= opts.gaussMinR2 && sigmaOK)
%                 okg = false;
%             end
%         end
% 
%         if okg
%             res.gauss.tth_peak_deg(it) = pg.mu;
%             res.gauss.tth_peak_err_deg(it) = errMuG;
%             res.gauss.amp(it) = pg.A;
%             res.gauss.fwhm(it) = 2*sqrt(2*log(2))*pg.sigma;
%             res.gauss.R2(it) = R2g;
%             res.gauss.noise(it) = noiseVal;
%             res.gauss.snr(it) = snrVal;
%             res.gauss.valid(it) = true;
%             fitStore(it).yfit_gauss = ygfit;
%             fitStore(it).x_gauss = pg.mu;
%             fitStore(it).valid_gauss = true;
%         else
%             res.gauss.R2(it) = R2g;
%             res.gauss.noise(it) = noiseVal;
%             res.gauss.snr(it) = snrVal;
%         end
%     end
% 
%     % ---------- pseudo-Voigt ----------
%     [ppv, okpv, ypvfit, R2pv, errMuPV] = fit_pvoigt_local(rr, yyProc, peakGuessDeg, opts);
% 
%     if okpv
%         fwhmOK = isfinite(ppv.fwhm) && ...
%                  ppv.fwhm >= opts.pvoigtFwhmRangeDeg(1) && ...
%                  ppv.fwhm <= opts.pvoigtFwhmRangeDeg(2);
%         muOK = abs(ppv.mu - peakGuessDeg) <= opts.pvoigtMuBoundDeg;
%         if ~(R2pv >= opts.pvoigtMinR2 && fwhmOK && muOK)
%             okpv = false;
%         end
%     end
% 
%     if ~okpv && opts.pvoigtFallbackToCentroid && okc
%         res.pvoigt.tth_peak_deg(it) = xc;
%         res.pvoigt.tth_peak_err_deg(it) = errc;
%         res.pvoigt.amp(it) = ac;
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%         res.pvoigt.valid(it) = true;
%         res.pvoigt.usedFallback(it) = true;
%         fitStore(it).x_pvoigt = xc;
%         fitStore(it).valid_pvoigt = true;
%         fitStore(it).usedPvoigtFallback = true;
%     elseif okpv
%         res.pvoigt.tth_peak_deg(it) = ppv.mu;
%         res.pvoigt.tth_peak_err_deg(it) = errMuPV;
%         res.pvoigt.amp(it) = ppv.A;
%         res.pvoigt.fwhm(it) = ppv.fwhm;
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%         res.pvoigt.valid(it) = true;
%         fitStore(it).yfit_pvoigt = ypvfit;
%         fitStore(it).x_pvoigt = ppv.mu;
%         fitStore(it).valid_pvoigt = true;
%         fitStore(it).usedPvoigtFallback = false;
%     else
%         res.pvoigt.R2(it) = R2pv;
%         res.pvoigt.noise(it) = noiseVal;
%         res.pvoigt.snr(it) = snrVal;
%     end
% end
% 
% % ---------------- plots ----------------
% if opts.doPlot
%     % profile plot
%     figure;
%     hold on; grid on;
%     plot(r, Iprof, '-', 'DisplayName', 'raw');
%     plot(r, IprofSm, '-', 'DisplayName', 'smoothed');
%     plot(r, IprofProc, '-', 'DisplayName', 'processed');
%     xline(peakGuessDeg, '--', 'DisplayName', 'peak guess');
%     xlabel('2\theta / radial');
%     ylabel('intensity');
%     title('\chi-integriertes Profil zur Peakdefinition');
%     legend('Location','best');
% 
%     % comparison plot
%     figure;
%     hold on; grid on;
%     plot(g(res.centroid.valid), res.centroid.tth_peak_deg(res.centroid.valid), 'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         plot(g(res.gauss.valid), res.gauss.tth_peak_deg(res.gauss.valid), 'r.-', 'DisplayName', 'gauss');
%     end
%     plot(g(res.pvoigt.valid), res.pvoigt.tth_peak_deg(res.pvoigt.valid), 'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('2\theta_{peak} (deg)');
%     title(sprintf('Methodenvergleich Peaktracking (guess %.4f°)', peakGuessDeg));
%     legend('Location','best');
% 
%     % relative comparison
%     figure;
%     hold on; grid on;
%     plot_relative_series(g, res.centroid.tth_peak_deg, res.centroid.valid, 'k.-', 'centroid');
%     if opts.useGauss
%         plot_relative_series(g, res.gauss.tth_peak_deg, res.gauss.valid, 'r.-', 'gauss');
%     end
%     plot_relative_series(g, res.pvoigt.tth_peak_deg, res.pvoigt.valid, 'b.-', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('\Delta 2\theta (deg)');
%     title('Methodenvergleich relativ zum jeweiligen Mittelwert');
%     legend('Location','best');
% 
%     % errorbar plot
%     figure;
%     hold on; grid on;
%     errorbar(g(res.centroid.valid), ...
%              res.centroid.tth_peak_deg(res.centroid.valid), ...
%              res.centroid.tth_peak_err_deg(res.centroid.valid), ...
%              'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         errorbar(g(res.gauss.valid), ...
%                  res.gauss.tth_peak_deg(res.gauss.valid), ...
%                  res.gauss.tth_peak_err_deg(res.gauss.valid), ...
%                  'r.-', 'DisplayName', 'gauss');
%     end
%     errorbar(g(res.pvoigt.valid), ...
%              res.pvoigt.tth_peak_deg(res.pvoigt.valid), ...
%              res.pvoigt.tth_peak_err_deg(res.pvoigt.valid), ...
%              'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('2\theta_{peak} (deg)');
%     title('Peaklagen mit Fehlerbalken');
%     legend('Location','best');
% 
%     % SNR plot
%     figure;
%     hold on; grid on;
%     plot(g, res.centroid.snr, 'k.-', 'DisplayName', 'centroid');
%     if opts.useGauss
%         plot(g, res.gauss.snr, 'r.-', 'DisplayName', 'gauss');
%     end
%     plot(g, res.pvoigt.snr, 'b.-', 'DisplayName', 'pVoigt');
%     xlabel('\gamma / \chi (deg)');
%     ylabel('SNR');
%     title('Signal-zu-Rauschen pro Profil');
%     legend('Location','best');
% 
%     if opts.plotFits
%         plot_fit_samples(fitStore, res, opts);
%     end
% end
% 
% res.fitStore = fitStore;
% 
% end
% 
% % =====================================================================
% % helpers
% % =====================================================================
% 
% function s = setd(s, f, v)
% if ~isfield(s, f) || isempty(s.(f))
%     s.(f) = v;
% end
% end
% 
% function S = init_method_struct(n)
% S = struct();
% S.tth_peak_deg = nan(n,1);
% S.tth_peak_err_deg = nan(n,1);
% S.amp = nan(n,1);
% S.fwhm = nan(n,1);
% S.R2 = nan(n,1);
% S.noise = nan(n,1);
% S.snr = nan(n,1);
% S.valid = false(n,1);
% S.usedFallback = false(n,1);
% end
% 
% function y = smooth1(x, w)
% x = x(:);
% w = max(1, round(w));
% if mod(w,2)==0, w = w + 1; end
% if w == 1
%     y = x;
%     return;
% end
% k = ones(w,1) / w;
% y = conv(x, k, 'same');
% end
% 
% function [yproc, base] = baseline_remove(y, mode, win)
% y = y(:);
% switch lower(string(mode))
%     case "none"
%         base = zeros(size(y));
%         yproc = y;
%     case "movmin"
%         win = max(5, round(win));
%         if mod(win,2)==0, win = win + 1; end
%         base = movmin(y, win);
%         yproc = y - base;
%         yproc(yproc < 0) = 0;
%     otherwise
%         error("Unknown baselineMode: %s", string(mode));
% end
% end
% 
% function idx = nearest_index(x, xq)
% x = x(:);
% xq = xq(:);
% idx = zeros(size(xq));
% for i = 1:numel(xq)
%     [~, idx(i)] = min(abs(x - xq(i)));
% end
% end
% 
% function [noise, snrVal] = estimate_peak_quality(y)
% y = y(:);
% noise = nan;
% snrVal = nan;
% 
% if isempty(y) || all(~isfinite(y))
%     return;
% end
% 
% ym = median(y, 'omitnan');
% madVal = median(abs(y - ym), 'omitnan');
% 
% noise = 1.4826 * madVal;
% if ~isfinite(noise) || noise <= 0
%     noise = std(y, 'omitnan');
% end
% if ~isfinite(noise) || noise <= 0
%     noise = eps;
% end
% 
% peakHeight = max(y, [], 'omitnan');
% snrVal = peakHeight / noise;
% end
% 
% function [xc, amp, ok, err] = fit_centroid(x, y)
% x = x(:); y = y(:);
% ok = false;
% xc = nan; amp = nan; err = nan;
% 
% if isempty(x) || isempty(y) || all(~isfinite(y))
%     return;
% end
% 
% [a, im] = max(y);
% if ~isfinite(a) || a <= 0
%     return;
% end
% 
% thr = 0.5 * a;
% msk = y >= thr;
% if nnz(msk) >= 3
%     yy = y(msk);
%     xx = x(msk);
%     xc = sum(xx .* yy) / sum(yy);
% 
%     varw = sum(yy .* (xx - xc).^2) / sum(yy);
%     err = sqrt(max(varw,0)) / sqrt(nnz(msk));
% else
%     xc = x(im);
%     dx = mean(diff(x), 'omitnan');
%     if ~isfinite(dx), dx = 0; end
%     err = abs(dx);
% end
% amp = a;
% ok = isfinite(xc);
% end
% 
% function [p, ok, yfit, R2, errMu] = fit_gauss_local(x, y)
% x = x(:); y = y(:);
% ok = false;
% R2 = nan;
% errMu = nan;
% yfit = nan(size(y));
% p = struct("A",nan,"mu",nan,"sigma",nan,"c",nan);
% 
% try
%     if numel(x) < 5 || max(y) <= 0
%         return;
%     end
% 
%     c0 = max(0, min(y));
%     y0 = y - c0;
%     y0(y0 < 0) = 0;
% 
%     [A0, im] = max(y0);
%     mu0 = x(im);
% 
%     half = 0.5 * A0;
%     msk = y0 >= half;
%     if nnz(msk) >= 3
%         sigma0 = (max(x(msk)) - min(x(msk))) / 2.355;
%     else
%         sigma0 = max((max(x)-min(x))/8, eps);
%     end
%     sigma0 = max(sigma0, eps);
% 
%     model = @(b,xx) b(1) * exp(-(xx-b(2)).^2 ./ (2*b(3)^2)) + b(4);
% 
%     b0 = [A0, mu0, sigma0, c0];
%     lb = [0, min(x), eps, 0];
%     ub = [Inf, max(x), max(x)-min(x), Inf];
% 
%     lsqOpts = optimoptions('lsqcurvefit', ...
%         'Display','off', ...
%         'MaxFunctionEvaluations', 5000, ...
%         'MaxIterations', 500);
% 
%     [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%     p.A = b(1);
%     p.mu = b(2);
%     p.sigma = b(3);
%     p.c = b(4);
% 
%     yfit = model(b, x);
%     R2 = calc_r2(y, yfit);
%     ok = isfinite(p.mu) && isfinite(p.sigma) && p.sigma > 0;
% 
%     if ok
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     end
% catch
% end
% end
% 
% function [p, ok, yfit, R2, errMu] = fit_pvoigt_local(x, y, muExpected, opts)
% x = x(:); y = y(:);
% ok = false;
% R2 = nan;
% errMu = nan;
% yfit = nan(size(y));
% p = struct("A",nan,"mu",nan,"sigma",nan,"gamma",nan,"eta",nan,"c",nan,"fwhm",nan);
% 
% try
%     if numel(x) < 5 || max(y) <= 0
%         return;
%     end
% 
%     c0 = max(0, min(y));
%     y0 = y - c0;
%     y0(y0 < 0) = 0;
% 
%     idxExp = nearest_index(x, muExpected);
%     lo = max(1, idxExp-2);
%     hi = min(numel(x), idxExp+2);
%     [A0, im0] = max(y0(lo:hi));
%     im0 = lo + im0 - 1;
% 
%     if ~isfinite(A0) || A0 <= 0
%         [A0, im0] = max(y0);
%         if ~isfinite(A0) || A0 <= 0
%             return;
%         end
%     end
% 
%     mu0 = x(im0);
%     xSpan = max(x) - min(x);
%     fwhm0 = max(xSpan/6, eps);
%     sigma0 = max(fwhm0 / (2*sqrt(2*log(2))), eps);
%     gamma0 = max(fwhm0 / 2, eps);
% 
%     lsqOpts = optimoptions('lsqcurvefit', ...
%         'Display','off', ...
%         'MaxFunctionEvaluations', 8000, ...
%         'MaxIterations', 800);
% 
%     fixedEta = [];
%     if ~isempty(opts.pvoigtFixedEta)
%         fixedEta = min(max(opts.pvoigtFixedEta, 0), 1);
%     end
% 
%     muLo = max(min(x), muExpected - opts.pvoigtMuBoundDeg);
%     muHi = min(max(x), muExpected + opts.pvoigtMuBoundDeg);
% 
%     if isempty(fixedEta)
%         % b = [A mu sigma gamma eta c]
%         model = @(b,xx) b(6) + b(1) .* ...
%             ( b(5) .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
%              (1-b(5)) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );
% 
%         b0 = [A0, mu0, sigma0, gamma0, 0.5, c0];
%         lb = [0, muLo, eps, eps, 0, 0];
%         ub = [Inf, muHi, xSpan, xSpan, 1, Inf];
% 
%         [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%         p.A = b(1);
%         p.mu = b(2);
%         p.sigma = b(3);
%         p.gamma = b(4);
%         p.eta = b(5);
%         p.c = b(6);
% 
%         yfit = model(b, x);
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     else
%         % b = [A mu sigma gamma c], eta fixed
%         etaFix = fixedEta;
%         model = @(b,xx) b(5) + b(1) .* ...
%             ( etaFix .* (1 ./ (1 + ((xx-b(2))./b(4)).^2)) + ...
%              (1-etaFix) .* exp(-0.5 * ((xx-b(2))./b(3)).^2) );
% 
%         b0 = [A0, mu0, sigma0, gamma0, c0];
%         lb = [0, muLo, eps, eps, 0];
%         ub = [Inf, muHi, xSpan, xSpan, Inf];
% 
%         [b,~,residual,~,~,~,J] = lsqcurvefit(model, b0, x, y, lb, ub, lsqOpts);
% 
%         p.A = b(1);
%         p.mu = b(2);
%         p.sigma = b(3);
%         p.gamma = b(4);
%         p.eta = etaFix;
%         p.c = b(5);
% 
%         yfit = model(b, x);
%         errMu = stderr_from_jacobian(J, residual, numel(y), numel(b), 2);
%     end
% 
%     fwhmG = 2 * sqrt(2*log(2)) * p.sigma;
%     fwhmL = 2 * p.gamma;
%     p.fwhm = p.eta * fwhmL + (1-p.eta) * fwhmG;
% 
%     R2 = calc_r2(y, yfit);
%     ok = isfinite(p.mu) && isfinite(p.fwhm) && p.fwhm > 0;
% catch
% end
% end
% 
% function errParam = stderr_from_jacobian(J, residual, nObs, nPar, parIdx)
% errParam = nan;
% try
%     if isempty(J) || size(J,1) <= nPar
%         return;
%     end
% 
%     mse = sum(residual.^2) / max(nObs - nPar, 1);
%     JTJ = J' * J;
%     if rcond(JTJ) < 1e-12
%         return;
%     end
% 
%     Cov = mse * inv(JTJ);
%     if parIdx <= size(Cov,1) && Cov(parIdx,parIdx) > 0
%         errParam = sqrt(Cov(parIdx,parIdx));
%     end
% catch
% end
% end
% 
% function R2 = calc_r2(y, yfit)
% y = y(:); yfit = yfit(:);
% ssRes = sum((y - yfit).^2);
% ssTot = sum((y - mean(y,'omitnan')).^2);
% if ssTot <= 0
%     R2 = nan;
% else
%     R2 = 1 - ssRes / ssTot;
% end
% end
% 
% function plot_relative_series(g, y, valid, sty, labelTxt)
% if ~any(valid), return; end
% y0 = mean(y(valid), 'omitnan');
% dy = y - y0;
% plot(g(valid), dy(valid), sty, 'DisplayName', labelTxt);
% end
% 
% function plot_fit_samples(fitStore, res, opts)
% validAny = res.centroid.valid | res.pvoigt.valid;
% if opts.useGauss
%     validAny = validAny | res.gauss.valid;
% end
% 
% idx = find(validAny);
% if isempty(idx)
%     return;
% end
% 
% nShow = min(opts.fitSampleCount, numel(idx));
% pick = unique(round(linspace(1, numel(idx), nShow)));
% idxShow = idx(pick);
% 
% % centroid plots
% figure;
% tiledlayout('flow');
% for k = 1:numel(idxShow)
%     i = idxShow(k);
%     nexttile; hold on; grid on;
%     plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%     if fitStore(i).valid_centroid
%         xline(fitStore(i).x_centroid, 'r-');
%     end
%     xlabel('2\theta'); ylabel('I');
%     title(sprintf('centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
% end
% 
% % gauss plots
% if opts.useGauss
%     figure;
%     tiledlayout('flow');
%     for k = 1:numel(idxShow)
%         i = idxShow(k);
%         nexttile; hold on; grid on;
%         plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%         if fitStore(i).valid_gauss && ~isempty(fitStore(i).yfit_gauss)
%             plot(fitStore(i).r, fitStore(i).yfit_gauss, 'r-');
%             xline(fitStore(i).x_gauss, 'b-');
%         end
%         xlabel('2\theta'); ylabel('I');
%         title(sprintf('gauss, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     end
% end
% 
% % pVoigt plots
% figure;
% tiledlayout('flow');
% for k = 1:numel(idxShow)
%     i = idxShow(k);
%     nexttile; hold on; grid on;
%     plot(fitStore(i).r, fitStore(i).yproc, 'k.-');
%     if fitStore(i).valid_pvoigt
%         if ~fitStore(i).usedPvoigtFallback && ~isempty(fitStore(i).yfit_pvoigt)
%             plot(fitStore(i).r, fitStore(i).yfit_pvoigt, 'r-');
%         end
%         xline(fitStore(i).x_pvoigt, 'b-');
%     end
%     xlabel('2\theta'); ylabel('I');
%     if fitStore(i).usedPvoigtFallback
%         title(sprintf('pVoigt->centroid, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     else
%         title(sprintf('pVoigt, \\chi=%.1f°, SNR=%.2f', fitStore(i).gamma, fitStore(i).snr));
%     end
% end
% end