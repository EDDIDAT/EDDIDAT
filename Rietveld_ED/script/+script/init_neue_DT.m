% Clear the workspace before the script is initialized.
clear all

% Define the path of the Rietveld program.
% script.initpath_neue_DT;
rvpath = fullfile('D:\Matlab - Auswertesoftware\Rietveld_ED');

% Erzeuge leeren Container mit korrekter Groesse
% Define an emtpy container with the correct size by defining how many
% phases are present, how many spectra under how many phi angles are
% measured.
numberOfPhases = 1;
numberOfSpecs = 32;
% numberOfPhiAngles = 1;
% Define the rietveld container in which all parameters are stored.
rc = rietveld.base.RVContainer();
% Set the phase count according to the number of phases defined above.
rc.setPhaseCnt(numberOfPhases);

% Rohdaten einlesen
% Load the raw data. The raw data has to be transformed into a ".mat" file
% using the script "Script_FilePreparation". This script converts the
% ".dat" files into ".mat" files and defines what data is X-data and 
% Y-data. (Up to now no file header can be read!)
% The data needs to be stored in the folder defined in the command below.
% In this case it is the "CurrentProject" folder.
% dataY = zeros(1, numberOfSpecs);
% for i = 1:numberOfSpecs
% 	load(fullfile(rvpath, 'data', 'CurrentProject', ['Simulationsdaten_correct_23062016_', num2str(i),'.mat']));
% 	dataX = X;
% 	dataY(1:length(X),i) = Y;
% end

% Rohdaten einlesen - neues Verfahren
% Mit dem Tool "File-Preparation" werden die Rohdaten vorbereitet. Dabei
% erhaelt man eine Struktur, in der die Messdaten sowie die DeadTime,
% RingCurrent, Psi-Winkel und Phi-Winkel aufgefuehrt sind.

% dataY = zeros(1, numberOfSpecs);
% for i = 1:numberOfSpecs
% 	load(fullfile(rvpath, 'data', 'CurrentProject', 'Stahl_Probe3_1_phi_0_90_180_270_sin2psi_tth16_16092011.mat'));
% 	dataX = S.EDSpectrum{1,i}(:,1);
% 	dataY(1:length(S.EDSpectrum{1,i}(:,1)),i) = S.EDSpectrum{1,i}(:,2);
% end
load(fullfile(rvpath, 'Au_Eichmessung_01032016.mat'));

% numberOfSpecs = 1;
% numberOfSpecs = size(S.EDSpectrum,2);
numberOfPhiAngles = size(unique(S.Phi),2);

EDSpectrum = S.EDSpectrum;%([30:71]);%,33:61,65:93,97:125]);
dataX = zeros(1, numberOfSpecs);
dataY = zeros(1, numberOfSpecs);
for i = 1:numberOfSpecs
% 	dataX{:,i} = EDSpectrum{1,i}(:,1);
    dataX(1:length(EDSpectrum{1,i}(:,1)),i) = EDSpectrum{1,i}(:,1);
	dataY(1:length(EDSpectrum{1,i}(:,1)),i) = EDSpectrum{1,i}(:,2);
end

% Set the X and Y data in the rietveld container.
rc.setDataX(dataX);
rc.setDataY(dataY);

% Erzeuge Rietveld-Funktion
% Create the Rietveld function. The fit function is assembled using
% mutliple "section functions", where each one has a individual purpose. 
% If for example a correction should not be executed, the "Interface" of
% the respective function should be loaded instead. This way the function 
% has no influence on the calculations. If the respecitve function needs a
% subfunction to work properly, the respective sub function needs to be
% defined.

% FitFunction
	% Define the subfunctions to calculate the spectrum.
		% Energie-Positionen - EnergyPosCalib für Standardproben
		% Calculation of the energy positions. Different function are
		% available. 1) EnergyPos and 2) EnergyPosCalib. Function 2) allows
		% to refine calibration parameters in case the dead time correction
		% is not working properly. If changed, tmpTau also needs to be
		% changed.
		tmpEPos = rietveld.func.spec.EnergyPos();
		% Define the function used to fit the background.
		tmpBkg = rietveld.func.spec.bkg.Polynomial();
		% Define the modul to consider Dummy Peaks.
		tmpDummy = rietveld.func.spec.dummy.DummyPeaks();
		% Define the model to analyze each peak seperately (similar to the
		% mathematica data evaluation)
		tmpSinglePeakAnalysis = rietveld.func.spec.dummy.DummyInterface();
		% Define the corrections that are being executed.
			% Absorption correction. Air absorption and material absorption
			% is considered.
			tmpACAir = rietveld.func.spec.corr.AttenuationCoeffAir();
			tmpACMat = rietveld.func.spec.corr.AttenuationCoeffMat();
			% Wiggler spectrum correction.
			tmpWiggler = rietveld.func.spec.corr.WigglerInterface();
		% Define the modul that calculates the fluorescence lines.
		tmpFluor = rietveld.func.spec.fluor.FluorescenceKL();
		tmpFluor.setSubFunction('AttenuationCoeffAir', tmpACAir);
		% Define the modul that calculates the escape peaks.
