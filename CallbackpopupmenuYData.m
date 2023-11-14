function [h] = CallbackpopupmenuYData(h, PlotWindow, YDataStr, valueSlider)
% Load "DiffractionLines" variable, depending on diffractometer used
if strcmp(h.Diffsel,'LEDDI')
    if strcmp(h.Detsel,'Detector 1')
        % Change slider parameters according to number of FittedPeaksDet1
        DiffractionLinestmp = h.DiffractionLinesDet1;
        FittedPeakstmp = h.FittedPeaksDet1;
        FitPeaksLogical = h.FitPeaksLogicalDet1;
    elseif strcmp(h.Detsel,'Detector 2')
        % Change slider parameters according to number of FittedPeaksDet2
        DiffractionLinestmp = h.DiffractionLinesDet2;
        FittedPeakstmp = h.FittedPeaksDet2;
        FitPeaksLogical = h.FitPeaksLogicalDet2;
    end
else
    DiffractionLinestmp = h.DiffractionLines;
    FittedPeakstmp = h.FittedPeaks;
    FitPeaksLogical = h.FitPeaksLogical;
end

% assignin('base','DiffractionLinestmp',DiffractionLinestmp)
% assignin('base','FittedPeakstmp',FittedPeakstmp)

% Create handle variable names
LegData = join(['LegDataplotfitdata',PlotWindow]);
Axes = join(['axesplotfitdata',PlotWindow]);
PlotPhi0 = join(['fitdata',PlotWindow,'plotphi0']);
PlotErrPhi0 = join(['fitdata',PlotWindow,'ploterrphi0']);
PlotPhi90 = join(['fitdata',PlotWindow,'plotphi90']);
PlotErrPhi90 = join(['fitdata',PlotWindow,'ploterrphi90']);
PlotPhi180 = join(['fitdata',PlotWindow,'plotphi180']);
PlotErrPhi180 = join(['fitdata',PlotWindow,'ploterrphi180']);
PlotPhi270 = join(['fitdata',PlotWindow,'plotphi270']);
PlotErrPhi270 = join(['fitdata',PlotWindow,'ploterrphi270']);
LegLabelData = join(['LegLabelDataplotfitdata',PlotWindow]);
LegendPlot = join(['legendplotfitdata',PlotWindow]);

maxValLatticeSpacing = join(['maxValLatticeSpacing',PlotWindow]);
minValLatticeSpacing = join(['minValLatticeSpacing',PlotWindow]);
maxValEnergy_Max = join(['maxValEnergy_Max',PlotWindow]);
minValEnergy_Max = join(['minValEnergy_Max',PlotWindow]);
maxValIntegralWidth = join(['maxValIntegralWidth',PlotWindow]);
minValIntegralWidth = join(['minValIntegralWidth',PlotWindow]);
maxValFWHM = join(['maxValFWHM',PlotWindow]);
minValFWHM = join(['minValFWHM',PlotWindow]);
maxValIntegralInt = join(['maxValIntegralInt',PlotWindow]);
minValIntegralInt = join(['minValIntegralInt',PlotWindow]);

dataforplotting = join(['dataforplotting',PlotWindow]);
eta = join(['eta',PlotWindow]);
phi = join(['phi',PlotWindow]);
% Load parameters needed to calculate and plot stresses
% Convert cell array of strings to cell array of double
PsiFileTableData = get(h.tablepsifile,'data');

PsiFileTableDataArray = cellfun(@str2num, PsiFileTableData);
PeakCountColumn = size(PsiFileTableDataArray,2);
% Find unique values in column 1 from PsiFileTableDataArray
[C,~,~] = unique(PsiFileTableDataArray(:,1));
% Get row index containing unique C 
indexUniquePeak = cell(1);

for k = 1:length(C)
    indexUniquePeak{k} = find(PsiFileTableDataArray(:,1) == C(k));
end
% assignin('base','indexUniquePeakYData',indexUniquePeak)
% Get index from peak to be kept during further analysis
indexPeakToKeep = cell(1);
for k = 1:length(C)
    if h.P.PopupValueFitFunc == 2 %PV-Func
        indexPeakToKeep{k} = PsiFileTableDataArray(indexUniquePeak{k},PeakCountColumn);
    elseif h.P.PopupValueFitFunc == 3 %TCH-Func
        indexPeakToKeep{k} = PsiFileTableDataArray(indexUniquePeak{k},PeakCountColumn);
    end
end

% % Get index from peaks to be kept
% idxkeepPeaks = getappdata(0,'idxkeepPeaks');
% % If idxkeepPeaks is empty, use size of "DiffractionLinestmp" instead
% if isempty(idxkeepPeaks)
%     idxkeepPeaks = 1:size(DiffractionLinestmp{1},2);
% end

% Get index from peaks to be kept
if isfield(h, 'idxkeepPeaks')
    idxkeepPeaks = h.idxkeepPeaks;
else
    % If idxkeepPeaks does not exist, use size of "DiffractionLinestmp"
    % instead.
    idxkeepPeaks = (1:size(DiffractionLinestmp{1},2))';
end

% % Delete peaks that were deselected from the user
% if isfield(h, 'idxkeepPeaks')
%     if size(DiffractionLinestmp{1},2) ~= size(h.idxkeepPeaks,1)
%         for k = 1:length(DiffractionLinestmp)
%             DiffractionLinestmp{k}(h.idxdeletePeaks) = [];
%         end
%     end
%     
%     FittedPeakstmp{1}(h.idxdeletePeaks,:) = [];
%     
% end

% assignin('base','indexPeakToKeepYData',indexPeakToKeep)
% assignin('base','idxkeepPeaks',idxkeepPeaks)
% assignin('base','indexPeakToKeep',indexPeakToKeep)
% assignin('base','DiffractionLinestmpCorr',DiffractionLinestmp)
% assignin('base','FittedPeakstmp',FittedPeakstmp)

% Get Temperature information
for k = 1:length(h.Measurement)
    Temperaturetmp(:,k) = h.Measurement(k).Temperatures(1);
end

