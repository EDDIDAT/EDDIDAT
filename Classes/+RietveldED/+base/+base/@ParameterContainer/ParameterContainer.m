classdef ParameterContainer < hgsetget
%% (* FitContainer *)
% Diese Klasse buendelt die Funktionsparameter. Die Verwaltung geschieht
% zunaechst in Oberkategorien (Groups). Diese haben jeweils eine
% bestimmte Dimension/Groesse. Wir einer Kategorie ein Parameter
% hinzugefuegt, so wird dieser auf die entsprechende Groesse repliziert.
% TODO: Dopplungen bei Parameter-Namen
% -------------------------------------------------------------------------
		
%% Funktions-Parameter

	properties (Access = private)
		
		% Struktur, die wiederum Unterstrukturen mit den Parametern
		% enthaelt. Die Felder sind Arrays (unterschiedlicher Groesse) von
		% Parameternstrukuren
		groups = struct();
		% Speichert due (Array-)Groessen der Gruppen.
		groupsSizes = struct();
	end
	
	methods (Access = public)
		
	%% Gruppen-Verwaltung
		
		function obj = addGroup(obj, name, size)
		% Fuegt dem Container eine neue (leere) Parametergruppe mit dem
		% Namen "Name" hinzu. "size" ist der Dimensionsvektor der Gruppe.
			
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			validateattributes(size, {'double'}, {'nonempty', 'integer', 'positive', 'row'});
			if length(size) == 1
				size = [size, 1];
			end
			% Existiert die Gruppe schon?
			if (obj.isGroup(name))
				
				return;
			end
			
			obj.groups.(name) = struct();
			obj.groupsSizes.(name) = size;
		end
		
		function size = getGroupSize(obj, groupName)
		% Gibt die Groesse der Gruppe "groupName" wieder.
			
			validateattributes(groupName, {'char'}, {'nonempty', 'row'});
			if (~obj.isGroup(groupName))
				
				error('The group you referenced does not exist!');
			end
			
			size = obj.groupsSizes.(groupName);
		end
		
		function names = getGroupNames(obj)
		% Gibt eine alphabetisch sortierte String-Liste mit allen
		% Gruppennamen wieder.
			
			names = sort(fieldnames(obj.groups))';
		end
		
		function b = isGroup(obj, groupName)
		% Gibt wieder ob die Gruppe bereits vorhanden ist oder nicht.
			
			validateattributes(groupName, {'char'}, {'nonempty', 'row'});
			b = isfield(obj.groups, groupName);
		end
		
	%% Parameter-Verwaltung
		
		function obj = addParam(obj, groupName, name, param)
		% Fuegt "param" als neuen Parameter mit Namen "name" der Gruppe
		% "groupName" hinzu.
			
			% Falls kein Parameter uebergeben
			if (nargin < 4)
				
				param = base.FunctionParameter();
			end
			
			% Validation
			validateattributes(groupName, {'char'}, {'nonempty', 'row'});
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			validateattributes(param, {'base.FunctionParameter'}, {'nonempty'});
			% Gruppe hinzufuegen, falls nicht vorhanden
			if (~obj.isGroup(groupName))
				
				obj.addGroup(groupName, size(param));
			end
			% Existiert der Parameter schon?
			if (obj.isParam(groupName, name))
				
				return;
			end
			
			for i = 1:prod(obj.getGroupSize(groupName))
				
				if numel(param) == prod(obj.getGroupSize(groupName))
					
					% Anzahl stimmt ueberein
					obj.groups.(groupName)(i).(name) = param(i);
				elseif isscalar(param)
					
					% Parameter auf Gruppen-Groesse replizieren
					obj.groups.(groupName)(i).(name) = param(1).clone();
				else
					
					error('The size of your parameter does not fit to the group!');
				end
			end
			
			% ggf. Dimension anpassen
			obj.groups.(groupName) = reshape(obj.groups.(groupName), obj.getGroupSize(groupName));
		end
		
		function [param, groupName] = getParam(obj, groupName, name, varargin)
		% Gibt den gesuchten Parameter "name" aus der Gruppe "groupName"
		% zurueck. Mit den weiteren Uebergabe-Parametern kann das
		% Gruppen-Array indiziert werden. Wird "groupName" leer gelassen,
		% so wird eine Suche durch den gesamten Container nach dem
		% Parameter durchgefuehrt.
		
			% globale Suche
			if (isempty(groupName))
				
				for gn = obj.getGroupNames()
					
					for pn = obj.getParamNames(gn{1})
						
						if (strcmp(pn{1}, name))
							
							groupName = gn{1};
						end
					end
				end
			end
		
			% Validation
			validateattributes(groupName, {'char'}, {'row'});
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			
			if (~obj.isGroup(groupName))
				
				error('The group you referenced does not exist!');
			end
			
			if (~obj.isParam(groupName, name))
				
				error('The parameter you referenced does not exist in this group!');
			end
			
			if nargin <= 3
			
				param = reshape([obj.groups.(groupName).(name)], obj.getGroupSize(groupName));
			else
				param = [obj.groups.(groupName)(varargin{:}).(name)];
			end
		end 
		
		function names = getParamNames(obj, groupName)
		% Gibt eine alphabetisch sortierte String-Liste mit allen
		% Parameternamen aus der Gruppe "groupName" wieder.
			
			validateattributes(groupName, {'char'}, {'nonempty', 'row'});
			if (~obj.isGroup(groupName))
				
				error('The group you referenced does not exist!');
			end
			
			names = sort(fieldnames(obj.groups.(groupName)))';
		end
		
		function b = isParam(obj, groupName, name)
		% Gibt wieder ob der Parameter in der Gruppe bereits vorhanden ist
		% oder nicht.
		
			validateattributes(groupName, {'char'}, {'nonempty', 'row'});
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			if (~obj.isGroup(groupName))
				
				error('The group you referenced does not exist!');
			end
			
			b = isfield(obj.groups.(groupName), name);
		end
		
	%% Sontiges
	
		function obj = reset(obj)
		% Loescht alle Parameter und Gruppen des Containers
		
			obj.groups = struct();
			obj.groupsSizes = struct();
		end
		
		function obj = merge(obj, pc)
		% Diese Methode verschmelzt zwei Parameter-Container. Prioritaet
		% hat der aufrufende Container, d.h. nur nicht vorhandene Parameter
		% und Gruppen aus "pc" werden hinzugefuegt.
			
			validateattributes(pc, {'base.ParameterContainer'}, {'scalar'});
			
			for groupName = pc.getGroupNames()
				
				% Falls noetig, fuege neue Gruppe hinzu
				if (~obj.isGroup(groupName{1}))
					
					obj.addGroup(groupName{1}, pc.getGroupSize(groupName{1}));
				end
				
				for paramName = pc.getParamNames(groupName{1})
					
					% Fuege neuen Parameter hinzu
					if (~obj.isParam(groupName{1}, paramName{1}))
					
						obj.addParam(groupName{1}, paramName{1}, pc.getParam(groupName{1}, paramName{1}));
					end
				end
			end
		end
		
		function paramStruct = getParamStruct(obj, paramName)
		% Erstellt ein "duennes Skelett" der Parameter. Die Strukur von
		% paramStruct ist identisch mit der von groups, d.h. man adressiert
		% als erstes die Gruppe (mit Index) und dann die Parameter. Diese
		% Felder enthalten nur die Werte der Parameter. Saemtliche
		% Strukturen sind alphabetisch geordnet. Gibt man noch "paramName"
		% vor, so wird die Struktur nur fuer diesen Parameter erzeugt.
		
			% Erzeugt die Struktur nur fuer den Parameter "paramName"
			if (nargin == 2)
				
				[param, groupName] = obj.getParam([], paramName);
				
				paramStruct.(groupName) = struct();
				for i = 1:prod(obj.getGroupSize(groupName))
				
					paramStruct.(groupName)(i).(paramName) = param(i).getValue();
				end
				paramStruct.(groupName) = reshape(paramStruct.(groupName), obj.getGroupSize(groupName));
				
				return;
			end
			
			% Durchlaeuft groups und erstellt das Skelett.
			for groupName = obj.getGroupNames()
				
				paramStruct.(groupName{1}) = struct();
				
				for paramName = obj.getParamNames(groupName{1})
					
					for i = 1:prod(obj.getGroupSize(groupName{1}))
				
						paramStruct.(groupName{1})(i).(paramName{1}) = obj.getParam(groupName{1}, paramName{1}, i).getValue();
					end
					paramStruct.(groupName{1}) = reshape(paramStruct.(groupName{1}), obj.getGroupSize(groupName{1}));
				end
				% Parameter (alphabetisch) ordnen
				paramStruct.(groupName{1}) = orderfields(paramStruct.(groupName{1}));
			end
			% Gruppen (alphabetisch) ordnen
			paramStruct = orderfields(paramStruct);
		end
	end
end

