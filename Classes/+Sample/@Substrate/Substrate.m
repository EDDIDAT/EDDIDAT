%% (* MATERIAL-KLASSE *)
%--------------------------------------------------------------------------
% Diese Klasse modelliert einen Werkstoff. Neben den charakteristischen
% Eigenschaften wird hier als Eigenschaft eine Liste von chemischen
% Elementen (Klasse: ChemicalElement) gefordert, sowie ein Kristallgitter 
% (Klasse: CrystalLattice). Dabei werden zu den Elementen dynamisch deren
% Stöchiemetrieanteile hinzugefügt.
%--------------------------------------------------------------------------
classdef Substrate < General.MLRObject & General.ISaveLoad
    
%% (* Eigenschaften *)
    %--> Modifizierbare Eigenschaften
    properties (Access = public)
        
    %% (* Charakteristische Eigenschaften des Materials *)
        %Chemische Summenformel im Format (E_1n_1 E_2n_2 ... E_in_i),
        %wobei die Buchstaben die Elemente und die Ziffern die Anteile 
        %sind, string|va
        ElementalFormula = 'none';
        %Materialdichte, g/cm^3, double|va
        MaterialDensity = 0;
        %Molekular-Masse, u, double|va
        MolecularWeight = [];
        %Kristallgitter, LatticeParameter|va
        LatticeParameter = [];
        %Kristallgitter, HKLdspacing|va
        HKLdspacing = [];
        %Kristallgitter, EnergyMax|va
        EnergyMax = [];
        %Kristallgitter, CrystalLattice|va
        CrystalLattice = [];
        %Kristallgitter, CrystalStructure|va
        CrystalStructure = [];
        %Elementeliste, ChemicalElement|va
        ChemicalElements = [];
    end
    
    %--> Modifizierbare, versteckte Eigenschaften
    properties (Hidden = true, SetAccess = public, GetAccess = public)
        %PDF-Nummer, falls der Werkstoff in der PDF-Datenbank zu finden
        %ist, double|va
        PDFNumber = NaN;
    end
    
    %--> Setter und Getter
    methods
        function set.ElementalFormula(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.ElementalFormula = in;
        end
        function set.MaterialDensity(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','scalar','finite'});
            obj.MaterialDensity = in;
        end
        function set.MolecularWeight(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','finite'});
            obj.MolecularWeight = in;
        end
        function set.LatticeParameter(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','finite'});
            obj.LatticeParameter = in;
        end
        function set.HKLdspacing(obj,in)
            validateattributes(in,{'double'},...
                {'real','finite'});
            obj.HKLdspacing = in;
        end
        function set.EnergyMax(obj,in)
            validateattributes(in,{'double'},...
                {'positive','real','finite'});
            obj.EnergyMax = in;
        end
        function set.CrystalLattice(obj,in)
            validateattributes(in,{'Sample.CrystalLattice'},{'scalar'});
            obj.CrystalLattice = in;
        end
        function set.CrystalStructure(obj,in)
            validateattributes(in,{'char'},{'row'});
            obj.CrystalStructure = in;
        end
        function set.ChemicalElements(obj,in)
            validateattributes(in,{'Sample.ChemicalElement'},{'vector'});
            
%         %% (* Dynamische Eigenschaften *)
%             %--> Hinzufügen des Stöchiometrieanteils 
%             %    (Stoichiometry, no unit, double|va)
%             for i_c = 1:length(in)
%                 %--> Nur wenn die Eigenschaft noch nicht existiert
%                 if isempty(findprop(in(i_c),'Stoichiometry'))
%                     p = addprop(in(i_c),'Stoichiometry');
%                     p.GetAccess = 'public';
%                     p.SetAccess = 'public';
%                     %Externe Set-Methode
%                     p.SetMethod = @set_Stoichiometry;
%                     %Standardwert = 1
%                     in(i_c).Stoichiometry = 1;
%                 end
%             end %--> for i_c = 1:...
            %Zuweisen
            obj.ChemicalElements = in;
        end
        function set.PDFNumber(obj,in)
            validateattributes(in,{'double'},...
                {'positive','integer','scalar'});
            obj.PDFNumber = in;
        end
    end
    
%% (* Methoden *)
    %--> Öffentliche Methoden
    methods (Access = public)
        
    %% (* Wissenschaftliche Funktionen *)
%         %Berechnet den linearen Absorptionskoeffizienten für das Material
%         mu = LAC(obj,Energy)
%         %Dielektrische Suszeptibilität
%         delta = DielectricSusceptibility(obj,Energy)
%         %Totalreflexionswinkel
%         alpha_crit = TotalReflectionAngle(obj,Energy)
%         %Brechungswinkelverschiebung
%         epsilon = RefractionShift(obj,Energy,IncidentAngle)
%         %Eindringtiefe des Strahls
%         tau = PenetrationDepth(obj,DiffractionAngle,varargin)
%         %Lagen der Interferenzen (Reflexe) auf der Energieskala
%         E = EnergyPositions(obj,DiffractionAngle,Index_Reflexes)
        
    %% (* Objektverwaltung *)
        %Interpreter für das Herausfinden der Elemente aus der Summenformel
        GetElementsFromFormula(obj)
    end
    
%% (* Import und Export *)
    %--> Eigenschaften für die ISaveLoad-Klasse
    properties (Transient = true, Hidden = true, Constant = true,...
                GetAccess = public)
         %Dateiendung im Format '.ext', string
         FileExtension = '.mtr';
         %Verzeichnis, string
         FilePath = fullfile(General.ProgramInfo.Path,...
                             General.ProgramInfo.Path_Data,...
                             'Substrates');
    end
    
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        %Importieren eines Materials aus der PDF-Datenbank
        obj = LoadFromPDF(Filename)
        %Einlesen der Materialparameter (*.mpd) Datei
        obj = LoadFromMpdFile(Filename)
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
        function obj = Substrate(varargin)
            %Aufrufen des Basisklassenkonstruktors
            obj = obj@General.MLRObject(varargin{:});
        end
    end
end
%--------------------------------------------------------------------------
% Externe Set-Funktion für die Eigenschaft Stoichiometry der Elementliste
function set_Stoichiometry(obj,in)
    validateattributes(in,{'double'},...
        {'scalar','positive','real','finite'});
    obj.Stoichiometry = in;
end