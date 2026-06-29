h.PathName = [General.ProgramInfo.Path,'\Data\Materials\'];

% if exist(Path,'dir') ~= 7
%     mkdir(Path);
% end

% Create matrix with material data
a = struct2table(h.DataFiltered1);

filename = [strrep(a.ElementSymbol{h.TableIndex},' ',''),'_test.mpd'];
Path = [h.PathName,filename];
fid = fopen(Path, 'w');
fprintf(fid, ['Dateiname: ',strrep(a.ElementSymbol{h.TableIndex},' ',''),'.mpd']);
fprintf(fid, '\n');
fprintf(fid, '\n');
fprintf(fid, 'Elementliste: \n');
% Element list
Elements_tmp = strsplit(char(regexprep(regexprep(a.ElementSymbol{h.TableIndex}, '\(|)|!|,', ''), '[+-]?\d+\.?\d*', '')));
sep = repmat(' ',size(Elements_tmp,1),3);
datastr = '';
for i = 1:size(Elements_tmp,2)
    datastr = [datastr sep Elements_tmp{i}];
end
fprintf(fid, [datastr,'\n']);
fprintf(fid, '\n');

fprintf(fid, 'Stoechiometrieliste: \n');
% Stochiometry list
% Elements in formula
Elements_tmp1 = strsplit(a.ElementSymbol{h.TableIndex});
% Stochiometry of the respective element in the formula.
StochiometryNumbers = regexp(Elements_tmp1,'\d+','match','once');

% Check if empty cell present
idxempty = cellfun(@isempty, StochiometryNumbers);
% Replace empty cells with '1'
% StochiometryNumbers{idxempty} = num2str(1);
StochiometryNumbers(idxempty) = {[num2str(1)]};
sep = repmat(' ',size(StochiometryNumbers,1),3);
stochiometry = '';
for i = 1:size(StochiometryNumbers,2)
    stochiometry = [stochiometry sep StochiometryNumbers{i}];
end
fprintf(fid, [stochiometry,'\n']);
fprintf(fid, '\n');

fprintf(fid, 'Ordnungszahlliste: \n');
Elements_tmp = strsplit(char(regexprep(regexprep(a.ElementSymbol{h.TableIndex}, '\(|)|!|,', ''), '[+-]?\d+\.?\d*', '')));
sep = repmat(' ',size(Elements_tmp,1),3);
dataatomnumber = '';
for i = 1:size(Elements_tmp,2)
    dataatomnumber = [dataatomnumber sep num2str(sym2an(Elements_tmp{i}))];
end

fprintf(fid, [dataatomnumber,'\n']);
fprintf(fid, '\n');

fprintf(fid, 'Atomgewichtsliste (in g/mol): \n');

for i = 1:size(Elements_tmp,2)
    atomnumber = sym2an(Elements_tmp{i});
    atomdata_tmp = pertable(atomnumber);
    atomicmass(i) = str2double(atomdata_tmp.RAmass);
end
sep = repmat(' ',size(Elements_tmp,1),3);
dataatommass = '';
for i = 1:size(Elements_tmp,2)
    dataatommass = [dataatommass sep num2str(atomicmass(i))];
end

fprintf(fid, [dataatommass,'\n']);
fprintf(fid, '\n');

fprintf(fid, 'Materialdichte (in g/cm^3): \n');
fprintf(fid, ['  ',num2str(a.Density{h.TableIndex}),'\n']);
fprintf(fid, '\n');

fprintf(fid, 'Gittertyp: ');
fprintf(fid, '\n');
fprintf(fid, '\n');

fprintf(fid, 'Gitterparameter (in nm): \n');
latticeparams = a.LatticeParameter{h.TableIndex};
sep = repmat(' ',size(latticeparams,2),3);
datalatticeparam = '';
for i = 1:size(latticeparams,1)
    datalatticeparam = [datalatticeparam sep num2str(latticeparams(i)/10)];
end

fprintf(fid, [datalatticeparam,'\n']);
fprintf(fid, '\n');

fprintf(fid, 'hkl- und d-Wertliste: \n');

% for i = 1:size(a.dSpacing{h.TableIndex},1)
%     datadspacing = [a.h{h.TableIndex}(i) a.k{h.TableIndex}(i) a.l{h.TableIndex}(i) h.TableIndex}(i)/10];
% end
for i = 1:size(a.dSpacing{h.TableIndex},1)
    if i ~= size(a.dSpacing{h.TableIndex},1)
        fprintf(fid, [num2str(a.h{h.TableIndex}(i)) num2str(a.k{h.TableIndex}(i)) num2str(a.l{h.TableIndex}(i)) ' ' num2str(a.dSpacing{h.TableIndex}(i)/10),'\n']);
    else
        fprintf(fid, [num2str(a.h{h.TableIndex}(i)) num2str(a.k{h.TableIndex}(i)) num2str(a.l{h.TableIndex}(i)) ' ' num2str(a.dSpacing{h.TableIndex}(i)/10)]);
    end
end

fclose(fid);