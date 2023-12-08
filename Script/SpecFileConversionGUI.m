function [meas,MeasurementBackup,DataTmp,Substrate,Diffractometer,P,T] = SpecFileConversionGUI(P,SampleInput,T)
%% (* Convert the measurement spec-file *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% This script converts and reads the measurement spec file.
% Name of the spec-file stored in "/Data/Measurements" (with extension).
SpecFileName = P.SpecFileName;            % <--
% Name of the Diffractometer-file stored in "/Data/Diffractometers".
% EDDI_5axis_tth --> synchrotron measurements
% LEDDI_9axis_tth --> LEDDI measurements
DiffractometerFileName = P.DiffractometerType;
% DiffractometerType = P.DiffractometerType;
% if DiffractometerType == 1
%     DiffractometerFileName = 'EDDI_5axis_tth';                          % <--
% elseif DiffractometerType == 2
% 	DiffractometerFileName = 'LEDDI_9axis_tth';
% elseif DiffractometerType == 3
% 	DiffractometerFileName = 'MetalJet-LIMAX-160';
% elseif DiffractometerType == 4
% 	DiffractometerFileName = 'MetalJet-LIMAX-70';
% end
% Which diffractometer has been used for the measurement:
% 1 = EDDI
% 2 = LEDDI
% DiffractometerType = P.Diffractometer;                                  % <--
% Type of measurement (standard, ascan/dscan)
% 1 = standard
% 2 = ascan, dscan ...
ScanMode = P.ScanMode;
% LoadFromSpecFileScript = P.LoadFromSpecFile;
% Choose the appropriate dead time correction for your measurements.
Calibration = P.Calibration;
% Available: 'Januar 2015', 'April 2015', 'Januar 2016', 'Februar 2016', 
% 'August 2016', 'Januar 2017', '30.Januar 2017'
% Clean up all temporary variables.
CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
clear Measurement;
% tic
% Create diffractometer object.
Diffractometer = Measurement.Diffractometer.LoadFromFile(DiffractometerFileName, Measurement.Diffractometer);
% Choose which file conversion has to be used.
% if LoadFromSpecFileScript == 1
    meas = Measurement.Measurement.LoadFromSpecFile_neu(SpecFileName, Diffractometer, ScanMode, Calibration);
%     meas = Measurement.Measurement.LoadFromSpecFile(SpecFileName, Diffractometer, DiffractometerType, Calibration);  
% else
%     meas = Measurement.Measurement.LoadFromSpecFile(SpecFileName, Diffractometer, DiffractometerType, Calibration);
% end
% Assign properties.
Sample = SampleInput;
set(meas, 'Sample', Sample);
MeasurementBackup = meas;
Substrate = T.Material.ShowSubstratePeaks;
% toc
% measnew = load('D:\Matlab - Auswertesoftware\Data\Results\MetalJet-LIMAX-160_new_format\Eberstein-Probe-unbeschichtet-tth19-y-scans_11052023_12052023\MeasData_new_Si_hex.mat');
% Eberstein-Probe-unbeschichtet-tth19-y-scans_11052023_12052023\MeasData_new_SiC_hex
% Eberstein-Probe-beschichtet-tth19-y-scans_12052023_16052023\MeasData_new_SiC_hex
% MeasurementBackup = measnew.measnew;
% meas = measnew.measnew;
assignin('base','measLoad',meas)

if strcmp(Diffractometer.Name,'ETA3000')
%     for c = 1:length(meas)
%         TwoTheta(:,c) = meas(c).twotheta;
%         Intensity(:,c) = meas(c).EDSpectrum(:,2);
%     end
% 
%     % Convert channel to degree
%     CalibParams = load(fullfile('Data','Calibration',[Calibration,'.mat']));
%     % Zero channel from scan of primary beam
%     n0 = CalibParams.zerochannel;
%     % Detector tilt
%     beta = CalibParams.beta;
%     % Distance detector - source
%     L = CalibParams.L;
%     % width of one channel
%     w = 0.00005;
%     % Number of channels
%     n = 0:639;
%     % Distance from each channel to detector center n0
%     d = (n-n0)*w;
%     
%     % Calculate twotheta for each channel
%     for l = 1:size(TwoTheta,2)
%         for m = 1:size(d,2)
%             twothetatmp(l,m) = TwoTheta(l) + asind(d(m)/L*(cosd(beta)/(1+(d(m)/L)^2 - 2*(d(m)/L)*sind(beta))).^0.5);
%         end
%     end
    
%     % Define python environment
%     pyenv('Version','D:\Anaconda3\envs\xayutilities\python.exe')
%     pe = pyenv;
%     pe.Version
    %% only for point detector mode
%     for c = 1:length(meas)
%         TwoTheta(:,c) = meas(c).twotheta;
% %         twothetatmp(:,c) = meas(c).twotheta;
%         Intensity(:,c) = meas(c).EDSpectrum(:,2);
%     end
% 
% %     % Script for FuzzyBinning of 2D Mythen data 
% %     NumBins = py.int(5120); %10240
% %     % Load meas data - "n x 640" format, with n = number of twotheta angles
%     if size(Intensity,2) ~= 640
%         Intensity = Intensity';
%     end
%     % Convert matrix to python array
%     
% %     if size(twothetatmp,2) ~= 640
% %         twothetatmp = twothetatmp';
% %     end
%     
% %     assignin('base','TwoTheta',TwoTheta)
% %     assignin('base','twothetatmp',twothetatmp)
% %     assignin('base','Intensity',Intensity)
% 
% %     % Run python script that does the fuzzy binning
% %     if size(unique(TwoTheta,'stable'),2) == 1
% %         for k = 1:size(Intensity,1)
% %             intensity = py.numpy.array(Intensity(k,:));
% %             angles = py.numpy.array(twothetatmp(k,:));
% %             result = pyrunfile("ConvertMeasDataMythen.py","ReturnList",NumBins=NumBins,angles=angles,intensity=intensity);
% %             % Convert python array to matlab arry
% %             X{k} = double(result{1});
% %             Y{k} = double(result{2});
% %         end
% % %         assignin('base','result',result)
% %         DataTmp = cell(1, length(meas));
% %         for c = 1:length(meas)
% %             meas(c).EDSpectrum = [X{c};Y{c}]';
% %             DataTmp{c} = meas(c).EDSpectrum;
% %         end
% %     
% %     else
% %         intensity = py.numpy.array(Intensity);
% %         angles = py.numpy.array(twothetatmp);
% %         [result] = pyrunfile("ConvertMeasDataMythen.py","ReturnList",NumBins=NumBins,angles=angles,intensity=intensity);
% %         % Convert python array to matlab arry
% %         X = double(result{1});
% %         Y = double(result{2});
% %     %     assignin('base','result',result)
% %         % Only keep one meas with corrected data
% %         meas(2:end) = [];
% %         DataTmp{1} = [X;Y]';
% %         meas(1).EDSpectrum = [X;Y]';
% %         meas(1).twotheta = TwoTheta;
% %     end
% 
%     TwoThetaReal = unique(TwoTheta);
%     indTwoThetaRealStart = find(TwoTheta==TwoThetaReal(1));
%     indTwoThetaRealEnd = find(TwoTheta==TwoThetaReal(end));
% %     assignin('base','indTwoThetaRealStart',indTwoThetaRealStart)
% %     assignin('base','indTwoThetaRealEnd',indTwoThetaRealEnd)
%     IndTwoThetaReal = [indTwoThetaRealStart; indTwoThetaRealEnd]';
%     Counts = sum(Intensity,2);
%     
%     for k = 1:size(IndTwoThetaReal,1)
%         ScanCounts{k} = Counts((IndTwoThetaReal(k,1):IndTwoThetaReal(k,2)));
%     end
%     
%     MeasScanCounts = Measurement.Measurement();
%     for k = 1:size(IndTwoThetaReal,1)
%         MeasScanCounts(k) = meas(IndTwoThetaReal(k,1));
%     end
%     
%     for k = 1:size(IndTwoThetaReal,1)
%         MeasScanCounts(k).EDSpectrum = [TwoThetaReal' ScanCounts{k}./MeasScanCounts(k).CountingTime];
%         MeasScanCounts(k).twotheta = TwoThetaReal;
%         MeasScanCounts(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCounts(k).SCSAngles.psi), '°'];
%     end
%     for k = 1:size(IndTwoThetaReal,1)
%         DataTmp{k} = MeasScanCounts(k).EDSpectrum;
%     end
% 
%     meas = MeasScanCounts;
% 
% %     assignin('base','result',result)
% %     assignin('base','X',X)
% %     assignin('base','Y',Y)
% %     if size(meas,2) == 1
% %         % Only keep one meas with corrected data
% %         meas(2:end) = [];
% %         DataTmp{1} = [X{1};Y{1}]';
% %         meas(1).EDSpectrum = [X{1};Y{1}]';
% %         meas(1).twotheta = TwoTheta;
% %     else
% %         DataTmp = cell(1, length(meas));
% %         for c = 1:length(meas)
% %             meas(c).EDSpectrum = [X{c};Y{c}]';
% %             DataTmp{c} = meas(c).EDSpectrum;
% %         end
% %     end
% %     assignin('base','meas1',meas)
    % Load data in point detector mode
    % Get twotheta and intensity
    if meas(1).MythenScanMode == 0
        for c = 1:length(meas)
            TwoTheta(:,c) = meas(c).twotheta;
            Intensity(:,c) = meas(c).EDSpectrum(:,2);
        end
        % Check format of meas data - "n x 640" format, with n = number of twotheta angles
        if size(Intensity,2) ~= 640
            Intensity = Intensity';
        end
        % Get unique twotheta values
        TwoThetaReal = unique(TwoTheta);
        indTwoThetaRealStart = find(TwoTheta==TwoThetaReal(1));
        indTwoThetaRealEnd = find(TwoTheta==TwoThetaReal(end));
        IndTwoThetaReal = [indTwoThetaRealStart; indTwoThetaRealEnd]';
        % Sum counts from each channel for each twotheta
        Counts = sum(Intensity,2);
        
        for k = 1:size(IndTwoThetaReal,1)
            ScanCounts{k} = Counts((IndTwoThetaReal(k,1):IndTwoThetaReal(k,2)));
        end
        
        MeasScanCounts = Measurement.Measurement();
        for k = 1:size(IndTwoThetaReal,1)
            MeasScanCounts(k) = meas(IndTwoThetaReal(k,1));
        end
        
        for k = 1:size(IndTwoThetaReal,1)
            MeasScanCounts(k).EDSpectrum = [TwoThetaReal' ScanCounts{k}./MeasScanCounts(k).CountingTime];
            MeasScanCounts(k).twotheta = TwoThetaReal;
            MeasScanCounts(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCounts(k).SCSAngles.psi), '°'];
        end

        for k = 1:size(IndTwoThetaReal,1)
            DataTmp{k} = MeasScanCounts(k).EDSpectrum;
        end

        data = load('D:\EDDIDAT_github\Data\Measurements\Schunk_Silver_TaC_sumData.mat');

        for k = 1:size(IndTwoThetaReal,1)
            MeasScanCounts(k).EDSpectrum = data.SilverCoUeScanSum15112023;
            MeasScanCounts(k).twotheta = data.SilverCoUeScanSum15112023(:,1);
            MeasScanCounts(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCounts(k).SCSAngles.psi), '°'];
        end

        for k = 1:size(IndTwoThetaReal,1)
            DataTmp{k} = MeasScanCounts(k).EDSpectrum;
        end
    
        meas = MeasScanCounts;
    elseif meas(1).MythenScanMode == 1
        for c = 1:length(meas)
            TwoTheta(:,c) = meas(c).twotheta;
            Intensity(:,c) = meas(c).EDSpectrum(:,2);
        end
    
        % Convert channel to degree
        CalibParams = load(fullfile('Data','Calibration',[Calibration,'.mat']));
        % Zero channel from scan of primary beam
        n0 = CalibParams.zerochannel;
        % Detector tilt
        beta = CalibParams.beta;
        % Distance detector - source
        L = CalibParams.L;
        % width of one channel
        w = 0.00005;
        % Number of channels
        n = 0:639;
        % Distance from each channel to detector center n0
        d = (n-n0)*w;
        
        % Calculate twotheta for each channel
        for l = 1:size(TwoTheta,2)
            for m = 1:size(d,2)
                twothetatmp(l,m) = TwoTheta(l) + asind(d(m)/L*(cosd(beta)/(1+(d(m)/L)^2 - 2*(d(m)/L)*sind(beta))).^0.5);
            end
        end
        % Script for FuzzyBinning of 2D Mythen data 
        NumBins = py.int(20480);
        % Load meas data - "n x 640" format, with n = number of twotheta angles
        if size(Intensity,2) ~= 640
            Intensity = Intensity';
        end
        % Convert matrix to python array
        
        if size(twothetatmp,2) ~= 640
            twothetatmp = twothetatmp';
        end

        % Run python script that does the fuzzy binning
        if size(unique(TwoTheta,'stable'),2) == 1
            for k = 1:size(Intensity,1)
                intensity = py.numpy.array(Intensity(k,:));
                angles = py.numpy.array(twothetatmp(k,:));
                result = pyrunfile("ConvertMeasDataMythen.py","ReturnList",NumBins=NumBins,angles=angles,intensity=intensity);
                % Convert python array to matlab arry
                X{k} = double(result{1});
                Y{k} = double(result{2});
            end
            DataTmp = cell(1, length(meas));
            for c = 1:length(meas)
                meas(c).EDSpectrum = [X{c};Y{c}]';
                DataTmp{c} = meas(c).EDSpectrum;
            end
        assignin('base','measLoad',meas)
        else
            intensity = py.numpy.array(Intensity);
            angles = py.numpy.array(twothetatmp);
            [result] = pyrunfile("ConvertMeasDataMythen.py","ReturnList",NumBins=NumBins,angles=angles,intensity=intensity);
            % Convert python array to matlab arry
            X = double(result{1});
            Y = double(result{2});
        %     assignin('base','result',result)
            % Only keep one meas with corrected data
            meas(2:end) = [];
            DataTmp{1} = [X;Y]';
            meas(1).EDSpectrum = [X;Y]';
            meas(1).twotheta = TwoTheta;
        end
    elseif meas(1).MythenScanMode == 2
        for c = 1:length(meas)
            TwoTheta(:,c) = meas(c).twotheta;
            Intensity(:,c) = meas(c).EDSpectrum(:,2);
        end
        
        DataTmp = cell(1, length(meas));
        for c = 1:length(meas)
            DataTmp{c} = meas(c).EDSpectrum;
        end
        
        if size(Intensity,2) ~= 640
            Intensity = Intensity';
        end
        
        spectra = py.numpy.array(Intensity);
        
        if size(TwoTheta,1) ~= 1
            TwoTheta = TwoTheta';
        end
        
        angles = py.numpy.array(TwoTheta);
        
        % Run python script that does the fitting of the scans and gives estimates
        % for beta, L and n0
        [result] = pyrunfile("MythenCalib.py","ReturnList",angles=angles,spectra=spectra);
        
        width = abs(double(result{1}));
        
        mythen.zerochannel = double(result{2});
        
        mythen.beta = double(result{3});
        
        mythen.L = 5e-5/width;

        [filename, filepath] = uiputfile({'*.mat', 'MAT-files (*.mat)'}, 'Save MYTHEN calibration parameters', [General.ProgramInfo.Path,'\Data\Calibration\',...
                    ['ETA3000_',meas(1).Anode,'Ka_',date]]);

        if ischar(filename)
            save(fullfile(filepath, filename), '-struct', 'mythen');
        end
        
%         set(h.plotEtheo,'visible','off')
%         set(h.checkboxtheopeaks1,'value',0)
        
    end
else
    DataTmp = cell(1, length(meas));
    for c = 1:length(meas)
        DataTmp{c} = meas(c).EDSpectrum;
    end
end
% Clean up all temporary variables.
if (CleanUpTemporaryVariables)
    clear('P');
end

disp('spec-file converted');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++