%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 10);

config.configParameter('Psi',...
		'Value', 0);

% psiTmp = [0];
% for i = 1:numberOfSpecs
% 	config.configParameter('Psi',...
% 		'Value', psiTmp(i),...
% 		'SpecIndex', i);
% end

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', [34.279; 34.719; 39.257]);
config.configParameter('FluorPos_L',...
	'Value', zeros(0,1));
config.configParameter('FluorInt_K',...
	'Value', [0.55; 1.00; 0.35]);
config.configParameter('FluorInt_L',...
	'Value', zeros(0,1));

%% Input of the h k l values and multiplicity m values
hklTmp = [1 1 1 8;...
    2 0 0 6;...
    2 2 0 12;...
    3 1 1 24;...
    2 2 2 8;...
    4 0 0 6;...
    3 3 1 24;...
    4 2 0 24;...
    4 2 2 24;...
%     3 3 3 8;...
    5 1 1 24;...
    4 4 0 12;...
    5 3 1 48;...
%     4 4 2 24;...
    6 0 0 6];...
%     6 2 0 24;...
%     5 3 3 24;
%     6 2 2 24;...
%     4 4 4 8;...
%     7 1 1 24;...
% %     5 5 1 24;...
%     6 4 0 24;...
%     6 4 2 48];...
%     5 5 3 24;...
%     7 3 1 48;...
%     8 0 0 6];
config.configParameter('H',...
	'Value', hklTmp(:,1));
config.configParameter('K',...
	'Value', hklTmp(:,2));
config.configParameter('L',...
	'Value', hklTmp(:,3));
config.configParameter('Multiplicity',...
	'Value', hklTmp(:,4));
config.configParameter('Alpha',...
	'Value', 90);
config.configParameter('Beta',...
	'Value', 90);
config.configParameter('Gamma',...
	'Value', 90);

ringCurrentTmp = [171.273];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end

deadTimeTmp = [13.525];
for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp = [-5.446e-007 2.954e-006;...
		-6.452e-007 3.282e-006;...
		-5.553e-007 2.964e-006;...
		-4.764e-007 2.806e-006;...
		-6.101e-007 3.147e-006;...
		-6.407e-007 3.228e-006;...
		-5.446e-007 2.954e-006;...
		-6.138e-007 3.182e-006;...
		-5.740e-007 3.022e-006;...
% 		-5.463e-007 2.941e-006;...
		-5.245e-007	2.939e-006;...
		-6.412e-007 3.237e-006;...
		-5.553e-007 2.964e-006;...
% 		-5.751e-007 3.044e-006];...
		-6.452e-007 3.282e-006];...
% 		-5.231e-007 2.938e-006;...
% 		-5.783e-007 3.090e-006;...
% 		-5.553e-007 2.964e-006;...
% 		-6.887e-007 3.387e-006;...
% 		-5.766e-007 3.034e-006;...
% % 		-5.434e-007	2.929e-006;...
% 		-5.925e-007 3.078e-006;...
% 		-5.885e-007 3.101e-006];
% 		-5.537e-007 3.015e-006;...
% 		-4.764e-007 2.806e-006;...
% 		-5.404e-007 2.928e-006;...
% 		-6.101e-007 3.147e-006;...
% 		-5.295e-007 2.889e-006;...
% 		-6.324e-007 3.241e-006];
config.configParameter('DEK_S1',...
	'Value', DEK_S_Tmp(:,1));
config.configParameter('DEK_S2',...
	'Value', DEK_S_Tmp(:,2));

%% Input of the attenuation factors
config.configParameter('DensityAir',...
	'Value', 1.293e-003);
load(fullfile(rvpath,'data','Physics','Air_Absorption.mat'));
config.configParameter('X_airabsorption',...
	'Value', X_airabsorption);
config.configParameter('Y_airabsorption',...
	'Value', Y_airabsorption_en);
config.configParameter('DetectorDistance',...
	'Value', 110);

%% material absorption correction
config.configParameter('Density',...
	'Value', 7.211);
load(fullfile(rvpath,'data','Physics','CeO2_absorption_XCOM'));
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

%% structure factor calculation
% load('C:\Users\hrp\Documents\MATLAB\Rietveld\TestDaten\AtomSF.mat')
% config.configParameter('SF_a',...
% 	'Value', Atomdata(123,[1 3 5 7]));
% config.configParameter('SF_b',...
% 	'Value', Atomdata(123,[2 4 6 8]));
% config.configParameter('SF_c',...
% 	'Value', Atomdata(123,9));
% config.configParameter('APConst',...
% 	'Value', [0 0 0;...
% 				1/2 1/2 1/2]);
% config.configParameter('APFitPattern',...
% 	'Value', [0 0 0;...
% 				0 0 0]);
% config.configParameter('APFitParams',...
% 	'Value', 0);
% config.configParameter('AtomCoordCnts',...
% 	'Value', 0);

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
config.configParameter('FluorDeltaEnergy_K',...
	'Value', zeros(3,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('FluorDeltaEnergy_L',...
	'Value', zeros(3,1),...
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

%% Escape peaks
% config.configParameter('EscapeInt_Alpha',...
% 	'Value', ones(4,1));
% config.configParameter('EscapeInt_Beta',...
% 	'Value', ones(4,1));
% config.configParameter('EscapeAlphaInd',...
% 	'Value', [1; 2; 3; 4]);
% config.configParameter('EscapeBetaInd',...
% 	'Value', [1; 2; 3; 4]);
% config.configParameter('EscapeScaleFactor_Alpha',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('EscapeScaleFactor_Beta',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('EscapeU_Alpha',...
% 	'Value', 0.0025,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('EscapeU_Beta',...
% 	'Value', 0.0005,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('EscapeW_Alpha',...
% 	'Value', 0.0025,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('EscapeW_Beta',...
% 	'Value', 0.0005,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);

%% Phase
config.configParameter('ScaleFactor',...
	'Value', 100,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('StructureFactor',...
	'Value', ones(13,1).*5000,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_a',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_b',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_c',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);

config.configParameter('LatticeParam1',...
	'Value', 5.411,...
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
% config.configParameter('StressCoef',...
% 	'Value', [0; 0; 0],...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
config.configParameter('StressCoef1',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoef2',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoef3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('P_Size',...
	'Value', 0.0494,...
	'LowerConstraint', 0.0494,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 2.4493e-005,...
	'LowerConstraint', 2.4493e-005,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', 1.7474e-005,...
	'LowerConstraint', 1.7474e-005,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', 1.6513e-004,...
	'LowerConstraint', 1.6513e-004,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Z_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Background',...
	'Value', zeros(5,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('MaxAmp',...
	'Value', [352.0671; 176.6207],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Center',...
	'Value', [38.7992; 51.2508],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Width',...
	'Value', [3.1356e-014; 14.6151],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape1',...
	'Value', [9.6669; 5.3133],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape2',...
	'Value', [0.6899; 9.4501],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);

% out = fitter.executeFit(rc);