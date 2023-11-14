%% (* MESSREIHEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert ein Diffraktometer. Die Eigenschaften sind in
% erster Linie die Bausteine aus denen das Diffraktometer zusammengesetzt
% ist.
%--------------------------------------------------------------------------
classdef Diffractometer < General.MLRObject & General.ISaveLoad
     
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        %Achseneinheiten, die das Probensystem steuern, struct|va
        SamplePositioner = [];
        %Achseneinheiten, die das Quellensystem steuern, struct|va
        SourcePositioner = [];
        %Achseneinheiten, die das Detektorsystem steuern, struct|va
        DetectorPositioner = [];
        %Detektor, Detector|va
        Detector = [];
        %Virtuelle Motoren
        VirtualMotors = [];
        %Literals for import
        ImportLiterals = [];
        %Check for SPEC format
        CheckSPECformat = [];
    end 
    
    %--> Setter und Getter
    methods
        function set.SamplePositioner(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist Motor
            validateattributes(struct2array(in),...
                {'Measurement.Motor'},{});
            obj.SamplePositioner = in;
        end
        function set.SourcePositioner(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist Motor
            validateattributes(struct2array(in),...
                {'Measurement.Motor'},{});
            obj.SourcePositioner = in;
        end
        function set.DetectorPositioner(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist Motor
            validateattributes(struct2array(in),...
                {'Measurement.Motor'},{});
            obj.DetectorPositioner = in;
        end
        function set.Detector(obj,in)
            validateattributes(in,{'Measurement.Detector'},{'scalar'});
            obj.Detector = in;
        end
        function set.VirtualMotors(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist Motor
            validateattributes(struct2array(in),...
                {'char'},{});
            obj.VirtualMotors = in;
        end
        function set.ImportLiterals(obj,in)
%             %äußere Struktur ist ein struct
%             validateattributes(in,{'struct'},{});
%             %innere Struktur ist Motor
%             validateattributes(struct2array(in),...
%                 {'char'},{});
            obj.ImportLiterals = in;
        end
        function set.CheckSPECformat(obj,in)
            %äußere Struktur ist ein double
            validateattributes(in,{'double'},{});
            obj.CheckSPECformat = in;
        end
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.dif';
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
        function obj = Diffractometer(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Mehr Eigenschaften hinzufügen