classdef DefaultFitter < fitting.AbstractFitter
%% (* DefaultFitter *)
% Objekte dieser Klasse fuehren den eigentlichen Fit mit "lsqcurvefit"
% durch. Die Methode "executeFit" bekommt einen "FitContainer" und fuehrt
% den Vorgang von dessen Inhalt aus.
% TODO: Standardfehler!?
% -------------------------------------------------------------------------
	
%% Hilfsvariablen und -methoden

	properties (Access = private)

		% Speichert den Fit-Container fuer Untermethoden zwischen
		fitContainer;
		
		% Arbeits-Kopie fuer schnelle Zugriffe auf die Fit-Parameter (siehe
		% "getParamStruct" und "insertParamStruct" in "FitContainer")
		workingCopy;
		
		% Diese Tabelle liefert eine eindeutige Relation zwischen den zu
		% fittenden Parametern und der Syntax von lsqcurvefit:
		% 1. Spalte: Gruppen-Name des Parameters
		% 2. Spalte: Name des Parameters
		% 3. Spalte: Index des Parameters in der Gruppe (Zeilenvektor),
		%	sind die Parameter verlinkt, so stehen hier alle Indizes mit
		%	gleichem Linking-Index
		% 4. Spalte: Dimension des Parameters selbst (ist der
		%	Parameter nicht skalar, so gibt es ja mehrere Unter-Parameter)
		% Die Laenge der Tabelle entspricht nicht unbedingt der Anzahl der
		% Fit-Parameter, denn manche Parameter koennen Unter-Parameter
		% enthalten.
		fitParamTable;
	end
	
	methods (Access = private)
		
		function obj = createFitParamTable(obj)
		% Diese Methode erstellt die Parameter-Tabelle (siehe
		% "fitParamTable")
						
			obj.fitParamTable = cell(0, 4);
			% Zaehler fuer die Zeile der Tabelle
			cnt = 0; 
			% Durchlaufe alle Parameter
			for groupName = obj.fitContainer.getGroupNames()
				
				for paramName = obj.fitContainer.getParamNames(groupName{1})
					
					% Abkuerzung
					params = obj.fitContainer.getParam(groupName{1}, paramName{1});
					% Der Parameter muss natuerlich ein FitParameter sein
					if isa(params, 'fitting.FitParameter')
						% Linker auslesen
						linking = get(params, 'linking');
						if ~iscell(linking), linking = {linking}; end
						linking = cell2mat(linking);
						% Finde die unabhaengigen Parameter...
						nonLinkedParams = find(linking == 0)';
						% ...und trage sie ein
						for paramInd = nonLinkedParams

							cnt = cnt + 1;
							obj.fitParamTable{cnt, 1} = groupName{1};
							obj.fitParamTable{cnt, 2} = paramName{1};
							obj.fitParamTable{cnt, 3} = paramInd;
							% Anzahl der Elemente, d.h. mehr als ein Parameter
							obj.fitParamTable{cnt, 4} = params(paramInd).getSize();
						end
						% Trage die verlinkten Parameter ein
						for linkingInd = unique(linking(linking > 0))'

							cnt = cnt + 1;
							linkedParams = find(linking == linkingInd);
							obj.fitParamTable{cnt, 1} = groupName{1};
							obj.fitParamTable{cnt, 2} = paramName{1};
							% Indizes alle verlinkten Parameter
							obj.fitParamTable{cnt, 3} = linkedParams';
							% Anzahl der Elemente, d.h. mehr als ein Parameter
							obj.fitParamTable{cnt, 4} = params(linkedParams(1)).getSize();
						end
					end
				end
			end
		end
		
		function [startValues, lowerConstr, upperConstr] = getFitConditions(obj)
		% Liesst aus dem Fit-Container die Startwerte und Constraints aus.
			
			startValues = [];
			lowerConstr = [];
			upperConstr = [];
			% Finde die Werte anhand der Parameter-Tabelle
			for i = 1:size(obj.fitParamTable, 1)
				
				tmp = get(obj.fitContainer.getParam(obj.fitParamTable{i, 1}, ...
					obj.fitParamTable{i, 2}, obj.fitParamTable{i, 3}(1)), 'value');
				if ~iscell(tmp), tmp = {tmp(:)}; end
				startValues = [startValues; cell2mat(tmp)]; %#ok
				
				tmp = get(obj.fitContainer.getParam(obj.fitParamTable{i, 1}, ...
					obj.fitParamTable{i, 2}, obj.fitParamTable{i, 3}(1)), 'lowerConstraint');
				if ~iscell(tmp), tmp = {tmp(:)}; end
				lowerConstr = [lowerConstr; cell2mat(tmp)]; %#ok
				
				tmp = get(obj.fitContainer.getParam(obj.fitParamTable{i, 1}, ...
					obj.fitParamTable{i, 2}, obj.fitParamTable{i, 3}(1)), 'upperConstraint');
				if ~iscell(tmp), tmp = {tmp(:)}; end
				upperConstr = [upperConstr; cell2mat(tmp)]; %#ok
			end
		end
		
		function jacob = getJacobPattern(obj)
		% Diese Funktion erzeugt ein (sparse) Jacobi-Muster fuer
		% lsqcurvefit. Alle nonzeros bedeuten, dass der Parameter p_i von
		% der Komponente y_j abhaengt. Ueber die Zeilen laeuft der y-Index
		% (als Vektor geschrieben!) und ueber die Spalten die Parameter.
		% Intern ermittelt die Methode das Pattern ueber die Fit-Tabelle
		% und die Dependencies der Fit-Funktion.
			
			jacob = [];

			% Durchlaufe die Parameter
			for i = 1:size(obj.fitParamTable, 1)
				
				% Jacobi-Pattern fuer den aktuellen Parameter
				jacobParam = sparse(0);
				
				% Abhaengigkeiten fuer den Parameter
				dep = obj.fitContainer.getFitFunction.getDependencies(obj.fitParamTable{i, 2});
				
				% Abbruch, wenn ein Parameter keine Pattern hat
				if (isempty(dep))
				
					return;
				end
				
				% Summiere ueber die Verlinkungen
				for paramInd = obj.fitParamTable{i, 3}
						
					% Entsprechend der Groesse von "value" replizieren
					jSub = dep.(obj.fitParamTable{i, 1})(paramInd).(obj.fitParamTable{i, 2});
					jSub = sparse(util.sprepmat(jSub(:), [1, prod(obj.fitParamTable{i, 4})]));
					
					jacobParam = jacobParam + jSub;
				end
				
				% An das Gesamt-Pattern anfuegen
				jacob = cat(2, jacob, jacobParam);
			end
			jacob = sparse(jacob);
		end
		
		function obj = insertFitResults(obj, fitValues, fitErrors)
		% Diese Hilfsmethode traegt die fertigen Fitwerte und -fehler in
		% den Fit-Container ein.
			
			% Fuer das Prinzip dieser Methode siehe auch "lsqFitFunc".
			
			% Zaehler fuer die Eintraege von "fitValues" und "fitErrors"
			cnt = 1;
			for i = 1:size(obj.fitParamTable, 1);
				
				% Groesse des Parameters (Anzahl der Unterparameter)
				dim = obj.fitParamTable{i, 4};
				% Werte richtig dimensionieren
				fitValueTmp = reshape(fitValues(cnt:cnt+prod(dim)-1), dim);
				fitErrorTmp = reshape(fitErrors(cnt:cnt+prod(dim)-1), dim);
				% Werte allen (verlinkten) Parametern zuweisen
				for j = obj.fitParamTable{i, 3}
					
					obj.fitContainer.getParam(obj.fitParamTable{i, 1}, obj.fitParamTable{i, 2}, j).setValue(fitValueTmp);
					obj.fitContainer.getParam(obj.fitParamTable{i, 1}, obj.fitParamTable{i, 2}, j).setFitError(fitErrorTmp);
				end
				% Gehe so viele Schritte weiter, dass man alle
				% Unterparameter eingetragen hat
				cnt = cnt + prod(dim);
			end
		end
	end
	
