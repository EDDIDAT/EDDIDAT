%% (* MOTOR-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse definiert einen Motor im Diffraktormeter, also eine
% veränderbare Achse.
%--------------------------------------------------------------------------
classdef Motor < General.MLRObject
    
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Charakteristische Eigenschaften des Motors *)
        %Position des Motors, Unit, double|va
        Position = NaN;
        %Einheit der Position, string|va
        Unit = 'none';
    	%Drehrichtung- und sinn, string|va
        MoveDirection = 'none';
    end
    
    %--> Setter und Getter
    methods
        function set.Position(obj,in)
            validateattributes(in,{'double'},{'scalar','real'});
            obj.Position = in;
        end
        function set.Unit(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.Unit = in;
        end
        function set.MoveDirection(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.MoveDirection = in;
        end
    end
    
%% (* Objektversion *)
    properties (Hidden = true, SetAccess = private, GetAccess = private)
         %Objektversion, string
         ObjectVersion = '1.0.0';
    end
    
    %--> Abrufmethode der Eigenschaft
    methods (Hidden = true, Access = public)
        % Gibt die Versionsnummer des Objektes wieder
        % Input: none
        % Output: rtn, Objektversion, string
        function rtn = Version(obj), rtn = obj.ObjectVersion; end
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = Motor(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end