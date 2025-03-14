classdef Mod3sigma33 < rietveld.func.spec.diffpeaks.strain.StrainInterface

	methods (Access = public)
		
		function eps_hkl = execute(obj, acm, general, meas, phase, spec)
		% acm wird aus Effizienzgruenden direkt uebergeben
			
			tau = obj.sfwc.Tau.execute(acm, general, meas, phase, spec);
			
			sigmatau = phase.StressCoef1./(phase.StressCoef4.*tau + 1) + ...
				phase.StressCoef2.*tau./(phase.StressCoef4.*tau + 1).^2 + ...
				2.* phase.StressCoef3.*tau.^2./(phase.StressCoef4.*tau + 1).^3;
				
			sigma_33 = phase.StressCoefa .* exp(-phase.StressCoefb./tau);
			% StressCoefa = Spannungswert von sigma33
			% StressCoefb = Wert f�r die Tiefe bei der sigma33 beginnt
			
			eps_hkl = ((sind(spec.Psi)^2) * general.DEK_S2 .* (sigmatau - sigma_33)) + general.DEK_S2 .* sigma_33 + ...
					  general.DEK_S1 .* (2.*sigmatau + sigma_33);
		end

		function obj = addFunctionParameters(obj, pc)

			obj.addParameter(pc, 'DEK_S1',...
				'Category', 'Material',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'DEK_S2',...
				'Category', 'Material',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'TwoTheta',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', false);
			obj.addParameter(pc, 'Psi',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
% 			obj.addParameter(pc, 'StressCoef',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [4, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', false);
			obj.addParameter(pc, 'StressCoef1',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'StressCoef2',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'StressCoef3',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'StressCoef4',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'StressCoefa',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
			obj.addParameter(pc, 'StressCoefb',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', false);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('Tau', 'rietveld.func.spec.diffpeaks.Tau', rietveld.func.spec.diffpeaks.Tau());
		end
	end
	
end



