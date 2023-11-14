classdef XrayTubeSpectrum < rietveld.func.spec.corr.WigglerInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X)
			
			% Fit des Primärstrahlspektrums der Wolframroehre:
			
            p1 = [5.56339671283320e-11;-1.83356703038030e-08;2.52952284691310e-06;-0.000188212991763570;0.00807383150138530;-0.195643012122700;2.35377897946780;-8.43695061253230;-28.3170153655710;233.882063481900];    
            Y(X<10) = 1;
            Y(10<=X&X<=60) = polyval(p1,X(10<=X&X<=60))./407.914;
            Y(X>60) = 9.45658/407.914;
			
			Y = Y';
			
%  			assignin('base', 'XRayTube', Y)
% 			assignin('base', 'X_Data', X)
			
% 			Y = 1;
		end
	end
end
