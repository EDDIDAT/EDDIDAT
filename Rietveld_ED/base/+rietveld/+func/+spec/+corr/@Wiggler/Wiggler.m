classdef Wiggler < rietveld.func.spec.corr.WigglerInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)
			
            % Wigglerfunction from mathematica
                Y(X<=20) = 1;
                Y(X>20) = (3422.94/632.112) * exp(X(X>20) / 11.84);
                Y = Y';
        end
    end
end

