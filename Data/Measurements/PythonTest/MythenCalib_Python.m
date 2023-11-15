% Define python environment
% pyenv('Version','D:\Anaconda3\envs\xayutilities\python.exe')
% pe = pyenv;

if size(Spectra,2) ~= 640
    Spectra = Spectra';
end

spectra = py.numpy.array(Spectra);

if size(Angles,1) ~= 1
    Angles = Angles';
end

angles = py.numpy.array(Angles);

% Run python script that does the fitting of the scans and gives estimates
% for beta, L and n0
[result] = pyrunfile("MythenCalib.py","ReturnList",angles=angles,spectra=spectra);

width = abs(double(result{1}))

n0 = double(result{2})

tilt_beta = double(result{3})

L = 5e-5/width