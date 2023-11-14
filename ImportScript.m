tic;
for k = 1:size(scansP,1)
    try
        DataScansP(k) = ImportPDF(scansP{k});
    catch Error
        % Nothing to do
        continue;
    end
end
toc;