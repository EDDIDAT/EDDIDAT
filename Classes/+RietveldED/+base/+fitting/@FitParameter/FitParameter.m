classdef FitParameter < base.FunctionParameter
%% (* FitParameter *)
% Diese Klasse erweitert die Klasse FunctionParameter um die Eigenschaften,
% die fuer einen Fit benoetigt werden. Man beachte, dass hier value vom Typ
% "double" sein muss.
% -------------------------------------------------------------------------

%% Felder
	
	properties (GetAccess = public, SetAccess = private)
		
		% Dieses Feld steuert die Abhaenigkeiten des Parameters.
		% -1 = der Parameter wir konstant festgehalten
		% 0 = der Parameter wird unabhaengig gefittet.
		% 1-x = Der Parameter wird mit allen weiteren Parametern gekoppelt,
		% die den gleichen Link-Index haben (aber nur Gleichnamige)
		% Generell werden alle Eintraege von value unabhaengig gefittet.
		linking = 0;
		
		% Untere Contrain-Grenze 
		% Muss die Groesse von value haben (gleiche Eingabesyntax wie
		% value).
		lowerConstraint = -Inf;
		% Obere Contrain-Grenze
		% Muss die Groesse von value haben (gleiche Eingabesyntax wie
		% value).
		upperConstraint = +Inf;

		% Speichert den (Standard-)Fehler des Fitparameters
		% Hat die Groesse von value und sollte in der Regel nur ausgelesen
		% werden (wird durch den Fitter ausgefuellt).
		fitError = 0;
	end
	
	methods (Access = public)
		
		function obj = setValue(obj, value)
			
			% nur numerische Werte sind hier zugelassen
			validateattributes(value, {'double'}, {'finite'}, 'Value', obj.getName());
			
			oldValue = obj.getValue();
			setValue@base.FunctionParameter(obj, value);
			
			% Falls sich die Groesse geaendert hat, werden die Dimensionen
			% korrigiert
			if (any(size(value) ~= size(oldValue)))
				
				obj.correctDimensions();
			end
			
			% Die Werte muessen in den Constraint-Bounds liegen
			try
				
				assert(all(obj.getUpperConstraint() >= obj.getValue()) & all(obj.getLowerConstraint() <= obj.getValue()));
			catch e
				
				obj.setValue(oldValue);
				error(['The values of ', obj.getName(), ' have to be in the constraint range!']);
			end
		end
		
		function obj = setLowerConstraint(obj, lowerConstraint)
			
			% leere Dimension anpassen
			if isempty(lowerConstraint)
				
				lowerConstraint = zeros(size(obj.value));
			end
			
			% Skalar "aufblaehen"
			if isscalar(lowerConstraint)
				lowerConstraint = repmat(lowerConstraint, obj.getSize());
			end
			
			validateattributes(lowerConstraint, {'double'}, ...
				{'size', obj.getSize(), 'nonnan'}, 'Lower constraint', obj.getName());
			assert(all(obj.getUpperConstraint() > lowerConstraint), ...
				'The upper constraints of ', obj.getName(), ' must be greater than the lower ones!');
			obj.lowerConstraint = lowerConstraint;
		end
		
		function lowerConstraint = getLowerConstraint(obj)
			
			lowerConstraint = obj.lowerConstraint;
		end
		
		function obj = setUpperConstraint(obj, upperConstraint)
			
			% leere Dimension anpassen
			if isempty(upperConstraint)
				
				upperConstraint = zeros(size(obj.value));
			end
			
			% Skalar "aufblaehen"
			if isscalar(upperConstraint)
				upperConstraint = repmat(upperConstraint, obj.getSize());
			end
			
			validateattributes(upperConstraint, {'double'}, ...
				{'size', obj.getSize(), 'nonnan'}, 'Upper constraint', obj.getName());
			assert(all(upperConstraint > obj.getLowerConstraint()), ...
				['The upper constraints of ', obj.getName(), ' must be greater than the lower ones!']);
			obj.upperConstraint = upperConstraint;
		end
		
		function upperConstraint = getUpperConstraint(obj)
			
			upperConstraint = obj.upperConstraint;
		end
		
		function obj = setLinking(obj, linking)
			
			validateattributes(linking, {'double'}, {'scalar', 'integer', '>=', -1});
			obj.linking = linking;
		end
		
		function linking = getLinking(obj)
			
			linking = obj.linking;
		end
		
		function obj = setFitError(obj, fitError)
			
			% leere Dimension anpassen
			if isempty(fitError)
				
				fitError = zeros(size(obj.value));
			end
			
			% Skalar "aufblaehen"
			if isscalar(fitError)
				fitError = repmat(fitError, obj.getSize());
			end
			
			validateattributes(fitError, {'double'}, ...
				{'size', size(obj.value), 'finite'}, 'Fit error', obj.getName());
			obj.fitError = fitError;
		end
		
		function fitError = getFitError(obj)
			
			fitError = obj.fitError;
		end
	end
	
%% Methoden
	
	methods (Access = private)
		
		function obj = correctDimensions(obj)
		% Hilfsmethode, um die Dimensionen der Werte anzupassen.
			
			obj.lowerConstraint = -Inf * ones(size(obj.getValue())); % manuell, um die Validation zu verhindern
			obj.upperConstraint = Inf * ones(size(obj.getValue())); % manuell, um die Validation zu verhindern
% 			obj.setLowerConstraint(-Inf);
% 			obj.setUpperConstraint(Inf);
			obj.setLinking(0);
			obj.setFitError(0);
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function new = clone(obj)
		% Erstellt eine tiefe Kopie des Parameters.
			
			new = fitting.FitParameter();
			new.setName(obj.getName());
			new.setUnit(obj.getUnit());
			new.setCategory(obj.getCategory());
			new.setDescription(obj.getDescription());
			new.setParamSize(obj.getParamSize());
			new.setValue(obj.getValue());
			new.setLinking(obj.getLinking());
			new.setLowerConstraint(obj.getLowerConstraint());
			new.setUpperConstraint(obj.getUpperConstraint());
			new.setFitError(obj.getFitError());
		end
	end
end

