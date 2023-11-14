function [h] = CallbackpopupmenuXDataNonSPEC(h, PlotWindow, XDataStr, valueSlider)
% Load "DiffractionLines" variable, depending on diffractometer used
if strcmp(h.Diffsel,'LEDDI')
    if strcmp(h.Detsel,'Detector 1')
        % Change slider parameters according to number of FittedPeaksDet1
        DiffractionLinestmp = h.DiffractionLinesDet1;
    elseif strcmp(h.Detsel,'Detector 2')
        % Change slider parameters according to number of FittedPeaksDet2
        DiffractionLinestmp = h.DiffractionLinesDet2;
    end
else
    DiffractionLinestmp = h.DiffractionLines;
end

% Create handle variable names
Slider = join(['Sliderplotwindowfitdata',PlotWindow]);
Axes = join(['axesplotfitdata',PlotWindow]);
PlotPhi0 = join(['fitdata',PlotWindow,'plotphi0']);
PlotErrPhi0 = join(['fitdata',PlotWindow,'ploterrphi0']);
PlotPhi90 = join(['fitdata',PlotWindow,'plotphi90']);
PlotErrPhi90 = join(['fitdata',PlotWindow,'ploterrphi90']);
PlotPhi180 = join(['fitdata',PlotWindow,'plotphi180']);
PlotErrPhi180 = join(['fitdata',PlotWindow,'ploterrphi180']);
PlotPhi270 = join(['fitdata',PlotWindow,'plotphi270']);
PlotErrPhi270 = join(['fitdata',PlotWindow,'ploterrphi270']);
PlotCheckBoxPhi0 = join(['plotwindowfitdata',PlotWindow,'checkboxphi0']);
PlotCheckBoxPhi90 = join(['plotwindowfitdata',PlotWindow,'checkboxphi90']);
PlotCheckBoxPhi180 = join(['plotwindowfitdata',PlotWindow,'checkboxphi180']);
PlotCheckBoxPhi270 = join(['plotwindowfitdata',PlotWindow,'checkboxphi270']);
PopupmenuXData = join(['popupmenuXData',PlotWindow]);
PopupmenuYData = join(['popupmenuYData',PlotWindow]);

ScansForPlot = join(['ScansForPlot',PlotWindow]);
dataforplotting = join(['dataforplotting',PlotWindow]);
eta = join(['eta',PlotWindow]);

% Load parameters needed to calculate and plot stresses
% Convert cell array of strings to cell array of double
PsiFileTableData = get(h.tablepsifile,'data');

PsiFileTableDataArray = cellfun(@str2num, PsiFileTableData);
PeakCountColumn = size(PsiFileTableDataArray,2);
% Find unique values in column 1 from PsiFileTableDataArray
[C,~,~] = unique(PsiFileTableDataArray(:,1));
% Get row index containing unique C 
indexUniquePeak = cell(1);
% assignin('base','PsiFileTableDataArray',PsiFileTableDataArray)
for k = 1:length(C)
    indexUniquePeak{k} = find(PsiFileTableDataArray(:,1) == C(k));
end

% Get index from peak to be kept during further analysis
indexPeakToKeep = cell(1);
for k = 1:length(C)
    if h.P.PopupValueFitFunc == 2 %PV-Func
        indexPeakToKeep{k} = PsiFileTableDataArray(indexUniquePeak{k},PeakCountColumn);
    elseif h.P.PopupValueFitFunc == 3 %TCH-Func
        indexPeakToKeep{k} = PsiFileTableDataArray(indexUniquePeak{k},PeakCountColumn);
    end
end

% % Det index from peaks to be kept
% idxkeepPeaks = getappdata(0,'idxkeepPeaks');
% 
% % If idxkeepPeaks is empty, use size of "DiffractionLinestmp" instead
% if isempty(idxkeepPeaks) 
%         idxkeepPeaks = 1:size(DiffractionLinestmp{1},2);
% end


% Get index from peaks to be kept
if isfield(h, 'idxkeepPeaks')
    idxkeepPeaks = h.idxkeepPeaks;
else
    % If idxkeepPeaks does not exist, use size of "DiffractionLinestmp"
    % instead.
    idxkeepPeaks = (1:size(DiffractionLinestmp{1},2))';
