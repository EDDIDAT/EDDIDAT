classdef RVContainer < fitting.FitContainer
%% (* RVContainer *)
% Dieser Container erweitert einen herkoemmlichen "FitContainer" um die
% Eigenschaften und Methoden, die fuer einen Rietveld-Fit benoetigt werden.
% -------------------------------------------------------------------------

%% Daten
	
	methods (Access = public)
		
		function obj = setDataY(obj, dataY)
		% Ueberschrieben, damit die Gruppen korrekt erzeugt werden koennen.
			
			setDataY@fitting.FitContainer(obj, dataY);
			% Gruppengroesse aktualisieren.
			obj.initRVGroups();
		end
	end
	
%% Rietveld-Fit (Eigenschaften)

	properties (GetAccess = public, SetAccess = private)
		
		% Anzahl der (Material-)Phasen.
		phaseCnt = 1;
	end

	methods (Access = public)
		
		function obj = setPhaseCnt(obj, phaseCnt)
			
			validateattributes(phaseCnt, {'double'}, {'integer', 'scalar', 'positive'});
			obj.phaseCnt = phaseCnt;
			obj.initRVGroups();
		end
		
		function phaseCnt = getPhaseCnt(obj)
			
			phaseCnt = obj.phaseCnt;
		end
		
		function specSize = getSpecSize(obj)
		% Gibt die Dimension der verschiedenen Spektren wieder. Dies ist
		% ein "size" Vektor, dessen Eintraege angeben wie viele Spektren
		% ueber diesem Index vorhanden sind. Dieser Parameter wird nicht
		% explizit gesetzt, sondern wird konsistenterweise aus "dataY"
		% ermittelt.
			
			specSize = size(obj.getDataY());
			specSize = specSize(2:end);
			if isscalar(specSize), specSize = [specSize, 1]; end
		end
	end
	
%% Rietveld-Fit (Methoden)
	
	methods (Access = public)
		
		function obj = setFitFunction(obj, fitFunction)
		% Hier wird nun eine "RVFunction" erwartet. Die Parameter
		% werden automatisch ausgelesen.
		
			validateattributes(fitFunction, {'rietveld.base.RVFunction'}, {'scalar'});
			setFitFunction@fitting.FitContainer(obj, fitFunction);
			
			% Den RVFitFunction den korrekten RVContainer zuweisen
			funcList = fitFunction.getSubFunctionList(true);
			for i = 1:size(funcList, 1)
				
				if (isa(funcList{i,3}, 'rietveld.base.RVFunction'))
					
					funcList{i,3}.setFitContainer(obj);
				end
			end
			
			fitFunction.setFitContainer(obj);
		end
		
		function obj = computeEnergyData(obj)
		% Diese Funktion muss vor dem Fitten aufgerufen werden (am besten
		% nach dem Init). Diese Methode ruft das Modul "ChannelToEnergy"
		% auf und berechnet mit dem Channels und der Totzeit die
		% Energiedaten fuer jedes einzelne Spektrum und schreibt sie in
		% "dataX" (pro Spektrum ein Vektor).
			
			specSize = obj.getSpecSize();
			
			params = obj.getParamStruct();
			
			modConverter = obj.getSubFunction('ChannelToEnergy');
			
			dataX = zeros(size(obj.getDataY()));
			
			for s = 1:prod(specSize)
					
				dataX(:, s) = modConverter.execute([], [], params.meas, [], params.spec(s));
			end
			
			obj.setDataX(dataX);
		end
		
		function sf = getSubFunction(obj, name)
		% Diese Hilfsfunktion dient dazu, benutzte Unterfunktionen zu
		% finden, um mit diesen wiederum Auswertungen zu machen. Der Name
		% "name" muss den Unterfunktionsnamen in den Modulen selbst
		% entsprechen.
			
			validateattributes(name, {'char'}, {'row'});
			
			% Rekursive Liste
			list = obj.getFitFunction().getSubFunctionList(true);
			
			sf = list(strcmp(name, list(:,1)), 3);
			
			assert(~isempty(sf), ['The sub function ', name, ' was not found']);
			
			sf = sf{1};
		end
	end
	
	methods (Access = private)
		
		function obj = initRVGroups(obj)
		% Setzt den Container zurueck und initialisiert die Gruppen mit den
		% korrekten Groessen.
			
			obj.reset();
			% Fuege die Gruppen, in ihrer korrekten Groesse ein.
			obj.addGroup('meas', [1 1]);
			obj.addGroup('phase', [obj.getPhaseCnt() 1]);
			obj.addGroup('spec', obj.getSpecSize());
			obj.addGroup('general', [obj.getPhaseCnt() obj.getSpecSize()]);
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function obj = RVContainer()
			
			obj.initRVGroups();
		end
	end
	
%% Sonstiges
	
	methods (Access = public)
		
		function s = toString(obj)
			
			s = {'+++ Rietveld-Container String-Representation +++'};
			
			% meas
			s{end+1,1} = '--> Measurement-Parameters';
			for paramName = obj.getParamNames('meas')
					
				s{end+1,1} = [paramName{1}, ': ', mat2str(obj.getParam('meas', paramName{1}).getValue(),5)];
			end
			% phase
			s{end+1,1} = '--> Phase-Parameters';
			for i = 1:prod(obj.getGroupSize('phase'))
				for paramName = obj.getParamNames('phase')
					
					s{end+1,1} = ['Phase ', num2str(i), ' | ' paramName{1}, ': ', mat2str(obj.getParam('phase', paramName{1},i).getValue(),5)];
				end
			end
			% spec
			s{end+1,1} = '--> Spectrum-Parameters';
			for i = 1:prod(obj.getGroupSize('spec'))
				for paramName = obj.getParamNames('spec')


					s{end+1,1} = ['Spectrum ', num2str(i), ' | ' paramName{1}, ': ', mat2str(obj.getParam('spec', paramName{1},i).getValue(),5)];
				end
			end
			% spec
			s{end+1,1} = '--> Phase-Spectrum-Parameters';
			gs = obj.getGroupSize('general');
			for i = 1:prod(gs(2:end))
				
				for j = 1:gs(1)
					
					for paramName = obj.getParamNames('general')

						s{end+1,1} = ['Spectrum ', num2str(i), ' | Phase ',...
							num2str(j), ' | ',...
							paramName{1}, ': ', mat2str(obj.getParam('general', paramName{1}, j, i).getValue(),5)];
					end
				end
			end

			s = char(s);
		end
	end
end

