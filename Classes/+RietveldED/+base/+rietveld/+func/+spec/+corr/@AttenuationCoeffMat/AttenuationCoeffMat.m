classdef AttenuationCoeffMat < rietveld.base.RVFunction
	
	methods (Access = public)
		
		function Y = execute(obj, E_Position, ~, ~, phase, ~)
			
			% X_abs = MeV -> X_abs.*1000 Umrechnung von MeV in keV
			% Y_abs = cm^2/g
            % XCOM data: X_abs has to be mulitplied by 1000 (MeV)
            % FFAST data: X_abs already is in keV
			Y = exp(interp1(log(phase.X_abs.*1000),log(phase.Y_abs),log(E_Position),'linear'));
% 			assignin('base', 'Y_abs_mat', Y);
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'X_abs',...
				'Category', 'Absorption',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'Y_abs',...
				'Category', 'Absorption',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
		end		
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end	
end

