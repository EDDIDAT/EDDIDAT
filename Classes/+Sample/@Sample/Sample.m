%% (* PROBEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert eine Probe. Das Herzstück dieses Objektes ist
% eine Liste von Materialen, aus denen sie bestellt. Abhängig vom Aufbau
% der Probe werden den Materialien entsprechende dynamische Eigenschaften
% zugeordnet.
%--------------------------------------------------------------------------
classdef Sample < General.MLRObject & General.ISaveLoad
    
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Charakteristische Eigenschaften der Probe *)
        %Aufbau bzw. Anordnung der Probe (bis jetzt entweder 
        %"PhaseMixture" oder "CoatingSystem"), string|va
        Structure = 'none';
        %Geometrie der Probe (noch nicht implementiert), Geometry|va
        Geometry = [];
        %Materialen aus denen die Probe besteht, Material|va
        Materials = [];
        %Substrat aus dem die Probe besteht, Substrate|va
        Substrate = [];
    end
    
    %--> Setter und Getter
    methods
        function set.Structure(obj,in)
            validatestring(in,{'PhaseMixture','CoatingSystem'});
            obj.Structure = in;
        end
        function set.Geometry(obj,in)
            validateattributes(in,{'Sample.Geometry'},{'scalar'});
            obj.Geometry = in;
        end
        function set.Materials(obj,in)
            validateattributes(in,{'Sample.Material'},{'vector'});
            
%         %% (* Dynamische Eigenschaften *)
%             %--> Phasengemenge?
%             if strcmp(obj.Structure,{'PhaseMixture'})
%                 %--> Hinzufügen des Volumenanteils 
%                 %    (VolumeFraction, %, double|va)
%                 for i_c = 1:length(in)
%                     %--> Nur wenn die Eigenschaft noch nicht existiert
%                     if isempty(findprop(in(i_c),'VolumeFraction'))
%                         p = addprop(in(i_c),'VolumeFraction');
%                         p.GetAccess = 'public';
%                         p.SetAccess = 'public';
%                         %Externe Set-Methode
%                         p.SetMethod = @set_VolumeFraction;
%                         %Standardwert = 1
%                         in(i_c).VolumeFraction = 1;
%                     end
%                 end %--> for i_c = 1:...
%             %--> Schichtsystem?, wobei die der Index auch die
%             %    Schichtreihenfolge bestimmt (1 = oberste Schicht)
%             elseif strcmp(obj.Structure,{'CoatingSystem'})
%                 %--> Hinzufügen der Schichtdicke 
%                 %    (CoatingThickness, mm, double|va)
%                 for i_c = 1:length(in)
%                     %--> Nur wenn die Eigenschaft noch nicht existiert
%                     if isempty(findprop(in(i_c),'CoatingThickness'))
%                         p = addprop(in(i_c),'CoatingThickness');
%                         p.GetAccess = 'public';
%                         p.SetAccess = 'public';
%                         %Externe Set-Methode
%                         p.SetMethod = @set_CoatingThickness;
%                         %Standardwert = 1
%                         in(i_c).CoatingThickness = Inf;
%                     end
%                 end %--> for i_c = 1:...
%             else
%                 error(['You have to specifiy the sample structure',...
%                     ' before assigning Materials!'])
%             end %--> if strcmp(obj...
            %Zuweisen
            obj.Materials = in;
        end
        function set.Substrate(obj,in)
            validateattributes(in,{'Sample.Substrate'},{'vector'});
            obj.Substrate = in;
        end
    end
    
%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        
    %% (* Wissenschaftliche Funktionen *)
        %Transmission durch beliebige Materialkombination
        T = Transmission(obj,Energy)
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.spl';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'Samples');
    end
    
%% (* Objektversion *)
    properties (Hidden = true, SetAccess = private, GetAccess = private)
         %Objektversion, string
         ObjectVersion = '1.0.0';
    end
    
    %--> Abrufmethode der Eigenschaft
    methods (Hidden = true, Access = public)
        % Gibt die Versionsnummer des Objektes wieder
        % Input: none
        % Output: rtn, Objektversion, string
        function rtn = Version(obj), rtn = obj.ObjectVersion; end
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        % Konstruktionsmöglichkeiten:
        % 1) Kein Argument
        % 2) Eingabe von Eigenschaften per InputParser
        function obj = Sample(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end
%--------------------------------------------------------------------------
% Externe Set-Funktion für die Eigenschaft VolumeFraction 
% der Materialliste
function set_VolumeFraction(obj,in)
    validateattributes(in,{'double'},{'scalar','real','>',0,'<=',100});
    obj.VolumeFraction = in;
end
%--------------------------------------------------------------------------
% Externe Set-Funktion für die Eigenschaft CoatingThickness 
% der Materialliste
function set_CoatingThickness(obj,in)
    validateattributes(in,{'double'},{'scalar','real','positive'});
    obj.CoatingThickness = in;
end

%% ##### TO BE IMPLEMENTED #####
% - Transmission bei Phasengemenge
% - Eindringtiefe und ED-Spektrum-Simulation