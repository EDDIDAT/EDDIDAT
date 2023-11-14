function CreateEtheoSpecFile(Element,mpd,twotheta,Emax,Int,Name)
%Function used to create a SpecFile with theoretical energy positions of
%the material entered from the user. Input: 'Elemental formula, mpd
%File name, twotheta, Emax, Intensity, Name of output file', e.g.
%CreateEtheoSpecFile('Au1','Au',16,80,150,'Au_tth16')

% Intensität = Vektor mit Nullen der Länge 16384
Intensity_tmp = zeros(16384,1);
% Theoretische Energielagen in Kanallagen umrechnen (aktuelle DT Korrektur)
E = CalcPeakPositions(Element,mpd,twotheta,Emax);
EPos = E.Etheo';
a = -0.01308;
b = 0.01141;
c = -1.07404E-9;
Ch = a + b.*EPos + c.*EPos.^2;
% KanallageE-theo +- 4 Kanäle mit bestimmter Intensität belegen (User)
Ch = round(Ch');
% Ersetzen der Kanallagen
Intensity_tmp(Ch) = Int;
% Umwandlung in Array(1024,16)
Intensity = reshape(Intensity_tmp,16,1024);
Intensity = Intensity';
% Load dummy spec file
DummySpec = load('Au_tth9_theo_ETheo.mat');
% Get index of @A
Index_tmp = Tools.StringOperations.SearchString(DummySpec.M,'@A');
% Create Spec file
Path = pwd;
fid = fopen([[Path,'\Data\Samples\'],Name,'_ETheo','.spec'],'w');
fprintf(fid,'%s\n',['#F ./data/',Name]);

for k = 2:Index_tmp-1
fprintf(fid,'%s\n',strtrim(DummySpec.M(k,:)));
end

for k = 1:size(Intensity,1)-1
    if k == 1
        str = mat2str(Intensity(k,:));
        str = strrep(str,']','\');
        str = strrep(str,'[','@A ');
        str = strtrim(str);
        fprintf(fid,'%s\n',str);
    else
        str = mat2str(Intensity(k,:));
        str = strrep(str,']','\');
        str = strrep(str,'[',' ');
        fprintf(fid,'%s\n',str);
    end
end
fclose(fid);
end

