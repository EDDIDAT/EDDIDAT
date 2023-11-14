name = 'Eberstein_04';

filelist = dir('*.mat');

for i=1:size(filelist,1)
    [~,FileList{i},~] = fileparts(filelist(i).name);
end

for k = 1:size(FileList,2)
    load(FileList{k})
    ModifyStressplots(t,0,600,50,-1000,1000,200,name)
    clear t
end