classdef RVDummyFunction < rietveld.base.RVFunction
%% (* RVDummyFunction *)
% Dummy Funktion, mathematisch gesehen die Identitaet. Kann u.a. als
% Default fuer Untermodule benutzt werden.
% -------------------------------------------------------------------------
	
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

