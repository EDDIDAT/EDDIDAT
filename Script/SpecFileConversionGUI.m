function [meas,MeasurementBackup,DataTmp,Diffractometer,P,T] = SpecFileConversionGUI(P,SampleInput,T,h)
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
% assignin('base','measoriginal',meas)
% %% Check if multiple spectra were recorded under the same psi angle
% if strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
%     % Check if psi angles were measured multiple times
%     for k = 1:length(meas)
%         psi(k) = meas(k).Motors_all.Chi;
%         phi(k) = meas(k).SCSAngles.phi;
%     end
%     
%     if length(psi) > length(unique(psi))+1 && length(unique(psi)) ~= 1 && length(psi) ~= 2*length(unique(psi))
%         % Get psi and phi values
%         for k = 1:length(meas)
%             psi(k) = meas(k).Motors_all.Chi;
%             phi(k) = meas(k).SCSAngles.phi;
%         end
%         
%         % Find unique psi values
%         [uniqueA i j] = unique(psi,'first');
% 
%         % Create matrix with psi and phi values
%         c = [psi;phi];
%             if phi(1) == 0 || phi(1) == 180
%                 % Find scan index for psi = 0 and phi = 180
%                 indpsi0phi180 = find(ismember(c',[0 180],'rows'));
%                 % Add scan index for scan with psi = 0 and phi = 180
%                 i(end+1) = indpsi0phi180;
%             elseif phi(1) == 90 || phi(1) == 270
%                 % Find scan index for psi = 0 and phi = 180
%                 indpsi90phi270 = find(ismember(c',[0 270],'rows'));
%                 % Add scan index for scan with psi = 0 and phi = 180
%                 i(end+1) = indpsi90phi270;
%             end
%         
% 
%         % Create new meas object with copies of scans with unique psi and phi values
%         measneu = meas(i);
%         
%         %indexToDupes = find(not(ismember(1:numel(psi),i)));
%         
%         % Get number of scans with equal psi angles
%         for k = 1:length(uniqueA)
%             psicount{k} = find(psi == uniqueA(k));
%         end
%         
%         % Delete scan for psi = 0 and phi = 180 in order to prevent summation over the same scan
%         for k = 1:size(psicount,2)
%             if phi(1) == 0 || phi(1) == 180
%                 idx = ismember(psicount{k}, indpsi0phi180);
%             elseif phi(1) == 90 || phi(1) == 270
%                 idx = ismember(psicount{k}, indpsi90phi270);
%             end
%             psicount{k}(idx) = [];
%         end
%         
%         % Sum up intensities for scans with equal psi angles 
%         for l = 1:length(psicount)
%             for k = 1:size(psicount{l},2)
%                 Intensity_tmp{l}(:,k) = meas(psicount{l}(k)).EDSpectrum(:,2);
%             end
%         end
%         
%         % Sum intensities
%         IntensityFinal = cellfun(@(x) {sum(x,2)}, Intensity_tmp);
%         
%         % Replace original intensities
%         for l = 1:length(IntensityFinal)
%             measneu(l).EDSpectrum(:,2) = IntensityFinal{l};
%         end
%         % Replace intensity of scan psi = 0 and phi = 180
%         measneu(end).EDSpectrum(:,2) = IntensityFinal{find(uniqueA==0)};
% %         meas = measneu;
% 
%         % Sort meas scans for phi and psi
%         for k = 1:length(measneu)
%             psineu(k) = measneu(k).Motors_all.Chi;
%             phineu(k) = measneu(k).SCSAngles.phi;
%         end
%         % Create matrix with psi and phi data
%         c = [phineu' psineu'];
%         % Add index to each row
%         c(:,3) = 1:length(c);
%         % Sort rows according to phi
%         csorted = sortrows(c,1);
%         if phi(1) == 0 || phi(1) == 180
%             % Find indices of phi = 0 and phi = 180 and create seperate tables
%             phitable1 = csorted(find(csorted(:,1) == 0,1,'first'):find(csorted(:,1) == 0,1,'last'),:);
%             phitable2 = csorted(find(csorted(:,1) == 180,1,'first'):find(csorted(:,1) == 180,1,'last'),:);
%         elseif phi(1) == 90 || phi(1) == 270
%             % Find indices of phi = 0 and phi = 180 and create seperate tables
%             phitable1 = csorted(find(csorted(:,1) == 90,1,'first'):find(csorted(:,1) == 90,1,'last'),:);
%             phitable2 = csorted(find(csorted(:,1) == 270,1,'first'):find(csorted(:,1) == 270,1,'last'),:);
%         end
%         % Sort table with phi = 180 data / phi = 270 data
%         phitable2 = sortrows(phitable2,2,'descend');
%         % Merge tables
%         TableSorted = [phitable1; phitable2];
%         % Sort meas data
%         meas = measneu(TableSorted(:,3));
%     end
%     disp('Multiple psi angles were detected. The intensities have been summed accordingly for each angle.');
% end

Sample = SampleInput;
set(meas, 'Sample', Sample);
MeasurementBackup = meas;

assignin('base','measLoad',meas.Clone)
% assignin('base','measorg',meas)

if strcmp(Diffractometer.Name,'ETA3000')
    % Load data in point detector mode
    % Get twotheta and intensity
    if meas(1).MythenScanMode == 0
        for c = 1:length(meas)
            TwoTheta(:,c) = meas(c).Motors_all.TwoTheta;
            Intensity(:,c) = meas(c).EDSpectrum(:,2);
            ScanModeNeu{c} = meas(c).ScanMode;
        end
        
        assignin('base','TwoTheta',TwoTheta)
        assignin('base','Intensity',Intensity)
        assignin('base','ScanModeNeu',ScanModeNeu)

        % 
        Intensity = Intensity';
        % Find index of scan modes
        idx_ascan = find(strcmp(ScanModeNeu,'ascan'));
        idx_mesh = find(strcmp(ScanModeNeu,'mesh'));
        idx_mcaacq = find(strcmp(ScanModeNeu,'mcaacq'));
        
        if ~isempty(idx_ascan)
            % Create measurement object
            MeasScanCountsascan = Measurement.Measurement();

            % Ascan preparations
            TwoThetaReal_ascan = unique(TwoTheta(idx_ascan));
            indTwoThetaRealStart_ascan = find(TwoTheta(idx_ascan)==TwoThetaReal_ascan(1));
            indTwoThetaRealEnd_ascan = find(TwoTheta(idx_ascan)==TwoThetaReal_ascan(end));
            IndTwoThetaReal_ascan = [indTwoThetaRealStart_ascan; indTwoThetaRealEnd_ascan]';

            for k = 1:size(IndTwoThetaReal_ascan,1)
                MeasScanCountsascan(k) = meas(idx_ascan(IndTwoThetaReal_ascan(k,1)));
            end

            % Sum counts from each channel for each twotheta
            if all(isprop(meas,'AScanSaveIntOnly')==0)
                Intensity_ascan = Intensity(idx_ascan,:);
                Counts = sum(Intensity_ascan,2);

                for k = 1:size(IndTwoThetaReal_ascan,1)
                    ScanCounts{k} = Counts((IndTwoThetaReal_ascan(k,1):IndTwoThetaReal_ascan(k,2)))./MeasScanCountsascan(k).CountingTime;
                end
                
            else
                Intensity_ascan = Intensity(idx_ascan);
                Counts = reshape(Intensity_ascan,length(TwoThetaReal_ascan),length(Intensity_ascan)/length(TwoThetaReal_ascan));

                for k = 1:size(IndTwoThetaReal_ascan,1)
                    ScanCounts{k} = Counts(:,k); %Counts((IndTwoThetaReal_ascan(k,1):IndTwoThetaReal_ascan(k,2)))./MeasScanCountsascan(k).CountingTime;
                end
            end

            for k = 1:size(IndTwoThetaReal_ascan,1)
                MeasScanCountsascan(k).EDSpectrum = [TwoThetaReal_ascan' ScanCounts{k}];
                MeasScanCountsascan(k).twotheta = TwoThetaReal_ascan;
                MeasScanCountsascan(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCountsascan(k).SCSAngles.psi), '°'];
            end
    
            for k = 1:size(IndTwoThetaReal_ascan,1)
                DataTmp_ascan{k} = MeasScanCountsascan(k).EDSpectrum;
            end

            meas_ascan = MeasScanCountsascan;
        end

        if ~isempty(idx_mesh)
            % Create measurement object
            MeasScanCountsmesh = Measurement.Measurement();

            % Mesh scan preparations
            TwoThetaReal_mesh = unique(TwoTheta(idx_mesh));
            indTwoThetaRealStart_mesh = find(TwoTheta(idx_mesh)==TwoThetaReal_mesh(1));
            indTwoThetaRealEnd_mesh = find(TwoTheta(idx_mesh)==TwoThetaReal_mesh(end));
            IndTwoThetaReal_mesh = [indTwoThetaRealStart_mesh; indTwoThetaRealEnd_mesh]';

            for k = 1:size(IndTwoThetaReal_mesh,1)
                MeasScanCountsmesh(k) = meas(idx_mesh(IndTwoThetaReal_mesh(k,1)));
            end
            
            % Sum counts from each channel for each twotheta
            if all(isprop(meas,'MeshSaveIntOnly')==0)
                Intensity_mesh = Intensity(idx_mesh,:);
                Counts = sum(Intensity_mesh,2);

                for k = 1:size(IndTwoThetaReal_mesh,1)
                    ScanCounts{k} = Counts((IndTwoThetaReal_mesh(k,1):IndTwoThetaReal_mesh(k,2)))./MeasScanCountsmesh(k).CountingTime;
                end
                
            else
                Intensity_mesh = Intensity(idx_mesh);
                Counts = reshape(Intensity_mesh,length(TwoThetaReal_mesh),length(Intensity_mesh)/length(TwoThetaReal_mesh));
            
                for k = 1:size(IndTwoThetaReal_mesh,1)
                    ScanCounts{k} = Counts(:,k);
                end
            end
    
            for k = 1:size(IndTwoThetaReal_mesh,1)
                MeasScanCountsmesh(k).EDSpectrum = [TwoThetaReal_mesh' ScanCounts{k}];
                MeasScanCountsmesh(k).twotheta = TwoThetaReal_mesh;
                MeasScanCountsmesh(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCountsmesh(k).SCSAngles.psi), '°'];
            end
    
            for k = 1:size(IndTwoThetaReal_mesh,1)
                DataTmp_mesh{k} = MeasScanCountsmesh(k).EDSpectrum;
            end
    
            meas_mesh = MeasScanCountsmesh;
        end

        if ~isempty(idx_mcaacq)   
            % Create measurement object
            MeasScanCountsmcaacq = Measurement.Measurement();

            % mcaacq scan preparations
            TwoThetaReal_mcaacq = unique(TwoTheta(idx_mcaacq));
            indTwoThetaRealStart_mcaacq = find(TwoTheta(idx_mcaacq)==TwoThetaReal_mcaacq(1));
            indTwoThetaRealEnd_mcaacq = find(TwoTheta(idx_mcaacq)==TwoThetaReal_mcaacq(end));
            IndTwoThetaReal_mcaacq = [indTwoThetaRealStart_mcaacq; indTwoThetaRealEnd_mcaacq]';

            for k = 1:size(IndTwoThetaReal_mcaacq,1)
                MeasScanCountsmcaacq(k) = meas(idx_mcaacq(IndTwoThetaReal_mcaacq(k,1)));
            end
            
            % Sum counts from each channel for each twotheta
            Intensity_mcaacq = Intensity(idx_mcaacq,:);
            Counts = sum(Intensity_mcaacq,2);
            
            for k = 1:size(IndTwoThetaReal_mcaacq,1)
                ScanCounts{k} = Counts(:,k);
            end
    
            for k = 1:size(IndTwoThetaReal_mcaacq,1)
                MeasScanCountsmcaacq(k).EDSpectrum = [TwoThetaReal_mcaacq' ScanCounts{k}];
                MeasScanCountsmcaacq(k).twotheta = TwoThetaReal_mcaacq;
                MeasScanCountsmcaacq(k).Name = ['Scan', num2str(k), ', Chi = ', num2str(MeasScanCountsmcaacq(k).SCSAngles.psi), '°'];
            end
    
            for k = 1:size(IndTwoThetaReal_mcaacq,1)
                DataTmp_mcaacq{k} = MeasScanCountsmcaacq(k).EDSpectrum;
            end
            
            meas_mcaacq = MeasScanCountsmcaacq;
      
        end

        if ~isempty(idx_ascan) && ~isempty(idx_mesh) && ~isempty(idx_mcaacq)
            meas = [meas_ascan, meas_mesh, meas_mcaacq];
            DataTmp = [DataTmp_ascan, DataTmp_mesh, DataTmp_mcaacq];
        elseif ~isempty(idx_ascan) && ~isempty(idx_mesh) && isempty(idx_mcaacq)
            meas = [meas_ascan, meas_mesh];
            DataTmp = [DataTmp_ascan, DataTmp_mesh];
        elseif ~isempty(idx_ascan) && isempty(idx_mesh) && ~isempty(idx_mcaacq)
            meas = [meas_ascan, meas_mcaacq];
            DataTmp = [DataTmp_ascan, DataTmp_mcaacq];
        elseif isempty(idx_ascan) && ~isempty(idx_mesh) && ~isempty(idx_mcaacq)
            meas = [meas_mesh, meas_mcaacq];
            DataTmp = [DataTmp_mesh, DataTmp_mcaacq];
        elseif ~isempty(idx_ascan) && isempty(idx_mesh) && isempty(idx_mcaacq)
            meas = meas_ascan;
            DataTmp = DataTmp_ascan;
        elseif isempty(idx_ascan) && ~isempty(idx_mesh) && isempty(idx_mcaacq)
            meas = meas_mesh;
            DataTmp = DataTmp_mesh;
        elseif isempty(idx_ascan) && isempty(idx_mesh) && ~isempty(idx_mcaacq)
            meas = meas_mcaacq;
            DataTmp = DataTmp_mcaacq;
        end
        
        % Check if chi = 0° was measured for each PhiS
        % Get psi and phiS values from each measurement
        for k = 1:length(meas)
            psi(k) = meas(k).Motors_all.Chi;
            phiS(k) = meas(k).Motors_all.PhiS;
        end
        % Count number of phiS angles
        phiwinkelcount = unique(phiS);
        % If more than one phiS was measured, check if number of psi values
        % with phiS = 0° and phiS = 90° is equal
        if length(phiwinkelcount) ~= 1
            if length(phiS(phiS == phiwinkelcount(1))) ~= length(phiS(phiS == phiwinkelcount(2)))
                [~,b] = find(phiS==0);
                phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phiS(b)));
                psizerodata = find(psi == 0);
                datacopy = meas(psizerodata).Clone;
                datacopy.Motors_all.PhiS = phimissingpsi;
                datacopy.Motors.PhiS = phimissingpsi;
                datacopy.SCSAngles.phi = abs(phimissingpsi);
                [~,b] = find(phiS==-180);
                meascorrected = [meas(1:b(1)-1) datacopy meas(b(1):end)];
                DataTmpcorrected = [DataTmp(1:b(1)-1) {datacopy.EDSpectrum} DataTmp(b(1):end)];
                meas = meascorrected;
                DataTmp = DataTmpcorrected;
            end
        end

    elseif meas(1).MythenScanMode == 1
        %Load data in line detector mode
        for c = 1:length(meas)
            TwoTheta(:,c) = meas(c).twotheta;
            Intensity(:,c) = meas(c).EDSpectrum(:,2);
        end
        assignin('base','TwoTheta',TwoTheta)
        assignin('base','Intensity',Intensity)
        % Convert channel to degree
        CalibParams = load(fullfile('Data','Calibration',[Calibration,'.mat']));
%         assignin('base','CalibParams',CalibParams)
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

        % Calculate blurring effect
        theta = TwoTheta/2;
        alpha = 0.496; %0.496;   % Divergence need to be calculated for ETA 2mm pinhole in front of polycap
        S = deg2rad(alpha)*L./sind(theta);
        blurring = get(h.selectblurring,'String');
        B = str2double(blurring);
%         B = 0.0005; % allowed blurring
        for k = 1:length(B)
            dmin(k,:) = -L/2 .*(1+S./B(k).*sind(theta)).*cotd(theta) + sqrt((L./2.*(1+S./B(k).*sind(theta)).*cotd(theta)).^2 + L.^2);
            dmax(k,:) = -L/2 .*(1-S./B(k).*sind(theta)).*cotd(theta) - sqrt((L./2.*(1-S./B(k).*sind(theta)).*cotd(theta)).^2 + L.^2);
        end
        
        dmax_inv = -1*dmax;
        dmin_inv = -1*dmin;
        
        dminmeas = Tools.Data.DataSetOperations.FindNearestIndex(d,dmin_inv);
        dmaxmeas = Tools.Data.DataSetOperations.FindNearestIndex(d,dmax_inv);
%         assignin('base','dminmeas',dminmeas)
%         assignin('base','dmaxmeas',dmaxmeas)
        % Calculate twotheta for each channel
        for l = 1:size(TwoTheta,2)
            for m = 1:size(d,2)
                twothetatmp(l,m) = TwoTheta(l) + asind(d(m)/L*(cosd(beta)/(1+(d(m)/L)^2 - 2*(d(m)/L)*sind(beta)).^0.5));
            end
        end
%         assignin('base','twothetatmp',twothetatmp)

        if size(Intensity,2) ~= 640
            Intensity = Intensity';
        end

        if size(twothetatmp,2) ~= 640
            twothetatmp = twothetatmp';
        end

%         assignin('base','twothetatmp',twothetatmp)
%         assignin('base','Intensity',Intensity)

        % Correct for blurring
%         for k = 1:size(Intensity,1)
%             if ~isnan(dminmeas(k)) && ~isnan(dmaxmeas(k))
% 	            Intensity_corr{k} = Intensity(k,dminmeas(k):dmaxmeas(k));
% 	            twothetatmp_corr{k} = twothetatmp(k,dminmeas(k):dmaxmeas(k));
%             elseif isnan(dminmeas(k)) && ~isnan(dmaxmeas(k))
% 	            Intensity_corr{k} = Intensity(k,1:dmaxmeas(k));
% 	            twothetatmp_corr{k} = twothetatmp(k,1:dmaxmeas(k));
%             elseif ~isnan(dminmeas(k)) && isnan(dmaxmeas(k))
% 	            Intensity_corr{k} = Intensity(k,dminmeas(k):end);
% 	            twothetatmp_corr{k} = twothetatmp(k,dminmeas(k):end);
%             elseif isnan(dminmeas(k)) && isnan(dmaxmeas(k))
% 	            Intensity_corr{k} = Intensity(k,:);
% 	            twothetatmp_corr{k} = twothetatmp(k,:);
%             end
%         end

        for k = 1:size(Intensity,1)
            if ~isnan(dminmeas(k)) && ~isnan(dmaxmeas(k))
                Intensity(k,1:dminmeas(k)) = NaN;
                Intensity(k,dmaxmeas(k):640) = NaN;
        
%                 twothetatmp(k,1:dminmeas(k)) = NaN;
%                 twothetatmp(k,dmaxmeas(k):end) = NaN;
        
            elseif isnan(dminmeas(k)) && ~isnan(dmaxmeas(k))
                Intensity(k,dmaxmeas(k):640) = NaN;
        
%                 twothetatmp(k,dmaxmeas(k):end) = NaN;
            elseif ~isnan(dminmeas(k)) && isnan(dmaxmeas(k))
                Intensity(k,1:dminmeas(k)) = NaN;
                
%                 twothetatmp(k,1:dminmeas(k)) = NaN;
            end
        end
        
%         assignin('base','twothetatmpcorr',twothetatmp)
%         assignin('base','Intensitycorr',Intensity)
        % Load meas data - "n x 640" format, with n = number of twotheta angles
%         if size(Intensity,2) ~= 640
%             Intensity = Intensity';
%         end
        % Convert matrix to python array
        
%         if size(twothetatmp,2) ~= 640
%             twothetatmp = twothetatmp';
%         end
        % Delete first and last channels
        Intensity(:,1:4) = [];
        twothetatmp(:,1:4) = [];
        Intensity(:,633:636) = [];
        twothetatmp(:,633:636) = [];

        % Script for FuzzyBinning of 2D Mythen data
        BinsUser = get(h.selectbins,'String');
        NumBins = py.int(str2double(BinsUser));
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
%         assignin('base','X_conv',X)
%         assignin('base','Y_conv',Y)
        else
%             intensity = py.numpy.array(cell2mat(Intensity_corr));
%             angles = py.numpy.array(cell2mat(twothetatmp_corr));

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

    % Get psi and phi angles from meas object
    for k = 1:length(meas)
        psi(k) = meas(k).SCSAngles.psi;
        phi(k) = meas(k).SCSAngles.phi;
    end
    
    % Hier muss geprueft werden, ob in zwei (oder mehr) phi-Richtungen
    % gemessen wurde. Entsprechend muss die fehlende Messung fuer psi = 0
    % kopiert werden.
    if length(unique(phi)) ~= 1
        % Find index of psi = 0°
        [~,bpsi0] = find(psi==0);
        % Get measured phi angles
        phiwinkelcount = unique(phi);
        % Get missing phi angles
        phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phi(bpsi0)));
        % Get measures phi angles
        phipsimeas = phiwinkelcount(ismember(phiwinkelcount,phi(bpsi0)));
        if ~isempty(phimissingpsi)
            % If LEDDI KETEK TWODET, phimissingpsi variable needs to be adjusted for
            % two detektor mode
            if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
                phimissingreplace = repelem(phimissingpsi,2);
            elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
                phimissingreplace = phimissingpsi;
            end
            % Clone meas objects with measured phi angles
            datacopy = meas(bpsi0).Clone;
            
            % Replace phi with missing phi
            for k = 1:length(datacopy)
                datacopy(k).Motors_all.Phi = phimissingreplace(k);
                datacopy(k).Motors.Phi = phimissingreplace(k);
                datacopy(k).SCSAngles.phi = abs(phimissingreplace(k));
            end
            % Combine cloned meas objects and put them at the right position
            if length(phimissingpsi) == 1
                [~,b1] = find(phi==phimissingpsi);
                if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
                    meascorrected = [meas(1:b1(1)-1) datacopy(1:2) meas(b1(1):end)];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) {datacopy(1:2).EDSpectrum} DataTmp(b1(1):end)];
                elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
                    meascorrected = [meas(1:b1(1)-1) datacopy(1) meas(b1(1):end)];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) datacopy(1).EDSpectrum DataTmp(b1(1):end)];
                end
            elseif length(phimissingpsi) == 2
                [~,b1] = find(phi==phimissingpsi(1));
                [~,b2] = find(phi==phimissingpsi(2));
                if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
                    meascorrected = [meas(1:b1(1)-1) datacopy(1:2) meas(b1(1):b2(1)-1) datacopy(3:4) meas(b2(1):b2(end))];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) {datacopy(1:2).EDSpectrum} DataTmp(b1(1):b2(1)-1) {datacopy(3:4).EDSpectrum} DataTmp(b2(1):b2(end))];
                elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
                    meascorrected = [meas(1:b1(1)-1) datacopy(1) meas(b1(1):b2(1)-1) datacopy(2) meas(b2(1):b2(end))];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) datacopy(1).EDSpectrum DataTmp(b1(1):b2(1)-1) datacopy(2).EDSpectrum DataTmp(b2(1):b2(end))];
                end
            end
            meas = meascorrected;
            DataTmp = DataTmpcorrected;
        end
    end

