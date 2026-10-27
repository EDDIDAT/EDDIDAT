function Diff = ComparePsiFiles(FileA, FileB)
% COMPAREPSIFILES  Vergleicht zwei psi-Dateien Zeile fuer Zeile (z.B. GUI-
% Ergebnis gegen BatchFitXFlash) und gibt je Peak (LNr) die Abweichungen
% von Emax, dEmax, Iint, Ib und der Position aus.
%
%   Diff = ComparePsiFiles('A.psi','B.psi')
%
% Voraussetzung: gleiche Zeilenanzahl und gleiche Reihenfolge. Spalten:
% LNr Emax dEmax Iint Ib tth phiP psiP etaP h k l xdiff ydiff zdiff.

A = ReadPsi_(FileA); B = ReadPsi_(FileB);
if size(A,1) ~= size(B,1)
    error('ComparePsiFiles:Rows','Zeilenanzahl verschieden: %d gegen %d.',size(A,1),size(B,1));
end
names = {'Emax','dEmax','Iint','Ib','xdiff','ydiff'}; cols = [2 3 4 5 13 14];
Diff = struct();
fprintf('%-5s %-6s %12s %12s %14s\n','LNr','Groesse','Median(B-A)','max|B-A|','Anteil exakt');
for lnr = unique(A(:,1))'
    r = A(:,1) == lnr;
    for k = 1:numel(cols)
        d = B(r,cols(k)) - A(r,cols(k));
        fprintf('%-5d %-6s %12.5g %12.5g %13.1f %%\n',lnr,names{k},median(d),max(abs(d)),100*mean(abs(d) < 1e-9));
        Diff.(sprintf('LNr%d',lnr)).(names{k}) = d;
    end
end
end

function M = ReadPsi_(file)
M = readmatrix(file,'FileType','text','NumHeaderLines',3,'Delimiter','\t');
M = M(:,1:15);
end
