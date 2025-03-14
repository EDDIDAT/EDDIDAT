%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 16);

config.configParameter('LowerChannelBound',...
	'Value', 1100.3);

config.configParameter('UpperChannelBound',...
	'Value', 10200.3);

config.configParameter('DummyIntensity',...
	'Value', [100;100;100;100;100;100;100;100;100],...
	'LowerConstraint', 0,...
	'UpperConstraint', 10000,...
	'Refinable', false);

config.configParameter('DummyMixingFactor',...
	'Value', [1;1;1;1;1;1;1;1;1],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

config.configParameter('DummyPosition',...
	'Value', [13.94; 17.75; 26.34; 30.62; 30.97; 34.98; 53.16; 59.54; 80.99],...	%17; 19; 20.17; 24.4; 28.85; 34; 35.5; 41.1; 46.2; 50.6
	'LowerConstraint', [13.84; 17.65; 26.24; 30.52; 30.83; 34.88; 53.06; 59.44; 80.89],...	%16.70; 18.70; 20; 24; 28.50; 33.80; 35.2; 40.9; 45.8; 50.3
	'UpperConstraint', [14.04; 17.85; 26.44; 30.66; 31.07; 35.08; 53.26; 59.64; 81.09],...	%17.30; 19.30; 20.5; 24.70; 29.10; 34.30; 35.8; 41.4; 46.5; 50.8
	'Refinable', false);

config.configParameter('DummyWidth',...
	'Value', [0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1],...
	'LowerConstraint', 0,...
	'UpperConstraint', 2,...
	'Refinable', false);

config.configParameter('Dummy_P_Size',...
	'Value', [0.0273706272;0.0273706272;0.0273706272;0.0273706272;0.0273706272;0.0273706272;0.0273706272;0.0273706272;0.0273706272],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

config.configParameter('Dummy_X_Size',...
	'Value', [0;0;0;0;0;0;0;0;0],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

config.configParameter('Dummy_U_Strain',...
	'Value', [0.000117234;0.000117234;0.000117234;0.000117234;0.000117234;0.000117234;0.000117234;0.000117234;0.000117234],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

config.configParameter('Dummy_Y_Strain',...
	'Value', [0.0026694852;0.0026694852;0.0026694852;0.0026694852;0.0026694852;0.0026694852;0.0026694852;0.0026694852;0.0026694852],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

% TwoThetaTmp = [20];
% for i = 1:numberOfSpecs
% 	config.configParameter('TwoTheta',...
% 		'Value', TwoThetaTmp(i),...
% 		'SpecIndex', i);
% end

% psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
% for i = 1:numberOfSpecs
% 	config.configParameter('Psi',...
% 		'Value', psiTmp(i),...
% 		'SpecIndex', i);
% end

config.configParameter('Psi',...
	'Value', 0);

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', [8.4; 11.3]);
config.configParameter('FluorPos_L',...
	'Value', [9.7; 9.96]);
config.configParameter('FluorInt_K',...
	'Value', [1; 0.5]);
config.configParameter('FluorInt_L',...
	'Value', [1; 0.7]);

%% Input of the h k l values and multiplicity m values
hklTmp = [%1 1 1 8];...
    2 0 0 6];...
%     2 2 0 12];...
%     3 1 1 24;...
%     2 2 2 8];...
% 	4 0 0 6];...
% %     3 3 1 24;...
%     4 2 0 24];...
%     4 2 2 24];
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

config.configParameter('RingCurrent',...
	'Value', 300);

% ringCurrentTmp = [300];
% for i = 1:numberOfSpecs
% 	config.configParameter('RingCurrent',...
% 		'Value', ringCurrentTmp(i),...
% 		'SpecIndex', i);
% end

% config.configParameter('DeadTime',...
% 	'Value', 0.0625);

deadTimeTmp = [4.44;4.503333333;0.21;0.248333333;0.216666667];
% 	0.037592593;0.037777778;0.037407407;0.037777778;0.038333333;0.038333333;...
% 	0.038703704;0.039444444;0.040185185;0.040555556;0.041296296;0.041851852;0.042222222;...
% 	0.042592593;0.042222222;0.042037037;0.041851852;0.040185185;0.037592593;0.036111111;...
% 	0.035;0.033703704;0.031666667;0.030925926;0.03;0.029074074;0.028518519;0.028333333;...
% 	0.027222222;0.026481481;0.026481481;0.025925926];

for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp = [-1.27e-006 5.80e-006];  %110
%             -1.90e-006 7.70e-006; %200
%             -1.27e-006 5.80e-006; %211
% %             -1.27e-006 5.80e-006; %220
%             -1.67e-006 7.02e-006; %310
%             -1.05e-006 5.17e-006; %222
% 			-1.67e-006 7.02e-006; %310
%             -1.27e-006 5.80e-006;]; %321
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
	'Value', 3.58);
load(fullfile(rvpath,'data','Physics','MgO_absorption_XCOM.mat'));
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
% 	'Value', ones(3,1));
% config.configParameter('EscapeInt_Beta',...
% 	'Value', ones(3,1));
% config.configParameter('EscapeAlphaInd',...
% 	'Value', [2; 3; 4]);
% config.configParameter('EscapeBetaInd',...
% 	'Value', [2; 3; 4]);
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
	'Value', ones(1,1).*100,...
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
	'Value', 4.246,...
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
config.configParameter('P_Size',...
	'Value', [0.0273706272],... %0.0458752946,0.0348190465,0.0273706272,0.021343722
	'LowerConstraint', [0.0273706272],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('P_Size_Instr',...
	'Value', [0.0273706272],... %0.0458752946,0.0348190465,0.0273706272,0.021343722
	'LowerConstraint', [0.0273706272],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', [0.000117234],... %0.0001903902;0.0001579451;0.000117234;0.000094514
	'LowerConstraint', [0.000117234],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', [0],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('X_Size_Instr',...
	'Value', [0],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', [0.0026694852],... %0.0009895165;0.0011955441;0.0026694852;0.0029200925
	'LowerConstraint', [0.0026694852],...
	'UpperConstraint', [1],...
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
	'Value', [60],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Center',...
	'Value', [28],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Width',...
	'Value', [25],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape1',...
	'Value', [1.6],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape2',...
	'Value', [6.3],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);

% out = fitter.executeFit(rc);