assignin('base','measmod',meas)
    
end
% Clean up all temporary variables.
if (CleanUpTemporaryVariables)
    clear('P');
end

disp('spec-file converted');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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

%         % Noise Correction of Mythen data
%         ScanCountsNoiseCorr = ScanCounts;
%         for i = 1:size(ScanCountsNoiseCorr,2)
%             % Find difference of measured counts for each twotheta step
%             % Calculate difference for increasing twotheta
%             for k = 2:length(ScanCountsNoiseCorr{i})
% 	            diffup(k) = ScanCountsNoiseCorr{i}(k)-ScanCountsNoiseCorr{i}(k-1);
%             end
%             
%             % Calculate difference for decreasing twotheta. Flip Intensity vector
%             tmp = flip(ScanCountsNoiseCorr{i});
%             
%             for k = 2:length(ScanCountsNoiseCorr{i})
% 	            diffdown(k) = tmp(k)-tmp(k-1);
%             end
%             
%             % Create matrix
%             diffall = [diffup'  flip(diffdown)'];
%             % Find indices of values for diffall > 1.15 (user selected limit)
%             idx = [diffall(:,1)>1.15 diffall(:,2)>1.15];
%             % Sum idx values in order to find entries which are 1 for both columns
%             Sumidx = sum(idx,2);
%             idxSumidx = find(Sumidx==2);
%             % Create matrix with intensity values for corresponding indices
%             NoiseCorr_tmp = [ScanCountsNoiseCorr{i}(idxSumidx-1) ScanCountsNoiseCorr{i}(idxSumidx) ScanCountsNoiseCorr{i}(idxSumidx+1) idxSumidx];
%             % Filter intensity values smaller than three counts (user selected limit)
%             idxNoiseCorr_tmp = [NoiseCorr_tmp(:,1)<=3 NoiseCorr_tmp(:,2) NoiseCorr_tmp(:,3)<=3 NoiseCorr_tmp(:,4)];
%             % Find entries which are 1 for both columns
%             NoiseCorr = find((idxNoiseCorr_tmp(:,1) + idxNoiseCorr_tmp(:,3))==2);
%             % Get indices of NoiseCorr values
%             idxNoiseCorr = NoiseCorr_tmp(NoiseCorr,4);
%             % Calculate average of idx-2/idx+2 in order to replace initial count value
%             for k = 1:length(idxNoiseCorr)
% 	            replacedata(k) = sum(ScanCounts{i}(idxNoiseCorr(k)-2:idxNoiseCorr(k)+2))/5;
%             end
%             % Correct intensity data
%             ScanCountsNoiseCorr{i}(idxNoiseCorr) = replacedata;
%         end

%         for k = 1:size(IndTwoThetaReal,1)
%             MeasScanCounts(k).EDSpectrum(:,2) = [ScanCountsNoiseCorr{k}];
%         end
%         assignin('base','ScanCountsNoiseCorr',ScanCountsNoiseCorr)