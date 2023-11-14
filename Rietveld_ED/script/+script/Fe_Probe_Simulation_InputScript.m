%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 16);

psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

config.configParameter('Phi',...
	'Value', 0);
PhiTmp = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0];
for i = 1:numberOfSpecs
	config.configParameter('Phi',...
		'Value', PhiTmp(i),...
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

ringCurrentTmp = [262.941;256.812;251.067;245.597;240.376;235.384;230.602;...
	226.007;221.582;217.33;213.335;209.378;205.526;201.809;198.32;195.029;...
	191.789;188.655;185.588;179.785;177.005;174.307;171.692;169.124;166.616;...
	156.616;142.412;140.389;138.415;136.49;134.616;130.034];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end

deadTimeTmp = [34.82;35.94;36.71;34.12333333;33.74666667;30.24666667;25.23;...
	23.18666667;22.05;23.15666667;20.81;15.15;15.50333333;12.93;10.56333333;...
	9.743333333;8.823333333;6.546666667;5.55;4.846666667;4.59;4.236666667;...
	4.426666667;4.133333333;3.64;3.456666667;3.243333333;2.906666667;2.8;...
	2.646666667;2.53;2.466666667];
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

%% structure factor calculation
% load('C:\Users\hrp\Documents\MATLAB\Rietveld\TestDaten\AtomSF.mat')
load(fullfile(rvpath,'data','Physics','AtomSF'));
config.configParameter('SF_a',...
	'Value', Atomdata(26,[1 3 5 7]));
config.configParameter('SF_b',...
	'Value', Atomdata(26,[2 4 6 8]));
config.configParameter('SF_c',...
	'Value', Atomdata(26,9));
config.configParameter('APConst',...
	'Value', [0 0 0;...
				1/2 1/2 1/2]);
config.configParameter('APFitPattern',...
	'Value', [0 0 0;...
				0 0 0]);
config.configParameter('APFitParams',...
	'Value', 0);
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
config.configParameter('ScaleFactor',...
	'Value', 100,...
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
config.configParameter('Sigma22_StressCoef1',...
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
config.configParameter('sigmatau',...
	'Value', zeros(7,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
% config.configParameter('StressCoefa',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('StressCoefb',...
% 	'Value', 0,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);

config.configParameter('P_Size',...
	'Value', 0.0402,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('P_Size_1',...
	'Value', 0.0402,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('P_Size_2',...
	'Value', 0,...
	'LowerConstraint', -5,...
	'UpperConstraint', 5,...
	'Refinable', false);
config.configParameter('P_Size_3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 2.9826E-5,...
	'LowerConstraint', 2.9826E-5,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain_1',...
	'Value', 3.77759E-5,...
	'LowerConstraint', 5E-6,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('U_Strain_2',...
	'Value', 2.12224E-4,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('U_Strain_3',...
	'Value', 24.52498,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', Inf,...
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
config.configParameter('X_Size_1',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('X_Size_2',...
	'Value', 0,...
	'LowerConstraint', -5,...
	'UpperConstraint', 5,...
	'Refinable', false);
config.configParameter('X_Size_3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', 2E-4,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Y_Strain_1',...
	'Value', 9.21875E-4,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Y_Strain_2',...
	'Value', 7.8125E-5,...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Y_Strain_3',...
	'Value', 21.74672,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', Inf,...
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

% out = fitter.executeFit(rc);