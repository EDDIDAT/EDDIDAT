%% (* PHYSIK-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt wichtige physikalische Funktionen und 
% Konstanten zur Verfügung.
%--------------------------------------------------------------------------
classdef Physics
    
%% (* Eigenscahften *)
    %--> Konstante Eigenschaften
    properties (Constant = true, GetAccess = public)
        
    %% (* Physikalische Naturkonstanten *)
    % Gibt es mehrere mögliche Einheiten, so sind die Konstanten Felder,
    % die ihren Einheiten entsprechen
        %Plancksches Wirkungsquantum, Unit, struct
        h = struct('eVs',4.1357e-015,...
                   'keVs',4.1357e-018,...
                   'Js',6.6261e-034);
        %Elementarladung, Unit, struct
        e = struct('esu',4.8032e-010,...
                   'As',1.6022e-019);
        %Masse eines Elektrons, Unit, struct
        m_e = struct('kg',9.109382e-031,...
                     'g',9.109382e-028);
        %Lichtgeschwindigkeit, Unit, struct
        c = struct('mps',299792458,...
                   'cmps',29979245800,...
                   'nmps',299792458 * 1e+09);
        %Avogadro-Konstante, mol^-1, double
        N_0 = 6.023 * 1e+023;
    end

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Quantenphysik *)
        %Energie-Wellenlängen-Beziehung
        rtn = EWR(in)
        %Bragg-Gleichung für Energiedispersion
        rtn = BraggEq_E(DiffractionOrder,BraggAngle,Energy,LatticeSpacing)
        
    %% (* Synchrotonring- und strahlung *)
        %Wigglerspektrum- bzw. funktion
        f = WigglerFunction(Energy,Mode)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = Physics(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Wigglerspektrum (Einheiten???)