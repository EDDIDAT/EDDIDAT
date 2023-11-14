classdef FluorescenceKLM < rietveld.func.spec.fluor.FluorInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)
			
			Y = 0;
			
			% 1 = K, 2 = L, 3 = M - noch eine extra Linie eingefuegt, fuer
			% den Fall das die Phasen mehr als 2 Atome besitzen.
			for i = 1:3
				
				if (i == 1)
					
					FluorPos = phase.FluorPos_K;
					FluorInt = phase.FluorInt_K;
					FluorDeltaEnergy = general.FluorDeltaEnergy_K;
					FluorU = general.FluorU_K;
					FluorW = general.FluorW_K;
					FluorScaleFactor = general.FluorScaleFactor_K;
				
				elseif (i == 2)
					
					FluorPos = phase.FluorPos_L;
					FluorInt = phase.FluorInt_L;
					FluorDeltaEnergy = general.FluorDeltaEnergy_L;
					FluorU = general.FluorU_L;
					FluorW = general.FluorW_L;
					FluorScaleFactor = general.FluorScaleFactor_L;
				else
					
					FluorPos = phase.FluorPos_M;
					FluorInt = phase.FluorInt_M;
					FluorDeltaEnergy = general.FluorDeltaEnergy_M;
					FluorU = general.FluorU_M;
					FluorW = general.FluorW_M;
					FluorScaleFactor = general.FluorScaleFactor_M;
				end
				
				FluorPos = FluorPos + polyval(FluorDeltaEnergy, FluorPos);
				FluorFWHM = FluorU .* FluorPos + FluorW;
				
				Int = FluorScaleFactor * (FluorInt .*...
					exp(-meas.DensityAir * meas.DetectorDistance * ...
					obj.sfwc.AttenuationCoeffAir.execute(FluorPos, general, meas, phase, spec)));
				
				for j = 1:size(FluorInt, 1)    
					
					Y = Y + Int(j) .* ...
						(2 * sqrt(log(2) / pi) / FluorFWHM(j)) * exp(-4 * log(2) * ((X - FluorPos(j))/FluorFWHM(j)).^2);
				end
			end
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'FluorDeltaEnergy_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorDeltaEnergy_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorDeltaEnergy_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorInt_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorInt_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorInt_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorPos_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorPos_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorPos_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'FluorU_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorU_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorU_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorW_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorW_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorW_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorScaleFactor_K',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorScaleFactor_L',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'FluorScaleFactor_M',...
				'Category', 'Fluorescence',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('AttenuationCoeffAir', 'rietveld.func.spec.corr.AttenuationCoeffAir',...
				rietveld.func.spec.corr.AttenuationCoeffAir());
		end
	end
end

