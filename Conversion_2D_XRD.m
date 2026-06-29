function [IntensityProfiles, ImageInfo ] = Conversion_2D_XRD(FileName,bins)
%Function to extract intensity data from 2D detector image
%   Import tif image and obtain information
% t = Tiff(FileName,'r');
% imageData = read(t);

t = imread(FileName);

% imageData = t(:,:,1);
% imageData = t(1:360,1:1000,1);
% t = t(1:360,1:1000,1:3);
% imageData = read(t);
info = imfinfo(FileName);
% info.Height = 360;
% info.Width = 1000;
disp(['Image Width = ',num2str(info.Width)])
disp(['Image Height = ',num2str(info.Height)])
disp(['Image x-resolution = ',num2str(info.XResolution)])
disp(['Image y-resolution = ',num2str(info.YResolution)])
disp(['Image Samples per Pixel = ',num2str(info.SamplesPerPixel)])
disp(['Image Resolution unit = ',num2str(info.ResolutionUnit)])

for k = 1:(info.Height/bins)-1
    BinData(:,k) = 1 + ((k-1)*bins) : 1 + ((k-1)*bins) + bins;
end


% Bin size: over how much pixel lines should be averaged
% bins = NumberOfBins;

% if bins == info.Height
%     suma = sum(t,1)/bins;
% else
%     % Set gamma zero pixel and respective gamma ranges
%     gammaminusrange = 1:GammaZero+bins/2;
%     gammaplusrange = GammaZero+bins/2+1:info.Height;
%     
%     gammabinnedstepsminus = nan(bins,ceil(numel(gammaminusrange)./bins));
%     gammabinnedstepsminus(1:numel(gammaminusrange)) = flip(gammaminusrange);
%     gammabinnedstepsminus = flip(gammabinnedstepsminus,1);
%     gammabinnedstepsminus = flip(gammabinnedstepsminus,2);
%     
%     gammabinnedstepsplus = nan(bins,ceil(numel(gammaplusrange)./bins));
%     gammabinnedstepsplus(1:numel(gammaplusrange)) = gammaplusrange;
%     
%     gammabinnedsteps = [gammabinnedstepsminus gammabinnedstepsplus];
%     
%     for k = 1:size(gammabinnedsteps,2)
%         PixelNr = ~isnan(gammabinnedsteps(:,k));
%         PixelBinLength = length(PixelNr(PixelNr==1)~=0);
%         suma(k,:) = sum(t(gammabinnedsteps(~isnan(gammabinnedsteps(:,k)),k),:),1)/PixelBinLength;
%     end
% 
% end
% Number of bins with current bin size
% binsnr = size(t,1) / bins;
% % Number of steps 
% steps = linspace(bins,size(t,1),binsnr);
% 
% % Create profiles according to bin size and average intensities
% for k = 1:length(steps)
%     if k == 1
%         a1 = t(1:steps(k),:);
%         suma1 = sum(a1,1)/bins;
%         suma(:,k) = suma1;
%     else
%         a1 = t(steps(k-1)+1:steps(k),:);
%         suma1 = sum(a1,1)/bins;
%         suma(:,k) = suma1;
%     end
% end
% 
% % Create export variables
% IntensityProfiles = suma;



for k = 1:size(BinData,2)
    IntensityProfiles(:,k) = (sum(t(BinData(:,k),:),1)./(bins+1))';
end

IntensityProfiles = double(IntensityProfiles);
ImageInfo = info;

end