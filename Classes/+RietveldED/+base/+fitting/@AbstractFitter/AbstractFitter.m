classdef AbstractFitter < hgsetget
%% (* AbstractFitter *)
% Abstraktes Modell fuer einen Fitter.
% -------------------------------------------------------------------------
	
	methods (Abstract = true, Access = public)
		
		[fitOutput, resnorm] = executeFit(obj, fitContainer);
		% Fuehrt den Fit auf Uebergabe von fitContainer durch. "fitOutput"
		% ist implementierungsspezifisch und "resnorm" gibt die Norm des
		% Residuums wieder.
		
		obj = setFitOptions(obj, varargin);
		% Konfigurieren der Fit-Optionen nach dem Property-Schema.
		
		fitOptions = getFitOptions(obj);
		% Gibt die Optionen als Struktur wieder.
	end
end

