%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 20,...   % DET1 = 20.0558; DET2 = 20.0554
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);

config.configParameter('LowerChannelBound',...
	'Value', 1500);

config.configParameter('UpperChannelBound',...
	'Value', 6000);

psiTmp = round(S.Psi);
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

phiTmp = round(S.Phi);
for i = 1:numberOfSpecs
	config.configParameter('Phi',...
		'Value', phiTmp(i),...
		'SpecIndex', i);
end

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', [6.403; 6.390; 7.058]);
config.configParameter('FluorPos_L',...
	'Value', zeros(0,1));
config.configParameter('FluorInt_K',...
	'Value', [1.00; 0.5; 0.17]);
config.configParameter('FluorInt_L',...
	'Value', zeros(0,1));

%% Input of the h k l values and multiplicity m values
hklTmp = [1 1 0 12;...
    2 0 0 6;...
    2 1 1 24;...
    2 2 0 12;...
    3 1 0 24;...
    2 2 2 8;...
    3 2 1 48];
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

ringCurrentTmp = S.RingCurrent;
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end

% config.configParameter('RingCurrent',...
% 	'Value', 300);

deadTimeTmp = S.DeadTime;
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
config.configParameter('DensityAir',...
	'Value', 1.2041e-003);
load(fullfile(rvpath,'data','Physics','Air_Absorption.mat'));
config.configParameter('X_airabsorption',...
	'Value', X_airabsorption);
config.configParameter('Y_airabsorption',...
	'Value', Y_airabsorption_en);
config.configParameter('DetectorDistance',...
	'Value', 110);

%% material absorption correction
config.configParameter('Density',...
	'Value', 7.870);
load(fullfile(rvpath,'data','Physics','Fe_absorption_XCOM'));
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

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
config.configParameter('ScaleFactor',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('StructureFactor',...
	'Value', ones(7,1).*25000,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
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
config.configParameter('LatticeParam1',...
	'Value', 2.8679,...
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
config.configParameter('sigmatau',...
	'Value', zeros(7,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
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
config.configParameter('StressCoef4',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoef5',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoef6',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoefa',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('StressCoefb',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('P_Size',...
	'Value', 0.0276603932,...
	'LowerConstraint', 0.0276603932,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 0.0001241635,...
	'LowerConstraint', 0.0001241635,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', 0.0005,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', 0.0024437191,...
	'LowerConstraint', 0.0024437191,...
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