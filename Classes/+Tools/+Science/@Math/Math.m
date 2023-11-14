%% (* MATHEMATIK-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt benötigte mathematische Funktionen und 
% Konstanten zur Verfügung.
%--------------------------------------------------------------------------
classdef Math
    
%% (* Eigenschaften *)
    %--> Konstante Eigenschaften
    properties (Constant = true, GetAccess = public)
        
    %% (* Grad/Bogenmaß *)
    % Winkel müssen mit ihrer eigenen Einheit multipliziert werden, um
    % diese in die andere Einheit umzurechnen, z. B. 180*Degree = pi oder
    % pi*Radian=180
        %Angabe von 1° in rad, rad, double
        Degree = pi / 180;
        %Angabe von 1rad in °, °, double
        Radian = 180 / pi;
    end
    
%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Eindimensionale Mathematische (Fit-)Funktionen *)
    % Fitfunktionen werden mit FF_... markiert
        %Gauss-Funktion
        y = FF_Gauss(x,p_1,p_2,p_3)
        %Lorentz-Funktion
        y = FF_Lorentz(x,p_1,p_2,p_3)
        %Pseudo-Voigt-Funktion
        y = FF_PseudoVoigt(x,p_1,p_2,p_3,p_4)
        %TCH-Funktion
        y = FF_TCH(x,p_1,p_2,p_3,p_4)
        %Pseudo-Voigt-Funktion ETA
        y = FF_PseudoVoigtETA(x,p_1,p_2,p_3,p_4,p_5)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = Math(), end
    end
end