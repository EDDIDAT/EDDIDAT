classdef RVFitFunc < rietveld.base.RVFunction
%% (* RVFitFunc *)
% Die eigentliche Fit-Funktion. Hier werden die einzelnen Spektren
% berechnet (Spectrum-Modul) und passend aneinander gefuegt.
% -------------------------------------------------------------------------
	
	methods (Access = public)
		
% 		function Y = execute(obj, X, general, meas, phase, spec)
% 			
% 			specSize = obj.getFitContainer().getSpecSize();
% 			
% 			Y = zeros(size(X));
% 			
% % 			Neuerung 06-11-13: Die Intensitätskorrektur hinsichtlich des
% % 			Wigglerspektrums erfolgt nun nicht mehr nur für die
% % 			Energiepositionen der verschiedenen Reflexe hkl sondern wird
% % 			auf das komplette Spektrum angewendet. In der Funktion
% % 			"Intensity" wird nunmehr nur noch das Wigglerspektrum- 
% % 			Interface verwendet. Nach genauer Überprüfung können die
% % 			entsprechenden Einträge auch gelöscht werden.
% 			for s = 1:prod(specSize)
% 				
% 				Y(:, s) = obj.sfwc.Spectrum.execute(X(:, s), general(:, s), meas, phase, spec(s)) .* obj.sfwc.Wiggler.execute(X(:, s));
% 			end
% 		end
		
		% Sicherheitskopie 06-11-13
		function Y = execute(obj, X, general, meas, phase, spec)
			
			specSize = obj.getFitContainer().getSpecSize();
			
			Y = zeros(size(X));
			
			for s = 1:prod(specSize)
				
				Y(:, s) = obj.sfwc.Spectrum.execute(X(:, s), general(:, s), meas, phase, spec(s));
			end
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
		
		function dep = getDependencies(obj, paramName)
	
			% Laenge des Y-Datensatzes auslesen
			lengthY = size(obj.getFitContainer().getDataY, 1);
			% Parameterstruktur ermitteln
			rvc = obj.getFitContainer(); % Abkuerzung
			
			% Spezieller Parameter oder nicht? (Effizienz)
			if (nargin < 2)
				
				dep = rvc.getParamStruct();
			else
				
				dep = rvc.getParamStruct(paramName);
			end
			
			function paramNames = getParamNames(groupName)
			% Hilfsfunktion, die die Parameternamen aus "dep" ausliest.
				
				if (isfield(dep, groupName))
					
					paramNames = fieldnames(dep.(groupName))';
				else
					
					paramNames = [];
				end
			end
			
			% meas-Gruppe
			for paramName = getParamNames('meas')
				
				dep.('meas').(paramName{1}) = util.sprepmat(shiftdim(ones(rvc.getSpecSize()), -1), [lengthY, 1]);
			end
			% phase-Gruppe
			for paramName = getParamNames('phase')
				
				[dep.('phase')(:).(paramName{1})] = deal(...
					util.sprepmat(shiftdim(ones(rvc.getSpecSize()), -1), [lengthY, 1]));
			end
			% spec-Gruppe
			for paramName = getParamNames('spec')
				
				for i = 1:prod(rvc.getSpecSize())
					
					tmp = zeros(rvc.getSpecSize());
					tmp(i) = 1;
					dep.('spec')(i).(paramName{1}) = ...
						util.sprepmat(shiftdim(tmp, -1), [lengthY, 1]);
				end
			end
			% general-Gruppe
			for paramName = getParamNames('general')
				
				for i = 1:prod(rvc.getSpecSize())
					
					tmp = zeros(rvc.getSpecSize());
					tmp(i) = 1;
					[dep.('general')(:,i).(paramName{1})] = deal(...
						util.sprepmat(shiftdim(tmp, -1), [lengthY, 1]));
				end
			end
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('Spectrum', 'rietveld.func.spec.Spectrum', rietveld.func.spec.Spectrum());
			obj.addSubFunction('ChannelToEnergy', 'rietveld.func.spec.corr.ChannelToEnergy', rietveld.func.spec.corr.ChannelToEnergy());
			% Neu eingefügt 06-11-13
% 			obj.addSubFunction('Wiggler', 'rietveld.func.spec.corr.WigglerInterface', rietveld.func.spec.corr.WigglerInterface());
		end
	end
end

