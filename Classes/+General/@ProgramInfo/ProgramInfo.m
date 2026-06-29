%% (* PROGRAMM-INFORMATIONS-KLASSE *)
%--------------------------------------------------------------------------
% Statische Klasse, die alle wichtigen Informationen über das Programm
% enthält (Name, Pfad usw.). Auf diese Informationen greifen dann andere
% Klassen zu.
%--------------------------------------------------------------------------
classdef ProgramInfo

%% (* Eigenschaften *)
    %--> Konstante Eigenschaften
    properties (Constant = true, GetAccess = public)

    %% (* Namen und Versionen *)
        %Kurzname des Programms, string
        Name = 'EDDIDAT';
        %Voller Name, string
        FullName = 'Stress Analysis With X-Ray Diffraction';
        %Release-Nummer, string
        Release = '0.0';

    %% (* Pfade *)
        %Absoluter Pfad des Programms, string
        Path = General.resolveProgramRoot();
        %Klassen-Pfad, relativ zum absoluten Pfad, string
        Path_Classes = ['Classes' filesep];
        %Daten-Pfad, relativ zum absoluten Pfad, string
        Path_Data = ['Data' filesep];
    end

%% (* Konstruktor *)
    methods (Access = private)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = ProgramInfo, end
    end
end
