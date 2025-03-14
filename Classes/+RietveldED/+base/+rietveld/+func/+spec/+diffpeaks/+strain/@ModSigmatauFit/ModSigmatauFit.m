classdef ModSigmatauFit < rietveld.func.spec.diffpeaks.strain.StrainInterface

	methods (Access = public)
		
		function eps_hkl = execute(obj, acm, general, meas, phase, spec)
		% acm wird aus Effizienzgruenden direkt uebergeben
			
			tau = obj.sfwc.Tau.execute(acm, general, meas, phase, spec);
            
% 			eps_hkl = ((sind(spec.Psi)^2) * general.DEK_S2 + 2 * general.DEK_S1) .* general.sigmatau;
            
%             eps_hkl = general.DEK_S2 .*(sind(spec.Psi)^2 * (general.sigma11 .* cosd(spec.Phi).^2 + general.sigma22 .* sind(spec.Phi).^2) + ...
%                         sind(2.*spec.Psi) .* (general.sigma13 .* cosd(spec.Phi) + general.sigma23 .* sind(spec.Phi))) + ...
%                         general.DEK_S1 .* (general.sigma11 + general.sigma22);    
%             if spec.Phi == 0        
%                 eps_hkl = general.DEK_S2 .*(sind(spec.Psi)^2 * (general.sigma11 .* cosd(spec.Phi).^2) + ...
%                             sind(2.*spec.Psi) .* (general.sigma13 .* cosd(spec.Phi))) + ...
%                             general.DEK_S1 .* (general.sigma11 + general.sigma22);
%             elseif spec.Phi == 90
%                 eps_hkl = general.DEK_S2 .*(sind(spec.Psi)^2 * (general.sigma22 .* sind(spec.Phi).^2) + ...
%                             sind(2.*spec.Psi) .* (general.sigma23 .* sind(spec.Phi))) + ...
%                             general.DEK_S1 .* (general.sigma11 + general.sigma22);
%             end
            
        %% Fit sigma_11 and sigma_22 directly using the basic equation of XSA
%               eps_hkl = general.DEK_S2 .*(sind(spec.Psi)^2 * (general.sigma11 .* cosd(spec.Phi).^2 + general.sigma22 .* sind(spec.Phi).^2)) + ...
%                         general.DEK_S1 .* (general.sigma11 + general.sigma22);

        %% Fit sigma_11 and sigma_22 directly using the stress factors F_11 and F_22            
%               eps_hkl = (general.DEK_S2 .* cosd(spec.Phi).^2 .* sind(spec.Psi)^2 + general.DEK_S1) .* general.sigma11 + ...
%                         (general.DEK_S2 .* sind(spec.Phi).^2 .* sind(spec.Psi)^2 + general.DEK_S1) .* general.sigma22 + ...
%                         (general.DEK_S2 .* cosd(spec.Phi) .* sind(2.*spec.Psi)) .* general.sigma13 + ...
%                         (general.DEK_S2 .* sind(spec.Phi) .* sind(2.*spec.Psi)) .* general.sigma23;
                    
        %% Fit epsilon directly
              eps_hkl = general.epsilon;
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
% 			obj.addParameter(pc, 'TwoTheta',...
% 				'Category', 'Measurement',...
% 				'ParamSize', [1, 1],...
% 				'Constant', true,...
% 				'PhaseDep', false,...
% 				'SpecDep', false);
			obj.addParameter(pc, 'Psi',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
            obj.addParameter(pc, 'Phi',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
% 			obj.addParameter(pc, 'sigmatau',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
            
%             obj.addParameter(pc, 'sigma11',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
%             obj.addParameter(pc, 'sigma22',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
%             obj.addParameter(pc, 'sigma13',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
%             obj.addParameter(pc, 'sigma23',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
            
%             obj.addParameter(pc, 'sigma13',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
%             obj.addParameter(pc, 'sigma23',...
% 				'Category', 'Peaks',...
% 				'ParamSize', [NaN, 1],...
% 				'Constant', false,...
% 				'PhaseDep', true,...
% 				'SpecDep', true);
            obj.addParameter(pc, 'epsilon',...
				'Category', 'Peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('Tau', 'rietveld.func.spec.diffpeaks.TauInterface', rietveld.func.spec.diffpeaks.Tau());
		end
	end
	
end

