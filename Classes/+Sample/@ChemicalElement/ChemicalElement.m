%% (* ELEMENT-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert ein chemisches Element, die unterste Ebene eines
% Probenelementes. Hier befinden sich alle Eigenschaften und Methoden, die
% sich ausschließlich auf das Element beziehen.
%--------------------------------------------------------------------------
classdef ChemicalElement < General.MLRObject & General.ISaveLoad
    
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Charakteristische Eigenschaften des Elementes *)
        %Voller Name des Elements, string|va
        FullName = 'unnamed';
        %Ordnungszahl, no unit, double|va
        AtomicNumber = 0;
        %Atomgewicht, u (Atomare Masseneinheit), double|va
        AtomicMass = 0;
        %Massendichte, g/cm^3, double|va
        MassDensity = 0;
        %Stützstellen für den Massenschwächungskoeffizienten 
        %(mass-attenuation-coefficient) [E,MAC], [keV,cm^2/g], double|va
        MAC_Data = [0,0];
        %++++++TMP
        Stoichiometry = 1;
        %++++++TMP
    end
    
    %--> Setter und Getter
    methods
        function set.FullName(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.FullName = in;
        end
        function set.AtomicNumber(obj,in)
            validateattributes(in,{'double'},...
                {'positive','integer','scalar'});
            obj.AtomicNumber = in;
        end
        function set.AtomicMass(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','scalar','finite'});
            obj.AtomicMass = in;
        end
        function set.MassDensity(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','scalar','finite'});
            obj.MassDensity = in;
        end
        function set.MAC_Data(obj,in)
            validateattributes(in,{'double'},...
                {'finite','positive','real','size',[NaN 2]});
            obj.MAC_Data = in;
        end
    end

%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        
    %% (* Wissenschaftliche Funktionen *)
        %Berechnung des MSK in Anhängigkeit von der Energie
        mu = MAC(obj,Energy)
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.ele';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'Chemical Elements');
    end
    
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Importieren von msk-Files zur benötigten MAC_Data-Eigenschaft
        rtn = MskToMAC(Filename)
    end
    
%% (* Objektversion *)
    properties (Hidden = true, SetAccess = private, GetAccess = private)
         %Objektversion, string
         ObjectVersion = '1.0.2';
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
        function obj = ChemicalElement(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end