classdef BkgInterface < rietveld.base.RVFunction
	
	methods (Access = public)
		
		function Y = execute(obj, ~, ~, ~, ~, ~)
			
			Y = 0;
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end
end

