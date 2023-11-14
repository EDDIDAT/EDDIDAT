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
	'Refinable', false);

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
hklTmp1 = [%1 1 1 8;...
    2 0 0 6;...
    2 2 0 12;...
    3 1 1 24;...
    2 2 2 8];...
% 	4 0 0 6;...
%     3 3 1 24;...
%     4 2 0 24;...
%     4 2 2 24];
% hexagonal
hklTmp2 = [%1 0 0 6;...
    0 0 2 2;...
    1 0 1 12];...
%     1 0 2 12;...
%     1 1 0 6];...
% 	1 0 3 12;...
%     2 0 0 6;...
%     1 1 2 12;...
%     2 0 1 12];
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
	'Value', 90,...
    'PhaseIndex', 1);

config.configParameter('H',...
	'Value', hklTmp2(:,1),...
    'PhaseIndex', 2);
config.configParameter('K',...
	'Value', hklTmp2(:,2),...
    'PhaseIndex', 2);
config.configParameter('L',...
	'Value', hklTmp2(:,3),...
    'PhaseIndex', 2);
config.configParameter('Multiplicity',...
	'Value', hklTmp2(:,4),...
    'PhaseIndex', 2);
config.configParameter('Alpha',...
	'Value', 90,...
    'PhaseIndex', 2);
config.configParameter('Beta',...
	'Value', 90,...
    'PhaseIndex', 2);
config.configParameter('Gamma',...
	'Value', 120,...
    'PhaseIndex', 2);

config.configParameter('RingCurrent',...
	'Value', 258);

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
DEK_S_Tmp1 = [-1.27e-006 5.80e-006;  %110
            -1.90e-006 7.70e-006; %200
            -1.27e-006 5.80e-006; %211
%             -1.27e-006 5.80e-006; %220
%             -1.67e-006 7.02e-006; %310
%             -1.05e-006 5.17e-006; %222
% 			-1.67e-006 7.02e-006; %310
%             -1.67e-006 7.02e-006;
            -1.27e-006 5.80e-006]; %321
        
DEK_S_Tmp2 = [-1.27e-006 5.80e-006;  %110
%             -1.90e-006 7.70e-006; %200
%             -1.27e-006 5.80e-006; %211
%             -1.27e-006 5.80e-006; %220
%             -1.67e-006 7.02e-006; %310
%             -1.05e-006 5.17e-006; %222
% 			-1.67e-006 7.02e-006; %310
%             -1.67e-006 7.02e-006;
            -1.27e-006 5.80e-006]; %321        
config.configParameter('DEK_S1',...
	'Value', DEK_S_Tmp1(:,1),...
    'PhaseIndex', 1);
config.configParameter('DEK_S2',...
	'Value', DEK_S_Tmp1(:,2),...
    'PhaseIndex', 1);

config.configParameter('DEK_S1',...
	'Value', DEK_S_Tmp2(:,1),...
    'PhaseIndex', 2);
config.configParameter('DEK_S2',...
	'Value', DEK_S_Tmp2(:,2),...
    'PhaseIndex', 2);

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
	'Value', 3.261,...
    'PhaseIndex', 1);
load(fullfile(rvpath,'data','Physics','AlCrN_absorption_XCOM.mat'));
config.configParameter('X_abs',...
	'Value', X_abs,...
    'PhaseIndex', 1);
config.configParameter('Y_abs',...
	'Value', Y_abs,...
    'PhaseIndex', 1);

config.configParameter('Density',...
	'Value', 3.261,...
    'PhaseIndex', 2);
load(fullfile(rvpath,'data','Physics','AlCrN_absorption_XCOM.mat'));
config.configParameter('X_abs',...
	'Value', X_abs,...
    'PhaseIndex', 2);
config.configParameter('Y_abs',...
	'Value', Y_abs,...
    'PhaseIndex', 2);

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
	'Refinable', true,...
    'PhaseIndex', 1);
