% Define python environment
pyenv('Version','D:\Anaconda3\envs\xayutilities\python.exe')
pe = pyenv;
% pe.Version
% Script for FuzzyBinning of 2D Mythen data 
NumBins = py.int(10240);
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

