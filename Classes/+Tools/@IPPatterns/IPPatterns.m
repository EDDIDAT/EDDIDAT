%% (* INPUTPARSER-SCHABLONEN *)
%--------------------------------------------------------------------------
% Diese statische Klasse bietet einige Schablonen f�r InputParser.
%--------------------------------------------------------------------------
classdef IPPatterns
    
%% (* Methoden *)
    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Konstruktor *)
        %IP mit allen �ffentlichen Eigenschaften
        ip = ObjectProperties(MetaClass);
    
    %% (* Plot-IPs *)
        %Eindimensionale Funktion
        ip = PlottableFunction2D()
        %Zweidimensionale Funktion
        ip = PlottableFunction3D()
    end
    
    %% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = IPPatterns(), end
    end
end