classdef RVCheckFunction < rietveld.base.RVFunction
%% (* RVCheckFunction *)
% Diese Funktion wird dazu benutzt die Rueckgaben von Unterfunktionen zu
% ueberpruefen. Sie wird in "setSubFunction" in "RVFunction" automatisch
% eingebettet.
% -------------------------------------------------------------------------
		
	methods (Access = public)
		
		function Y = execute(obj, X, varargin)
			
			% Delegation
			Y = obj.sfwc.SubModule.execute(X, varargin{:});
			
			% Werte muessen finit sein
			assert(all(isfinite(Y(:))), ['Infinite value in module ', class(obj.sfwc.SubModule)]);
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
		
		function dep = getDependencies(obj, paramName)
			
			% Delegation
			dep = obj.sfwc.SubModule.getDependencies(paramName);
		end
	end
	
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('SubModule', 'rietveld.base.RVFunction', rietveld.base.RVDummyFunction());
		end
	end
end

