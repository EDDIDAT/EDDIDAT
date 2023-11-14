%% (* MESSREIHEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert einen Detektor. Sie enthält alle
% charakteristische Eigenschaften, wie z. B. Kalibrierungen.
%--------------------------------------------------------------------------
classdef Detector < General.MLRObject & General.ISaveLoad
     
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        %Energiekalibrierungsparameter in Form eines Ploynomvektors 
        %[a_n,a_n-1,...,a_0], keV, double|va
        EnergyCalibrationParameters = 0;
        %Handle auf eine anonyme Funktion, die die Energieverschiebung 
        %(keV) in Abhängigkeit von der Totzeit (ms) wieder gibt,
        %function_handle|va
        DTLineRefraction = @(x)0;
    end 
    
    %--> Setter und Getter
    methods
        function set.EnergyCalibrationParameters(obj,in)
            validateattributes(in,{'double'},...
                {'vector','real','finite'});
            obj.EnergyCalibrationParameters = in;
        end
        function set.DTLineRefraction(obj,in)
            validateattributes(in,{'function_handle'},{'scalar'});
            obj.DTLineRefraction = in;
        end
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.dec';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'Diffractometers');
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
        function obj = Detector(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Detektorauflösung