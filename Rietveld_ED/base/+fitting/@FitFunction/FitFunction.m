classdef FitFunction < base.Function
%% (* FitFunction *)
% Dies ist eine abstrakte Fitfunktion. Sie erweitert "Function" um einige
% (abstrakte) Methoden, die fuer das fitten benoetigt werden. Damit die
% Funktion automatisiert aufgerufen werden kann, muss zusaetzlich
% "addFunctionParameters" implementiert werden, wodurch der Input von
% "execute" eindeutig festgelegt wird. Im ein Jacobi-Pattern vorzugeben,
% sollte man "getDependencies" ueberschreiben. Weiterhin kennt die
% Fit-Funktion ihren Container und kann dadurch automatisch ihre Parameter
% an diesen weitergeben.
% -------------------------------------------------------------------------

%% Felder

	properties (GetAccess = public, SetAccess = private)
		
		% Dadurch, dass die Funktion ihren Container kennt, hat sie Zugriff
		% auf relevante aeussere Eigenschaften und das Hinzufuegen der
		% Parameter kann automatisiert werden. Rekursive Aufrufe fuer
		% Untermodule sind auch nicht mehr notwendig.
		fitContainer;
	end
	
	methods (Access = public)
		
		function obj = setFitContainer(obj, fitContainer)
			
			validateattributes(fitContainer, {'fitting.FitContainer'}, {'scalar'});
			obj.fitContainer = fitContainer;
			% Automatisches Hinzufuegen der Parameter 
			obj.addFunctionParameters(fitContainer);
		end
		
		function fitContainer = getFitContainer(obj)
			
			fitContainer = obj.fitContainer;
		end
	end
	
%% Erweiterungen
	
	methods (Abstract = true, Access = public)
		
		obj = addFunctionParameters(obj, pc);
		% Diese Methode fuegt die Parameter dieser Funktion in den
		% "ParameterContainer" pc ein. In diesem stehen dann alle
		% Parameter/Gruppen, die die Funktion ("execute") erwartet. An
		% "execute" muessen nun per "varargin" die in
		% "addFunctionParameter" erzeugten Parameter uebergeben werden.
		% Dabei wird jede Gruppe einzeln uebergeben (Wichtig: die Gruppen
		% muessen alphabetisch geordnet sein).
	end
	
	methods (Access = public)
		
		function dep = getDependencies(obj, paramName) %#ok
		% Diese Methode gibt die Abhaengigkeit der einzelnen Komponenten
		% des Output-Vektors "Y" von "execute" wieder. Ist die Rueckgabe
		% gleich "[]", so gibt es keine formalen Unabhaengigkeiten.
		% Andernfalls wir eine Struktur wiedergegeben, die genau der von
		% "getParamStruct" von "ParameterContainer" entspricht. Die Felder
		% selbst enthalten Matrizen in der Dimension von "Y", die mit
		% logischen Variablen die entsprechenden Abhaengigkeiten
		% wiedergeben (true, wenn der Parameter von der Komponente
		% abhaengt). Wenn der "value" des Parameters nicht-skalar ist, so
		% gelten die Abhaengigkeiten fuer jeden Unterparameter. Diese
		% Methode ist Standardmaessig mit der Rueckgabe "[]" implementiert
		% und muss daher nicht ueberschrieben werden. Die Dimension von "Y"
		% kann man sich z.B. aus dem "FitContainer" holen. Mit dem Argument
		% "paramName" kann man sich auf die Anhaengigkeiten fuer ein
		% bestimmten Parameter beschraenken (aus Effizienzgruenden).
			
			dep = [];
		end
	end
end

