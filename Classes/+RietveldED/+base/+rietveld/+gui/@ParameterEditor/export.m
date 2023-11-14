function rc = export(javaRVPC, rc, mode)

	% Validation
	validateattributes(javaRVPC, {'rvgui.param.RVParameterContainer'}, {});
	validateattributes(rc, {'rietveld.base.RVContainer'}, {'scalar'});
	validatestring(mode, {'all', 'once phase', 'once spec', 'once'});
	
	% Durchlaufe den Java-Container
	for i = 1:javaRVPC.size()
		
		% Java-Parameter
		jParam = javaRVPC.get(i-1);
		
		% Finde den zugehoerigen FunctionParameter
		[param, groupName] = rc.getParam('', jParam.getName().getValue());
		
		% Anhand der Gruppe und des Modus wird spezifiziert, welche
		% Parameter beschrieben werden
		switch groupName
			
			case 'meas'
				
				% Der Parameter ist bereits skalar
			case 'phase'
				
				% Der Parameter besitzt eine Phase, sonst skalar
				if (~strcmp(mode, 'once phase') && ~strcmp(mode, 'once'))
					param = param(jParam.getPhaseIndex().getValue());
				end
			case 'spec'
				
				% Der Parameter besitzt einen Spektrumsindex, sonst skalar
				if (~strcmp(mode, 'once spec') && ~strcmp(mode, 'once'))
					ind = num2cell(jParam.getSpecIndex().getValue().toArray());
					param = param(ind{:});
				end
			case 'general'
				
				% Nur Spektrumsindex, alle Phasen
				if (strcmp(mode, 'once phase'))
					
					ind = num2cell(jParam.getSpecIndex().getValue().toArray());
					param = param(1:rc.getPhaseCnt(), ind{:});
					
				% Nur Phasenindex, alle Spektren
				elseif (strcmp(mode, 'once spec'))
					
					param = param(jParam.getPhaseIndex().getValue(), :);
					
				% Vollstaendig indiziert
				elseif (strcmp(mode, 'all'))
					ind = num2cell([jParam.getPhaseIndex().getValue(); jParam.getSpecIndex().getValue().toArray()]);
					param = param(ind{:});
				end
		end
		
		% Beschreibe die ausgewaehlten Parameter
		for j = 1:numel(param)
			
			% Konvertieren
%             class(jParam.getValue().getValue())
%             class(jParam.getValue().getValue().toArray())
			value = java.Utils.createMatlabArray(jParam.getValue().getValue().toArray());
			% Bei NaNs und nichtleer unveraendert lassen
			if (isempty(value) || ~all(isnan(value(:))))
				
				param(j).setValue(value);
			end
			
			% Fit-Parameter?
			if (isa(param(j), 'fitting.FitParameter'))
			
				% Konvertieren
				lc = java.Utils.createMatlabArray(jParam.getLowerConstraint().getValue().toArray());
				% Bei NaNs und nichtleer unveraendert lassen
				if (isempty(lc) || ~all(isnan(lc(:))))
				
					param(j).setLowerConstraint(lc);
				end
				
				% Konvertieren
				uc = java.Utils.createMatlabArray(jParam.getUpperConstraint().getValue().toArray());
				% Bei NaNs und nichtleer unveraendert lassen
				if (isempty(uc) || ~all(isnan(uc(:))))
				
					param(j).setUpperConstraint(uc);
				end
				
				% Linking anpassen
				if (jParam.getRefinable().getValue())
					param(j).setLinking(0);
				else
					param(j).setLinking(-1);
				end
			end
		end
	end
end

