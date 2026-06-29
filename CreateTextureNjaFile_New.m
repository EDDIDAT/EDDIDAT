function CreateTextureNjaFile_New(FolderName,FileName,hklinfo,data)
%     psifiledata = str2double(PsiFileTableData(:,[8,7,4,10,11,12]));
    % Check psi data and find numnber of measured hkl
%     idxhkl = find(sum(psifiledata(:,1:2),2)==0);
%     assignin('base','FileName',FileName)
%     assignin('base','hklinfo',hklinfo)

    hkl = hklinfo(:,1:3);
    % Load dummy header for texture file
%     DummyTexture = fullfile('D:\EDDIDAT_github\Data\Materials\Texture-File-Header.txt');

    DummyTexture = fullfile('Data','Materials','Texture-File-Header.txt');
    M = Tools.StringOperations.AsciiFile2Text(DummyTexture,'\r\n');
%     assignin('base','M',M)
%     assignin('base','FileName',FileName)
%     assignin('base','data',data)

    for k = 1:size(hkl,1)
        Path = pwd;

        Path_tmp = fullfile(Path,'\Data\Results\Texture\',FolderName,'\');

        if exist(Path_tmp,'dir') ~= 7
            mkdir(Path_tmp);
        end

        fid = fopen([Path_tmp,FileName,'_',strrep(num2str(hkl(k,:)),' ',''),'.nja'],'w');
        % Change File name in header file
        IndexFileName = Tools.StringOperations.SearchString(M,'&Sample=');
        StrFileNameNew = [['&Sample=',FolderName],blanks(length(M(IndexFileName,:)) - length(['&Sample=',FolderName]))];
        M(IndexFileName(1),:) = StrFileNameNew;
        
        % Change hkl values
        IndexHKL = Tools.StringOperations.SearchString(M,'&H=');
        StrHKLSample = sprintf([['&H=',num2str(hkl(k,1))],'\t',['&K=',num2str(hkl(k,2))],'\t',['&L=',num2str(hkl(k,3))]]);
        StrHKLnew = [StrHKLSample, blanks(length(M(IndexHKL,:)) - length(StrHKLSample))];
        M(IndexHKL(1),:) = StrHKLnew;
        
        % Change texture step info for alpha and beta
%         IndexAlpha = Tools.StringOperations.SearchString(M,'&AlphaStart=');
%         StrAlphaSample = sprintf([['&AlphaStart=',num2str(min(psifiledata(:,1))),'.000'],'\t',['&AlphaEnd=',num2str(max(psifiledata(:,1))),'.000'],'\t',['&AlphaStep=',num2str(unique(diff(unique(psifiledata(:,1))))),'.000']]);
%         IndexBeta = Tools.StringOperations.SearchString(M,'&BetaStart=');
%         StrBetaSample = sprintf([['&BetaStart=',num2str(min(psifiledata(:,2))),'.000'],'\t',['&BetaEnd=',num2str(max(psifiledata(:,2))),'.000'],'\t',['&BetaStep=',num2str(unique(diff(unique(psifiledata(:,2))))),'.000']]);
%         M(IndexAlpha(1),:) = [StrAlphaSample, blanks(length(M(IndexAlpha,:)) - length(StrAlphaSample))];
%         M(IndexBeta(1),:) = [StrBetaSample, blanks(length(M(IndexBeta,:)) - length(StrBetaSample))];

        % Get data for hkl
%         if k ~= size(hkl,1)
%             dataforfile = psifiledata(idxhkl(k):idxhkl(k+1)-1,1:3);
%             dataforfile(:,4) = 0;
%         else
%             dataforfile = psifiledata(idxhkl(k):end,1:3);
%             dataforfile(:,4) = 0;
%         end
        
        % Set neg. intensity values to 0
%         dataforfile(dataforfile < 0) = 0;

        % Change number of values
        IndexValues = Tools.StringOperations.SearchString(M,'&NoValues=');
        StraValuesSample = ['&NoValues=',num2str(size(data{k},1))];
        M(IndexValues(1),:) = [StraValuesSample, blanks(length(M(IndexValues,:)) - length(StraValuesSample))];

        for m = 1:size(M,1)
            fprintf(fid,'%s\n',M(m,:));
        end

        for n = 1:length(data{k})
            fprintf(fid,'%0.3f \t %0.3f \t %0.2f \t %0.3f\n',[data{k}(n,1) data{k}(n,2) data{k}(n,3) data{k}(n,4)]);
        end
        fclose(fid);

    end
end