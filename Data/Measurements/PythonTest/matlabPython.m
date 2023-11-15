% Define python environment
pyenv('Version','D:\Anaconda3\envs\xayutilities\python.exe')
pe = pyenv;
pe.Version
% Script for FuzzyBinning of 2D Mythen data 
NumBins = py.int(19400);
% Load meas data - "n x 640" format, with n = number of twotheta angles
if size(Intensity,2) ~= 640
    Intensity = Intensity';
end
% Convert matrix to python array
intensity = py.numpy.array(Intensity);
if size(twotheta,2) ~= 640
    twotheta = twotheta';
end
angles = py.numpy.array(twotheta);
% Run python script that does the fuzzy binning
[result] = pyrunfile("ConvertMeasDataMythen.py","ReturnList",NumBins=NumBins,angles=angles,intensity=intensity);
% Convert python array to matlab arry
X = double(result{1});
Y = double(result{2});
% Plot spectrum
plot(X,Y)

% 
% % Convert channel to degree
% % Zero channel from scanof primary beam
% n0 = 345.23;
% % Detector tilt
% beta = -0.383;
% % Distance detector - source
% L = 0.3357;
% % width of one channel
% w = 0.00005;
% % Number of channels
% n = 0:639;
% % Distance from each channel to detector center n0
% d = (n-n0)*w;
% % Measured twotheta angles
% twothetaCCH
% 
% % Calculate twotheta for each channel
% for l = 1:size(twothetaCCH,2)
%     for k = 1:size(d,2)
%         twotheta(l,k) = twothetaCCH(l) + asind(d(k)/L*(cosd(beta)/(1+(d(k)/L)^2 - 2*(d(k)/L)*sind(beta))).^0.5);
%     end
% end