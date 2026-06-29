function trk = track_peak_from_gamma_binned(tth_deg, I_byGamma, gammaBinsDeg, peakGuessDeg, opts)
%TRACK_PEAK_FROM_GAMMA_BINNED
% Trackt Peaklage 2theta_peak(gamma) aus gamma-gebinnten Diffraktogrammen.
%
% Inputs:
%   tth_deg       : [nT x 1] 2theta-Achse in Grad
%   I_byGamma     : [nT x nG] Intensitäten pro Gamma-Bin (z.B. out.I_mean oder out.I_sum)
%   gammaBinsDeg  : [nG x 2] Gamma-Bin-Grenzen in Grad
%   peakGuessDeg  : erwartete Peaklage (z.B. 38.6)
%   opts:
%     window_deg        (default 1.0)   +- Suchfenster um peakGuess
%     minCountOrSignal  (default 0)     minimaler Signallevel (nach Normierung) um Bin zu akzeptieren
%     k_bins            (default 6)     Halbbreite (in Indizes) um Maximum für Schwerpunkt
%     smooth_points     (default 5)     gleitende Mittelung entlang 2theta (0/1 = aus)
%     useLog            (default false) log1p auf Intensität vor Peak-Suche (robust bei Ausreißern)
%
% Output:
%   trk.gamma_center_deg
%   trk.tth_peak_deg
%   trk.peak_height
%   trk.peak_rms_deg
%   trk.valid

    if nargin < 5 || isempty(opts), opts = struct(); end
    opts = applyDefaults(opts, struct( ...
        "window_deg", 1.0, ...
        "minCountOrSignal", 0.0, ...
        "k_bins", 6, ...
        "smooth_points", 5, ...
        "useLog", false ...
    ));

    tth_deg = tth_deg(:);
    nT = numel(tth_deg);
    nG = size(I_byGamma, 2);

    gamma_center = mean(gammaBinsDeg, 2);

    tth_peak = nan(nG,1);
    peak_height = nan(nG,1);
    peak_rms = nan(nG,1);
    valid = false(nG,1);

    % index window
    mWin = (tth_deg >= (peakGuessDeg - opts.window_deg)) & (tth_deg <= (peakGuessDeg + opts.window_deg));
    idxWin = find(mWin);
    if numel(idxWin) < 20
        error("Zu kleines 2theta-Fenster. Erhöhe opts.window_deg oder nutze feinere tth_bin_deg.");
    end

    for g = 1:nG
        y = double(I_byGamma(:,g));

        % optional preprocess
        if opts.useLog
            y = log1p(max(y,0));
        end
        if opts.smooth_points > 1
            y = movmean(y, opts.smooth_points);
        end

        % focus on window
        yw = y(idxWin);
        xw = tth_deg(idxWin);

        % quick reject if almost empty
        if max(yw) <= opts.minCountOrSignal
            continue
        end

        % find max
        [h, imaxLocal] = max(yw);
        imax = idxWin(1) + imaxLocal - 1;

        % centroid around max (±k bins)
        k = opts.k_bins;
        lo = max(1, imax-k);
        hi = min(nT, imax+k);

        xc = tth_deg(lo:hi);
        yc = y(lo:hi);

        % baseline remove locally (robust)
        yc0 = yc - min(yc);
        if sum(yc0) <= 0
            continue
        end

        mu = sum(xc .* yc0) / sum(yc0);
        rms = sqrt(sum(yc0 .* (xc - mu).^2) / sum(yc0));

        tth_peak(g) = mu;
        peak_height(g) = h;
        peak_rms(g) = rms;
        valid(g) = true;
    end

    trk = struct();
    trk.gamma_center_deg = gamma_center;
    trk.tth_peak_deg = tth_peak;
    trk.peak_height = peak_height;
    trk.peak_rms_deg = peak_rms;
    trk.valid = valid;
    trk.peakGuessDeg = peakGuessDeg;
    trk.opts = opts;
end

function opts = applyDefaults(opts, def)
    f = fieldnames(def);
    for i=1:numel(f)
        if ~isfield(opts, f{i}) || isempty(opts.(f{i}))
            opts.(f{i}) = def.(f{i});
        end
    end
end