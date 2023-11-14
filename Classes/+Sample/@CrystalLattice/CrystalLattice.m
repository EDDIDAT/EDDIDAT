%% (* KRISTALLGITTER-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse ist zwar eigentlich direkt an ein Material gebunden, wird
% jedoch zur besseren Übersicht in einem eigenen Objekt gespeichert,
% welches stets als Eigenschaft in der Klasse Material vorzufinden ist.
%--------------------------------------------------------------------------
classdef CrystalLattice < General.MLRObject

%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Charakteristische Eigenschaften des Gitters *)
        %Kristallzellvolumen, nm^3, double|va
        CellVolume = 0;
        %Gittersystem, string|va
        System = 'none';
        %Gittertyp, string|va
        Lattice = 'none';
        %Raumgruppe, string|va
        SpaceGroup = 'none';
        %Zellenparameter (0 = nicht vorgegeben), [a,b,c;alpha,beta,gamma], 
        %[nm;°], double|va
        CellParameters = [0,0,0;0,0,0];
        %Theoretische Beugungslinien, hier werden DiffractionLine-Objekte
        %erzeugt, die später für die Auswertung benötigt werden
        %(interessant sind v. a. LatticeSpacing, HKL, und Intensity_Max),
        %DiffractionLine|va
        DiffractionLines = [];
    end
    
    %--> Setter und Getter
    methods
        function set.CellVolume(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','scalar','finite'});
            obj.CellVolume = in;
        end
        function set.System(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.System = in;
        end
        function set.Lattice(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.Lattice = in;
        end
        function set.SpaceGroup(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.SpaceGroup = in;
        end
        function set.CellParameters(obj,in)
            validateattributes(in,{'double'},...
                {'nonnegative','real','finite','size',[2 3]});
            %Der erste Wert muss positiv sein (also gegeben)
            validateattributes(in(1),{'double'},{'positive'});
            %Automatische Korrektur
            in(1,in(1,:) == 0) = in(1);
            in(2,in(2,:) == 0) = 90;
            %Zuweisen
            obj.CellParameters = in;
        end
        function set.DiffractionLines(obj,in)
            validateattributes(in,{'SpectraAnalysis.DiffractionLine'},...
                {'vector'});
            obj.DiffractionLines = in;
%[d(A),Int,h,k,l,DEC_S1,DEC_S2h], [nm,no unit,no unit,no unit,no
%unit,10^-6/MPa,10^-6/MPa], double|va
%             validateattributes(in,{'double'},...
%                 {'real','size',[NaN 7]});
%             validateattributes(in(:,3:5),{'double'},{'integer'});
%             validateattributes(in(:,1:2),{'double'},{'positive'});
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
        function obj = CrystalLattice(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end