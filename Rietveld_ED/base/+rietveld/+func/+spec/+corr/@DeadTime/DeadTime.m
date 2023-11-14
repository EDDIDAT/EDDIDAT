classdef DeadTime < rietveld.func.spec.corr.DeadTimeInterface
	
	methods (Access = public)
		
		function X = execute(obj, X, general, meas, phase, spec)
			
			deltaE = obj.sfwc.DeltaEDeadTime.execute([], general, meas, phase, spec);
% 			disp(deltaE)
			X = X - deltaE;
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
% 		function obj = addFunctionParameters(obj, pc)
% 			
% 			obj.addParameter(pc, 'DeadTime',...
% 				'Category', 'Measurement',...
% 				'ParamSize', [1, 1],...
% 				'Constant', true,...
% 				'PhaseDep', false,...
% 				'SpecDep', true);
% 		end		
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('DeltaEDeadTime', 'rietveld.func.spec.corr.DeltaEDeadTime', rietveld.func.spec.corr.DeltaEDeadTime());
		end
	end	
end