Temperaturetmp = mat2cell(Temperaturetmp',length(Temperaturetmp),1);

% % Get Weight Factor
% for k = 1:size(FittedPeakstmp{1},1)
%     WeightFactor{k} = FittedPeakstmp{1}(k,4);
% end

% Get Weight Factor
for m = 1:size(idxkeepPeaks,1)
    for k = 1:length(indexPeakToKeep{m})
        WeightFactor{m}(k,:) = FittedPeakstmp{indexPeakToKeep{m}(k)}(m,4);
%         WeightFactor{m}(k,:) = h.FittedPeaks{indexPeakToKeep{m}(k)}(idxkeepPeaks(m),4);
    end
end

% % Get parameters from fitted peak data
% for m = 1:size(DiffractionLinestmp{1},2)
% %     for k = 1:length(indexPeakToKeep{m})
%         % Read in Emax
%         Params.Energy_Max{m} = DiffractionLinestmp{1}(1,m).Energy_Max';
%         % Read in FWHM
%         Params.FWHM{m} = DiffractionLinestmp{1}(1,m).FWHM';
%         % Read in IB
%         Params.IntegralWidth{m} = DiffractionLinestmp{1}(1,m).IntegralWidth';
%         % Read in IntensityInt
%         Params.Intensity_Int{m} = DiffractionLinestmp{1}(1,m).Intensity_Int';
%         % Read in IntensityMax
%         Params.Intensity_Max{m} = DiffractionLinestmp{1}(1,m).Intensity_Max';
%         % Read in d-spacing
%         Params.LatticeSpacing{m} = DiffractionLinestmp{1}(1,m).LatticeSpacing';
%         % Read in d-spacing error
%         Params.LatticeSpacing_Delta{m} = DiffractionLinestmp{1}(1,m).LatticeSpacing_Delta';
%         % Read in psi Winkel
%         Params.Psi_Winkel{m} = DiffractionLinestmp{1}(1,m).SCSAngles.psi';
%         % Read in phi Winkel
%         Params.Phi_Winkel{m} = DiffractionLinestmp{1}(1,m).SCSAngles.phi';
% %     end
% end

% Get parameters from fitted peak data
for m = 1:size(idxkeepPeaks,1)
    for k = 1:length(indexPeakToKeep{m})
%         Read in Emax
        Params.Energy_Max{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Energy_Max;
%         Read in FWHM
        Params.FWHM{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).FWHM;
%         Read in IB
        Params.IntegralWidth{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).IntegralWidth;
%         Read in IntensityInt
        Params.Intensity_Int{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Intensity_Int;
%         Read in IntensityMax
        Params.Intensity_Max{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Intensity_Max;
%         Read in d-spacing
        Params.LatticeSpacing{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).LatticeSpacing;
%         Read in d-spacing error
        Params.LatticeSpacing_Delta{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).LatticeSpacing_Delta;
%         Read in psi Winkel
        Params.Psi_Winkel{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).SCSAngles.psi;
%         Read in phi Winkel
        Params.Phi_Winkel{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).SCSAngles.phi;
    end
end
% assignin('base','Params2',Params)
Params.Temperature = repmat(Temperaturetmp,1,size(idxkeepPeaks,1));
Params.WeightFactor = WeightFactor;

% If measured under more than one phi angle, rearrange data
for k = 1:size(Params.Phi_Winkel,2)
    [PhiWinkel{k},ia{k},~] = unique(Params.Phi_Winkel{k});
end

% Distinction between measurements under different phi angles
if length(ia{1}) == 1 || length(ia{1}) > 4
    ParamsToFit = Params;
elseif length(ia{1}) == 2
    % Measurements performed under two different phi angles
    for j = 1:length(ia{1})
        for k = 1:size(Params.Energy_Max,2)
            if j ~= 2
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):ia{k}(j+1)-1);
            elseif j == 2
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):end);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):end);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):end);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):end);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):end);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):end);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):end);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):end);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):end);
            end
        end
    end
elseif length(ia{1}) == 3
    % Measurements performed under three different phi angles
    for j = 1:length(ia{1})
        for k = 1:size(Params.Energy_Max,2)
            if j ~= 2
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):ia{k}(j+1)-1);
            elseif j == 3
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):end);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):end);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):end);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):end);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):end);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):end);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):end);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):end);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):end);
            end
        end
    end
