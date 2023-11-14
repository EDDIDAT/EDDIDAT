classdef TauInterface < rietveld.base.RVFunction
	
	methods (Access = public)
		
		function X = execute(obj, X, ~, ~, ~, ~)
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end
end