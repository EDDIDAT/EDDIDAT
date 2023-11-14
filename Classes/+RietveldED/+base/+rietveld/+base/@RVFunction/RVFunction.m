classdef RVFunction < fitting.FitFunction
%% (* RVFunction *)
% Eine Fit-Funktion, die speziell fuer das Rietveld-Modell zugeschnitten
% ist. Sie interagiert mit "RVContainer" und ist in der Lage, ihre
% benoetigten Parameter selbststaendig in diesen Einzufuegen.
% -------------------------------------------------------------------------
	
%% Felder

	methods (Access = public)
		
		function obj = setFitContainer(obj, rvContainer)
		% Hier muss ein "RVContainer" gesetzt werden.
			
			validateattributes(rvContainer, {'rietveld.base.RVContainer'}, {'scalar'});
			setFitContainer@fitting.FitFunction(obj, rvContainer);
		end
	end
	
%% Methoden

	methods (Abstract = true, Access = public)
		
		Y = execute(obj, X, general, meas, phase, spec);
		% Input-Struktur genauer spezifizieren.
	end
	
%% Unter-Module/Funktionen

	properties (GetAccess = protected, SetAccess = private)
		
		% In dieser Struktur werden die Unterfunktionen (UF) gespeichert.
		% Die erste Komponente der Struktur entspricht den Namen der
		% (Ober-)Klassen und die Zweite den Instanzen.
		subFunctionStruct = struct();
	end
	
	methods (Access = public)
		
		function subFunctionList = getSubFunctionList(obj, recursive)
		% Alle Unterfunktionen, die rekursiv aufgerufen werden, werden in
		% dieser Liste wiedergegeben. Es handelt sich um ein Cellarray:
		% 1. Spalte: Name der Unterfunktion (UF)
		% 2. Spalte: (Ober-)Klassenname der UF
		% 3. Spalte: Verwendete Instanz der UF
		% Die Instanzen koennen mit "setSubFunction" gesetzt werden. Ist
		% "recursive" gleich true, so werden rekursive saemtliche UF
		% hinzugefuegt.
		
			if (nargin < 2)
				
				recursive = true;
			end
			
			% intern wird die Struktur konvertiert
			if isempty(fieldnames(obj.subFunctionStruct))
				
				subFunctionList = cell(0,3);
			else
				
				s = size(struct2cell(obj.subFunctionStruct));
				% Wichtig: Dimension korrigieren
				subFunctionList = [fieldnames(obj.subFunctionStruct), reshape(struct2cell(obj.subFunctionStruct), [s(1), s(3)])];
			end
			
			% Rekursive Aufrufe
			if (recursive)
			
				subFunctionListRecursive = cell(0,3);

				for i = 1:size(subFunctionList, 1) 

					subFunctionListRecursive = [subFunctionListRecursive; subFunctionList{i, 3}.getSubFunctionList()]; %#ok
				end

				subFunctionList = [subFunctionList; subFunctionListRecursive];
			end
		end
		
		function obj = setSubFunction(obj, name, subFunction, useCheckFunction)
		% Setzt die UF "subFunction" in das Feld "name" ein. Ist
		% "useCheckFunction" true, so wird die UF intern in eine
		% RVCheckFunction eingebettet, so dass die Rueckgabe der UF
		% ueberprueft wird.
			
			if (nargin < 4)
				
				useCheckFunction = true;
			end
		
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			validateattributes(subFunction, {obj.subFunctionStruct(1).(name)}, {'scalar'});
			
			if (useCheckFunction)
				
				% Einbetten der UF
				checkFunc = rietveld.base.RVCheckFunction();
				checkFunc.setFitContainer(subFunction.getFitContainer());
				checkFunc.setSubFunction('SubModule', subFunction, false);

				obj.subFunctionStruct(2).(name) = checkFunc;
			else
				
				obj.subFunctionStruct(2).(name) = subFunction;
			end
			
			% Arbeitskopie aktualisieren
			obj.sfwc = obj.subFunctionStruct(2);
		end
	end
	
	properties (GetAccess = protected, SetAccess = private)
		
		% Diese Struktur wird intern fuer einen schnellen, direkten
		% Zugriff auf die UF genutzt. Die Felder sind genau die Namen aus
		% der "subFunctionStruct". Inhalte sind die Instanzen.
		% sfwc = SubFunctionWorkingCopy
		sfwc = struct();
	end
	
	methods (Abstract = true, Access = protected)
		
		obj = initSubFunctions(obj);
		% Diese Methode ist dafuer verantwortlich, dass die
		% "subFunctionStruct" erstellt wird. Dazu kann/sollte
		% "addSubFunction" benutzt werden.
	end
	
	methods (Access = protected)
		
		function obj = addSubFunction(obj, name, className, defaultSF)
		% Fuegt der UF-Struktur Eintraege hinzu. Dies ist ein Objekt der
		% Klasse "className" mit Namen "name" und der Standard-Instanz
		% "defaultSF".
			
			validateattributes(name, {'char'}, {'nonempty', 'row'});
			validateattributes(className, {'char'}, {'nonempty', 'row'});
			validateattributes(defaultSF, {'rietveld.base.RVFunction'}, {'scalar'});
			validateattributes(defaultSF, {className}, {'scalar'});
			
			obj.subFunctionStruct(1).(name) = className;
			obj.setSubFunction(name, defaultSF, false);
		end
	end	

