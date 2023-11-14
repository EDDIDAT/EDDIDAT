%% (* PLOT-OPTIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Statische Klasse mit einigen Methoden zur Festlegung von
% Plot- und Achsenoptionen und Standard-Plot-Routinen
%--------------------------------------------------------------------------
classdef Plotting

%% (* Methoden *)
    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Geb�ndelte Aufrufe f�r Plot-Optionen *)
        %Setzt Standardoptionen f�r den 2D-Plot
        DefaultPlotOptions2D(Axis)
        %Setzt Standardoptionen f�r den 3D-Plot
        DefaultPlotOptions3D(Axis)
        
    %% (* Kategorische Aufrufe f�r Plot-Optionen *)
    % + Standard-Optionen
        %Setzt Eigenschaften zur Beschriftung
        DefaultLabelStyle(Axis)
        %Setzt Eigenschaften zum Gitter
        DefaultGridStyle(Axis)
        %Setzt Eigenschaften zur Achse
        DefaultAxesStyle(Axis)
        %Setzt Eigenschaften zu den 2D-Graphen
        DefaultCurve2DStyle(Axis)
        %Setzt Eigenschaften zu den 3D-Graphen
        DefaultCurve3DStyle(Axis)
    % + Modifikationen
        %L�sst den Bennutzer die Skalierung der Achsen festlegen
        SetAxesScale(Axis,varargin)
        
    %% (* Plot-Funktionen *)
        %Plot einer 2D Funktion
        Curve = PlotCurve2D(obj,Fun,varargin)
        %Plot einer 3D Funktion
        Curve = PlotCurve3D(obj,Fun,varargin)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = Plotting(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Legende als Subfunction
% - Haben alle Graphen eine LineWidth???