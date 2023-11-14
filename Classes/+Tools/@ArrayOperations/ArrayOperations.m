%% (* MATRIXOPERATIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt dem Benutzer einige weitere
% Array-Funktionen zur Verfügung, die in der MATLAB-Bibliothek fehlen.
%--------------------------------------------------------------------------
classdef ArrayOperations

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Size-Funktionen *)
        varargout = MatchSize(Arrays,Size)
        M_out = CutMatrix(M,Index_Min,Index_Max)
        
    %% (* Konvertierungs-Funktionen *)
        M_out = Cell2Mat(M)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = ArrayOperations(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Leere Elemente in einem Cellarray finden (Problem bei Clone)
% - Logisches Array von ausgehend von einem Spaltenindex (beliebig in jeder
%   Zeile) mit Einsen nach links oder rechts füllen