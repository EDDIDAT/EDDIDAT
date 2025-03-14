classdef DummyTCHpV < rietveld.func.spec.dummy.DummyInterface

	methods (Access = public)
		
		function Y = execute(obj, X, ~, ~, ~, spec)
			
			Y = 0;
			
				H_kG = sqrt(spec.Dummy_P_Size + spec.Dummy_U_Strain .* (spec.DummyPosition.^2));
				H_kL = spec.Dummy_X_Size + spec.Dummy_Y_Strain .* spec.DummyPosition;
				
				H_k = (H_kG.^5 + 2.69269.*H_kG.^4.*H_kL + 2.42843.*H_kG.^3.*H_kL.^2 ...
				+ 4.47163.*H_kG.^2.*H_kL.^3 + 0.07842.*H_kG.*H_kL.^4 + H_kL.^5).^(0.2);
				GL = 1.36603 .* (H_kL ./ H_k) - 0.47719 .* (H_kL ./ H_k).^2 + 0.11116 .* (H_kL ./ H_k).^3;
			
			for i = 1:length(spec.DummyPosition)
 				Y = Y + spec.DummyIntensity(i) * (GL(i) * (2 / (pi * H_k(i))) ./ ...
					(1 + 4 * ((X - spec.DummyPosition(i)) / H_k(i)).^2) ...
					+ (1 - GL(i)) * (2 * sqrt(log(2)/pi) / H_k(i)) * ...
					exp(-4 * log(2) * ((X - spec.DummyPosition(i)) / H_k(i)).^2));
				
			end
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'DummyIntensity',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);
			obj.addParameter(pc, 'DummyPosition',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);			
			obj.addParameter(pc, 'Dummy_P_Size',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);
			obj.addParameter(pc, 'Dummy_X_Size',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);
			obj.addParameter(pc, 'Dummy_U_Strain',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);
			obj.addParameter(pc, 'Dummy_Y_Strain',...
				'Category', 'Dummy peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true,...
				'Value', []);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
		end
	end
end

