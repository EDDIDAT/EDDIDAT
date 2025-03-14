%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 15);

psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;83;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
		'SpecIndex', i);
end

%% Input of photon energies of principal K-, L-shell emmision lines
config.configParameter('FluorPos_K',...
	'Value', zeros(0,1));
config.configParameter('FluorPos_L',...
	'Value', zeros(0,1));
config.configParameter('FluorInt_K',...
	'Value', zeros(0,1));
config.configParameter('FluorInt_L',...
	'Value', zeros(0,1));

%% Input of the h k l values and multiplicity m values
hklTmp1 = [1 0 0 6;...
0 0 2 2;...
1 0 1 12;...
1 0 2 12;...
1 1 0 6;...
1 0 3 12;...
2 0 0 6;...
1 1 2 12;...
2 0 1 12];...
% 0 0 4 2;...
% 2 0 2 12];

config.configParameter('H',...
	'Value', hklTmp1(:,1),...
	'PhaseIndex', 1);
config.configParameter('K',...
	'Value', hklTmp1(:,2),...
	'PhaseIndex', 1);
config.configParameter('L',...
	'Value', hklTmp1(:,3),...
	'PhaseIndex', 1);
config.configParameter('Multiplicity',...
	'Value', hklTmp1(:,4),...
	'PhaseIndex', 1);
config.configParameter('Alpha',...
	'Value', 90,...
	'PhaseIndex', 1);
config.configParameter('Beta',...
	'Value', 90,...
	'PhaseIndex', 1);
config.configParameter('Gamma',...
	'Value', 120,...
	'PhaseIndex', 1);

% hklTmp2 = [1 1 0 12;...
% 2 0 0 6];...	
% % 2 1 1 24;...
% % 2 2 0 12;...
% % 3 1 0 24;...
% % 2 2 2 8;...	
% % 3 2 1 48;...
% % 4 0 0 6];
% config.configParameter('H',...
% 	'Value', hklTmp2(:,1),...
% 	'PhaseIndex', 2);
% config.configParameter('K',...
% 	'Value', hklTmp2(:,2),...
% 	'PhaseIndex', 2);
% config.configParameter('L',...
% 	'Value', hklTmp2(:,3),...
% 	'PhaseIndex', 2);
% config.configParameter('Multiplicity',...
% 	'Value', hklTmp2(:,4),...
% 	'PhaseIndex', 2);
% config.configParameter('Alpha',...
% 	'Value', 90,...
% 	'PhaseIndex', 2);
% config.configParameter('Beta',...
% 	'Value', 90,...
% 	'PhaseIndex', 2);
% config.configParameter('Gamma',...
% 	'Value', 90,...
% 	'PhaseIndex', 2);

ringCurrentTmp = [163.838;163.525;163.205;162.89;162.584;162.275;161.969;...
	161.664;161.358;161.054;160.75;160.451;160.146;159.846;159.551;159.251;...
	158.95;158.654;158.357;158.066;157.773;157.478;157.206;157.105;297.525;...
	296.6;295.68;294.758;293.853;292.956;292.056;291.174];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end
deadTimeTmp = [9.87;6.84;7.38;9.63;11.96;3.87;6.13;4.37;2.91;3.99;6.35;...
	3.11;1.83;8.14;2.37;1.61;1.34;1.26;1.46;2.55;3.72;4.86;6.23;2.87;15.79;...
	17.26;18.67;20.05;21.31;22.38;23.76;25.26];
for i = 1:numberOfSpecs
	config.configParameter('DeadTime',...
		'Value', deadTimeTmp(i),...
		'SpecIndex', i);
end

%% Input of the DEK values
DEK_S_Tmp1 = [
-2.954e-006 1.201e-005;...
-2.283e-006 1.003e-005;...
-2.884e-006 1.181e-005;...
-2.706e-006 1.129e-005;...
-2.954e-006 1.201e-005;...
-2.559e-006 1.085e-005;...
-2.954e-006 1.201e-005;...
-2.859e-006 1.174e-005;...
-2.938e-006 1.197e-005];...
% -2.283e-006 1.003e-005];
config.configParameter('DEK_S1',...
	'Value', DEK_S_Tmp1(:,1),...
	'PhaseIndex', 1);
config.configParameter('DEK_S2',...
	'Value', DEK_S_Tmp1(:,2),...
	'PhaseIndex', 1);

% DEK_S_Tmp2 = [-3.732e-006 1.366e-005;...
% -4.276e-006 1.529e-005];...
% % -3.732e-006 1.366e-005;...
% % -3.732e-006 1.366e-005;...
% % -4.080e-006 1.470e-005;...
% % -3.551e-006 1.311e-005;...
% % -3.732e-006 1.366e-005;...
% % -4.276e-006 1.529e-005];
% config.configParameter('DEK_S1',...
% 	'Value', DEK_S_Tmp2(:,1),...
% 	'PhaseIndex', 2);
% config.configParameter('DEK_S2',...
% 	'Value', DEK_S_Tmp2(:,2),...
% 	'PhaseIndex', 2);

