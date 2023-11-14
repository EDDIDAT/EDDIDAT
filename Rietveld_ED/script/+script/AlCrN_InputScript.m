%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 12);

config.configParameter('LowerChannelBound',...
	'Value', 2000);

config.configParameter('UpperChannelBound',...
	'Value', 6500);

config.configParameter('DummyIntensity',...
	'Value', [0],...	%;0;0;0;0;0;0;0;0],...
	'LowerConstraint', 0,...
	'UpperConstraint', 10000,...
	'Refinable', true);

config.configParameter('DummyMixingFactor',...
	'Value', [1],...	%;1;1;1;1;1;1;1;1],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

config.configParameter('DummyPosition',...
	'Value', [1],... %[19.07; 21.75; 23.96; 32.31; 37.65; 44.81],...	%; 20.98; 29.67; 36.34; 41.96; 46.91; 51.39
	'LowerConstraint', [0],... %[18.87; 21.55; 23.76; 32.11; 37.45; 44.61],...	%; 20.68; 29.37; 36.04; 41.66; 46.61; 51.09
	'UpperConstraint', [2],... %[19.37; 22.05; 24.26; 32.61; 37.95; 45.11],...	%; 21.28; 29.97; 36.64; 42.26; 47.21; 51.69
	'Refinable', false);

config.configParameter('DummyWidth',...
	'Value', [0.1],...	%;0.1;0.1;0.1;0.1;0.1;0.1;0.1;0.1],...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);

% TwoThetaTmp = [20];
% for i = 1:numberOfSpecs
% 	config.configParameter('TwoTheta',...
% 		'Value', TwoThetaTmp(i),...
% 		'SpecIndex', i);
% end

psiTmp = round(S.Psi);
% psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89]; %0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

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
hklTmp = [1 1 1 8;...
    2 0 0 6;...
    2 2 0 12;...
    3 1 1 24;...
    2 2 2 8];...
% 	4 0 0 6;...
%     3 3 1 24;...
%     4 2 0 24;...
%     4 2 2 24];
% hexagonal
% hklTmp = [1 0 0 6;...
%     0 0 2 2;...
%     1 0 1 12;...
%     1 0 2 12;...
%     1 1 0 6;...
% 	1 0 3 12;...
%     2 0 0 6;...
%     1 1 2 12;...
%     2 0 1 12];
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

% Tablette_3_auf_1
deadTimeTmp = S.DeadTime;
% deadTimeTmp = [11.84666667;17.06666667;19.06;20.39666667;21.32;21.80666667;...
%     21.89666667;21.63333333;21.06333333;20.72666667;21.00333333;19.83;18.98;...
%     18.41333333;17.76666667;17.10666667;16.55;15.95;15.39;15.07666667;...
%     14.74333333;8.363333333;13.89;13.70666667;13.51;13.36333333;13.15666667;...
%     12.93666667;12.76333333;12.61333333;12.38;12.05666667];

% Tablette_1_auf_3
% deadTimeTmp = [7.653333333;9.01;9.926666667;10.42;10.66333333;10.63333333;...
%     10.52666667;10.37;10.18333333;10.00333333;9.816666667;9.596666667;9.4;...
%     9.15;8.873333333;8.663333333;8.446666667;8.27;8.09;7.946666667;7.8;...
%     7.61;7.503333333;7.43;7.346666667;7.236666667;7.22;7.073333333;7.03;...
%     6.993333333;6.926666667;6.823333333];

for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp = [-1.27e-006 5.80e-006;  %110
            -1.90e-006 7.70e-006; %200
            -1.27e-006 5.80e-006; %211
            -1.27e-006 5.80e-006; %220
            -1.67e-006 7.02e-006; %310
            -1.05e-006 5.17e-006; %222
			-1.67e-006 7.02e-006; %310
            -1.67e-006 7.02e-006;
            -1.27e-006 5.80e-006]; %321
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
	'Value', S.Density);
load(fullfile(rvpath,'data','Physics','AlCrN_absorption_XCOM.mat'));
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
	'Value', ones(9,1).*100,...
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
	'Value', 4.11,...
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
	'Value', zeros(9,1),...
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
% config.configParameter('LayerThickness1',...
% 	'Value', [0],... 
% 	'LowerConstraint', [0],...
% 	'UpperConstraint', [2],...
% 	'Refinable', false);
% config.configParameter('LayerThickness2',...
% 	'Value', [263],... 
% 	'LowerConstraint', [0],...
% 	'UpperConstraint', [2],...
% 	'Refinable', false);
config.configParameter('LayerThickness1',...
	'Value', [0],... 
	'LowerConstraint', [0],...
	'UpperConstraint', [inf],...
	'Refinable', false);
config.configParameter('LayerThickness2',...
	'Value', [263],... 
	'LowerConstraint', [0],...
	'UpperConstraint', [inf],...
	'Refinable', false);
config.configParameter('P_Size1',...
	'Value', [0.4835],... 
	'LowerConstraint', [0],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('P_Size2',...
	'Value', [0.2040],... 
	'LowerConstraint', [0],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('P_Size',...
	'Value', [0.026675908],... 
	'LowerConstraint', [0.026675908],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('P_Size_Instr',...
	'Value', [0.026675908],... 
	'LowerConstraint', [0.026675908],...
	'UpperConstraint', [2],...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Value', [1.19034e-04],... 
	'LowerConstraint', [1.19034e-04],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
config.configParameter('X_Size1',...
	'Value', [0.2764],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('X_Size2',...
	'Value', [0.1166],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('X_Size',...
	'Value', [],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('X_Size_Instr',...
	'Value', [0],...
	'LowerConstraint', [0],...
	'UpperConstraint', [1],...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Value', [0.0028423485],...
	'LowerConstraint', [0.0028423485],...
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
	'Value', [60; 30],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Center',...
	'Value', [28; 45],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Width',...
	'Value', [20; 20],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape1',...
	'Value', [1.6; 1.6],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);
config.configParameter('Shape2',...
	'Value', [6.3; 6.3],...
	'LowerConstraint', 0,...
	'UpperConstraint', Inf,...
	'Refinable', false);

% out = fitter.executeFit(rc);