end

% assignin('base','DiffractionLinestmp',DiffractionLinestmp)
if length(idxkeepPeaks) == 1
    set(h.(Slider),'Min',0);
    set(h.(Slider),'Max',1);
    set(h.(Slider),'SliderStep',[0 1]);
    set(h.(Slider),'Visible','off');
else
    set(h.(Slider),'Value',1);
    set(h.(Slider),'Min',1);
    set(h.(Slider),'Max',length(idxkeepPeaks));
    set(h.(Slider),'SliderStep',[1/(length(idxkeepPeaks)-1) 1/(length(idxkeepPeaks)-1)]);
end

for k = 1:length(h.Measurement)
    Scantmp(:,k) = k;
end

Scantmp = mat2cell(Scantmp',length(Scantmp),1);
% assignin('base','Scantmp',Scantmp)
% assignin('base','DiffractionLinestmp',DiffractionLinestmp)
% assignin('base','indexPeakToKeep',indexPeakToKeep)
% assignin('base','idxkeepPeaks',idxkeepPeaks)

h.(ScansForPlot) = Scantmp;
% Get parameters from fitted peak data
for m = 1:size(idxkeepPeaks,1)
    for k = 1:length(indexPeakToKeep{m})
        % Read in Emax
        Params.Energy_Max{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Energy_Max;
        % Read in FWHM
        Params.FWHM{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).FWHM;
        % Read in IB
        Params.IntegralWidth{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).IntegralWidth;
        % Read in IntensityInt
        Params.Intensity_Int{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Intensity_Int;
        % Read in IntensityMax
        Params.Intensity_Max{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).Intensity_Max;
        % Read in d-spacing
        Params.LatticeSpacing{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).LatticeSpacing;
        % Read in d-spacing error
        Params.LatticeSpacing_Delta{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).LatticeSpacing_Delta;
        % Read in psi Winkel
        Params.Psi_Winkel{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).SCSAngles.psi;
        % Read in phi Winkel
        Params.Phi_Winkel{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).SCSAngles.phi;
        % Read in phi Winkel
        Params.Eta_Winkel{m}(k,:) = DiffractionLinestmp{indexPeakToKeep{m}(k),1}(1,idxkeepPeaks(m)).SCSAngles.eta;
    end
end


% Params.Temperature = repmat(Temperaturetmp,1,size(idxkeepPeaks,2));
% Params.Scans = repmat(Scantmp,1,size(idxkeepPeaks,2));
Params.Scans = indexPeakToKeep;
assignin('base','Params',Params)
% assignin('base','Params',Params)
% If measured under more than one phi angle, rearrange data
for k = 1:size(Params.Phi_Winkel,2)
	[PhiWinkel{k},ia{k},~] = unique(Params.Phi_Winkel{k});
end
h.PhiWinkelForPlot = PhiWinkel;
% Find indices of phi angles.
h.idxphi0 = find(PhiWinkel{1}==0);
h.idxphi90 = find(PhiWinkel{1}==90);
h.idxphi180 = find(PhiWinkel{1}==180);
h.idxphi270 = find(PhiWinkel{1}==270);

% If Eta or sin²Eta was choosen, check whether eta was changed during
% measurement
if strcmp(XDataStr,'Eta') || strcmp(XDataStr,'sin²Eta')
    % Check if eta was changed during the measurement
    for k = 1:size(Params,2)
        for l = 1:size(Params(k).Eta_Winkel,2)
            if all(Params(k).Eta_Winkel{l} == 90)
                index(k) = 1;
            else
                index(k,l) = 0;
            end
        end
    end
    if all(index == 1)
        msgbox('Eta was not varied during the measurement!','Warning Message','warn')
        % Set pop up menu to defautl value
        set(h.(PopupmenuXData),'Value',1)
        return
    end
end

% Delete previous plots (if  present) in order to update the plot
if ~ismember(0,PhiWinkel{1})
    set(h.(PlotPhi0),'visible', 'off')
    set(h.(PlotErrPhi0),'visible', 'off')
else
    set(h.(PlotPhi0),'visible', 'on')
    set(h.(PlotErrPhi0),'visible', 'on')
end

if ~ismember(90,PhiWinkel{1})
    set(h.(PlotPhi90),'visible', 'off')
    set(h.(PlotErrPhi90),'visible', 'off')
else
    set(h.(PlotPhi90),'visible', 'on')
    set(h.(PlotErrPhi90),'visible', 'on')
end

if ~ismember(180,PhiWinkel{1})
    set(h.(PlotPhi180),'visible', 'off')
    set(h.(PlotErrPhi180),'visible', 'off')
else
    set(h.(PlotPhi180),'visible', 'on')
    set(h.(PlotErrPhi180),'visible', 'on')
end

if ~ismember(270,PhiWinkel{1})
    set(h.(PlotPhi270),'visible', 'off')
    set(h.(PlotErrPhi270),'visible', 'off')
else
    set(h.(PlotPhi270),'visible', 'on')
    set(h.(PlotErrPhi270),'visible', 'on')
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):ia{k}(j+1)-1);
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):end);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):end);
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):ia{k}(j+1)-1);
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):end);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):end);
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):ia{k}(j+1)-1);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):ia{k}(j+1)-1);
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
                % Read in eta Winkel
                ParamsToFit(j).Eta_Winkel{k} = Params.Eta_Winkel{k}(ia{k}(j):end);
                % Read in Scans
                ParamsToFit(j).Scans{k} = Params.Scans{k}(ia{k}(j):end);
            end
        end
    end
