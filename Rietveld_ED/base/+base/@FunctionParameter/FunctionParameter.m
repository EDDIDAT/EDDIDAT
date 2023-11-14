classdef FunctionParameter < hgsetget
%% (* FunctionParameter *)
% Diese Klasse stellt einen Funktions-Parameter dar. Neben den klassischen
% Eigenschaften "name", "unit" und "value" gibt es eine
% Groessen-Restriktion, die festlegt welche Dimension der Parameter haben
% darf.
% TODO: validator implementieren (ueber Konstruktor), name muss gueltiger
% FieldName sein, Konstruktor
% -------------------------------------------------------------------------

%% Felder
	
	properties (GetAccess = public, SetAccess = private)
		
		% Der Name des Parameters
		name = 'Untitled';
		% (Physikalische) Einheit des Parameters
		unit = 'no unit';
		% Kategorie des Parameters
		category = 'Misc';
		% Beschreibung des Parameters
		description = '';
		
		% Wert des Parameters
		% Weist man ein Skalar, so wird die Groesse automatisch an 
		% paramSize angepasst. Alle weiteren Eigenschaften, die die Groesse
		% von value haben, sollten automatisch an die Groesse von value
		% angepasst werden (und damit auch zurueckgesetzt)
		value = 0;
		
		% "size"-Vektor fuer value
		% Die Syntax entspricht der bei validateattibutes bzw. size(...) 
		% (insbesondere NaN fuer beliebig viele Eintraege)
		paramSize = [NaN NaN];
	end
	
	methods (Access = public)
		
		function obj = setName(obj, name)
			
			validateattributes(name, {'char'}, {'nonempty','row'});
			obj.name = name;
		end
		
		function name = getName(obj)
			
			name = obj.name;
		end
		
		function obj = setUnit(obj, unit)
			
			validateattributes(unit, {'char'}, {});
			if ~isempty(unit)
				validateattributes(unit, {'char'}, {'row'});
			end
			obj.unit = unit;
		end
		
		function unit = getUnit(obj)
			
			unit = obj.unit;
		end
		
		function obj = setCategory(obj, category)
			
			validateattributes(category, {'char'}, {'nonempty','row'});
			obj.category = category;
		end
		
		function category = getCategory(obj)
			
			category = obj.category;
		end
		
		function obj = setDescription(obj, description)
			
			validateattributes(description, {'char'}, {});
			if ~isempty(description)
				validateattributes(description, {'char'}, {'row'});
			end
			obj.description = description;
		end
		
		function description = getDescription(obj)
			
			description = obj.description;
		end
		
		function obj = setValue(obj, value)
			
			% Bei leeren eingaben die "Dimension" anpassen
			if isempty(value)
				
				s = obj.getParamSize();
				s(isnan(s)) = 0;
				value = zeros(s);
			end
			
			% Anpassen an die Groesse
			if isscalar(value)
				
				s = obj.getParamSize();
				s(isnan(s)) = 1;
				value = repmat(value, s);
			end
			% size-check
			validateattributes(value, {class(value)}, {'size', obj.getParamSize()}, 'Value', obj.getName());
			
			obj.value = value;
		end
		
		function value = getValue(obj)
			
			value = obj.value;
		end
		
		function obj = setParamSize(obj, paramSize)
			
			% Groessen-Vektor anpassen
			validateattributes(paramSize, {'double'}, {'nonempty', 'row'});
			validateattributes(paramSize(~isnan(paramSize)), {'double'}, {'integer', 'positive'});
			if length(paramSize) == 1
				paramSize = [paramSize, 1];
			end
			obj.paramSize = paramSize;
			% Dimensionen von value anpassen
			paramSize(isnan(paramSize)) = 1;
			obj.setValue(zeros(paramSize)); 
		end
		
		function paramSize = getParamSize(obj)
			
			paramSize = obj.paramSize;
		end
	end
	
%% Methoden
	
	methods (Access = public)
		
		function dims = getSize(obj)
		% Gibt die aktuelle Groesse von value wieder.
			
			dims = size(obj.getValue());
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function new = clone(obj)
		% Erstellt eine tiefe Kopie des Parameters.
			
			new = base.FunctionParameter();
			new.setName(obj.getName());
			new.setUnit(obj.getUnit());
			new.setCategory(obj.getCategory());
			new.setDescription(obj.getDescription());
			new.setParamSize(obj.getParamSize());
			new.setValue(obj.getValue());
		end
	end
end