%% Input of the attenuation factors
config.configParameter('DensityAir',...
	'Value', 1.1839e-003);
load(fullfile(rvpath,'data','Physics','Air_Absorption.mat'));
config.configParameter('X_airabsorption',...
	'Value', X_airabsorption);
config.configParameter('Y_airabsorption',...
	'Value', Y_airabsorption_en);
config.configParameter('DetectorDistance',...
	'Value', 110);

%% material absorption correction
config.configParameter('Density',...
	'Value', 4.51);
load(fullfile(rvpath,'data','Physics','Ti_absorption_XCOM'));
config.configParameter('X_abs',...
	'Value', X_abs);
config.configParameter('Y_abs',...
	'Value', Y_abs);

%% structure factor calculation
% load(fullfile(rvpath,'data','Physics','AtomSF.mat'));
% config.configParameter('SF_a',...
% 	'Value', [Atomdata(21,[1 3 5 7]); Atomdata(12,[1 3 5 7])]);
% config.configParameter('SF_b',...
% 	'Value', [Atomdata(21,[2 4 6 8]); Atomdata(12,[2 4 6 8])]);
% config.configParameter('SF_c',...
% 	'Value', [Atomdata(21,9); Atomdata(12,9)]);
% config.configParameter('APConst',...
% 	'Value', [0 0 0.35;...
%             2/3 1/3 0.68333;...
%             1/3 2/3 0.016666;...
%             0 0 0.85;...
%             2/3 1/3 0.48333;...
%             1/3 2/3 0.81666;...
%             0 0 -0.35;...
%             2/3 1/3 -0.01666;...
%             1/3 2/3 0.31666;...
%             0 0 0.85;...
%             2/3 1/3 0.18333;...
%             1/3 2/3 0.51667;...
% 			%
% 			0.3 0 1/4;...
%             0.96666 1/3 1/4+1/3;...
%             0.63333 2/3 1/4+2/3;...
%             0 0.3 1/4;...
%             2/3 0.63333 1/4+1/3;...
%             1/3 0.96666 1/4+2/3;...
%             -0.3 -0.3 1/4;...
%             0.36666 0.03333 1/4+1/3;...
%             0.03333 0.36666 1/4+2/3;...
%             -0.3 0 3/4;...
%             0.36666 1/3 3/4+1/3;...
%             0.03333 2/3 3/4+2/3;...
%             0 -0.3 3/4;...
%             2/3 0.03333 3/4+1/3;...
%             1/3 0.36666 3/4+2/3;...
%             0.3 0.3 3/4;...
%             0.96666 0.63333 3/4+1/3;...
%             0.63333 0.96666 3/4+2/3]);
% config.configParameter('APFitPattern',...
% 	'Value', [0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			%
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0;...
% 			0 0 0]);
% % 		'Value', [0 0 1;...
% % 			0 0 1;...
% % 			0 0 1;...
% % 			0 0 -1;...
% % 			0 0 -1;...
% % 			0 0 -1;...
% % 			0 0 -1;...
% % 			0 0 -1;...
% % 			0 0 -1;...
% % 			0 0 1;...
% % 			0 0 1;...
% % 			0 0 1;...
% % 			%
% % 			1 0 0;...
% % 			1 0 0;...
% % 			1 0 0;...
% % 			0 1 0;...
% % 			0 1 0;...
% % 			0 1 0;...
% % 			-1 -1 0;...
% % 			-1 -1 0;...
% % 			-1 -1 0;...
% % 			-1 0 0;...
% % 			-1 0 0;...
% % 			-1 0 0;...
% % 			0 -1 0;...
% % 			0 -1 0;...
% % 			0 -1 0;...
% % 			1 1 0;...
% % 			1 1 0;...
% % 			1 1 0]);
% config.configParameter('APFitParams',...
% 	'Value', 0);
% config.configParameter('AtomCoordCnts',...
% 	'Value', [12; 18]);

