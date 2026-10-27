function M = bcfNetIntensity(Cube,E,c0,hw,fl)
% BCFNETINTENSITY  Netto-Intensitaetskarte eines Reflexes aus einem Blockwuerfel (ohne Fit).
%
%   M = bcfNetIntensity(Cube,E,c0,hw,fl)
%
%   Cube  ny x nx x nE (Counts je Block und Kanal)
%   E     Energieachse in keV (nE x 1)
%   c0    Reflexlage in keV, hw halbe Fensterbreite, fl Breite der beiden Flankenfenster (keV)
%
% Netto = Summe der Counts im Fenster [c0-hw, c0+hw] minus linearer Untergrund durch die Mittelwerte
% der Flankenfenster direkt links und rechts. Gleiche Methode wie roi_karten.py.
E = E(:);
s  = E >= c0 - hw      & E <= c0 + hw;
lo = E >= c0 - hw - fl & E <  c0 - hw;
hi = E >  c0 + hw      & E <= c0 + hw + fl;
if ~any(s), error('bcfNetIntensity:Window','Das Fenster enthaelt keine Kanaele.'); end
if ~any(lo) && ~any(hi), error('bcfNetIntensity:Flanks','Keine Flankenkanaele im Energiebereich.'); end
ns = nnz(s);
w = zeros(size(E));
w(s) = 1;
if any(lo) && any(hi)
    xl = mean(E(lo)); xh = mean(E(hi));
    t = (E(s) - xl) / (xh - xl);
    w(lo) = -sum(1 - t) / nnz(lo);
    w(hi) = -sum(t) / nnz(hi);
elseif any(lo)
    w(lo) = -ns / nnz(lo);          % nur linke Flanke: konstanter Untergrund
else
    w(hi) = -ns / nnz(hi);
end
idx = find(w ~= 0);
[ny,nx,~] = size(Cube);
sub = reshape(double(Cube(:,:,idx)),[],numel(idx));
M = reshape(sub * w(idx),ny,nx);
end
