%% (* AUSWERTUNGS-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse stellt das Auswertungs-Objekt einer Messreihe dar. Das
% Herzst�ck der Auswertung ist ein 2D-Array mit den ausgewerteten
% Beigungslinien (�ber die Messungen und die verschiedenen Beugungslinien)
% (DiffractionLine). Anhand dieser Informationen k�nnen alle m�glichen
% Auswertungen vorgenommen werden.
%--------------------------------------------------------------------------
classdef SpectraAnalysis < General.MLRObject & General.ISaveLoad

%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        %Beugungslinien, 1. Dimension: Alle Linien eines Spektrum �ber
        %einer Messung, 2. Dimension: Eine Linie �ber alle Messungen,
        %DiffractionLine|va
        DiffractionLines = [];
    end
    
    %--> Setter und Getter
    methods
        function set.DiffractionLines(obj,in)
            validateattributes(in,{'SpectraAnalysis.DiffractionLine'},...
                {'2d'});
            obj.DiffractionLines = in;
        end
    end
    
%% (* Methoden *)

    %--> �ffentliche Methoden
    methods (Access = public)
        %Zusatzfunktion: Berechnet die kumulative Zeitdifferenz zwischen 
        %den Messungen
        rtn = DeltaTime(obj,Index_Measurement)
    end

    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Erstellen eines Auswertungsobjektes *)
    % Die Grundlage bei der Erstellung sind bereits erstellte
    % DiffractionLine-Objekte (DL) aus den Messungen. Da alle Spektren
    % zun�chst unabh�ngig voneinander ausgewertet wurden kann die Anzahl
    % der Peaks pro Messung varieren so, dass die �u�ere Struktur der
    % Eingabe DLs eine Zelle ist (pro Messung eine Zelle), in diesen Zellen
    % sind dann die Vektoren mit den DLs der entsprechenden Messung
        %Erzeugt ein Auswertungsobjekt und setzt die entscheidende
        %Eigenschaft DiffractionLines anhand von Vorgabewerten und
        %einzelnen Beugungslinien
        obj = CreateFromDL(DL_Unfiltered,PeakRanges)
        %Automatisches Finden von sinnvollen Peak-Bereichen �ber alle
        %Messungen
        PeakRanges = FindPeakRanges(DL_Unfiltered,RangeWidth)
    end
    
%% (* Import und Export *)
    %--> Eigenschaften f�r die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.spa';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'SpectraAnalysis');
    end
    
    %--> �ffentliche Methoden
    methods (Access = public)
        %Exportieren in einen Psi-File (Mathematica)
        SaveToPsiFile(obj,Filename,WriteDummyPeaks,Mode)
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
        % Konstruktionsm�glichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = SpectraAnalysis(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end   
end