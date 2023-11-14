classdef WigglerInterface < rietveld.base.RVFunction
	
	methods (Access = public)
		
		function Y = execute(obj, X)
			
			Y = 1;
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end
end

