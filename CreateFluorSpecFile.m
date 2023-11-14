function CreateFluorSpecFile(Element,Int)
%Function used to create a SpecFile with theoretical energy positions of
%fluorescence lines entered from the user. Input: 'Elemental formula,
%Intensity', e.g. CreateFluorSpecFile('In',150)

% Path of the fluorescence line file
fid = fopen(fullfile('Data','Materials','Fluorescence_Lines.dat'));
% Read file, column names are as follows
% No.;Element;Ka1;Ka2;Kb1;La1;La2;Lb1;Lb2;Lg1
FluorCellArray = textscan(fid,'%d %s %f %f %f %f %f %f %f %f',...
'headerlines',1, 'delimiter','\t');
FluorElements = FluorCellArray;
% Find index of the selected element.
IndexFE = strfind(FluorElements{1,2}, Element);
Index = find(not(cellfun('isempty', IndexFE)));
% Selected fluorescence lines to plot, column names are:
% No.;Element;Ka1;Ka2;Kb1;La1;La2;Lb1;Lb2;Lg1
Ka1 = FluorElements{1,3}(Index);
Ka2 = FluorElements{1,4}(Index);
Kb1 = FluorElements{1,5}(Index);
% Not yet included
La1 = FluorElements{1,6}(Index);
La2 = FluorElements{1,7}(Index);
Lb1 = FluorElements{1,8}(Index);
Lb2 = FluorElements{1,9}(Index);
Lg1 = FluorElements{1,10}(Index);
EPos = [Ka1 Ka2 Kb1 La1 La2 Lb1 Lb2 Lg1];
% Theoretische Energielagen in Kanallagen umrechnen (aktuelle DT Korrektur)
a = 0.36057;
b = 74.29887;
c = 2.29243e-4;
Ch = a + b.*EPos + c.*EPos.^2;
% KanallageE-theo +- 4 Kanäle mit bestimmter Intensität belegen (User)
Ch = round(Ch');
% Intensität = Vektor mit Nullen der Länge 16384
Intensity_tmp = zeros(16384,1);
% Ersetzen der Kanallagen
Intensity_tmp(Ch) = Int;
% Umwandlung in Array(1024,16)
Intensity = reshape(Intensity_tmp,16,1024);
Intensity = Intensity';
% Load dummy spec file
DummySpec = load('SpecFileDummy.mat');
% Get index of @A
Index_tmp = Tools.StringOperations.SearchString(DummySpec.M,'@A');
% Create Spec file
Path = pwd;
fid = fopen([[Path,'\Data\Samples\'],Element,'_FluorETheo','.spec'],'w');
fprintf(fid,'%s\n',['#F ./data/',Element]);

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