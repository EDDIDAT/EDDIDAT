%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 8);

psiTmp = [0];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', 0);
config.configParameter('FluorPos_L',...
	'Value', 0);
config.configParameter('FluorInt_K',...
	'Value', 1);
config.configParameter('FluorInt_L',...
	'Value', 1);

%% Input of the h k l values and multiplicity m values
hklTmp = [%1 1 1 8;...
		2 0 0 6;...
		2 2 0 12;...
		3 1 1 24;...
		2 2 2 8];
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

ringCurrentTmp = [284.75];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end
deadTimeTmp = [19.23333333];
for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
% DEK_S_Tmp = [-1.27e-006 5.80e-006;  %110
%             -1.90e-006 7.70e-006; %200
%             -1.27e-006 5.80e-006; %211
%             -1.27e-006 5.80e-006; %220
%             -1.67e-006 7.02e-006; %310
%             -1.05e-006 5.17e-006; %222
%             -1.27e-006 5.80e-006;]; %321
config.configParameter('DEK_S1',...
	'Value', zeros(4,1));
config.configParameter('DEK_S2',...
	'Value', zeros(4,1));

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
	'Value', 3.75);
load(fullfile(rvpath,'data','Physics','TiH2_absorption_XCOM.mat'))
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

%% structure factor calculation
load(fullfile(rvpath,'data','Physics','AtomSF.mat'))
config.configParameter('SF_a',...
	'Value', [Atomdata(22,[1 3 5 7]); Atomdata(1,[1 3 5 7])]);
config.configParameter('SF_b',...
	'Value', [Atomdata(22,[2 4 6 8]); Atomdata(1,[2 4 6 8])]);
config.configParameter('SF_c',...
	'Value', [Atomdata(22,9); Atomdata(1,9)]);
config.configParameter('APConst',...
	'Value', [0 0 0;...
			  0 1/2 1/2;...
			  1/2 0 1/2;...
			  1/2 1/2 0;...
			  1/4 1/4 1/4;...
			  1/4 3/4 3/4;...
			  3/4 1/4 3/4;...
			  3/4 3/4 1/4;...
			  1/4 1/4 3/4;...
			  1/4 3/4 1/4;...
			  3/4 1/4 1/4;...
			  3/4 3/4 3/4]);
config.configParameter('APFitPattern',...
	'Value', [0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0;...
			  0 0 0]);
config.configParameter('APFitParams',...
	'Value', 0);
config.configParameter('AtomCoordCnts',...
	'Value', [4; 8]);
% AtomCoordCnts gibt die L�nge der jeweiligen Atom Positionen APConst an.

%% FitParameter for the FWHM and the line position calibration
config.configParameter('ScaleFactor_Fluor_K',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
config.configParameter('ScaleFactor_Fluor_L',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true);
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
% 	'Value', ones(3,1));
% config.configParameter('EscapeInt_Beta',...
% 	'Value', ones(1,1));
% config.configParameter('EscapeAlphaInd',...
% 	'Value', [3; 4; 5;]);
% config.configParameter('EscapeBetaInd',...
% 	'Value', 3);
% config.configParameter('EscapeScaleFactor_Alpha',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', true);
% config.configParameter('EscapeScaleFactor_Beta',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', true);
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
	'Value', ones(4,1).*100,...
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
config.configParameter('DeltaEnergy_d',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('LatticeParam1',...
	'Value', 4.454,...
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
config.configParameter('StressCoef',...
	'Value', [0;0;0],...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('P_Size',...
	'Value', 0.0522473095,...
	'LowerConstraint', 0.0522473095,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', 0.0000241487,...
	'LowerConstraint', 0.0000241487,...
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
	'Value', 0.0008614425,...
	'LowerConstraint', 0.0008614425,...
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

% out = fitter.executeFit(rc);