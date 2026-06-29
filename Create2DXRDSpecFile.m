function [IntensityData,Intensity] = Create2DXRDSpecFile(FileName,ImageName,NumberOfBins,FileNameGammaData,Anode)
% Function used to create a SpecFile with theoretical energy positions of
% the material entered from the user. Input: 'Elemental formula, mpd
% File name, twotheta, Emax, Intensity, Name of output file', calibration
% parameters a, b and c e.g.
% CreateEtheoSpecFile('Au1','Au',16,80,150,'Au_tth16',0.033,0.011,-8.3e-9)

% % Intensität = Vektor mit Nullen der Länge 16384
% Intensity_tmp = zeros(992,1);
% % Ersetzen der Kanallagen
% Intensity_tmp = Int;
% % Umwandlung in Array(1024,16)
% Intensity = reshape(Intensity_tmp,16,62)';

IntensityData = Conversion_2D_XRD(ImageName,NumberOfBins);
assignin('base','IntensityData',IntensityData)

BinnedGamma = CalcBinnedGamma(FileNameGammaData, NumberOfBins);

% Create intensity data
for k = 1:size(IntensityData,2)
    Intensity{k} = reshape(IntensityData(1:992,k),16,62)';
end

% Load dummy spec file
DummySpec = load('SpecFileDummy2DXRD.mat');
Index_Scan = Tools.StringOperations.SearchString(DummySpec.SPECFileHeader,'#S');
% Get index of Anode entry
Index_Anode = Tools.StringOperations.SearchString(DummySpec.SPECFileHeader,'#HV_ANODE');
% Get index of @A
Index_tmp = Tools.StringOperations.SearchString(DummySpec.SPECFileHeader,'@A');
% Get index of MotorPositions
Index_MotorPos = Tools.StringOperations.SearchString(DummySpec.SPECFileHeader,'#P0');
% Create Spec file
Path = pwd;
fid = fopen([[Path,'\Data\Samples\'],FileName,'_',num2str(NumberOfBins),'PixelBin','.spec'],'w');
% Write file header
fprintf(fid,'%s\n',['#F /home/specadm/specdata/',FileName]);

for k = 2:Index_Scan-1
    fprintf(fid,'%s\n',strtrim(DummySpec.SPECFileHeader(k,:)));
end

for l = 1:size(Intensity,2)
%     fprintf(fid,'%s\n','#C Winkel im Probensystem:');
%     if BinnedGamma(l) < 0
%         fprintf(fid,'%s\n','#C phiP 0.000');
%     elseif BinnedGamma(l) > 0
%         fprintf(fid,'%s\n','#C phiP 180.000');
%     end
%     fprintf(fid,'%s\n',['#C psiP ',num2str(abs(BinnedGamma(l)))]);
%     fprintf(fid,'%s\n','#C eta 90.000');
%     fprintf(fid,'\n');

    % Write scan number to file
    str = ['#S ',num2str(l),'  mcaacq 600'];
    str = strrep(str,']','');
    str = strrep(str,'[','');
    fprintf(fid,'%s\n',str);
    
    
    for k = Index_Scan+1:Index_MotorPos-1
        fprintf(fid,'%s\n',strtrim(DummySpec.SPECFileHeader(k,:)));
    end

    str = ['#P0 -11.5 -1.22 19.351875 0 22.4 22.4 ',num2str(BinnedGamma(l)),' 0'];

%     if BinnedGamma(l) < 0
%         str = ['#P0 -11.5 -1.22 19.351875 0 22.4 22.4 ',num2str(BinnedGamma(l)),' 0'];
%     elseif BinnedGamma(l) > 0
%         str = ['#P0 -11.5 -1.22 19.351875 180 22.4 22.4 ',num2str(BinnedGamma(l)),' 0'];
%     end

    str = strrep(str,']','');
    str = strrep(str,'[','');
    fprintf(fid,'%s\n',str);

    for k = Index_MotorPos+1:Index_Anode-1
        fprintf(fid,'%s\n',strtrim(DummySpec.SPECFileHeader(k,:)));
    end

%     for k = Index_Scan+1:Index_Anode-1
%         fprintf(fid,'%s\n',strtrim(DummySpec.SPECFileHeader(k,:)));
%     end
    
    str = ['#HV_ANODE ',Anode];
    str = strrep(str,']','');
    str = strrep(str,'[','');
    fprintf(fid,'%s\n',str);
    
    for k = Index_Anode+1:Index_tmp-1
        fprintf(fid,'%s\n',strtrim(DummySpec.SPECFileHeader(k,:)));
    end
    
    
    for k = 1:size(Intensity{l},1)
        if k == 1
            str = mat2str(Intensity{l}(k,:));
            str = strrep(str,']','\');
            str = strrep(str,'[','@A ');
            str = strtrim(str);
            fprintf(fid,'%s\n',str);
        else
            str = mat2str(Intensity{l}(k,:));
            str = strrep(str,']','\');
            str = strrep(str,'[',' ');
            fprintf(fid,'%s\n',str);
        end
    end
    fprintf(fid,'\n');
    
end

fclose(fid);

end

% %% mean Gamma calculation
% pixels = 0:999;
% % Gamma from pyfi or whatever
% Gamma = -86.88158 + 0.12946*pixels;
% % 
% 
% pixels = GammaData(:,1);
% Gamma = GammaData(:,2);
% 
% GammaNew = reshape(Gamma,bins,size(Gamma,1)/bins);
% 
% gammaminusrange = 1:GammaZero+bins/2;
% gammaplusrange = GammaZero+bins/2+1:size(Gamma,1);
% 
% gammabinnedstepsminus = nan(bins,ceil(numel(gammaminusrange)./bins));
% gammabinnedstepsminus(1:numel(gammaminusrange)) = flip(gammaminusrange);
% gammabinnedstepsminus = flip(gammabinnedstepsminus,1);
% gammabinnedstepsminus = flip(gammabinnedstepsminus,2);
% 
% gammabinnedstepsplus = nan(bins,ceil(numel(gammaplusrange)./bins));
% gammabinnedstepsplus(1:numel(gammaplusrange)) = gammaplusrange;
% 
% gammabinnedsteps = [gammabinnedstepsminus gammabinnedstepsplus];
% 
% for k = 1:size(gammabinnedsteps,2)
%     PixelNr = ~isnan(gammabinnedsteps(:,k));
%     PixelBinLength = length(PixelNr(PixelNr==1)~=0);
%     gammatmp(k,:) = mean(GammaNew(gammabinnedsteps(~isnan(gammabinnedsteps(:,k)),k)));
% end