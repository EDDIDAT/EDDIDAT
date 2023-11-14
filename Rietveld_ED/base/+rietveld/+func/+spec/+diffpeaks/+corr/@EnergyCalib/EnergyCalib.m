classdef EnergyCalib < rietveld.func.spec.corr.EnergyCalibInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, ~, ~, ~, spec)
			
			Y = polyval([spec.DeltaEnergy_c, spec.DeltaEnergy_b, spec.DeltaEnergy_a], X);
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'DeltaEnergy_a',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
			obj.addParameter(pc, 'DeltaEnergy_b',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
			obj.addParameter(pc, 'DeltaEnergy_c',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
		end		
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end	
end