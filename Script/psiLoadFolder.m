function D = psiLoadFolder(folder,varargin)
% PSILOADFOLDER  Liest alle psi-Dateien eines Ordners (ein Datensatz = ein Binning) und legt die
% Ergebnisse je Peak auf ein regelmaessiges Raster.
%
%   D = psiLoadFolder(folder)
%   D = psiLoadFolder(folder,'UseCache',true,'ProgressFcn',@(k,n,name) ...)
%
% Spalten einer psi-Datei: LNr Emax dEmax Iint Ib tth phiP psiP etaP h k l xdiff ydiff zdiff.
% Das Raster entsteht aus den tatsaechlich vorkommenden Positionen (Cluster kleiner als der halbe
% Punktabstand), nicht aus einem festen Abstand. Rueckgabe D (Struct):
%   Name, Folder, Bin, Step [dx dy] (mm), PixelUm [px py], x, y (Zentren, mm), nx, ny, bx, by (Blockindizes,
%   0-basiert), Aligned (Raster liegt auf dem globalen Blockraster), NSpectra, NFiles, Collisions,
%   Peaks(k): LNr, Name, Emed, tth, hkl, Grid.Emax/.dEmax/.Iint/.Ib (ny x nx, NaN = kein Wert)
p = inputParser;
addParameter(p,'UseCache',true,@islogical);
addParameter(p,'ProgressFcn',[]);
parse(p,varargin{:});
opt = p.Results;

folder = char(folder);
files = dir(fullfile(folder,'*.psi'));
if isempty(files), error('psiLoadFolder:NoFiles','Keine .psi-Dateien in %s gefunden.',folder); end
[~,names] = sort({files.name}); files = files(names);

% --- Cache ---
sig = sprintf('%s|%d|%d|%.6f',lower(folder),numel(files),sum([files.bytes]),max([files.datenum]));
key = dec2hex(mod(sum(double(sig).*(1:numel(sig))),2^32));
cacheDir = fullfile(tempdir,'EDDIDAT_psi_cache'); cacheFile = fullfile(cacheDir,['psi_' key '.mat']);
if opt.UseCache && exist(cacheFile,'file')
    try
        L = load(cacheFile,'D','sig');
        if strcmp(L.sig,sig), D = L.D; return, end
    catch
    end
end

% --- Dateien lesen ---
rows = cell(numel(files),1);
for k = 1:numel(files)
    f = fullfile(folder,files(k).name);
    rows{k} = readPsi(f);
    if ~isempty(opt.ProgressFcn), opt.ProgressFcn(k,numel(files),files(k).name); end
end
A = vertcat(rows{:});
if isempty(A), error('psiLoadFolder:Empty','Die psi-Dateien enthalten keine Datenzeilen.'); end

% --- Binning aus den Dateinamen, sonst aus dem Punktabstand ---
tok = regexp({files.name},'_B(\d+)','tokens','once');
bins = cellfun(@(t) str2double(t{1}),tok(~cellfun(@isempty,tok)));
[ix,xs] = clusterAxis(A(:,13)); [iy,ys] = clusterAxis(A(:,14));
nx = numel(xs); ny = numel(ys);
stepx = fitStep(xs); stepy = fitStep(ys);
if isempty(bins), B = max(1,round(stepx/0.007)); else, B = mode(bins); end
psx = stepx/B; psy = stepy/B;
bxf = xs/stepx - 0.5; byf = ys/stepy - 0.5;           % Blockindizes (Blockmitte = (b+0.5)*Schritt)
bx = round(bxf); by = round(byf);
aligned = max(abs(bxf - bx)) < 0.15 && max(abs(byf - by)) < 0.15;

% --- Raster je Peak ---
lnrs = unique(A(:,1))';
Pk = struct('LNr',{},'Name',{},'Emed',{},'tth',{},'hkl',{},'Grid',{});
coll = 0; nSp = 0;
for l = lnrs
    r = A(:,1) == l;
    lin = sub2ind([ny nx],iy(r),ix(r));
    coll = coll + (numel(lin) - numel(unique(lin)));
    g = struct();
    q = {'Emax',2;'dEmax',3;'Iint',4;'Ib',5};
    ok = A(r,2) ~= 0;                                  % Emax = 0: kein Peak
    for j = 1:4
        G = nan(ny,nx); v = A(r,q{j,2}); G(lin(ok)) = v(ok); g.(q{j,1}) = G;
    end
    Em = median(A(r & A(:,2) ~= 0,2));
    hkl = round(median(A(r,10:12),1));
    nm = sprintf('Peak %d: %.2f keV',l,Em); if any(hkl ~= 0), nm = sprintf('%s (%d%d%d)',nm,hkl); end
    Pk(end+1) = struct('LNr',l,'Name',nm,'Emed',Em,'tth',median(A(r,6)),'hkl',hkl,'Grid',g); %#ok<AGROW>
    nSp = max(nSp,nnz(r));
end

[~,leaf] = fileparts(folder);
D = struct('Name',leaf,'Folder',folder,'Bin',B,'Step',[stepx stepy],'PixelUm',1000*[psx psy],'x',xs(:)','y',ys(:)', ...
    'nx',nx,'ny',ny,'bx',bx(:)','by',by(:)','Aligned',aligned,'NSpectra',nSp,'NFiles',numel(files),'Collisions',coll,'Peaks',Pk);

try
    if ~exist(cacheDir,'dir'), mkdir(cacheDir); end
    save(cacheFile,'D','sig');
catch
end
end

%% ------------------------------------------------------------------------
function A = readPsi(file)
% Liest die Datenzeilen einer psi-Datei (15 Spalten). Kopfzeilen werden anhand der ersten Zeile erkannt, die
% mit einer Zahl beginnt.
fid = fopen(file,'r'); if fid < 0, error('psiLoadFolder:Open','Kann %s nicht oeffnen.',file); end
nh = 0; found = false;
for i = 1:12
    ln = fgetl(fid); if ~ischar(ln), break, end
    if ~isempty(regexp(ln,'^\s*[-+]?\d','once')), found = true; break, end
    nh = nh + 1;
end
fclose(fid);
if ~found, A = zeros(0,15); return, end
A = readmatrix(file,'FileType','text','Delimiter','\t','NumHeaderLines',nh);
if size(A,2) < 15, A = [A nan(size(A,1),15 - size(A,2))]; end
A = A(:,1:15);
A = A(all(isfinite(A(:,[1 13 14])),2),:);
end

function s = fitStep(pos)
% Punktabstand als Steigung einer Geradenanpassung ueber die ganzzahligen Positionsnummern. Der Median der
% Einzelabstaende waere auf die vierte Nachkommastelle der psi-Positionen begrenzt und wuerde ueber 25 mm driften.
pos = pos(:);
if numel(pos) < 3, s = median(diff(pos)); return, end
s = median(diff(pos));
for it = 1:6                                         % Spaltennummern und Steigung abwechselnd verfeinern
    k = round((pos - pos(1))/s);
    c = polyfit(k,pos,1);
    if abs(c(1) - s) < 1e-9, s = c(1); break, end
    s = c(1);
end
end

function [idx,pos] = clusterAxis(v)
% Rasterindex je Wert aus den vorkommenden Positionen (Cluster < halber Punktabstand)
u = unique(round(v,4));
if numel(u) < 2, idx = ones(size(v)); pos = u; return, end
step = median(diff(u));
g = cumsum([true; diff(u) > step/2]);
pos = accumarray(g,u,[],@mean);
edges = [-inf; (pos(1:end-1) + pos(2:end))/2; inf];
idx = discretize(v,edges);
end