end

% assignin('base','ParamsToFit',ParamsToFit)

% Find indices of phi angles.
idxphi0 = find(PhiWinkel{1}==0);
idxphi90 = find(PhiWinkel{1}==90);
idxphi180 = find(PhiWinkel{1}==180);
idxphi270 = find(PhiWinkel{1}==270);

% Create vectors with dspacings according to the number of phi angles used
% in the measurement
if ~isempty(idxphi0) && isempty(idxphi90) && isempty(idxphi180) && isempty(idxphi270)
    % sigma11 || sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})
elseif isempty(idxphi0) && ~isempty(idxphi90) && isempty(idxphi180) && isempty(idxphi270)
    % sigma11 || sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})  
elseif ~isempty(idxphi0) && ~isempty(idxphi90) && isempty(idxphi180) && isempty(idxphi270)
    % sigma11 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})
elseif isempty(idxphi0) && ~isempty(idxphi90) && ~isempty(idxphi180) && isempty(idxphi270)
    % sigma11 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})
elseif isempty(idxphi0) && isempty(idxphi90) && ~isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
elseif ~isempty(idxphi0) && isempty(idxphi90) && isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
elseif ~isempty(idxphi0) && isempty(idxphi90) && ~isempty(idxphi180) && isempty(idxphi270)
    % sigma11 + sigma13
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})
elseif isempty(idxphi0) && ~isempty(idxphi90) && isempty(idxphi180) && ~isempty(idxphi270)
    % sigma22 + sigma23
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'}) 
elseif ~isempty(idxphi0) && isempty(idxphi90) && ~isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma13 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
elseif ~isempty(idxphi0) && ~isempty(idxphi90) && ~isempty(idxphi180) && isempty(idxphi270)
    % sigma11 + sigma13 + sigma22
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'off'})
elseif ~isempty(idxphi0) && ~isempty(idxphi90) && isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma22 + sigma23
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
elseif isempty(idxphi0) && ~isempty(idxphi90) && ~isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma22 + sigma23
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'off'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
elseif ~isempty(idxphi0) && ~isempty(idxphi90) && ~isempty(idxphi180) && ~isempty(idxphi270)
    % sigma11 + sigma13 + sigma22 + sigma23
    set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{1,'on'})
    set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{1,'on'})
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

for k = 1:size(tau,2)
    h.TauMaxAxesLimits{k} = cellfun(@max, tau(k).temptau);
end

% assignin('base','tau',tau)

