classdef Tau < rietveld.func.spec.diffpeaks.TauInterface
	
	methods (Access = public)
		
		function tau = execute(obj, acm, ~, meas, phase, spec)
		% acm wird aus Effizienzgruenden direkt uebergeben
			
            if meas.Diffractometer == 1
                tau = (sind(meas.TwoTheta / 2) ./ (2 * phase.Density * acm)) * 10000 * cosd(spec.Psi);

            elseif meas.Diffractometer == 2

                if meas.Mode == 1
                   if meas.Detector == 1 % rausgefahren
                       tau = (sind(meas.TwoTheta / 2) ./ (2 * phase.Density * acm)) * 10000 * ((1-2.*sind(spec.Psi).^2)/(sqrt(2).*sqrt(1-sind(spec.Psi).^2)));
                   elseif meas.Detector == 2 % Primaerstrahl
                       tau = (sind(meas.TwoTheta / 2) ./ (2 * phase.Density * acm)) * 10000 * sqrt(1-sind(spec.Psi).^2);
                   end

                elseif meas.Mode == 2
                   if meas.Detector == 1 % rausgefahren
                       tau = (sind(meas.TwoTheta / 2) ./ (2 * phase.Density * acm)) * 10000 * (cosd(spec.Psi)-1/3.*tand(spec.Psi).*sind(spec.Psi));
                   elseif meas.Detector == 2 % Primaerstrahl
                       tau = (sind(meas.TwoTheta / 2) ./ (2 * phase.Density * acm)) * 10000 * ((3-4.*sind(spec.Psi).^2)/(3.*sqrt(1-sind(spec.Psi).^2)));
                   end

                end
            end
        end

        function obj = addFunctionParameters(obj, pc)

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
            obj.addParameter(pc, 'Diffractometer',...
                'Category', 'Measurement',...
                'ParamSize', [1, 1],...
                'Constant', true,...
                'PhaseDep', false,...
                'SpecDep', false);
            obj.addParameter(pc, 'Mode',...
                'Category', 'Measurement',...
                'ParamSize', [1, 1],...
                'Constant', true,...
                'PhaseDep', false,...
                'SpecDep', false);
            obj.addParameter(pc, 'Detector',...
                'Category', 'Measurement',...
                'ParamSize', [1, 1],...
                'Constant', true,...
                'PhaseDep', false,...
                'SpecDep', false);
            obj.addParameter(pc, 'Density',...
                'Category', 'Material',...
                'ParamSize', [1, 1],...
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