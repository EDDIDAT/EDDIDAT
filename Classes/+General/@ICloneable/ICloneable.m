%% (* KOPIER-SCHNITTSTELLE *)
%--------------------------------------------------------------------------
% Diese Schnittstellenklasse bietet dem erbenden Objekt eine
% Kopierfunktion, die eine Hardcopy des Objektes erstellt. Wenn die
% Funktion nicht spezifisch genug ist, muss sie überschrieben werden.
% Weiterhin kann man mit statischen Methoden einen Arraykonstruktor
% ausführen, der ein Array von neuen Objekten erzeugt.
%--------------------------------------------------------------------------
classdef ICloneable < handle
    
%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        %Hardcopy eines Objektes
        obj_out = Clone(obj,CloneProperties);
    end
    
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Führt einen Konstruktor mehrfach aus und erzeugt ein Array von
        %identischen Objekten, aber mit unterschiedlichen Referenzen
        obj = CloneConstruction(Constructor,Size);
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        function obj = ICloneable(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Überprüfung, ob die Eigenschaft eines Array von Objekten leer ist in
%   Toolbox implementieren
% - Clone per struct(obj)