% Set data for plot of d-spacings, regression line, IB and Intensity
if ~isempty(idxphi0)
    if strcmp(XDataStr,'Psi')
        XDataphi0 = ParamsToFit(idxphi0).Psi_Winkel;
        xlabel(h.(Axes),'\psi')
        h.(Axes).XLim = [0 90];
        h.(Axes).XTick = (0:10:90);
    elseif strcmp(XDataStr,'sin²Psi')
        func = @(x) sind(x).^2;
        XDataphi0 = cellfun(func,ParamsToFit(idxphi0).Psi_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\psi')
        h.(Axes).XLim = [0 1];
        h.(Axes).XTick = (0:0.1:1);
    elseif strcmp(XDataStr,'Eta')
        XDataphi0 = ParamsToFit(idxphi0).Eta_Winkel;
        xlabel(h.(Axes),'\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'sin²Eta')
        func = @(x) sind(x).^2;
        XDataphi0 = cellfun(func,ParamsToFit(idxphi0).Eta_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'tau')
        XDataphi0 = tau(idxphi0).temptau;
        taumax = cellfun(@max, XDataphi0);
        XLimtau = ceil(round(taumax(valueSlider),1)/5)*5;
        xlabel(h.(Axes),'tau [µm]')
        h.(Axes).XLim = [0 XLimtau];
        h.(Axes).XTick = (0:0.5:XLimtau);
    elseif strcmp(XDataStr,'Energy')
        XDataphi0 = ParamsToFit(idxphi0).Energy_Max;
        xlabel(h.(Axes),'Energy [keV]')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'Scan number')
        XDataphi0 = ParamsToFit(idxphi0).Scans;
        xlabel(h.(Axes),'Scan number')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    end
    
    set(h.(PlotPhi0),{'XData','YData'},{XDataphi0{valueSlider},zeros(size(XDataphi0{valueSlider},1),1)})
    set(h.(PlotErrPhi0),{'XData','YData','YNegativeDelta','YPositiveDelta'},{XDataphi0{valueSlider},zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1)})
end

if ~isempty(idxphi90)
    if strcmp(XDataStr,'Psi')
        XDataphi90 = ParamsToFit(idxphi90).Psi_Winkel;
        xlabel(h.(Axes),'\psi')
        h.(Axes).XLim = [0 90];
        h.(Axes).XTick = (0:10:90);
    elseif strcmp(XDataStr,'sin²Psi')
        func = @(x) sind(x).^2;
        XDataphi90 = cellfun(func,ParamsToFit(idxphi90).Psi_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\psi')
        h.(Axes).XLim = [0 1];
        h.(Axes).XTick = (0:0.1:1);
    elseif strcmp(XDataStr,'Eta')
        XDataphi90 = ParamsToFit(idxphi90).Eta_Winkel;
        xlabel(h.(Axes),'\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto') 
    elseif strcmp(XDataStr,'sin²Eta')
        func = @(x) sind(x).^2;
        XDataphi90 = cellfun(func,ParamsToFit(idxphi90).Eta_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'tau')
        XDataphi90 = tau(idxphi90).temptau;
        taumax = cellfun(@max, XDataphi90);
        XLimtau = ceil(round(taumax(valueSlider),1)/5)*5;
        xlabel(h.(Axes),'tau [µm]')
        h.(Axes).XLim = [0 XLimtau];
        h.(Axes).XTick = (0:0.5:XLimtau);
    elseif strcmp(XDataStr,'Energy')
        XDataphi90 = ParamsToFit(idxphi90).Energy_Max;
        xlabel(h.(Axes),'Energy [keV]')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'Scan number')
        XDataphi90 =  ParamsToFit(idxphi90).Scans;
        xlabel(h.(Axes),'Scan number')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    end
    
    set(h.(PlotPhi90),{'XData','YData'},{XDataphi90{valueSlider},zeros(size(XDataphi90{valueSlider},1),1)})
    set(h.(PlotErrPhi90),{'XData','YData','YNegativeDelta','YPositiveDelta'},{XDataphi90{valueSlider},zeros(size(XDataphi90{valueSlider},1),1),zeros(size(XDataphi90{valueSlider},1),1),zeros(size(XDataphi90{valueSlider},1),1)})
end