% 		tmpEscape = rietveld.func.spec.escape.EscapePeaks();
% 		tmpEscape.setSubFunction('EnergyPos', tmpEPos);
% 		tmpEscape.setSubFunction('AttenuationCoeffAir', tmpACAir);
		% Define the functions that are used/needed to calculate all peak
		% related factors.
			% Define how the intensity is calculated. One can chose between
			% the Rietveld method, where the intensities are calculated
			% using the atomic scattering factors or the Le Bail method,
			% where the intensities are treated as an additional fit
			% parameter.
			tmpFHKL = rietveld.func.spec.diffpeaks.fhkl.LeBail();
			tmpIntensity = rietveld.func.spec.diffpeaks.Intensity();
			tmpIntensity.setSubFunction('AttenuationCoeffAir', tmpACAir);
			tmpIntensity.setSubFunction('Wiggler', tmpWiggler);
			tmpIntensity.setSubFunction('FHKL', tmpFHKL);
			% Define the functions used to analyze the residual stresses.
				% Define the functions used to calculate the information
				% depth tau.
				tmpTau = rietveld.func.spec.diffpeaks.Tau();
			% Function used to describe the residual stress depth
			% distribution.
			tmpStrain = rietveld.func.spec.diffpeaks.strain.ModSigmatauFit();
			tmpStrain.setSubFunction('Tau', tmpTau);
		% Define the profile function used to describe the peak shape.
		tmpPeaks = rietveld.func.spec.diffpeaks.TCHPV();
		tmpPeaks.setSubFunction('AttenuationCoeffMat', tmpACMat);
		tmpPeaks.setSubFunction('EnergyPos', tmpEPos);
		tmpPeaks.setSubFunction('Intensity', tmpIntensity);
		tmpPeaks.setSubFunction('Strain', tmpStrain);
% 		tmpPeaks.setSubFunction('StressMod', tmpStressMod);
% 		tmpPeaks.setSubFunction('Tau', tmpTau);
	% Assembling of the "Spectrum function".
	tmpSpec = rietveld.func.spec.Spectrum();
	tmpSpec.setSubFunction('Background', tmpBkg);
	tmpSpec.setSubFunction('DummyPeaks', tmpDummy);
	tmpSpec.setSubFunction('SinglePeakAnalysis', tmpSinglePeakAnalysis);
% 	tmpSpec.setSubFunction('EnergyCalibCorr', tmpEnergyCalibCorr);
	tmpSpec.setSubFunction('Fluorescence', tmpFluor);
% 	tmpSpec.setSubFunction('Escape', tmpEscape);
	tmpSpec.setSubFunction('DiffPeaks', tmpPeaks);
% 	tmpSpec.setSubFunction('Wiggler', tmpWiggler);
% Define the function used to correct for dead time induced diffraction
% line shifts.
tmpChannelToEnergy = rietveld.func.spec.corr.ChannelToEnergy;
% tmpChannelToEnergy = rietveld.func.spec.corr.ChannelToEnergy('30.Januar 2017');
% tmpWigglerSpectrum = rietveld.func.spec.corr.Wiggler();
% Define the Rietveld fit function.
tmpFitFunc = rietveld.func.RVFitFunc();
tmpFitFunc.setSubFunction('Spectrum', tmpSpec);
tmpFitFunc.setSubFunction('ChannelToEnergy', tmpChannelToEnergy);
% tmpFitFunc.setSubFunction('Wiggler', tmpWigglerSpectrum);

% Define the fit function in the rietveld container.
rc.setFitFunction(tmpFitFunc);

% Define the "fitter" that executes the fit.
fitter = fitting.DefaultFitter;
% Define whether the fit errors should be calculated or not.
fitter.setFitOptions('ComputeFitErrors', false);
% Define different additional moduls that can be used to calculate, plot or
% export important values.
config = script.RietveldPCConfigurator(rc);
% Compute energy positions, information depths or export refined
% diffraction patterns.
analysis = rietveld.analysis.RVAnalysis(rc); 
% Calculate the microstructural parameters. Also export option.
microstructure = rietveld.analysis.RVMicrostructure(rc);
% Plot the residual stress depth dsistribution.
residualstressplot = rietveld.analysis.RVResidualStressPlot(rc);
% Calculate and plot the exp. obtained and recalculated d-sin²Psi 
% distributions. 
recalcdistribplot = rietveld.analysis.RVPlotRecalcDistrib(rc);
% sin2psi Methode
sin2psi = rietveld.analysis.RVsin2psi(rc);