elseif length(ia{1}) == 4
    % Measurements performed under four different phi angles
    for j = 1:length(ia{1})
        for k = 1:size(Params.Energy_Max,2)
            if j ~= 4
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):ia{k}(j+1)-1);
            elseif j == 4
                % Read in Emax
                ParamsToFit(j).Energy_Max{k} = Params.Energy_Max{k}(ia{k}(j):end);
                % Read in FWHM
                ParamsToFit(j).FWHM{k} = Params.FWHM{k}(ia{k}(j):end);
                % Read in IB
                ParamsToFit(j).IntegralWidth{k} = Params.IntegralWidth{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Int{k} = Params.Intensity_Int{k}(ia{k}(j):end);
                % Read in Intensity
                ParamsToFit(j).Intensity_Max{k} = Params.Intensity_Max{k}(ia{k}(j):end);
                % Read in d-spacing
                ParamsToFit(j).LatticeSpacing{k} = Params.LatticeSpacing{k}(ia{k}(j):end);
                % Read in d-spacing error
                ParamsToFit(j).LatticeSpacing_Delta{k} = Params.LatticeSpacing_Delta{k}(ia{k}(j):end);
                % Read in psi Winkel
                ParamsToFit(j).Psi_Winkel{k} = Params.Psi_Winkel{k}(ia{k}(j):end);
                % Read in phi Winkel
                ParamsToFit(j).Phi_Winkel{k} = Params.Phi_Winkel{k}(ia{k}(j):end);
                % Read in Temperature
                ParamsToFit(j).Temperature{k} = Params.Temperature{k}(ia{k}(j):end);
                % Read in Weight Factor
                ParamsToFit(j).WeightFactor{k} = Params.WeightFactor{k}(ia{k}(j):end);
            end
        end
    end
end

% Find indices of phi angles.
if length(unique(ParamsToFit(1).Phi_Winkel{1})) <= 4
    idxphi0 = find(PhiWinkel{1}==0);
    idxphi90 = find(PhiWinkel{1}==90);
    idxphi180 = find(PhiWinkel{1}==180);
    idxphi270 = find(PhiWinkel{1}==270);
else
    idxphi0 = [];
    idxphi90 = [];
    idxphi180 = [];
    idxphi270 = [];
end

% Calculate tau
for j = 1:length(ParamsToFit)
    for k = 1:size(ParamsToFit(j).Energy_Max,2)
        tau(j).absorbcoeff{k} = h.Measurement(1).Sample.Materials(1).LAC(ParamsToFit(j).Energy_Max{k});
    end
end

for j = 1:length(ParamsToFit)
    for k = 1:size(ParamsToFit(j).Energy_Max,2)
        tau(j).temptau{k} = (sind(h.Measurement(1).twotheta./2).*cosd(ParamsToFit(j).Psi_Winkel{k}))./(2.*tau(j).absorbcoeff{k}./10000);
    end
end

% assignin('base','ParamsToFit',ParamsToFit)

% % Create hkl label (needs to be executed here already
% DataPeaksfromFit = get(h.tablephasehkl,'data');
% assignin('base','DataPeaksfromFit',DataPeaksfromFit)
% assignin('base','idxSelectPeaktable',h.idxSelectPeaktable)
% Peakstmp = DataPeaksfromFit(repmat(FitPeaksLogical(1:size(DataPeaksfromFit,1),1),1,5));
% 
% if size(Peakstmp,1) ~= 1
%     Peaks = reshape(Peakstmp,size(Peakstmp,1)/5,5);
% else
%     Peaks = Peakstmp;
% end
% 
% Peaks = cell2mat(Peaks);
% if length(idxkeepPeaks) ~= size(Peaks,1)
%     Peaks = Peaks(idxkeepPeaks,:);
% end
% assignin('base','Peaks',Peaks)
if isfield(h, 'idxSelectPeaktable')
    Peaks = h.hkltablepsifile(h.idxSelectPeaktable,:);
else
    % Create hkl label (needs to be executed here already
    DataPeaksfromFit = get(h.tablephasehkl,'data');
    Peakstmp = DataPeaksfromFit(repmat(FitPeaksLogical(1:size(DataPeaksfromFit,1),1),1,5));

    if size(Peakstmp,1) ~= 1
        Peaks = reshape(Peakstmp,size(Peakstmp,1)/5,5);
    else
        Peaks = Peakstmp;
    end
end
% assignin('base','Peaks',Peaks)
if iscell(Peaks)
    Peaks = cell2mat(Peaks);
    h.PeaksforLabel = Peaks;
else
    h.PeaksforLabel = Peaks;
end
% assignin('base','Peaks1',Peaks)
if ~isfield(h,['eta', PlotWindow]) && ~isfield(h,['phi', PlotWindow])
    % Set data for plot of d-spacings, regression line, IB and Intensity
    if ~isempty(idxphi0)
        if strcmp(YDataStr,'d-spacing')
            if h.checkboxnorm.Value == 1
                % Get hkl values
                hhkl = h.PeaksforLabel(:,1);
                lhkl = h.PeaksforLabel(:,2);
                khkl = h.PeaksforLabel(:,3);
                hklsquare = sqrt(hhkl.^2+khkl.^2+lhkl.^2);
                
                YDataphi0 = ParamsToFit(idxphi0).LatticeSpacing;
                YDataphi0err = ParamsToFit(idxphi0).LatticeSpacing_Delta;
                
                for k = 1:size(hklsquare,1)
                    YDataphi0new{k} = YDataphi0{k}.*hklsquare(k);
                    YDataphi0errnew{k} = YDataphi0err{k}.*hklsquare(k);
                end
                YDataphi0 = YDataphi0new;
                YDataphi0err = YDataphi0errnew;
                ylabel(h.(Axes),'d [nm]')
                assignin('base','YDataphi0new',YDataphi0new)
                assignin('base','hklsquare',hklsquare)
                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k}).*hklsquare(k);
                    h.(minValLatticeSpacing){k} = min(minValtmp{k}).*hklsquare(k);
                end
               
            else
            
                YDataphi0 = ParamsToFit(idxphi0).LatticeSpacing;
                YDataphi0err = ParamsToFit(idxphi0).LatticeSpacing_Delta;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
                    h.(minValLatticeSpacing){k} = min(minValtmp{k});
                end
            end

            h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Energy')
            YDataphi0 = ParamsToFit(idxphi0).Energy_Max;
            ylabel(h.(Axes),'Energy [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).Energy_Max,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).Energy_Max{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).Energy_Max{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValEnergy_Max){k} = max(maxValtmp{k});
                h.(minValEnergy_Max){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValEnergy_Max){valueSlider}./0.05).*0.05 ceil(h.(maxValEnergy_Max){valueSlider}/0.05).*0.05];
            
            if abs(h.(Axes).YLim(1) - h.(minValEnergy_Max){k}) < 0.005
                h.(Axes).YLim(1) = h.(Axes).YLim(1) - 0.05;
            end
            
            if abs(h.(Axes).YLim(2) - h.(maxValEnergy_Max){k}) < 0.005
                h.(Axes).YLim(2) = h.(Axes).YLim(2) + 0.05;
            end
            
            yticks(h.(Axes),'auto')
