%% Choice of scattering angle TwoTheta and Psi and Phi angles
config.configParameter('TwoTheta',...
	'Value', 16);
% Input of psi-anlges used during the measurements. The number has to match
% the number of spectra measured or evaulated, respectively.
psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

% Input of phi-angles used during the measurement. The number has to match
% the number of spectra measured or evaulated, respectively.
config.configParameter('Phi',...
	'Value', 0);
PhiTmp = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
for i = 1:numberOfSpecs
	config.configParameter('Phi',...
		'Value', PhiTmp(i),...
		'SpecIndex', i);
end

%% Input of photon energies of principal K-, L-shell emmision lines
% Input of the theoretical flurescence line positions.
config.configParameter('FluorPos_K',...
	'Value', [6.403; 6.390; 7.058]);
config.configParameter('FluorPos_L',...
	'Value', zeros(0,1));
% Input of the theoretical intensity ratio.
config.configParameter('FluorInt_K',...
	'Value', [1.00; 0.5; 0.17]);
config.configParameter('FluorInt_L',...
	'Value', zeros(0,1));

%% Input of the h k l values and multiplicity m values

% Set the matrix with all hkl reflexes and their multiplicity present in
% the spectra. The peaks that are actually present in the spectra can be
% adjusted in the gui once they have been determined. As the first step of
% the parameter input procedure all peaks are set in each spectrum. The
% user then has to adjust the correct peak numbers by hand.
hklTmp = [1 1 0 12;...
    2 0 0 6;...
    2 1 1 24;...
    2 2 0 12;...
    3 1 0 24;...
    2 2 2 8;...
    3 2 1 48];

% Set which hkl reflex should be considered in which spectrum. Example (1):
% reflex hkl is present in all spectra: "hklTmp(:,1(2)(3)(4))". The numbers
% in brackets stand for the respective column of the matrix hklTmp.
config.configParameter('H',...
	'Value', hklTmp(:,1));
config.configParameter('K',...
	'Value', hklTmp(:,2));
config.configParameter('L',...
	'Value', hklTmp(:,3));
config.configParameter('Multiplicity',...
	'Value', hklTmp(:,4));

% Setting up the right angles alpha, beta and gamma according to the
% crystal system of the sample under investigation.
config.configParameter('Alpha',...
	'Value', 90);
config.configParameter('Beta',...
	'Value', 90);
config.configParameter('Gamma',...
	'Value', 90);

% Set up the d0 spacing, i.e. some reference values determined on a
% standard reference sample of using the stress-free directions. This is
% important for the analysis of residual stresses.
config.configParameter('d0',...
	'Value', [2.02652190606686;1.43296738200297;1.17001296798638;1.01326095303343;0.906288147971589;0.827324103739366;0.765953284268216]); %2.030483162;1.435768413;1.1723;1.015241581;0.908059675;0.82894128;0.767450498]);

% Input of the ring current values.
ringCurrentTmp = [299.194;299.372;299.544;298.481;298.658;298.877;298.939;...
	299.108;299.27;299.458;298.402;298.54;298.713;298.391;298.562;298.833;...
	299.079;299.254;299.361;299.598;298.561;298.771;299.023;299.249;299.458;...
	299.439;298.448;298.739;299.217;299.438;298.441;298.693];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end

% Input of the dead time values.
deadTimeTmp = [29.26666667;31.75555556;30.74444444;30.75555556;29.29444444;...
	29.13333333;28.30555556;28.65555556;24.98888889;24.20555556;21.29444444;...
	19.54444444;17.79444444;16.01666667;13.84444444;12.06111111;10.11666667;...
	8.544444444;7.283333333;6.633333333;5.461111111;4.7;4.638888889;4.627777778;...
	4.611111111;4.65;4.688888889;4.683333333;4.855555556;4.844444444;4.922222222;5.044444444];
for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp = [-1.233e-006 5.7e-006
			-1.876e-006 7.628e-006
			-1.233e-006 5.7e-006
			-1.233e-006 5.7e-006
			-1.645e-006 6.934e-006
			-1.019e-006 5.058e-006
			-1.233e-006 5.7e-006];
config.configParameter('DEK_S1',...
	'Value', DEK_S_Tmp(:,1));
config.configParameter('DEK_S2',...
	'Value', DEK_S_Tmp(:,2));

%% Input of the attenuation factors
% Input for air density. Has to be changed when temperature is higher than
% room temperature.
config.configParameter('DensityAir',...
	'Value', 1.2041e-003);
% Load the "literature data" for the absorption correction for air.
load(fullfile(rvpath,'data','Physics','Air_Absorption.mat'));
config.configParameter('X_airabsorption',...
	'Value', X_airabsorption);
config.configParameter('Y_airabsorption',...
	'Value', Y_airabsorption_en);
% Set up the distance from the detector to the sample. Standard values for
% typical configurations: .
config.configParameter('DetectorDistance',...
	'Value', 110);

%% material absorption correction
% Set up the material density.
config.configParameter('Density',...
	'Value', 7.870);
% Load the "literature data" for the absorption correcion of the sample
% under investigation.
load(fullfile(rvpath,'data','Physics','Fe_absorption_XCOM'));
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

