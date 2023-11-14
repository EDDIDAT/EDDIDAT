classdef XrayTubeSpectrum < rietveld.func.spec.corr.WigglerInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)
			
			Y = (42.54973./168.87) - (14.45448./168.87).*X + (2.4072./168.87).*X.^2 - ...
				(0.10758./168.87).*X.^3 + (0.00189./168.87).*X.^4 - (1.19848e-005./168.87).*X.^5;

% 			Y = Y';
		end
	end
end
