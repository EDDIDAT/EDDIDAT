function P = bcfFindPeaks(E,y,varargin)
% BCFFINDPEAKS  Einfache Peaksuche in einem Spektrum (ohne Toolbox).
%
%   P = bcfFindPeaks(E,y)                       Standardwerte
%   P = bcfFindPeaks(E,y,'SmoothKeV',0.08,'MinPromFrac',0.03,'MinDistKeV',0.15,'MaxPeaks',10)
%
% Gibt ein Struct-Array (nach Prominenz absteigend) mit den Feldern
%   E (keV), Height, Prominence, FWHM (keV, Halbwertsbreite der geglaetteten Linie)
% zurueck. Eine Linie zaehlt, wenn ihre Prominenz mindestens MinPromFrac der Spanne (max - min) des
% geglaetteten Spektrums betraegt. Naehere Linien als MinDistKeV werden zusammengefasst (hoehere bleibt).
p = inputParser;
addParameter(p,'SmoothKeV',0.08,@isnumeric);
addParameter(p,'MinPromFrac',0.03,@isnumeric);
addParameter(p,'MinDistKeV',0.15,@isnumeric);
addParameter(p,'MaxPeaks',10,@isnumeric);
parse(p,varargin{:});
o = p.Results;
E = E(:); y = double(y(:));
dE = median(diff(E));
n = max(3,2*round(o.SmoothKeV/dE/2)+1);
ys = movmean(y,n);
rng_ = max(ys) - min(ys);
P = struct('E',{},'Height',{},'Prominence',{},'FWHM',{});
if rng_ <= 0, return, end
cand = find(ys(2:end-1) > ys(1:end-2) & ys(2:end-1) >= ys(3:end)) + 1;
prom = zeros(size(cand)); fw = zeros(size(cand));
for k = 1:numel(cand)
    i = cand(k); h = ys(i);
    j = i - 1; mL = h;
    while j >= 1 && ys(j) <= h, mL = min(mL,ys(j)); j = j - 1; end
    jr = i + 1; mR = h;
    while jr <= numel(ys) && ys(jr) <= h, mR = min(mR,ys(jr)); jr = jr + 1; end
    prom(k) = h - max(mL,mR);
    lev = h - prom(k)/2;
    a = i; while a > 1 && ys(a) > lev, a = a - 1; end
    b = i; while b < numel(ys) && ys(b) > lev, b = b + 1; end
    if a < i && ys(a+1) ~= ys(a), xa = E(a) + (lev - ys(a)) * (E(a+1) - E(a)) / (ys(a+1) - ys(a)); else, xa = E(a); end
    if b > i && ys(b-1) ~= ys(b), xb = E(b-1) + (lev - ys(b-1)) * (E(b) - E(b-1)) / (ys(b) - ys(b-1)); else, xb = E(b); end
    fw(k) = xb - xa;
end
keep = prom >= o.MinPromFrac * rng_;
cand = cand(keep); prom = prom(keep); fw = fw(keep);
[prom,ord] = sort(prom,'descend'); cand = cand(ord); fw = fw(ord);
sel = false(size(cand));
for k = 1:numel(cand)
    if all(abs(E(cand(k)) - E(cand(sel))) >= o.MinDistKeV), sel(k) = true; end
end
cand = cand(sel); prom = prom(sel); fw = fw(sel);
m = min(numel(cand),o.MaxPeaks);
for k = 1:m
    P(k).E = E(cand(k)); P(k).Height = ys(cand(k)); P(k).Prominence = prom(k); P(k).FWHM = fw(k);
end
end