%% Parameter-Verwaltung
	
	methods (Access = protected)
		
		function obj = addParameter(obj, pc, name, varargin)
		% Diese Methode wird von den Rietveld-Funktionen in
		% "addFunctionParameters" genutzt, um komfortable Parameter
		% hinzuzufuegen.
		% TODO: Inputbeschreibung
			
			validateattributes(pc, {'base.ParameterContainer'}, {'scalar'});
			
			ip = inputParser();
			ip.addRequired('Name', @ischar);
			ip.addParamValue('Unit', 'No unit', @ischar);
			ip.addParamValue('Category', 'Misc', @ischar);
			ip.addParamValue('Description', '', @ischar);
			ip.addParamValue('ParamSize', [1 1], @isnumeric);
			ip.addParamValue('PhaseDep', true, @islogical);
			ip.addParamValue('SpecDep', true, @islogical);
			ip.addParamValue('Constant', false, @islogical);
			ip.addParamValue('Value', 0, @isnumeric);
			ip.addParamValue('LowerConstraint', -Inf, @isnumeric);
			ip.addParamValue('UpperConstraint', Inf, @isnumeric);
			ip.parse(name, varargin{:});
			res = ip.Results;
			
			if (res.Constant)
				
				p = base.FunctionParameter();
				p.setName(res.Name);
				p.setUnit(res.Unit);
				p.setCategory(res.Category);
				p.setDescription(res.Description);
				p.setParamSize(res.ParamSize);
				p.setValue(res.Value);
			else
				
				p = fitting.FitParameter();
				p.setName(res.Name);
				p.setUnit(res.Unit);
				p.setCategory(res.Category);
				p.setParamSize(res.ParamSize);
				p.setValue(res.Value);
				p.setLinking(-1);
				p.setLowerConstraint(res.LowerConstraint);
				p.setUpperConstraint(res.UpperConstraint);
			end
			
			if (res.PhaseDep && res.SpecDep)
				
				pc.addParam('general', res.Name, p);
			elseif (res.PhaseDep && ~res.SpecDep)
				
				pc.addParam('phase', res.Name, p);
			elseif (~res.PhaseDep && res.SpecDep)
				
				pc.addParam('spec', res.Name, p);
			else
				
				pc.addParam('meas', res.Name, p);
			end
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function obj = RVFunction(rvContainer)
			
			obj.initSubFunctions();
			
			% Container gleich bei der Uebergabe
			if (nargin == 2)
				
				obj.setFitContainer(rvContainer);
			else
				
				% Default
				obj.setFitContainer(rietveld.base.RVContainer());
			end
		end
	end
end

