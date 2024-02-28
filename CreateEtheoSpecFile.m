function CreateEtheoSpecFile(Element,mpd,twotheta,Emax,Int,FileName,Calib_a,Calib_b,Calib_c)
% Function used to create a SpecFile with theoretical energy positions of
% the material entered from the user. Input: 'Elemental formula, mpd
% File name, twotheta, Emax, Intensity, Name of output file', calibration
% parameters a, b and c e.g.
% CreateEtheoSpecFile('Au1','Au',16,80,150,'Au_tth16',0.033,0.011,-8.3e-9)

% Intensität = Vektor mit Nullen der Länge 16384
Intensity_tmp = zeros(16384,1);
% Theoretische Energielagen in Kanallagen umrechnen (aktuelle DT Korrektur)
E = CalcPeakPositions(Element,mpd,twotheta,Emax);
EPos = E.Etheo';
% Calib_a = -0.03335;
% Calib_b = 0.01161;
% Calib_c = -8.132E-09;
% User input of calibration parameters
calib = [Calib_a Calib_b Calib_c];
% Calculate channel position for Etheo positions
Ch = -sqrt((-Calib_a.*Calib_c+0.25.*Calib_b.^2+Calib_c.*EPos)/Calib_c.^2)+ -Calib_b./(2.*Calib_c);
% KanallageE-theo +- 4 Kanäle mit bestimmter Intensität belegen (User)
Ch = round(Ch');
% Ersetzen der Kanallagen
Intensity_tmp(Ch) = Int;
% Umwandlung in Array(1024,16)
Intensity = reshape(Intensity_tmp,16,1024);
Intensity = Intensity';
% Load dummy spec file
DummySpec = load('SpecFileDummy.mat');
% Get index of @A
Index_tmp = Tools.StringOperations.SearchString(DummySpec.M,'@A');
% Get index of calib
Index_calib = Tools.StringOperations.SearchString(DummySpec.M,'#@CALIB');
% Create Spec file
Path = pwd;
fid = fopen([[Path,'\Data\Samples\'],FileName,'_ETheo','.spec'],'w');
fprintf(fid,'%s\n',['#F ./data/',FileName]);


for k = 2:Index_calib-1
    fprintf(fid,'%s\n',strtrim(DummySpec.M(k,:)));
end

str = ['#@CALIB ',mat2str(calib)];
str = strrep(str,']','');
str = strrep(str,'[','');
fprintf(fid,'%s\n',str);

for k = Index_calib+1:Index_tmp-1
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

