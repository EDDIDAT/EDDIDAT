%% (* MESSREIHEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert eine Messreihe, d. h. sie enthält alle wichtigen
% Daten die eine Messung eindeutig spezifizieren. Dazu gehören neben Probe
% Spektrum auch weitere Größen wie Zeit, Winkel und Kalibrierungen.
% Hat man erst einmal ein vollständiges Messobjekt, so kann daraus ein
% Ergebnisobjekt erzeugt werden.
%--------------------------------------------------------------------------
classdef Measurement < General.MLRObject & General.ISaveLoad
     
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Allgemeine Informationen *)
        %Gibt an aus welcher Messreihe die Daten stammen, string|va
        MeasurementSeries = 'none';
        %Gemessene Probe, Sample|va
        Sample = [];
        %Diffraktometer, Diffractometer|va
        Diffractometer = Measurement.Diffractometer;
        
    %% (* Zeiten *)
        %Zeitpunkt der Messung (Datumsvektor), time, double|va
        Time = 0;
        %Theoretische Messungsdauer, in der detektiert wird, s,
        %double|va
        RealTime = 0;
        %Prozentualer Anteil der Totzeit, %, double|va
        DeadTime = 0;        
        
    %% (* Rahmenbedingungen *)
        %Ringstrom, mA, double|va
        RingCurrent = 0;
        %Heiz-Rate, °C*min^-1, double|va
        HeatRate = 0;
        %Temperaturvektor (Sensoren), °C, double|va
        Temperatures = [0 0];
        %Sample thickness
        SampleThickness = 0;
        % Anode ETA
        Anode = 0;
        % Counting Time ETA
        CountingTime = 0;
        
    %% (* Motoren bzw. Positionen *)
        %Relevante Motor-Positionen, in einer Struktur gespeichert, 
        %struct|va
        Motors = [];
        %Sämtlich aus dem SpecFile eingelesene Motor-Positionen, struct|va
        Motors_all = [];
        
    %% (* Auswertungsrelevante Winkel und Positionen *)
        %Positionen des Probentisches (x,y,z), mm, double|va
        SampleStagePos = [0 0 0];
        %Winkel im Probensystem (SCS = Sample Coordinate System), °,
        %struct|va
        SCSAngles = struct('chi',0,'phi',0,'psi',0,'eta',0,...
            'alpha',0,'beta',0);
        %2*theta in Bezug auf den echten Strahlgang, °, double|va
        twotheta = 0;
             
    %% (* Messdaten *)
        %Gibt an von welchem Kanal bis zu welchem Kanal gemessen wurde,
        %double|va
        ChannelRange = [0 0];
        %Das gemessene energiedispersive Spektrum, Energie gegen 
        %Intensität, [E,I], [keV,cts], double|va
        EDSpectrum = [0 0];
    end
    
    %--> Abhängige Eigenschaften
    properties (Dependent = true)
        %Summe der Intensitäten (MCA_ROI = MultiChannelAnalysis_
        %RegionOfInterest), cts, double|va
        MCA_ROI
    end
    
    %--> Setter und Getter
    methods
        function set.MeasurementSeries(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.MeasurementSeries = in;
        end
        function set.Sample(obj,in)
            validateattributes(in,{'Sample.Sample'},{'scalar'});
            obj.Sample = in;
        end
        function set.Diffractometer(obj,in)
            validateattributes(in,{'Measurement.Diffractometer'},...
                {'scalar'});
            obj.Diffractometer = in;
        end
        function set.Time(obj,in)
            validateattributes(in,{'double'},{'vector','real','finite'});
            obj.Time = in;
        end
        function set.RealTime(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','scalar','finite'});
            obj.RealTime = in;
        end
        function set.DeadTime(obj,in)
            validateattributes(in,{'double'},...
                {'>=',0,'<=',100,'real','scalar','finite'});
            obj.DeadTime = in;
        end
        function set.RingCurrent(obj,in)
            validateattributes(in,{'double'},...
                {'>=',0,'real','scalar','finite'});
            obj.RingCurrent = in;
        end
        function set.HeatRate(obj,in)
            validateattributes(in,{'double'},...
                {'real','scalar','finite'});
            obj.HeatRate = in;
        end
        function set.Temperatures(obj,in)
            validateattributes(in,{'double'},...
                {'real','vector','finite'});
            obj.Temperatures = in;
        end
        function set.SampleThickness(obj,in)
            validateattributes(in,{'double'},...
                {'>=',0,'real','scalar','finite'});
            obj.SampleThickness = in;
        end
        function set.Motors(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist double
            validateattributes(struct2array(in),...
                {'double'},{'real','vector'});
            obj.Motors = in;
        end
        function set.Motors_all(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist double
            validateattributes(struct2array(in),...
                {'double'},{'real','vector'});
            obj.Motors_all = in;
        end
        function set.SampleStagePos(obj,in)
            validateattributes(in,{'double'},...
                {'real','row','size',[1 3]});
            obj.SampleStagePos = in;
        end
        function set.SCSAngles(obj,in)
            %äußere Struktur ist ein struct
            validateattributes(in,{'struct'},{});
            %innere Struktur ist double
            validateattributes(struct2array(in),...
                {'double'},{'real','vector','finite'});
            %--> Die Feldnamen bleiben konstant
            if all(strcmp(sort(fields(obj.SCSAngles)),sort(fields(in))))
                obj.SCSAngles = in;
            end
        end
        function set.twotheta(obj,in)
            validateattributes(in,{'double'},...
                {'real','finite'});
            obj.twotheta = in;
        end
        function set.ChannelRange(obj,in)
            validateattributes(in,{'double'},...
                {'finite','size',[1 2],'integer','nonnegative'});
            obj.ChannelRange = in;
        end
        function set.EDSpectrum(obj,in)
            validateattributes(in,{'double'},...
                {'real','size',[NaN 2]});
            %Intensitätsspalte
            %validateattributes(in(:,2),{'double'},{'nonnegative'});
            obj.EDSpectrum = in;
        end
    end
    
    %--> Getter für abhängige Eigenschaften
    methods
        function rtn = get.MCA_ROI(obj)
            %Summe der Intensitäten
            rtn = sum(obj.EDSpectrum(:,2));
        end
    end
    
%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        
    %% (* Korrekturen *)
        obj = CorrectWigglerSpectrum(obj,Mode)
        obj = CorrectAbsorption(obj,Mode,Diffsel)
        obj = CorrectDeadTime(obj)
        obj = CorrectRingCurrent(obj,RingCurrentNorm)
        
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.dat';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'Measurements');
    end
    
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Importieren einer Messreihe aus einem SpecFile
        obj = LoadFromSpecFile(Filename,Diffractometer,Mode,Calibration)
        obj = LoadFromSpecFile2(Filename,Diffractometer,Mode,Calibration)
        obj = LoadFromSpecFile_without_angles(Filename,Diffractometer,Mode)
        obj = LoadFromSpecFile_neu(Filename,Diffractometer,Mode,Calibration)
    end
    
%% (* Objektversion *)
    properties (Hidden = true, SetAccess = private, GetAccess = private)
         %Objektversion, string
         ObjectVersion = '1.0.0';
    end
    
    %--> Abrufmethode der Eigenschaft
    methods (Hidden = true, Access = public)
        % Gibt die Versionsnummer des Objektes wieder.
        % Input: none
        % Output: rtn, Objektversion, string
        function rtn = Version(obj), rtn = obj.ObjectVersion; end
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = Measurement(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - SaveToDatFile implementieren
% - Asymmetrische Scans --> Sample anpassen
% - BatchFiles
% - Eingabe Struktur für FitEDSpectrum_PV_auto
% - Diffraktometer-Anpassungsfunktion (Motoren-Übergabe, SCS-Winkel, usw.)
% - SCS-Winkel aus Diffraktometer (1 M-File in dem alle Subfunctions 
%   stehen (4 achsig, hexapod usw.), welche Funktion aufgerufen wird ist
%   Eigenschaft des Diffraktometers) --> Wo implementieren?
% - Exception Subfuncs in LoadFromSpecFile