%% structure factor calculation
% Calculation of the structure factors needed for the Rietveld refinement
% of data. When using the Le Bail method, the structure factors are not
% needed.
% Loading the library file containing the coefficients for the analytical
% approximation of the atomic scattering factors.
load(fullfile(rvpath,'data','Physics','AtomSF'));
% Setting up the correct element number according to the sample under
% investigation. The number in "Atomdata(...,[1 3 5 7])" determines the
% element. The correct number can be found using the list:
% "List_of_Elements" in the folder "rietveld\data\physics". If the sample
% under investigation consists of more than one element, the input looks
% like this: config.configParameter('SF_a',...
%			 'Value', [Atomdata(21,[1 3 5 7]); Atomdata(12,[1 3 5 7])]);
config.configParameter('SF_a',...
	'Value', Atomdata(26,[1 3 5 7]));
config.configParameter('SF_b',...
	'Value', Atomdata(26,[2 4 6 8]));
config.configParameter('SF_c',...
	'Value', Atomdata(26,9));
% Setting up the atom positons accroding to the crystal system (Wyckoff
% positions). List here all atom positions of each element.
config.configParameter('APConst',...
	'Value', [0 0 0;...
			  1/2 1/2 1/2]);
% The "APFitPattern" is used to define which atom positions can be refined
% and which are constant. A "0" means the atom position defined in 
% "APConst" is constant whereas a "1" means it can be refined.
config.configParameter('APFitPattern',...
	'Value', [0 0 0;...
			  0 0 0]);
% Define the start value for the refinable parameter.		  
config.configParameter('APFitParams',...
	'Value', 0);
% The parameter "AtomCoordCnts" defines which atom position belongs to
% which element. If, for example, two elements are considerd and the first
% element has 8 atom positons and the second one 12, the input looks like
% this: config.configParameter('AtomCoordCnts',...
%		'Value', [8; 12]);
config.configParameter('AtomCoordCnts',...
	'Value', 0);

%% FitParameter for the FWHM and the line position calibration
config.configParameter('FluorScaleFactor_K',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorScaleFactor_L',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% config.configParameter('FluorDeltaEnergy_K',...
% 	'Value', zeros(3,1),...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('FluorDeltaEnergy_L',...
% 	'Value', zeros(3,1),...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
config.configParameter('DeltaEnergyFluor_a',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergyFluor_b',...
	'Value',  0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergyFluor_c',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorU_K',...
	'Value', 0.0025,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorW_K',...
	'Value', 0.0005,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorU_L',...
	'Value', 0.0025,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorW_L',...
	'Value', 0.0005,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);

%% Phase
% Setting up the scale factor.
config.configParameter('ScaleFactor',...
	'Value', 100,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
% Setting up the structure factor in case the Le Bail method is used to
% calculate the peak intensities. Their number also needs to be adjusted
% according to the actual hkl reflexes present in each spectrum.
config.configParameter('StructureFactor',...
	'Value', ones(7,1).*25000,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% Setting up the correction factors for the energy postions that are used
% in the modul "EnergyPosCalib" (if the correct dead time correction is
% applied, those parameters are not needed).
config.configParameter('DeltaEnergy_a',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_b',...
	'Value',  0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_c',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% Setting up the lattice parameters. The parameters are kept constant when
% doing residual stress analysis.
config.configParameter('LatticeParam1',...
	'Value', 2.8659348,... %2.87153683,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('LatticeParam2',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('LatticeParam3',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% Setting up the Stresscoefficients for the residual stress analysis.
config.configParameter('Sigma11_StressCoef1',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma11_StressCoef2',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma11_StressCoef3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma11_StressCoef4',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma11_StressCoef5',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma22_StressCoef1',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma22_StressCoef2',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma22_StressCoef3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma22_StressCoef4',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma22_StressCoef5',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma33_StressCoef1',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma33_StressCoef2',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma33_StressCoef3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma33_StressCoef4',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('Sigma33_StressCoef5',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% Setting up the microstructural parameters.
config.configParameter('P_Size',...
	'Value', 0.0428563229,...
	'LowerConstraint', 0.0428563229,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 0.0000271186,...
	'LowerConstraint', 0.0000271186,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', 0.0011063105,...
	'LowerConstraint', 0.0011063105,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Z_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
% Setting up the background parameters. Different functions are available.
config.configParameter('Background',...
	'Value', zeros(6,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
% config.configParameter('MaxAmp',...
% 	'Value', [30; 55],...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', Inf,...
% 	'Refinable', false);
% config.configParameter('Center',...
% 	'Value', [14; 48],...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', Inf,...
% 	'Refinable', false);
% config.configParameter('Width',...
% 	'Value', [8; 29],...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', Inf,...
% 	'Refinable', false);
% config.configParameter('Shape1',...
% 	'Value', [3.2; 4.8],...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', Inf,...
% 	'Refinable', false);
% config.configParameter('Shape2',...
% 	'Value', [3.3; 7.9],...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', Inf,...
% 	'Refinable', false);