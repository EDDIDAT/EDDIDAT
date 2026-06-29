function CreateTextureNjaFile(FileName,PsiFileTableData)
    psifiledata = str2double(PsiFileTableData(:,[8,7,4,10,11,12]));
    % Check psi data and find numnber of measured hkl
    idxhkl = find(sum(psifiledata(:,1:2),2)==0);
    hkl = psifiledata(idxhkl,4:6);
    % Load dummy header for texture file
    DummyTexture = fullfile('D:\EDDIDAT_github\Data\Materials\Texture-File-Header.txt');
    M = Tools.StringOperations.AsciiFile2Text(DummyTexture,'\r\n');

    for k = 1:size(hkl,1)
        Path = pwd;
        fid = fopen([[Path,'\Data\Results\'],FileName,'_',strrep(num2str(hkl(k,:)),' ',''),'.nja'],'w');
        % Change File name in header file
        IndexFileName = Tools.StringOperations.SearchString(M,'&Sample=');
        StrFileNameNew = [['&Sample=',FileName],blanks(length(M(IndexFileName,:)) - length(['&Sample=',FileName]))];
        M(IndexFileName(1),:) = StrFileNameNew;
        
        % Change hkl values
        IndexHKL = Tools.StringOperations.SearchString(M,'&H=');
        StrHKLSample = sprintf([['&H=',num2str(hkl(k,1))],'\t',['&K=',num2str(hkl(k,2))],'\t',['&L=',num2str(hkl(k,3))]]);
        StrHKLnew = [StrHKLSample, blanks(length(M(IndexHKL,:)) - length(StrHKLSample))];
        M(IndexHKL(1),:) = StrHKLnew;
        
        % Change texture step info for alpha and beta
        IndexAlpha = Tools.StringOperations.SearchString(M,'&AlphaStart=');
        StrAlphaSample = sprintf([['&AlphaStart=',num2str(min(psifiledata(:,1))),'.000'],'\t',['&AlphaEnd=',num2str(max(psifiledata(:,1))),'.000'],'\t',['&AlphaStep=',num2str(unique(diff(unique(psifiledata(:,1))))),'.000']]);
        IndexBeta = Tools.StringOperations.SearchString(M,'&BetaStart=');
        StrBetaSample = sprintf([['&BetaStart=',num2str(min(psifiledata(:,2))),'.000'],'\t',['&BetaEnd=',num2str(max(psifiledata(:,2))),'.000'],'\t',['&BetaStep=',num2str(unique(diff(unique(psifiledata(:,2))))),'.000']]);
        M(IndexAlpha(1),:) = [StrAlphaSample, blanks(length(M(IndexAlpha,:)) - length(StrAlphaSample))];
        M(IndexBeta(1),:) = [StrBetaSample, blanks(length(M(IndexBeta,:)) - length(StrBetaSample))];

        % Get data for hkl
        if k ~= size(hkl,1)
            dataforfile = psifiledata(idxhkl(k):idxhkl(k+1)-1,1:3);
            dataforfile(:,4) = 0;
        else
            dataforfile = psifiledata(idxhkl(k):end,1:3);
            dataforfile(:,4) = 0;
        end
        
        % Set neg. intensity values to 0
        dataforfile(dataforfile < 0) = 0;

        % Change number of values
        IndexValues = Tools.StringOperations.SearchString(M,'&NoValues=');
        StraValuesSample = ['&NoValues=',num2str(size(dataforfile,1))];
        M(IndexValues(1),:) = [StraValuesSample, blanks(length(M(IndexValues,:)) - length(StraValuesSample))];

        for m = 1:size(M,1)
            fprintf(fid,'%s\n',M(m,:));
        end

        for n = 1:length(dataforfile)
            fprintf(fid,'%0.3f \t %0.3f \t %0.2f \t %0.3f\n',[dataforfile(n,1) dataforfile(n,2) dataforfile(n,3) dataforfile(n,4)]);
        end
        fclose(fid);

    end
end