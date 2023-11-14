%% FitParameter for the FWHM and the line position calibration
config.configParameter('FluorScaleFactor_K',...
	'Refinable', true);
config.configParameter('FluorScaleFactor_L',...
	'Refinable', true);
config.configParameter('FluorDeltaEnergy_K',...
	'Refinable', false);
config.configParameter('FluorDeltaEnergy_L',...
	'Refinable', false);
config.configParameter('FluorU_K',...
	'Refinable', false);
config.configParameter('FluorW_K',...
	'Refinable', false);
config.configParameter('FluorU_L',...
	'Refinable', false);
config.configParameter('FluorW_L',...
	'Refinable', false);

%% Phase
config.configParameter('ScaleFactor',...
	'Refinable', true);
config.configParameter('StructureFactor',...
	'Refinable', true);
config.configParameter('DeltaEnergy_a',...
	'Refinable', false);
config.configParameter('DeltaEnergy_b',...
	'Refinable', true);
config.configParameter('DeltaEnergy_c',...
	'Refinable', false);
config.configParameter('LatticeParam1',...
	'Refinable', false);
config.configParameter('LatticeParam2',...
	'Refinable', false);
config.configParameter('LatticeParam3',...
	'Refinable', false);
config.configParameter('StressCoef',...
	'Refinable', false);
config.configParameter('P_Size',...
	'Refinable', false);
config.configParameter('U_Strain',...
	'Refinable', false);
config.configParameter('V_Detector',...
	'Refinable', false);
config.configParameter('X_Size',...
	'Refinable', false);
config.configParameter('Y_Strain',...
	'Refinable', false);
config.configParameter('Z_Detector',...
	'Refinable', false);
config.configParameter('Background',...
	'Refinable', false);

out = fitter.executeFit(rc);