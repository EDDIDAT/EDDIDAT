%% (* INPUTPARSER-SCHABLONEN *)
%--------------------------------------------------------------------------
% Diese statische Klasse bietet einige Schablonen für InputParser.
%--------------------------------------------------------------------------
classdef IPPatterns
    
%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Konstruktor *)
        %IP mit allen öffentlichen Eigenschaften
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