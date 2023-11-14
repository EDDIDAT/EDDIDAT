classdef DeltaEDeadTime < rietveld.base.RVFunction
	
	methods (Access = public)
		
		function deltaE = execute(obj, ~, ~, ~, ~, spec)
			
			deltaE =((-0.005369)-exp((0.044193).*((-182.575) + spec.DeadTime))+(0.143431)./((3.38148) + spec.DeadTime));
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'DeadTime',...
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

