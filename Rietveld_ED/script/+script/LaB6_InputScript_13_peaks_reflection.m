%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 11);

config.configParameter('LowerChannelBound',...
	'Value', 1550);

config.configParameter('UpperChannelBound',...
	'Value', 10560);

psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', [33.034; 33.442; 37.801]);
config.configParameter('FluorPos_L',...
	'Value', 38.74);
config.configParameter('FluorInt_K',...
	'Value', [0.55; 1.00; 0.32]);
config.configParameter('FluorInt_L',...
	'Value', 1.00);

%% Input of the h k l values and multiplicity m values
hklTmp = [1 0 0 6];...
% 		1 1 0 12;...
% 		1 1 1 8;...
% 		2 0 0 6;...
% 		2 1 0 24;...
% 		2 1 1 24;...
% 		2 2 0 12;...
% % 		2 2 1 24;...
% 		3 0 0 6;...
% % 		3 1 0 24;...
% 		3 1 1 24;...
% % 		2 2 2 8;...
% 		3 2 0 24;...
% 		3 2 1 48;...
% % 		4 0 0 6;...
% % 		3 2 2 24;...
% 		4 1 0 24;...
% % 		3 3 0 12;...
% 		4 1 1 24];...
% % 		3 3 1 24;...
% % 		4 2 0 24;...
% % 		4 2 1 48];...
% % 		3 3 2 24;...
% % 		4 2 2 24;...
% % 		4 3 0 24;...
% % 		5 0 0 6;...
% % 		5 1 0 24;...
% % 		4 3 1 48;...
% % 		5 1 1 24];
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
ringCurrentTmp = [222.833;221.576;220.309;219.024;217.616;216.141;214.683;213.241;211.811;210.399;209.002;207.62;206.246;204.896;203.563;202.328;201.12;199.927;198.743;197.573;196.421;195.275;194.155;193.053;191.955;190.861;189.772;188.689;187.616;186.551;185.482;184.412];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end
deadTimeTmp = [38.66;38.37666667;38.61666667;39.23;36.10333333;35.65;29.99666667;27.46;27.46;23.29;17.82;17.85333333;14.58666667;15.40666667;11.10333333;10.98333333;9.736666667;7;6.523333333;4.796666667;4.43;4.143333333;4.003333333;3.68;2.44;2.133333333;2.06;1.84;1.44;1.226666667;1.12;0.89];
for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp = [-5.446e-007 2.954e-006];...
% 		-6.452e-007 3.282e-006;...
% 		-5.553e-007 2.964e-006;...
% 		-4.764e-007 2.806e-006;...
% 		-6.101e-007 3.147e-006;...
% 		-6.407e-007 3.228e-006;...
% 		-5.446e-007 2.954e-006;...
% % 		-6.138e-007 3.182e-006;...
% 		-5.740e-007 3.022e-006;...
% 		-5.463e-007 2.941e-006;...
% 		-5.245e-007	2.939e-006;...
% 		-6.412e-007 3.237e-006;...
% 		-5.553e-007 2.964e-006;...
% 		-5.751e-007 3.044e-006;...
% % 		-6.452e-007 3.282e-006;...
% 		-5.231e-007 2.938e-006;...
% % 		-5.783e-007 3.090e-006;...
% 		-5.553e-007 2.964e-006;...
% % 		-6.887e-007 3.387e-006;...
% 		-5.766e-007 3.034e-006;...
% 		-5.434e-007	2.929e-006;...
% 		-5.925e-007 3.078e-006;...
% 		-5.885e-007 3.101e-006];...
% % 		-5.537e-007 3.015e-006;...
% % 		-4.764e-007 2.806e-006;...
% % 		-5.404e-007 2.928e-006;...
% % 		-6.101e-007 3.147e-006;...
% % 		-5.295e-007 2.889e-006;...
% % 		-6.324e-007 3.241e-006];
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
	'Value', 4.711);
load(fullfile(rvpath,'data','Physics','LaB6_absorption_XCOM'));
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

%% structure factor calculation
% load('C:\Users\hrp\Documents\MATLAB\Rietveld\TestDaten\AtomSF.mat')
% config.configParameter('SF_a',...
% 	'Value', Atomdata(52,[1 3 5 7]));
% config.configParameter('SF_b',...
% 	'Value', Atomdata(52,[2 4 6 8]));
% config.configParameter('SF_c',...
% 	'Value', Atomdata(52,9));
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
	'Refinable', true);
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
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('StructureFactor',...
	'Value', ones(1,1).*25000,...
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
	'Value', 4.15689,...
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
	'Value', 0.0476,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 2.9491e-005,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', 0.0050,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', 1.8252e-004,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Z_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Background',...
	'Value', zeros(6,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('MaxAmp',...
	'Value', [30; 55],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Center',...
	'Value', [14; 48],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Width',...
	'Value', [8; 29],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape1',...
	'Value', [3.2; 4.8],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape2',...
	'Value', [3.3; 7.9],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);

% out = fitter.executeFit(rc);