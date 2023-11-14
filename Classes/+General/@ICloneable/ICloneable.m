%% (* KOPIER-SCHNITTSTELLE *)
%--------------------------------------------------------------------------
% Diese Schnittstellenklasse bietet dem erbenden Objekt eine
% Kopierfunktion, die eine Hardcopy des Objektes erstellt. Wenn die
% Funktion nicht spezifisch genug ist, muss sie �berschrieben werden.
% Weiterhin kann man mit statischen Methoden einen Arraykonstruktor
% ausf�hren, der ein Array von neuen Objekten erzeugt.
%--------------------------------------------------------------------------
classdef ICloneable < handle
    
%% (* Methoden *)
    %--> �ffentliche Methoden
    methods (Access = public)
        %Hardcopy eines Objektes
        obj_out = Clone(obj,CloneProperties);
    end
    
    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
        %F�hrt einen Konstruktor mehrfach aus und erzeugt ein Array von
        %identischen Objekten, aber mit unterschiedlichen Referenzen
        obj = CloneConstruction(Constructor,Size);
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsm�glichkeiten:
        % 1) Kein Argument
        function obj = ICloneable(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - �berpr�fung, ob die Eigenschaft eines Array von Objekten leer ist in
%   Toolbox implementieren
% - Clone per struct(obj)