%% (* BASISOBJEKT-KLASSE *)
%--------------------------------------------------------------------------
% Hierbei handelt es sich um eine Basis-Klasse (fast) aller Objekte im
% Projekt. Sie bildet in erster Linie eine Schnittstelle für wichtige 
% Operationen, die alle abgeleiteten Objekt gemein haben sollten. Die
% meisten Funktionen müssen dennoch überschrieben werden, damit sie dem
% entsprechenden Objekt angepasst sind. Die Klasse erbt von dynamicprops
% (<Handle) und hgsetget (< Handle), damit man Referenzen hat und 
% dynamische Eigenschaften an die Objekte hinzufügen kann.
%--------------------------------------------------------------------------
classdef MLRObject < dynamicprops & hgsetget & General.ICloneable
    
%% (* Eigenschaften *)
    %--> Modifizierbare, versteckte Eigenschaften
    properties (Hidden = true, Access = public)
        %Möglichkeit für den Benutzer einen (beliebigen) spezifischen Wert
        %abzulegen, variant
        Tag = [];
    end
    
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        %Legt den Names des Objektes fest, Ausnahme ist hier die 
        %Initialisierung, string|va
        Name = 'unnamed';
    end
    
    %--> Getter und Setter
    methods
        function set.Name(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.Name = in;
        end
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
        function obj = MLRObject(varargin)
            
        %% (* Leerkonstruktor *)
        % Beschleunigt den Erstell-Vorgang ungemein
            if nargin == 0, return; end
            
        %% (* Konstruktor-IP *)
            ip = Tools.IPPatterns.ObjectProperties(metaclass(obj));
            ip.parse(varargin{:});
            
        %% (* Zuweisen der Ergebnisse *)
            %Alle Felder der ausgewerteten Inputargumente
            ResultProps = fieldnames(ip.Results);
            %--> Durchlaufen aller Ergebnisse des IP
            for i_c = size(ResultProps):-1:1
                %Zur Eigenschaft gehöriger Eingabewert
                in = ip.Results.(ResultProps{i_c});
                %--> Nur nicht leere Werte werden zugewiesen
                if ~isempty(in)
                    obj.(ResultProps{i_c}) = in;
                end
            end %--> for i_c = 1:size...
        end
    end
end