%% FitParameter for the FWHM and the line position calibration
% config.configParameter('FluorScaleFactor_K',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('FluorScaleFactor_L',...
% 	'Value', 1,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
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
% config.configParameter('FluorU_K',...
% 	'Value', 0.0025,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('FluorW_K',...
% 	'Value', 0.0005,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('FluorU_L',...
% 	'Value', 0.0025,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('FluorW_L',...
% 	'Value', 0.0005,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);

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
	'Value', ones(9,1).*5000,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
% config.configParameter('StructureFactor',...
% 	'Value', ones(2,1).*5000,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
config.configParameter('DeltaEnergy_a',...
	'Value', -0.0589622142,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_b',...
	'Value',  0.0039071778,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_c',...
	'Value', -0.0000317374,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('LatticeParam1',...
	'Value', 2.9305,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
config.configParameter('LatticeParam2',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
config.configParameter('LatticeParam3',...
	'Value', 4.683,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
% config.configParameter('LatticeParam1',...
% 	'Value', 3.3065,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('LatticeParam2',...
% 	'Value', 0,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('LatticeParam3',...
% 	'Value', 0,...
% 	'LowerConstraint', 0,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('StressCoef',...
% 	'Value', [0; 0; 0],...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
config.configParameter('StressCoef1',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
config.configParameter('StressCoef2',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
config.configParameter('StressCoef3',...
	'Value', 0,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
	'PhaseIndex', 1);
% config.configParameter('StressCoef4',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 1);
% config.configParameter('StressCoef5',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 1);
% config.configParameter('StressCoef1',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('StressCoef2',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('StressCoef3',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('StressCoef4',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);
% config.configParameter('StressCoef5',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false,...
% 	'PhaseIndex', 2);

PSizeTmp = [0.0502013594;0.0502446513;0.050883747;0.0502590269;0.0490599774;0.0489173275;0.0488981299;0.0477996657;0.0474481573;0.0500811317;0.0457207015;0.0473108938;0.0485669823;0.0462963442;0.0478146083;0.0459047886;0.0469061129;0.0467540115;0.0444681981;0.0444540439;0.0444449469;0.0425778781;0.0451021654;0.0404900154;0.0500606178;0.0455221648;0.0444361975;0.0512012391;0.0522396196;0.0445678384;0.0511182532;0.0561820993];
for i = 1:numberOfSpecs
	config.configParameter('P_Size',...
		'Value', PSizeTmp(i),...
		'LowerConstraint', PSizeTmp(i),...
		'UpperConstraint', 1,...
		'Refinable', false,...
		'SpecIndex', i);
end
UStrainTmp = [0.0000249598;0.0000251696;0.0000256275;0.0000241061;0.0000242132;0.0000268985;0.0000253148;0.0000264198;0.0000246841;0.0000228209;0.0000259155;0.0000259922;0.00002301;0.0000299621;0.0000268776;0.0000300256;0.0000332464;0.0000291114;0.0000357937;0.0000347077;0.0000389419;0.0000348535;0.0000243967;0.0000358454;0.0000325206;0.0000361284;0.0000375686;0.0000244504;0.0000243573;0.0000300105;0.0000313943;0.0000193196];
for i = 1:numberOfSpecs
	config.configParameter('U_Strain',...
		'Value', UStrainTmp(i),...
		'LowerConstraint', UStrainTmp(i),...
		'UpperConstraint', 1,...
		'Refinable', false,...
		'SpecIndex', i);
end
XSizeTmp = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0.0000003257;0;0.0032972534;0;0.0067317478;0.0022940847;0;0.006785599;0;0.0085771126;0.0061058634;0;0;0;0.00001443;0.0000000001];
for i = 1:numberOfSpecs
	config.configParameter('X_Size',...
		'Value', XSizeTmp(i),...
		'LowerConstraint', XSizeTmp(i),...
		'UpperConstraint', 1,...
		'Refinable', false,...
		'SpecIndex', i);
end
YStrainTmp = [0.0007054714;0.0006869204;0.0006174438;0.0007314754;0.0008082948;0.000637419;0.0006798111;0.0006801544;0.000706133;0.0006898344;0.0008884988;0.0006712409;0.000792033;0.0005049794;0.0006895082;0.0004918902;0.0003674743;0.0006627239;0.0002865086;0.0005682389;0.0000693117;0.0007145413;0.0009752655;0.0005302348;0.0002637037;0.0000129473;0.0000641386;0.0004614898;0.0004388313;0.0005535187;0;0.0000000032];
for i = 1:numberOfSpecs
	config.configParameter('Y_Strain',...
		'Value', YStrainTmp(i),...
		'LowerConstraint', YStrainTmp(i),...
		'UpperConstraint', 1,...
		'Refinable', false,...
		'SpecIndex', i);
end

% config.configParameter('P_Size',...
% 	'Value', 0.0476,...
% 	'LowerConstraint', 0.0476,...
% 	'UpperConstraint', 1,...
% 	'Refinable', false);
% config.configParameter('U_Strain',...
% 	'Value', 2.9491e-005,...
% 	'LowerConstraint', 2.9491e-005,...
% 	'UpperConstraint', 1,...
% 	'Refinable', false);
config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false);
% config.configParameter('X_Size',...
% 	'Value', 0.0050,...
% 	'LowerConstraint', 0.0050,...
% 	'UpperConstraint', 1,...
% 	'Refinable', false);
% config.configParameter('Y_Strain',...
% 	'Value', 1.8252e-004,...
% 	'LowerConstraint', 1.8252e-004,...
% 	'UpperConstraint', 1,...
% 	'Refinable', false);
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