%             assignin('base','maxValEnergy_Max',h.(maxValEnergy_Max))
            h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            YDataphi0 = ParamsToFit(idxphi0).IntegralWidth;
            ylabel(h.(Axes),'IB [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValIntegralWidth){k} = max(maxValtmp{k});
                h.(minValIntegralWidth){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValIntegralWidth){valueSlider}./0.05).*0.05 ceil(h.(maxValIntegralWidth){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'FWHM')
            YDataphi0 = ParamsToFit(idxphi0).FWHM;
            ylabel(h.(Axes),'FWHM [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).FWHM,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).FWHM{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).FWHM{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValFWHM){k} = max(maxValtmp{k});
                h.(minValFWHM){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValFWHM){valueSlider}./0.05).*0.05 ceil(h.(maxValFWHM){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Weighting Factor')
            YDataphi0 = ParamsToFit(idxphi0).WeightFactor;
            ylabel(h.(Axes),'Weighting Factor \eta')
            h.(Axes).YLim = [0 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
        elseif strcmp(YDataStr,'Form Factor')
            for k = 1:length(ParamsToFit(idxphi0).FWHM)
                YDataphi0{k} = ParamsToFit(idxphi0).FWHM{k}./ParamsToFit(idxphi0).IntegralWidth{k};
            end
            ylabel(h.(Axes),'Form factor FWHM/IB')
            h.(Axes).YLim = [0.6 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            YDataphi0 = ParamsToFit(idxphi0).Intensity_Int;
            ylabel(h.(Axes),'Int. Intensity [cts]')
            yticks(h.(Axes),'auto')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        elseif strcmp(YDataStr,'Max. Intensity')
            YDataphi0 = ParamsToFit(idxphi0).Intensity_Max;
            ylabel(h.(Axes),'Max. Intensity [cts]')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        end

        if strcmp(YDataStr,'d-spacing')
            set(h.(PlotErrPhi0), 'Visible', 'on')
            set(h.(PlotPhi0), 'Visible', 'off')
            set(h.(PlotErrPhi0), {'YData','YNegativeDelta','YPositiveDelta'}, {YDataphi0{valueSlider},YDataphi0err{valueSlider},YDataphi0err{valueSlider}});
        else
            set(h.(PlotPhi0), 'Visible', 'on')
            set(h.(PlotErrPhi0), 'Visible', 'off')
            set(h.(PlotErrPhi0), {'YData','YNegativeDelta','YPositiveDelta'}, {zeros(size(YDataphi0{valueSlider},1),1),zeros(size(YDataphi0{valueSlider},1),1),zeros(size(YDataphi0{valueSlider},1),1)});
            set(h.(PlotPhi0),'YData',YDataphi0{valueSlider})
        end
    end

    if ~isempty(idxphi90)
        if strcmp(YDataStr,'d-spacing')
            if h.checkboxnorm.Value == 1
                % Get hkl values
                hhkl = h.PeaksforLabel(:,1);
                lhkl = h.PeaksforLabel(:,2);
                khkl = h.PeaksforLabel(:,3);
                hklsquare = sqrt(hhkl.^2+khkl.^2+lhkl.^2);
                
                YDataphi90 = ParamsToFit(idxphi90).LatticeSpacing;
                YDataphi90err = ParamsToFit(idxphi90).LatticeSpacing_Delta;
                
                for k = 1:size(hklsquare,1)
                    YDataphi90new{k} = YDataphi90{k}.*hklsquare(k);
                    YDataphi90errnew{k} = YDataphi90err{k}.*hklsquare(k);
                end
                YDataphi90 = YDataphi90new;
                YDataphi90err = YDataphi90errnew;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k}).*hklsquare(k);
                    h.(minValLatticeSpacing){k} = min(minValtmp{k}).*hklsquare(k);
                end
               
            else
            
                YDataphi90 = ParamsToFit(idxphi90).LatticeSpacing;
                YDataphi90err = ParamsToFit(idxphi90).LatticeSpacing_Delta;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
                    h.(minValLatticeSpacing){k} = min(minValtmp{k});
                end
            end
            h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Energy')
            set(h.fitdata1plotphi90,'visible','on')
            YDataphi90 = ParamsToFit(idxphi90).Energy_Max;
            ylabel(h.(Axes),'Energy [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).Energy_Max,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).Energy_Max{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).Energy_Max{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValEnergy_Max){k} = max(maxValtmp{k});
                h.(minValEnergy_Max){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValEnergy_Max){valueSlider}./0.05).*0.05 ceil(h.(maxValEnergy_Max){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            YDataphi90 = ParamsToFit(idxphi90).IntegralWidth;
            ylabel(h.(Axes),'IB [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValIntegralWidth){k} = max(maxValtmp{k});
                h.(minValIntegralWidth){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValIntegralWidth){valueSlider}./0.05).*0.05 ceil(h.(maxValIntegralWidth){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'FWHM')
            YDataphi90 = ParamsToFit(idxphi90).FWHM;
            ylabel(h.(Axes),'FWHM [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).FWHM,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).FWHM{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).FWHM{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValFWHM){k} = max(maxValtmp{k});
                h.(minValFWHM){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValFWHM){valueSlider}./0.05).*0.05 ceil(h.(maxValFWHM){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Weighting Factor')
            YDataphi90 = ParamsToFit(idxphi90).WeightFactor;
            ylabel(h.(Axes),'Weighting Factor \eta')
            h.(Axes).YLim = [0 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
        elseif strcmp(YDataStr,'Form Factor')
            for k = 1:length(ParamsToFit(idxphi90).FWHM)
                YDataphi90{k} = ParamsToFit(idxphi90).FWHM{k}./ParamsToFit(idxphi90).IntegralWidth{k};
            end
            ylabel(h.(Axes),'Form factor FWHM/IB')
            h.(Axes).YLim = [0.6 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            YDataphi90 = ParamsToFit(idxphi90).Intensity_Int;
            ylabel(h.(Axes),'Int. Intensity [cts]')
            yticks(h.(Axes),'auto')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        elseif strcmp(YDataStr,'Max. Intensity')
            YDataphi90 = ParamsToFit(idxphi90).Intensity_Max;
            ylabel(h.(Axes),'Max. Intensity [cts]')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        end

        if strcmp(YDataStr,'d-spacing')
            set(h.(PlotErrPhi90), 'Visible', 'on')
            set(h.(PlotPhi90), 'Visible', 'off')
            set(h.(PlotErrPhi90), {'YData','YNegativeDelta','YPositiveDelta'}, {YDataphi90{valueSlider},YDataphi90err{valueSlider},YDataphi90err{valueSlider}});
        else
            set(h.(PlotPhi90), 'Visible', 'on')
            set(h.(PlotErrPhi90), 'Visible', 'off')
            set(h.(PlotErrPhi90), {'YData','YNegativeDelta','YPositiveDelta'}, {zeros(size(YDataphi90{valueSlider},1),1),zeros(size(YDataphi90{valueSlider},1),1),zeros(size(YDataphi90{valueSlider},1),1)});
            set(h.(PlotPhi90),'YData',YDataphi90{valueSlider})
        end
    end

    if ~isempty(idxphi180)  
        if strcmp(YDataStr,'d-spacing')
            if h.checkboxnorm.Value == 1
                hhkl = h.PeaksforLabel(:,1);
                lhkl = h.PeaksforLabel(:,2);
                khkl = h.PeaksforLabel(:,3);
                hklsquare = sqrt(hhkl.^2+khkl.^2+lhkl.^2);
                
                YDataphi180 = ParamsToFit(idxphi180).LatticeSpacing;
                YDataphi180err = ParamsToFit(idxphi180).LatticeSpacing_Delta;
                
                for k = 1:size(hklsquare,1)
                    YDataphi180new{k} = YDataphi180{k}.*hklsquare(k);
                    YDataphi180errnew{k} = YDataphi180err{k}.*hklsquare(k);
                end
                YDataphi180 = YDataphi180new;
                YDataphi180err = YDataphi180errnew;
                ylabel(h.(Axes),'d [nm]')
                
                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k}).*hklsquare(k);
                    h.(minValLatticeSpacing){k} = min(minValtmp{k}).*hklsquare(k);
                end
                
            else
                YDataphi180 = ParamsToFit(idxphi180).LatticeSpacing;
                YDataphi180err = ParamsToFit(idxphi180).LatticeSpacing_Delta;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
                    h.(minValLatticeSpacing){k} = min(minValtmp{k});
                end
            end

            h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';

        elseif strcmp(YDataStr,'Energy')
            YDataphi180 = ParamsToFit(idxphi180).Energy_Max;
            ylabel(h.(Axes),'Energy [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).Energy_Max,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).Energy_Max{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).Energy_Max{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValEnergy_Max){k} = max(maxValtmp{k});
                h.(minValEnergy_Max){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValEnergy_Max){valueSlider}./0.05).*0.05 ceil(h.(maxValEnergy_Max){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            YDataphi180 = ParamsToFit(idxphi180).IntegralWidth;
            ylabel(h.(Axes),'IB [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValIntegralWidth){k} = max(maxValtmp{k});
                h.(minValIntegralWidth){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValIntegralWidth){valueSlider}./0.05).*0.05 ceil(h.(maxValIntegralWidth){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'FWHM')
            YDataphi180 = ParamsToFit(idxphi180).FWHM;
            ylabel(h.(Axes),'FWHM [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).FWHM,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).FWHM{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).FWHM{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValFWHM){k} = max(maxValtmp{k});
                h.(minValFWHM){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValFWHM){valueSlider}./0.05).*0.05 ceil(h.(maxValFWHM){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Weighting Factor')
            YDataphi180 = ParamsToFit(idxphi180).WeightFactor;
            ylabel(h.(Axes),'Weighting Factor \eta')
            h.(Axes).YLim = [0 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
        elseif strcmp(YDataStr,'Form Factor')
            for k = 1:length(ParamsToFit(idxphi180).FWHM)
                YDataphi180{k} = ParamsToFit(idxphi180).FWHM{k}./ParamsToFit(idxphi180).IntegralWidth{k};
            end
            ylabel(h.(Axes),'Form factor FWHM/IB')
            h.(Axes).YLim = [0.6 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            YDataphi180 = ParamsToFit(idxphi180).Intensity_Int;
            ylabel(h.(Axes),'Int. Intensity [cts]')
            yticks(h.(Axes),'auto')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        elseif strcmp(YDataStr,'Max. Intensity')
            YDataphi180 = ParamsToFit(idxphi180).Intensity_Max;
            ylabel(h.(Axes),'Max. Intensity [cts]')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        end

        if strcmp(YDataStr,'d-spacing')
            set(h.(PlotErrPhi180), 'Visible', 'on')
            set(h.(PlotPhi180), 'Visible', 'off')
            set(h.(PlotErrPhi180), {'YData','YNegativeDelta','YPositiveDelta'}, {YDataphi180{valueSlider},YDataphi180err{valueSlider},YDataphi180err{valueSlider}});
        else
            set(h.(PlotPhi180), 'Visible', 'on')
            set(h.(PlotErrPhi180), 'Visible', 'off')
            set(h.(PlotErrPhi180), {'YData','YNegativeDelta','YPositiveDelta'}, {zeros(size(YDataphi180{valueSlider},1),1),zeros(size(YDataphi180{valueSlider},1),1),zeros(size(YDataphi180{valueSlider},1),1)});
            set(h.(PlotPhi180),'YData',YDataphi180{valueSlider})
        end
    end

    if ~isempty(idxphi270)  
        if strcmp(YDataStr,'d-spacing')
            if h.checkboxnorm.Value == 1
                % Get hkl values
                hhkl = h.PeaksforLabel(:,1);
                lhkl = h.PeaksforLabel(:,2);
                khkl = h.PeaksforLabel(:,3);
                hklsquare = sqrt(hhkl.^2+khkl.^2+lhkl.^2);
                
                YDataphi270 = ParamsToFit(idxphi270).LatticeSpacing;
                YDataphi270err = ParamsToFit(idxphi270).LatticeSpacing_Delta;
                
                for k = 1:size(hklsquare,1)
                    YDataphi270new{k} = YDataphi270{k}.*hklsquare(k);
                    YDataphi270errnew{k} = YDataphi270err{k}.*hklsquare(k);
                end
                YDataphi270 = YDataphi270new;
                YDataphi270err = YDataphi270errnew;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k}).*hklsquare(k);
                    h.(minValLatticeSpacing){k} = min(minValtmp{k}).*hklsquare(k);
                end
               
            else
                
                YDataphi270 = ParamsToFit(idxphi270).LatticeSpacing;
                YDataphi270err = ParamsToFit(idxphi270).LatticeSpacing_Delta;
                ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
                    h.(minValLatticeSpacing){k} = min(minValtmp{k});
                end
            end
            h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Energy')
            set(h.fitdata1plotphi270,'visible','on')
            YDataphi270 = ParamsToFit(idxphi270).Energy_Max;
            ylabel(h.(Axes),'Energy [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).Energy_Max,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).Energy_Max{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).Energy_Max{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValEnergy_Max){k} = max(maxValtmp{k});
                h.(minValEnergy_Max){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValEnergy_Max){valueSlider}./0.05).*0.05 ceil(h.(maxValEnergy_Max){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            YDataphi270 = ParamsToFit(idxphi270).IntegralWidth;
            ylabel(h.(Axes),'IB [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValIntegralWidth){k} = max(maxValtmp{k});
                h.(minValIntegralWidth){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValIntegralWidth){valueSlider}./0.05).*0.05 ceil(h.(maxValIntegralWidth){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'FWHM')
            YDataphi270 = ParamsToFit(idxphi270).FWHM;
            ylabel(h.(Axes),'FWHM [keV]')

            for k = 1:length(ParamsToFit)
                for l = 1:size(ParamsToFit(k).FWHM,2)
                    maxValtmp{l}(k,:) = max(ParamsToFit(k).FWHM{l});
                    minValtmp{l}(k,:) = min(ParamsToFit(k).FWHM{l});
                end
            end

            for k = 1:size(maxValtmp,2)
                h.(maxValFWHM){k} = max(maxValtmp{k});
                h.(minValFWHM){k} = min(minValtmp{k});
            end

            h.(Axes).YLim = [floor(h.(minValFWHM){valueSlider}./0.05).*0.05 ceil(h.(maxValFWHM){valueSlider}/0.05).*0.05];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Weighting Factor')
            YDataphi270 = ParamsToFit(idxphi270).WeightFactor;
            ylabel(h.(Axes),'Weighting Factor \eta')
            h.(Axes).YLim = [0 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
        elseif strcmp(YDataStr,'Form Factor')
            for k = 1:length(ParamsToFit(idxphi270).FWHM)
                YDataphi270{k} = ParamsToFit(idxphi270).FWHM{k}./ParamsToFit(idxphi270).IntegralWidth{k};
            end
            ylabel(h.(Axes),'Form factor FWHM/IB')
            h.(Axes).YLim = [0.6 1];
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            YDataphi270 = ParamsToFit(idxphi270).Intensity_Int;
            ylabel(h.(Axes),'Int. Intensity [cts]')
            yticks(h.(Axes),'auto')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        elseif strcmp(YDataStr,'Max. Intensity')
            YDataphi270 = ParamsToFit(idxphi270).Intensity_Max;
            ylabel(h.(Axes),'Max. Intensity [cts]')
            h.(Axes).YLimMode = 'auto';
            ytickformat(h.(Axes),'auto')
        end

        if strcmp(YDataStr,'d-spacing')
            set(h.(PlotPhi270), 'Visible', 'off')
            set(h.(PlotErrPhi270), 'Visible', 'on')
            set(h.(PlotErrPhi270), {'YData','YNegativeDelta','YPositiveDelta'}, {YDataphi270{valueSlider},YDataphi270err{valueSlider},YDataphi270err{valueSlider}});
        else
            set(h.(PlotPhi270), 'Visible', 'on')
            set(h.(PlotErrPhi270), 'Visible', 'off')
            set(h.(PlotErrPhi270), {'YData','YNegativeDelta','YPositiveDelta'}, {zeros(size(YDataphi270{valueSlider},1),1),zeros(size(YDataphi270{valueSlider},1),1),zeros(size(YDataphi270{valueSlider},1),1)});
            set(h.(PlotPhi270),'YData',YDataphi270{valueSlider})
        end
    end

    % assignin('base','ParamsToFit',ParamsToFit)

    % Create variable with plot data
    if ~isempty(idxphi0)
        h.(dataforplotting).phi0.Y = YDataphi0;
        if strcmp(YDataStr,'d-spacing')
            h.(dataforplotting).phi0.Yerror = YDataphi0err;
        end
    end
    if ~isempty(idxphi90)
        h.(dataforplotting).phi90.Y = YDataphi90;
        if strcmp(YDataStr,'d-spacing')
            h.(dataforplotting).phi90.Yerror = YDataphi90err;
        end
    end
    if ~isempty(idxphi180)
        h.(dataforplotting).phi180.Y = YDataphi180;
        if strcmp(YDataStr,'d-spacing')
            h.(dataforplotting).phi180.Yerror = YDataphi180err;
        end
    end
    if ~isempty(idxphi270)
        h.(dataforplotting).phi270.Y = YDataphi270;
        if strcmp(YDataStr,'d-spacing')
            h.(dataforplotting).phi270.Yerror = YDataphi270err;
        end
    end

%     assignin('base','dataforplotting',h.(dataforplotting))


    % Create legend
    if ~isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0)];
        else
            h.(LegData) = [h.(PlotPhi0)];
        end

        h.(LegLabelData) = {'\phi = 0°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi90)];
        else
            h.(LegData) = [h.(PlotPhi90)];
        end

        h.(LegLabelData) = {'\phi = 90°'};
    elseif isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi180)];
        else
            h.(LegData) = [h.(PlotPhi180)];
        end

        h.(LegLabelData) = {'\phi = 180°'};
    elseif isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi270)];
        else
            h.(LegData) = [h.(PlotPhi270)];
        end

        h.(LegLabelData) = {'\phi = 270°'};     
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0) h.(PlotErrPhi90)];
        else
            h.(LegData) = [h.(PlotPhi0) h.(PlotPhi90)];
        end

        h.(LegLabelData) = {'\phi = 0°','\phi = 90°'};
    elseif ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)

        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0) h.(PlotErrPhi180)];
        else
            h.(LegData) = [h.(PlotPhi0) h.(PlotPhi180)];
        end

        h.(LegLabelData) = {'\phi = 0°','\phi = 180°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi90) h.(PlotErrPhi270)];
        else
            h.(LegData) = [h.(PlotPhi90) h.(PlotPhi270)];
        end

        h.(LegLabelData) = {'\phi = 90°','\phi = 270°'};
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0) h.(PlotErrPhi90) h.(PlotErrPhi180)];
        else
            h.(LegData) = [h.(PlotPhi0) h.(PlotPhi90) h.(PlotPhi180)];
        end

        h.(LegLabelData) = {'\phi = 0°','\phi = 90°','\phi = 180°'};
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0) h.(PlotErrPhi90) h.(PlotErrPhi270)];
        else
            h.(LegData) = [h.(PlotPhi0) h.(PlotPhi90) h.(PlotPhi270)];
        end

        h.(LegLabelData) = {'\phi = 0°','\phi = 90°','\phi = 270°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi90) h.(PlotErrPhi180) h.(PlotErrPhi270)];
        else
            h.(LegData) = [h.(PlotPhi90) h.(PlotPhi180) h.(PlotPhi270)];
        end

        h.(LegLabelData) = {'\phi = 90°','\phi = 180°','\phi = 270°'};
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        if strcmp(YDataStr,'d-spacing')
            h.(LegData) = [h.(PlotErrPhi0) h.(PlotErrPhi90) h.(PlotErrPhi180) h.(PlotErrPhi270)];
        else
            h.(LegData) = [h.(PlotPhi0) h.(PlotPhi90) h.(PlotPhi180) h.(PlotPhi270)];
        end

        h.(LegLabelData) = {'\phi = 0°','\phi = 90°','\phi = 180°','\phi = 270°'};    
    end

    % Legend for plot of d-spacings
    h.(LegendPlot) = legend(h.(Axes),h.(LegData),h.(LegLabelData));
    h.(LegendPlot).Visible = 'on';
    h.(LegendPlot).FontSize = 14;

%     % Create hkl label
%     DataPeaksfromFit = get(h.tablephasehkl,'data');
%     % assignin('base','DataPeaksfromFit',DataPeaksfromFit)
%     % assignin('base','FitPeaksLogical',h.FitPeaksLogical)
%     Peakstmp = DataPeaksfromFit(repmat(FitPeaksLogical(1:size(DataPeaksfromFit,1),1),1,5));
% 
%     if size(Peakstmp,1) ~= 1
%         Peaks = reshape(Peakstmp,size(Peakstmp,1)/5,5);
%     else
%         Peaks = Peakstmp;
%     end
% 
%     Peaks = cell2mat(Peaks);
%     if length(idxkeepPeaks) ~= size(Peaks,1)
%         Peaks = Peaks(idxkeepPeaks,:);
%     end
%     h.PeaksforLabel = Peaks;

    % Read hkl values from array
    for ii = 1:size(Peaks,1)
        hkllabeltmp(ii,:) = mat2str(Peaks(ii,(1:3)));
    end
    % Remove '[' and ']' from character array
    for ii = 1:size(hkllabeltmp,1)
        hkllabeltmp1(ii,:) = regexprep(hkllabeltmp(ii,:),'[','');
    end

    for ii = 1:size(hkllabeltmp,1)
        hkllabeltmp2(ii,:) = regexprep(hkllabeltmp1(ii,:),']','');
    end
    % Final output with hkl values
    hkllabel = hkllabeltmp2;
    h.labelforplot = hkllabel;
    
    title(h.(LegendPlot),[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
else
    % If eta measurements are analyzed, data has to be prepared in a different
    % way.
    if isfield(h,['eta', PlotWindow])
        if strcmp(YDataStr,'d-spacing')
            for i = 1:length(h.(eta).psiIndex{valueSlider})
                set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).Tabledspacing{valueSlider,i},h.(eta).Tabledspacingdelta{valueSlider,i},h.(eta).Tabledspacingdelta{valueSlider,i}});
            end
            ylabel(h.(Axes),'d [nm]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            for i = 1:length(h.(eta).psiIndex{valueSlider})
                set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).TableIB{valueSlider,i},h.(eta).TableIB{valueSlider,i}.*0,h.(eta).TableIB{valueSlider,i}.*0});
            end
            ylabel(h.(Axes),'IB [keV]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            for i = 1:length(h.(eta).psiIndex{valueSlider})
                set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).TableIntensity_Int{valueSlider,i},h.(eta).TableIntensity_Int{valueSlider,i}.*0,h.(eta).TableIntensity_Int{valueSlider,i}.*0});
            end
            ylabel(h.(Axes),'Int. Intensity [cts]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %4.f ';
        else
            warndlg('Option not available for eta measurements','Warning');
        end    

        % Create limits for plots
        % Limits for lattice spacings
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) + min(ParamsToFit(k).LatticeSpacing_Delta{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
            h.(minValLatticeSpacing){k} = min(minValtmp{k});
        end
        % Limits for integral breadth
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValIntegralWidth){k} = max(maxValtmp{k});
            h.(minValIntegralWidth){k} = min(minValtmp{k});
        end
        % Limits for integral intensity
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).Intensity_Int,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).Intensity_Int{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).Intensity_Int{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValIntegralInt){k} = max(maxValtmp{k});
            h.(minValIntegralInt){k} = min(minValtmp{k});
        end


        % Create hkl label
        DataPeaksfromFit = get(h.tablephasehkl,'data');
        % assignin('base','DataPeaksfromFit',DataPeaksfromFit)
        % assignin('base','FitPeaksLogical',h.FitPeaksLogical)
        Peakstmp = DataPeaksfromFit(repmat(FitPeaksLogical(1:size(DataPeaksfromFit,1),1),1,5));
        Peaks = reshape(Peakstmp,size(Peakstmp,1)/5,5);
        if iscell(Peaks)
            Peaks = cell2mat(Peaks);
        end
        h.PeaksforLabel = Peaks;
    %     assignin('base','Peaks',Peaks)
        % Read hkl values from array
        for ii = 1:size(Peaks,1)
            hkllabeltmp(ii,:) = mat2str(Peaks(ii,(1:3)));
        end
        % Remove '[' and ']' from character array
        for ii = 1:size(hkllabeltmp,1)
            hkllabeltmp1(ii,:) = regexprep(hkllabeltmp(ii,:),'[','');
        end

        for ii = 1:size(hkllabeltmp,1)
            hkllabeltmp2(ii,:) = regexprep(hkllabeltmp1(ii,:),']','');
        end
        % Final output with hkl values
        hkllabel = hkllabeltmp2;
        h.labelforplot = hkllabel;

        % Add legend to plot
        h.(eta).legend = legend(h.(Axes),h.(eta).LegData,h.(eta).leglabel);
        % Add reflex hkl to plot legend
        title(h.(eta).legend,[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
%     assignin('base','etaneu',h.(eta))

    % If phi measurements are analyzed, data has to be prepared in a different
    % way.
    elseif isfield(h,['phi', PlotWindow])
        if strcmp(YDataStr,'d-spacing')
            if h.checkboxnorm.Value == 1
                % Get hkl values
                hhkl = h.PeaksforLabel(:,1);
                lhkl = h.PeaksforLabel(:,2);
                khkl = h.PeaksforLabel(:,3);
                hklsquare = sqrt(hhkl.^2+khkl.^2+lhkl.^2);
                
                YDataphi0 = h.(phi).Tabledspacing;
                YDataphi0err = h.(phi).Tabledspacingdelta;
                
                for k = 1:size(hklsquare,1)
                    YDataphi0new{k} = YDataphi0{k}.*hklsquare(k);
                    YDataphi0errnew{k} = YDataphi0err{k}.*hklsquare(k);
                end
                
                YDataphi0 = YDataphi0new;
                YDataphi0err = YDataphi0errnew;
                
                h.(phi).Tabledspacing = YDataphi0';
                h.(phi).Tabledspacingdelta = YDataphi0err';
                assignin('base','hphineu',h.(phi))
                h.(dataforplotting).Y = YDataphi0;
                h.(dataforplotting).Yerror = YDataphi0err;
                
                for i = 1:length(h.(phi).psiIndex{valueSlider})
                    set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{YDataphi0{valueSlider,i},YDataphi0err{valueSlider,i},YDataphi0err{valueSlider,i}});
                end
%                 ylabel(h.(Axes),'d [nm]')

                for k = 1:length(ParamsToFit)
                    for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                        maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                        minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) - max(ParamsToFit(k).LatticeSpacing_Delta{l});
                    end
                end

                for k = 1:size(maxValtmp,2)
                    h.(maxValLatticeSpacing){k} = max(maxValtmp{k}).*hklsquare(k);
                    h.(minValLatticeSpacing){k} = min(minValtmp{k}).*hklsquare(k);
                end
               
            else
                YDataphi0 = h.(phi).Tabledspacing;
                YDataphi0err = h.(phi).Tabledspacingdelta;

                h.(dataforplotting).Y = YDataphi0;
                h.(dataforplotting).Yerror = YDataphi0err;

                for i = 1:length(h.(phi).psiIndex{valueSlider})
                    set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).Tabledspacing{valueSlider,i},h.(phi).Tabledspacingdelta{valueSlider,i},h.(phi).Tabledspacingdelta{valueSlider,i}});
                end
            end
            ylabel(h.(Axes),'d [nm]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.4f ';
        elseif strcmp(YDataStr,'Integral Breadth')
            for i = 1:length(h.(phi).psiIndex{valueSlider})
                set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).TableIB{valueSlider,i},h.(phi).TableIB{valueSlider,i}.*0,h.(phi).TableIB{valueSlider,i}.*0});
            end
            ylabel(h.(Axes),'IB [keV]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
        elseif strcmp(YDataStr,'Int. Intensity')
            for i = 1:length(h.(phi).psiIndex{valueSlider})
                set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).TableIntensity_Int{valueSlider,i},h.(phi).TableIntensity_Int{valueSlider,i}.*0,h.(phi).TableIntensity_Int{valueSlider,i}.*0});
            end
            ylabel(h.(Axes),'Int. Intensity [cts]')        
            ylim(h.(Axes),'auto')
            yticks(h.(Axes),'auto')
            h.(Axes).YAxis.TickLabelFormat = ' %4.f ';
        else
            warndlg('Option not available for phi measurements','Warning');
        end    

        h.(dataforplotting).phi0.Y = YDataphi0;
        
        % Create limits for plots
        % Limits for lattice spacings
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).LatticeSpacing,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).LatticeSpacing{l}) + max(ParamsToFit(k).LatticeSpacing_Delta{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).LatticeSpacing{l}) + min(ParamsToFit(k).LatticeSpacing_Delta{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValLatticeSpacing){k} = max(maxValtmp{k});
            h.(minValLatticeSpacing){k} = min(minValtmp{k});
        end
        % Limits for integral breadth
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).IntegralWidth,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).IntegralWidth{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).IntegralWidth{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValIntegralWidth){k} = max(maxValtmp{k});
            h.(minValIntegralWidth){k} = min(minValtmp{k});
        end
        % Limits for integral intensity
        for k = 1:length(ParamsToFit)
            for l = 1:size(ParamsToFit(k).Intensity_Int,2)
                maxValtmp{l}(k,:) = max(ParamsToFit(k).Intensity_Int{l});
                minValtmp{l}(k,:) = min(ParamsToFit(k).Intensity_Int{l});
            end
        end

        for k = 1:size(maxValtmp,2)
            h.(maxValIntegralInt){k} = max(maxValtmp{k});
            h.(minValIntegralInt){k} = min(minValtmp{k});
        end


        % Create hkl label
        DataPeaksfromFit = get(h.tablephasehkl,'data');
        % assignin('base','DataPeaksfromFit',DataPeaksfromFit)
        % assignin('base','FitPeaksLogical',h.FitPeaksLogical)
        Peakstmp = DataPeaksfromFit(repmat(FitPeaksLogical(1:size(DataPeaksfromFit,1),1),1,5));
        Peaks = reshape(Peakstmp,size(Peakstmp,1)/5,5);
        if iscell(Peaks)
            Peaks = cell2mat(Peaks);
        end
        h.PeaksforLabel = Peaks;
    %     assignin('base','Peaks',Peaks)
        % Read hkl values from array
        for ii = 1:size(Peaks,1)
            hkllabeltmp(ii,:) = mat2str(Peaks(ii,(1:3)));
        end
        % Remove '[' and ']' from character array
        for ii = 1:size(hkllabeltmp,1)
            hkllabeltmp1(ii,:) = regexprep(hkllabeltmp(ii,:),'[','');
        end

        for ii = 1:size(hkllabeltmp,1)
            hkllabeltmp2(ii,:) = regexprep(hkllabeltmp1(ii,:),']','');
        end
        % Final output with hkl values
        hkllabel = hkllabeltmp2;
        h.labelforplot = hkllabel;

        % Add legend to plot
        h.(phi).legend = legend(h.(Axes),h.(phi).LegData,h.(phi).leglabel);
        % Add reflex hkl to plot legend
        title(h.(phi).legend,[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
    end
end

end