config.configParameter('StructureFactor',...
	'Value', ones(4,1).*100,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('ScaleFactor',...
	'Value', 1,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', true,...
    'PhaseIndex', 2);
config.configParameter('StructureFactor',...
	'Value', ones(2,1).*100,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 2);

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
	'Value', 4.12,...
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
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('LatticeParam1',...
	'Value', 3.11,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 2);
config.configParameter('LatticeParam2',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 2);
config.configParameter('LatticeParam3',...
	'Value', 4.979,...
	'LowerConstraint', 0,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 2);

% config.configParameter('StressCoef',...
% 	'Value', [0; 0; 0],...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);

config.configParameter('sigmatau',...
	'Value', zeros(4,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('sigmatau',...
	'Value', zeros(2,1),...
	'LowerConstraint', -Inf,...
	'UpperConstraint', +Inf,...
	'Refinable', false,...
    'PhaseIndex', 2);

% config.configParameter('StressCoef1',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('StressCoef2',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);
% config.configParameter('StressCoef3',...
% 	'Value', 0,...
% 	'LowerConstraint', -Inf,...
% 	'UpperConstraint', +Inf,...
% 	'Refinable', false);

% P_Sizetmp = [0.0482180510960118;0.0426543783148014;0.0434367165445984;0.0445977203936459;0.0439441984020984;0.0440563545233448;0.0451585017738049;0.0450729033818221;0.0457362474057003;0.0458528966169859;0.0468257082339684;0.0472768347199869;0.0469178145157571;0.0476439029367146;0.0477441919323436;0.0461968412908187;0.0456575981329135;0.0454638211055982;0.0448438042614467;0.0440964722401919;0.0430780441546944;0.0439318859642735;0.0445439209443792;0.0432379403349773;0.0456275907751726;0.0441590689354951;0.0455123953102080;0.0449610244961180;0.0458054346805498;0.0454578490741010;0.0464143927893713;0.0454262833734470;0.0463880022676396;0.0478971745257168;0.0469974595793055]';
% for i = 1:numberOfSpecs
% 	config.configParameter('P_Size',...
% 	'Value', P_Sizetmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', P_Sizetmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('P_Size',...
	'Value', 0.0482180510960118,... 
	'LowerConstraint', 0.0482180510960118,...
	'UpperConstraint', [2],...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('P_Size',...
	'Value', 0.0482180510960118,... 
	'LowerConstraint', 0.0482180510960118,...
	'UpperConstraint', [2],...
	'Refinable', false,...
    'PhaseIndex', 2);

% U_Straintmp = [8.42464122226825e-06;4.72955808199076e-06;6.10382332749214e-06;5.71172068892042e-06;6.80851996022974e-06;7.77321556891925e-06;7.12982585607464e-06;7.30221445775231e-06;9.37925553190371e-06;8.94599338974379e-06;8.80547120810762e-06;8.74139176244313e-06;1.01045491044404e-05;8.50543804208069e-06;7.55073723041911e-06;7.64948872004694e-06;7.98566368062471e-06;7.58205597907531e-06;7.08176172317447e-06;7.36666506913393e-06;5.99761260197589e-06;4.71584361530253e-06;7.01368000529862e-06;5.96366249137546e-06;5.60321576839913e-06;7.56023188689490e-06;7.61625220517248e-06;5.81250160686614e-06;8.59061993007666e-06;6.31677127443701e-06;8.20398693428487e-06;9.39461214017590e-06;9.40555804095820e-06;9.45053996197512e-06;9.16081732387081e-06]';
% for i = 1:numberOfSpecs
% 	config.configParameter('U_Strain',...
% 	'Value', U_Straintmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', U_Straintmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('U_Strain',...
	'Value', 8.42464122226825e-06,... 
	'LowerConstraint', 8.42464122226825e-06,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('U_Strain',...
	'Value', 8.42464122226825e-06,... 
	'LowerConstraint', 8.42464122226825e-06,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 2);

% V_Detectortmp = zeros(35,1);
% for i = 1:numberOfSpecs
% 	config.configParameter('V_Detector',...
% 	'Value', V_Detectortmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', V_Detectortmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('V_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false,...
    'PhaseIndex', 2);

% X_Sizetmp = [4.06812139273214e-14;1.08423788603478e-05;8.31461846471213e-06;5.21815061872534e-06;4.23866810558300e-06;1.28567931211290e-07;2.98959750732596e-06;5.17725948123911e-06;6.25487833565994e-07;1.22224115276752e-06;6.60152138899693e-07;8.23157301563591e-08;4.29287924168206e-14;1.08065665480981e-07;1.15971750937744e-06;2.36515007934342e-06;5.01573104405398e-08;6.27557518490173e-06;2.86724692248748e-06;5.42741262134137e-06;4.24334994203956e-06;9.78943568107958e-06;4.41726113207805e-06;4.14157844204009e-09;1.19253631806895e-05;3.67134656490363e-06;3.39251555770424e-06;1.00522186212441e-05;1.64929215541266e-06;4.38198334565514e-06;1.29319827583935e-06;6.65723720560188e-07;9.11224452867737e-11;4.15216947384962e-14;4.02209905291476e-14]';
% for i = 1:numberOfSpecs
% 	config.configParameter('X_Size',...
% 	'Value', X_Sizetmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', X_Sizetmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('X_Size',...
	'Value', 4.06812139273214e-14,...
	'LowerConstraint', 4.06812139273214e-14,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('X_Size',...
	'Value', 4.06812139273214e-14,...
	'LowerConstraint', 4.06812139273214e-14,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 2);

% Y_Straintmp = [0.00215915773743272;0.00322434620017332;0.00302452513263164;0.00286879659055580;0.00289343432963433;0.00277264033297455;0.00268137110965322;0.00266178816451842;0.00235173430958073;0.00240736827866653;0.00231908356349877;0.00224551910152798;0.00218702996825254;0.00225659782791118;0.00239487555609116;0.00247777841282383;0.00248076314565337;0.00266089964832569;0.00266747740896182;0.00288067211795637;0.00302568458834863;0.00306288784103599;0.00275796971868286;0.00294163067606388;0.00271007834819765;0.00269368372659819;0.00255506349407901;0.00281657781874887;0.00250183429536171;0.00266488584716973;0.00241882856574174;0.00245239891074516;0.00227367441107508;0.00210571475063992;0.00221931819908207]';
% for i = 1:numberOfSpecs
% 	config.configParameter('Y_Strain',...
% 	'Value', Y_Straintmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', Y_Straintmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('Y_Strain',...
	'Value', 0.00215915773743272,...
	'LowerConstraint', 0.00215915773743272,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('Y_Strain',...
	'Value', 0.00215915773743272,...
	'LowerConstraint', 0.00215915773743272,...
	'UpperConstraint', [1],...
	'Refinable', false,...
    'PhaseIndex', 2);

% Z_Detectortmp = zeros(35,1);
% for i = 1:numberOfSpecs
% 	config.configParameter('Z_Detector',...
% 	'Value', Z_Detectortmp(i),...
% 	'SpecIndex', i,...
% 	'LowerConstraint', Z_Detectortmp(i),...
% 	'UpperConstraint', [1],...
% 	'Refinable', false);
% end

config.configParameter('Z_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false,...
    'PhaseIndex', 1);

config.configParameter('Z_Detector',...
	'Value', 0,...
	'LowerConstraint', 0,...
	'UpperConstraint', 1,...
	'Refinable', false,...
    'PhaseIndex', 2);


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