classdef EscapePeaks < rietveld.func.spec.escape.EscapeInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)
			
			Y = 0;
			
            tmpEnergyPos = obj.sfwc.EnergyPos.execute([], general, meas, phase, spec);
			
			tmpEscapePosAlpha = tmpEnergyPos(general.EscapeAlphaInd) - 9.88642;
			tmpEscapePosBeta = tmpEnergyPos(general.EscapeBetaInd) - 10.9821;
			
			% 1 = Alpha, 2 = Beta
			for i = 1:2
				
				if (i == 1)
					
					EscapePos = tmpEscapePosAlpha;
					EscapeInt = general.EscapeInt_Alpha;
					EscapeU = general.EscapeU_Alpha;
					EscapeW = general.EscapeW_Alpha;
					EscapeScaleFactor = general.EscapeScaleFactor_Alpha;
				else
					
					EscapePos = tmpEscapePosBeta;
					EscapeInt = general.EscapeInt_Beta;
					EscapeU = general.EscapeU_Beta;
					EscapeW = general.EscapeW_Beta;
					EscapeScaleFactor = general.EscapeScaleFactor_Beta;
				end
				
				EscapeFWHM = EscapeU .* EscapePos + EscapeW;
				
				Int = EscapeScaleFactor * (EscapeInt .*...
					exp(-meas.DensityAir * meas.DetectorDistance * ...
					obj.sfwc.AttenuationCoeffAir.execute(EscapePos, general, meas, phase, spec)));
				
				for j = 1:size(EscapeInt, 1)    
					
					Y = Y + Int(j) .* ...
						(2 * sqrt(log(2) / pi) / EscapeFWHM(j)) * exp(-4 * log(2) * ((X - EscapePos(j))/EscapeFWHM(j)).^2);
				end
			end
        end
 
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'EscapeAlphaInd',...
				'Category', 'Escape',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeBetaInd',...
				'Category', 'Escape',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);			
			obj.addParameter(pc, 'EscapeInt_Alpha',...
				'Category', 'Escape',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeInt_Beta',...
				'Category', 'Escape',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeU_Alpha',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeU_Beta',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeW_Alpha',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeW_Beta',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeScaleFactor_Alpha',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'EscapeScaleFactor_Beta',...
				'Category', 'Escape',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
		end
	end
	
	methods (Access = protected)
		
        function obj = initSubFunctions(obj)
			
			obj.addSubFunction('EnergyPos', 'rietveld.func.spec.EnergyPos', rietveld.func.spec.EnergyPos());
            obj.addSubFunction('AttenuationCoeffAir', 'rietveld.func.spec.corr.AttenuationCoeffAir', rietveld.func.spec.corr.AttenuationCoeffAir());
		end
	end   
end

