%% Choice of scattering angle TwoTheta
config.configParameter('TwoTheta',...
	'Value', 16);

psiTmp = [0;4;8;12;16;20;24;28;32;36;40;44;48;52;56;60;64;68;72;74;76;78;80;81;82;84;85;86;87;88;89];
for i = 1:numberOfSpecs
	config.configParameter('Psi',...
		'Value', psiTmp(i),...
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

ringCurrentTmp = [142.412;140.389;138.415;136.49;134.616;137.034;262.941;...
	256.812;251.067;245.597;240.376;235.384;230.602;226.007;221.582;217.33;...
	213.335;209.378;205.526;201.809;198.32;195.029;191.789;188.655;185.588;...
	179.785;177.005;174.307;171.692;169.124;166.616];
for i = 1:numberOfSpecs
	config.configParameter('RingCurrent',...
		'Value', ringCurrentTmp(i),...
		'SpecIndex', i);
end

deadTimeTmp = [8.816666667;8.895;8.721666667;8.418333333;7.841666667;...
	5.781666667;14.08;12.785;11.37;9.966666667;8.69;7.411666667;6.266666667;...
	5.328333333;4.438333333;3.73;3.085;2.583333333;2.141666667;2.015;2.053333333;...
	2.896666667;4.465;5.366666667;6.33;8.133333333;9.265;10.66666667;...
	12.06166667;13.27666667;14.33166667];
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
	'Value', 0.0065266839,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergyFluor_b',...
	'Value',  0.0003371013,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergyFluor_c',...
	'Value', -0.0000125857,...
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
	'Value', 0.0065266839,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_b',...
	'Value',  0.0003371013,...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false);
config.configParameter('DeltaEnergy_c',...
	'Value', -0.0000125857,...
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

% PSizeTmp = [0.0502013594;0.0502446513;0.050883747;0.0502590269;0.0490599774;0.0489173275;0.0488981299;0.0477996657;0.0474481573;0.0500811317;0.0457207015;0.0473108938;0.0485669823;0.0462963442;0.0478146083;0.0459047886;0.0469061129;0.0467540115;0.0444681981;0.0444540439;0.0444449469;0.0425778781;0.0451021654;0.0404900154;0.0500606178;0.0455221648;0.0444361975;0.0512012391;0.0522396196;0.0445678384;0.0511182532;0.0561820993];
% for i = 1:numberOfSpecs
% 	config.configParameter('P_Size',...
% 		'Value', PSizeTmp(i),...
% 		'LowerConstraint', PSizeTmp(i),...
% 		'UpperConstraint', 1,...
% 		'Refinable', false,...
% 		'SpecIndex', i);
% end
% UStrainTmp = [0.0000249598;0.0000251696;0.0000256275;0.0000241061;0.0000242132;0.0000268985;0.0000253148;0.0000264198;0.0000246841;0.0000228209;0.0000259155;0.0000259922;0.00002301;0.0000299621;0.0000268776;0.0000300256;0.0000332464;0.0000291114;0.0000357937;0.0000347077;0.0000389419;0.0000348535;0.0000243967;0.0000358454;0.0000325206;0.0000361284;0.0000375686;0.0000244504;0.0000243573;0.0000300105;0.0000313943;0.0000193196];
% for i = 1:numberOfSpecs
% 	config.configParameter('U_Strain',...
% 		'Value', UStrainTmp(i),...
% 		'LowerConstraint', UStrainTmp(i),...
% 		'UpperConstraint', 1,...
% 		'Refinable', false,...
% 		'SpecIndex', i);
% end
% XSizeTmp = [0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0;0.0000003257;0;0.0032972534;0;0.0067317478;0.0022940847;0;0.006785599;0;0.0085771126;0.0061058634;0;0;0;0.00001443;0.0000000001];
% for i = 1:numberOfSpecs
% 	config.configParameter('X_Size',...
% 		'Value', XSizeTmp(i),...
% 		'LowerConstraint', XSizeTmp(i),...
% 		'UpperConstraint', 1,...
% 		'Refinable', false,...
% 		'SpecIndex', i);
% end
% YStrainTmp = [0.0007054714;0.0006869204;0.0006174438;0.0007314754;0.0008082948;0.000637419;0.0006798111;0.0006801544;0.000706133;0.0006898344;0.0008884988;0.0006712409;0.000792033;0.0005049794;0.0006895082;0.0004918902;0.0003674743;0.0006627239;0.0002865086;0.0005682389;0.0000693117;0.0007145413;0.0009752655;0.0005302348;0.0002637037;0.0000129473;0.0000641386;0.0004614898;0.0004388313;0.0005535187;0;0.0000000032];
% for i = 1:numberOfSpecs
% 	config.configParameter('Y_Strain',...
% 		'Value', YStrainTmp(i),...
% 		'LowerConstraint', YStrainTmp(i),...
% 		'UpperConstraint', 1,...
% 		'Refinable', false,...
% 		'SpecIndex', i);
% end

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