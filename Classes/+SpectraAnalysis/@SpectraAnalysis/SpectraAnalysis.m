%% (* AUSWERTUNGS-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse stellt das Auswertungs-Objekt einer Messreihe dar. Das
% Herzstück der Auswertung ist ein 2D-Array mit den ausgewerteten
% Beigungslinien (über die Messungen und die verschiedenen Beugungslinien)
% (DiffractionLine). Anhand dieser Informationen können alle möglichen
% Auswertungen vorgenommen werden.
%--------------------------------------------------------------------------
classdef SpectraAnalysis < General.MLRObject & General.ISaveLoad

%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        %Beugungslinien, 1. Dimension: Alle Linien eines Spektrum über
        %einer Messung, 2. Dimension: Eine Linie über alle Messungen,
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

    %--> Öffentliche Methoden
    methods (Access = public)
        %Zusatzfunktion: Berechnet die kumulative Zeitdifferenz zwischen 
        %den Messungen
        rtn = DeltaTime(obj,Index_Measurement)
    end

    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Erstellen eines Auswertungsobjektes *)
    % Die Grundlage bei der Erstellung sind bereits erstellte
    % DiffractionLine-Objekte (DL) aus den Messungen. Da alle Spektren
    % zunächst unabhängig voneinander ausgewertet wurden kann die Anzahl
    % der Peaks pro Messung varieren so, dass die äußere Struktur der
    % Eingabe DLs eine Zelle ist (pro Messung eine Zelle), in diesen Zellen
    % sind dann die Vektoren mit den DLs der entsprechenden Messung
        %Erzeugt ein Auswertungsobjekt und setzt die entscheidende
        %Eigenschaft DiffractionLines anhand von Vorgabewerten und
        %einzelnen Beugungslinien
        obj = CreateFromDL(DL_Unfiltered,PeakRanges)
        %Automatisches Finden von sinnvollen Peak-Bereichen über alle
        %Messungen
        PeakRanges = FindPeakRanges(DL_Unfiltered,RangeWidth)
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.spa';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'SpectraAnalysis');
    end
    
    %--> Öffentliche Methoden
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
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = SpectraAnalysis(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end   
end