%% Fit-Methoden

	properties (GetAccess = public, SetAccess = private)
		
		% Speichert die Optionen fuer den Fit in einer Struktur, die mit
		% "setFitOptions" beschrieben werden kann (nach dem
		% Property-Schema).
		fitOptions = [];
	end
	
	methods (Access = public)
		
		function fitOptions = getFitOptions(obj)
			
			fitOptions = obj.fitOptions;
		end
		
		function obj = setFitOptions(obj, varargin)
		% TODO: Inputbeschreibung
			
			ip = inputParser();
			ip.addParamValue('Display', true, @(x)validateattributes(x, {'logical'}, {'scalar'}));
			ip.addParamValue('ParameterDiag', true, @(x)validateattributes(x, {'logical'}, {'scalar'}));
			ip.addParamValue('ComputeFitErrors', false, @(x)validateattributes(x, {'logical'}, {'scalar'}));
			ip.addParamValue('UseWeighting', true, @(x)validateattributes(x, {'logical'}, {'scalar'}));
			ip.parse(varargin{:});
			obj.fitOptions = ip.Results;
		end
		
		function [fitOutput, resnorm] = executeFit(obj, fitContainer)
			
			validateattributes(fitContainer, {'fitting.FitContainer'}, {'scalar'});
			obj.fitContainer = fitContainer;
			
			% Arbeits-Kopie fuer die Parameter erstellen
			obj.workingCopy = obj.fitContainer.getParamStruct();
			% Erstelle die Parameter-Tabelle
			obj.createFitParamTable();
			
			% Lese die Fit-Bedingungen aus und konvertiere sie fuer
			% lsqcurvefit
			[startValues, lowerConstr, upperConstr] = obj.getFitConditions();
			
			% Gewichtung
			if (obj.getFitOptions().UseWeighting)
				
				dataYWeight = sqrt(abs(obj.fitContainer.getDataY));
				dataYWeight(dataYWeight == 0) = 1;
			else
				
				dataYWeight = 1;
			end
			
			% lsqcurvefit ausfuehren
			[P,resnorm,residual,~,fitOutput,~,jacobian] = lsqcurvefit(@(p, x)lsqFitFunc(obj, p, x) ./ dataYWeight,...
				startValues, obj.fitContainer.getDataX, obj.fitContainer.getDataY ./ dataYWeight,...
				lowerConstr, upperConstr,...
				optimset(obj.getLsqcfOpt()));
			
			% Fehler berechnen, TODO: nur fuer kleine Probleme geeignet
			if (obj.getFitOptions().ComputeFitErrors)
				
				[~, SE] = nlparci(P, residual, 'jacobian', jacobian);
			else
				
				SE = zeros(size(P));
			end
			
			% Die Fit-Ergebnisse wieder in den Container einfuegen
			obj.insertFitResults(P, SE);
		end
	end
	
	methods (Access = private)
		
		function lsqcfOpt = getLsqcfOpt(obj)
		% Ermittelt aus "fitOptions" die Eingabestruktur fuer lsqcurvefit.
			
			lsqcfOpt = struct();
			
			if (obj.getFitOptions().Display)
				
				lsqcfOpt.Display = 'iter-detailed';
			else
				
				lsqcfOpt.Display = 'off';
			end
			
			if (obj.getFitOptions().ParameterDiag)
				
				lsqcfOpt.Diagnostics = 'on';
			else
				
				lsqcfOpt.Diagnostics = 'off';
			end
			
			lsqcfOpt.JacobPattern = obj.getJacobPattern();
			lsqcfOpt.PrecondBandWidth = Inf;
			lsqcfOpt.MaxIter = 100;
			lsqcfOpt.TolFun = 1e-008;
			lsqcfOpt.TolX = 1e-008;
		end
		
		function Y = lsqFitFunc(obj, P, X)
		% Hilfsfunktion, die eine Funktion liefert, die einem
		% Function-Handle in lsqcurvefit entspricht. Sie verbindet also die
		% Eingabestrukturen.
			
			% Arbeits-Kopie aktualisieren
			% Prinzip: Durchlaufe die Parameter-Tabelle. In jedem Schritt
			% muessen auch die Unter-Parameter des Tabelleneintags
			% durchlaufen werden (falls der Parameter nicht skalar ist).
			% Aufgrund der Struktur der Parameter-Tabelle entspricht diese
			% Reihenfolge genau der Reihenfolge der Parameter in "P"
			
			% Zaehler fuer die Eintraege von "P"
			cnt = 1;
			for i = 1:size(obj.fitParamTable, 1);
				
				% Groesse des Parameters in der Arbeits-Kopie (Dimension
				% der Unter-Parameter)
				dim = obj.fitParamTable{i, 4};
				% Schreiben mit deal (die Dimension der Unter-Parameter
				% muss mit Hilfe von reshape angepasst werden)
				[obj.workingCopy.(obj.fitParamTable{i, 1})(obj.fitParamTable{i, 3}).(obj.fitParamTable{i, 2})]... 
					= deal(reshape(P(cnt:cnt+prod(dim)-1), dim));
				% Gehe so viele Schritte weiter, dass man alle
				% Unterparameter eingetragen hat
				cnt = cnt + prod(dim);
			end
			% Mit der aktualisierten Kopie die Fitfunktion aufrufen (die
			% Gruppen sind die Uebergabeparameter)
			workingCopyCell = struct2cell(obj.workingCopy);
			Y = obj.fitContainer.getFitFunction().execute(X, workingCopyCell{:});
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function obj = DefaultFitter()
			
			% Initialisiere mit Standard-Werten
			obj.setFitOptions();
		end
	end
end