if ~isempty(idxphi180)  
    if strcmp(XDataStr,'Psi')
        XDataphi180 = ParamsToFit(idxphi180).Psi_Winkel;
        xlabel(h.(Axes),'\psi')
        h.(Axes).XLim = [0 90];
        h.(Axes).XTick = (0:10:90);
    elseif strcmp(XDataStr,'sin²Psi')
        func = @(x) sind(x).^2;
        XDataphi180 = cellfun(func,ParamsToFit(idxphi180).Psi_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\psi')
        h.(Axes).XLim = [0 1];
        h.(Axes).XTick = (0:0.1:1);
    elseif strcmp(XDataStr,'Eta')
        XDataphi180 = ParamsToFit(idxphi180).Eta_Winkel;
        xlabel(h.(Axes),'\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'sin²Eta')
        func = @(x) sind(x).^2;
        XDataphi180 = cellfun(func,ParamsToFit(idxphi180).Eta_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'tau')
        XDataphi180 = tau(idxphi180).temptau;
        taumax = cellfun(@max, XDataphi180);
        XLimtau = ceil(round(taumax(valueSlider),1)/5)*5;
        xlabel(h.(Axes),'tau [µm]')
        h.(Axes).XLim = [0 XLimtau];
        h.(Axes).XTick = (0:0.5:XLimtau);
    elseif strcmp(XDataStr,'Energy')
        XDataphi180 = ParamsToFit(idxphi180).Energy_Max;
        xlabel(h.(Axes),'Energy [keV]')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'Scan number')
        XDataphi180 = ParamsToFit(idxphi180).Scans;
        xlabel(h.(Axes),'Scan number')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    end
    
    set(h.(PlotPhi180),{'XData','YData'},{XDataphi180{valueSlider},zeros(size(XDataphi180{valueSlider},1),1)})
    set(h.(PlotErrPhi180),{'XData','YData','YNegativeDelta','YPositiveDelta'},{XDataphi180{valueSlider},zeros(size(XDataphi180{valueSlider},1),1),zeros(size(XDataphi180{valueSlider},1),1),zeros(size(XDataphi180{valueSlider},1),1)})
end

if ~isempty(idxphi270)  
    if strcmp(XDataStr,'Psi')
        XDataphi270 = ParamsToFit(idxphi270).Psi_Winkel;
        xlabel(h.(Axes),'\psi')
        h.(Axes).XLim = [0 90];
        h.(Axes).XTick = (0:10:90);
    elseif strcmp(XDataStr,'sin²Psi')
        func = @(x) sind(x).^2;
        XDataphi270 = cellfun(func,ParamsToFit(idxphi270).Psi_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\psi')
        h.(Axes).XLim = [0 1];
        h.(Axes).XTick = (0:0.1:1);
    elseif strcmp(XDataStr,'Eta')
        XDataphi270 = ParamsToFit(idxphi270).Eta_Winkel;
        xlabel(h.(Axes),'\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'sin²Eta')
        func = @(x) sind(x).^2;
        XDataphi270 = cellfun(func,ParamsToFit(idxphi270).Eta_Winkel,'UniformOutput',0);
        xlabel(h.(Axes),'sin²\eta')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'tau')
        XDataphi270 = tau(idxphi270).temptau;
        taumax = cellfun(@max, XDataphi270);
        XLimtau = ceil(round(taumax(valueSlider),1)/5)*5;
        xlabel(h.(Axes),'tau [µm]')
        h.(Axes).XLim = [0 XLimtau];
        h.(Axes).XTick = (0:0.5:XLimtau);
    elseif strcmp(XDataStr,'Energy')
        XDataphi270 = ParamsToFit(idxphi270).Energy_Max;
        xlabel(h.(Axes),'Energy [keV]')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    elseif strcmp(XDataStr,'Scan number')
        XDataphi270 =  ParamsToFit(idxphi270).Scans;
        xlabel(h.(Axes),'Scan number')
        h.(Axes).XLimMode = 'auto';
        xtickformat(h.(Axes),'auto')
        xticks(h.(Axes),'auto')
    end

    set(h.(PlotPhi270),{'XData','YData'},{XDataphi270{valueSlider},zeros(size(XDataphi270{valueSlider},1),1)})
    set(h.(PlotErrPhi270),{'XData','YData','YNegativeDelta','YPositiveDelta'},{XDataphi270{valueSlider},zeros(size(XDataphi270{valueSlider},1),1),zeros(size(XDataphi270{valueSlider},1),1),zeros(size(XDataphi270{valueSlider},1),1)})
end

% Create variable with plot data
if ~isempty(idxphi0)
    h.(dataforplotting).phi0.X = XDataphi0;
end
if ~isempty(idxphi90)
    h.(dataforplotting).phi90.X = XDataphi90;
end
if ~isempty(idxphi180)
    h.(dataforplotting).phi180.X = XDataphi180;
end
if ~isempty(idxphi270)
    h.(dataforplotting).phi270.X = XDataphi270;
end

% If eta measurements are analyzed, data has to be prepared in a different
% way.
if strcmp(XDataStr,'Eta') || strcmp(XDataStr,'sin²Eta')
    for i = 1:length(ParamsToFit.Psi_Winkel)
        h.(eta).psiIndex{i} = unique(ParamsToFit.Psi_Winkel{i}, 'stable');
    end
    assignin('base','hpsiIndex',h.(eta).psiIndex)

    for k = 1:length(ParamsToFit.Psi_Winkel)
        for i = 1:length(h.(eta).psiIndex{k})
            IndexMin(i) = arrayfun(@(x) find(ParamsToFit.Psi_Winkel{k} == x,1,'first'), h.(eta).psiIndex{k}(i) );
            IndexMax(i) = arrayfun(@(x) find(ParamsToFit.Psi_Winkel{k} == x,1,'last'), h.(eta).psiIndex{k}(i) );
            psiTable{k} = [IndexMin; IndexMax]';
        end
    end	


    for k = 1:length(ParamsToFit.Psi_Winkel)	
        for i = 1:length(h.(eta).psiIndex{k})
            h.(eta).TablePsi{k,i} = ParamsToFit.Psi_Winkel{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
%             h.(eta).TableTau{k,i} = ParamsToFit.Psi_Winkel{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
            h.(eta).TableEta{k,i} = ParamsToFit.Eta_Winkel{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
            h.(eta).Tabledspacing{k,i} = ParamsToFit.LatticeSpacing{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
            h.(eta).Tabledspacingdelta{k,i} = ParamsToFit.LatticeSpacing_Delta{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
            h.(eta).TableIB{k,i} = ParamsToFit.IntegralWidth{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
            h.(eta).TableIntensity_Int{k,i} = ParamsToFit.Intensity_Int{k}(psiTable{k}(i,1):psiTable{k}(i,2),:);
        end
    end
%     assignin('base','heta',h.(eta))
    % Set plot data from other plots to zero and invisible
    set(h.(PlotPhi0),{'XData','YData','Visible'},{zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1),'off'})
    set(h.(PlotErrPhi0),{'XData','YData','YNegativeDelta','YPositiveDelta','Visible'},{zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1),zeros(size(XDataphi0{valueSlider},1),1),'off'})
    
    % Plot sin²eta data. First, only zeros are plotted. Later the user can
    % choose which peak information he wants to plot as a function of eta
    % or sin²eta.
    hold(h.(Axes),'on')
    for i = 1:length(h.(eta).psiIndex{valueSlider})
        if strcmp(XDataStr,'Eta')
            h.(eta).etaplot{i} = errorbar(h.(Axes),h.(eta).TableEta{valueSlider,i},h.(eta).Tabledspacing{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i});
        elseif strcmp(XDataStr,'sin²Eta')
            h.(eta).etaplot{i} = errorbar(h.(Axes),sind(h.(eta).TableEta{valueSlider,i}).^2,h.(eta).Tabledspacing{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{i});
        end
        % Create label data from psi angles
        h.(eta).leglabel{i} = ['\psi = ',num2str(h.(eta).psiIndex{valueSlider}(i,:))];
    end
%     assignin('base','Eta',h.(eta))
    % Create data matrix for legend entries.
    for k = 1:length(h.(eta).etaplot)
        h.(eta).LegData(k) = h.(eta).etaplot{k};
    end
    
    hold(h.(Axes),'off')
    % Plot legend
%     h.(eta).legend = legend(h.(Axes),h.(eta).LegData,h.(eta).leglabel);
%     title(legeta,[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')

end

% assignin('base','dataforplotting',h.dataforplotting)

% Set title
title(h.(Axes),{strrep(strtrim(h.Measurement(1).MeasurementSeries),'_',' ');'   '},'HorizontalAlignment','center')

end

