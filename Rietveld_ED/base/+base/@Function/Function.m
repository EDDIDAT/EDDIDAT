classdef Function < hgsetget
%% (* Function *)
% Diese Klasse stellt die einfachte Form einer (mathematische)
% Funktion/Abbildung dar. Die Methode "execute" muss in Unterklassen dann
% konkret implementiert werden.
% -------------------------------------------------------------------------

	methods (Abstract = true, Access = public)
		
		Y = execute(obj, X, varargin);
		% Fuehrt die Funktion aus. Dabei wird auf jeden Fall ein Input "X"
		% verlangt. An die Dimension von "X" und "Y" werden zunaechst keine
		% Restriktionen gestellt. "varargin" kann hier zunaechst beliebig
		% sein.
	end
end

