classdef LeBail < rietveld.func.spec.diffpeaks.fhkl.FHKLInterface
	
	methods (Access = public)
		
		function structureFactor = execute(obj, ~, general, ~, ~, ~)
			
			structureFactor = abs(general.StructureFactor).^2;
        end

		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'StructureFactor',...
				'Category', 'Peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end
end

