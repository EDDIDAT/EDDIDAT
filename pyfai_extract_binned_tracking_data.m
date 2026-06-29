function B = pyfai_extract_binned_tracking_data(out, opts)
%PYFAI_EXTRACT_BINNED_TRACKING_DATA
% Bereitet pyFAI-2D-Daten genauso auf wie im Peaktracking und gibt
% die gebinnten 1D-Profile zurück.
%
% INPUT
%   out.I         : [nRad x nChi] oder [nChi x nRad]
%   out.radial    : radiale Achse (z.B. 2theta)
%   out.azimuthal : chi/gamma-Achse
%
%   opts.profileChiRange = [] oder [chiMin chiMax]
%       Bereich für das globale 1D-Summenprofil zur Peakdefinition
%
%   opts.trackChiRange = [] oder [chiMin chiMax]
%       Bereich, in dem Trackingprofile erzeugt werden
%
%   opts.trackChiBin = 1
%       jeder n-te chi-Bin wird als Trackingpunkt verwendet
%
%   opts.trackChiAvgBins = 1
%       Mittelung pro Trackingpunkt über +/- diese Anzahl chi-Bins
%
%   opts.smoothPoints = 1
%       optionale Glättung der erzeugten 1D-Profile
%
%   opts.useLog = false
%       optional log10(1+I) auf die Trackingprofile
%
%   opts.baselineMode = "none" | "movmin"
%       optionale Untergrundbehandlung
%
%   opts.baselineWin = 51
%
% OUTPUT
%   B.radial                 : radiale Achse
%   B.chi                    : volle chi-Achse
%   B.profileChiRange
%   B.trackChiRange
%   B.trackIdxAll            : alle chi-Indizes im Trackbereich
%   B.trackIdx               : tatsächlich ausgewählte Tracking-Indizes
%   B.gamma_deg              : chi/gamma-Mitte pro Trackingprofil
%   B.trackChiBin
%   B.trackChiAvgBins
%
%   B.profile.raw            : globales 1D-Profil über profileChiRange
%   B.profile.smoothed
%   B.profile.processed
%   B.profile.baseline
%
%   B.track.rawProfiles      : [nRad x nTrack]
%   B.track.smoothedProfiles : [nRad x nTrack]
%   B.track.processedProfiles: [nRad x nTrack]
%   B.track.baselines        : [nRad x nTrack]
%   B.track.chiLoIdx         : unterer gemittelter chi-Index je Profil
%   B.track.chiHiIdx         : oberer gemittelter chi-Index je Profil
%   B.track.chiLoDeg         : untere chi-Grenze je Profil
%   B.track.chiHiDeg         : obere chi-Grenze je Profil
%
% BEISPIEL
%   opts = struct;
%   opts.profileChiRange = [-160 0];
%   opts.trackChiRange   = [-160 -80];
%   opts.trackChiAvgBins = 4;
%   opts.trackChiBin     = 4;
%   B = pyfai_extract_binned_tracking_data(out, opts);

if nargin < 2 || isempty(opts)
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

% ---------------- global 1D profile ----------------
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

if opts.useLog
    IprofSm = log10(max(IprofSm, 0) + 1);
end

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
nTrack = numel(trackIdx);

rawProfiles = nan(nRad, nTrack);
smProfiles = nan(nRad, nTrack);
procProfiles = nan(nRad, nTrack);
baseProfiles = nan(nRad, nTrack);

chiLoIdx = nan(nTrack,1);
chiHiIdx = nan(nTrack,1);
chiLoDeg = nan(nTrack,1);
chiHiDeg = nan(nTrack,1);

for it = 1:nTrack
    c0 = trackIdx(it);
    cLo = max(1, c0 - opts.trackChiAvgBins);
    cHi = min(nChi, c0 + opts.trackChiAvgBins);

    prof = mean(I(:, cLo:cHi), 2);
    profSm = smooth1(prof, opts.smoothPoints);

    if opts.useLog
        profSm = log10(max(profSm, 0) + 1);
    end

    [profProc, base] = baseline_remove(profSm, opts.baselineMode, opts.baselineWin);

    rawProfiles(:, it) = prof;
    smProfiles(:, it) = profSm;
    procProfiles(:, it) = profProc;
    baseProfiles(:, it) = base;

    chiLoIdx(it) = cLo;
    chiHiIdx(it) = cHi;
    chiLoDeg(it) = chi(cLo);
    chiHiDeg(it) = chi(cHi);
end

% ---------------- output ----------------
B = struct();
B.radial = r;
B.chi = chi;

B.profileChiRange = opts.profileChiRange;
B.trackChiRange = opts.trackChiRange;
B.trackChiBin = opts.trackChiBin;
B.trackChiAvgBins = opts.trackChiAvgBins;

B.trackIdxAll = trackIdxAll;
B.trackIdx = trackIdx;
B.gamma_deg = g(:);

B.profile = struct();
B.profile.raw = Iprof;
B.profile.smoothed = IprofSm;
B.profile.processed = IprofProc;
B.profile.baseline = baseProf;
B.profile.profileIdx = profileIdx;

B.track = struct();
B.track.rawProfiles = rawProfiles;
B.track.smoothedProfiles = smProfiles;
B.track.processedProfiles = procProfiles;
B.track.baselines = baseProfiles;
B.track.chiLoIdx = chiLoIdx;
B.track.chiHiIdx = chiHiIdx;
B.track.chiLoDeg = chiLoDeg;
B.track.chiHiDeg = chiHiDeg;

end

% =====================================================================
% helpers
% =====================================================================

function s = setd(s, f, v)
if ~isfield(s, f) || isempty(s.(f))
    s.(f) = v;
end
end

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