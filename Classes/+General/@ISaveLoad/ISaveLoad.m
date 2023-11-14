%% (* SPEICHERN- UND LADEN-SCHNITTSTELLE *)
%--------------------------------------------------------------------------
% Diese Interface-Klasse implementiert bereits einen einfachen Speichern-
% und Laden-Algorithmus, der nach belieben benutzt werden kann. Wenn
% speziellere Algorithmen zu verwenden sind, können die Methoden der
% Schnittstelle überschrieben werden. In der abgeleiteten Klasse müssen die
% Dateiendung und der Pfad als Eigenschaften implementiert werden.
% FORMATVORLAGE FÜR DIE BENÖTIGTEN EIGENSCHAFTEN:
% %% (* Import und Export *)
%     %--> Eigenschaften für die ISaveLoad-Klasse
%     properties (Transient = true, Hidden = true, Constant = true,...
%                 GetAccess = public)
%          %Dateiendung im Format '.ext', string
%          FileExtension = '.obj';
%          %Verzeichnis, string
%          FilePath = fullfile(General.ProgramInfo.Path,...
%                              General.ProgramInfo.Path_Data);
%     end
%--------------------------------------------------------------------------
classdef ISaveLoad < handle
    
%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        %Speichern eines Objektes in eine Datei
        SaveToFile(obj,Filename)
    end
    
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Laden eines Objektes aus einer Datei
        obj = LoadFromFile(Filename,Caller)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        function obj = ISaveLoad(), end
    end
end