function R = psiResampleCommon(DS,Z,varargin)
% PSIRESAMPLECOMMON  Bringt Datensaetze mit verschiedenem Binning auf ein gemeinsames Raster.
%
%   R = psiResampleCommon(DS,Z)
%   R = psiResampleCommon(DS,Z,'W',W,'MinCoverage',1.0)
%
%   DS  Struct-Array der Datensaetze (aus psiLoadFolder: Bin, bx, by, PixelUm, nx, ny)
%   Z   Zellarray, Z{k} = Werte (ny x nx) des k-ten Datensatzes (z. B. Iint je Pixel, Emax, Ib)
%   W   optional Zellarray von Gewichten (gleiche Groesse), z. B. Iint fuer Emax/Ib (gewichtetes Mittel)
%
% Die Zellgroesse ist das kleinste gemeinsame Vielfache der Blockgroessen in Pixeln (4x4 und 6x6 -> 12x12,
% 3x3 und 4x4 -> 12x12). Dann liegt jeder Block vollstaendig in genau einer Zelle, es wird nicht interpoliert.
% Rueckgabe R:
%   L (Zellgroesse in Pixel), x, y (Zellzentren in mm), Z{k} (Mittelwert je Zelle, NaN wenn die Abdeckung
%   unter MinCoverage liegt), S{k} (Standardfehler des Mittels aus der Streuung der Blockwerte in der Zelle,
%   NaN bei nur einem Block), K{k} (Zahl der Bloecke je Zelle), Kmax(k) (Bloecke bei voller Zelle), Aligned.
p = inputParser;
addParameter(p,'W',[]);
addParameter(p,'MinCoverage',1.0,@isnumeric);
parse(p,varargin{:});
W = p.Results.W; minCov = p.Results.MinCoverage;

n = numel(DS);
L = 1; for k = 1:n, L = lcm(L,DS(k).Bin); end
cx = cell(1,n); cy = cell(1,n);
for k = 1:n
    cx{k} = floor(DS(k).bx * DS(k).Bin / L);
    cy{k} = floor(DS(k).by * DS(k).Bin / L);
end
c0x = min(cellfun(@min,cx)); c0y = min(cellfun(@min,cy));
nCx = max(cellfun(@max,cx)) - c0x + 1; nCy = max(cellfun(@max,cy)) - c0y + 1;

R = struct('L',L,'Aligned',all([DS.Aligned]),'Kmax',zeros(1,n),'Z',{cell(1,n)},'S',{cell(1,n)},'K',{cell(1,n)});
psx = mean(arrayfun(@(d) d.PixelUm(1),DS))/1000; psy = mean(arrayfun(@(d) d.PixelUm(2),DS))/1000;
R.x = ((c0x:(c0x+nCx-1)) + 0.5) * L * psx;
R.y = ((c0y:(c0y+nCy-1)) + 0.5) * L * psy;

for k = 1:n
    Zk = Z{k};
    [CX,CY] = meshgrid(cx{k} - c0x + 1,cy{k} - c0y + 1);
    valid = isfinite(Zk);
    if ~isempty(W), wk = W{k}; valid = valid & isfinite(wk) & wk > 0; w = wk(valid); else, w = ones(nnz(valid),1); end
    lin = sub2ind([nCy nCx],CY(valid),CX(valid));
    v = Zk(valid);
    sz = [nCy*nCx 1];
    sw  = accumarray(lin,w,sz);
    swz = accumarray(lin,w.*v,sz);
    cnt = accumarray(lin,1,sz);
    s1  = accumarray(lin,v,sz);
    s2  = accumarray(lin,v.^2,sz);
    mu = swz ./ sw;
    kmax = (L/DS(k).Bin)^2;
    mu1 = s1 ./ cnt;                                    % ungewichteter Mittelwert fuer die Streuung
    var1 = (s2 - cnt.*mu1.^2) ./ max(cnt-1,1);
    se = sqrt(max(var1,0) ./ cnt); se(cnt < 2) = NaN;
    bad = cnt < minCov*kmax | cnt == 0;
    mu(bad) = NaN; se(bad) = NaN;
    R.Z{k} = reshape(mu,nCy,nCx); R.S{k} = reshape(se,nCy,nCx); R.K{k} = reshape(cnt,nCy,nCx); R.Kmax(k) = kmax;
end
end
