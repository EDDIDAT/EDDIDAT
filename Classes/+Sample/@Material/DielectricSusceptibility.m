% Diese Funktion berechnet den f�r die Brechnungskorrektur ben�tigte
% dielektrische Suszeptibilit�t delta in Abh�ngigkeit von der Energie.
% Input: Energy, Energie, keV, double|va
% Output: delta, dielektrische Suszeptibilit�t, no unit, 
%          double|[size(Energy)]
function delta = DielectricSusceptibility(obj,Energy)

%% (* Stringenzpr�fung *)
    %--> M�glichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        delta = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'positive','real','finite'});
        
%% (* �bergabe der relevanten Eigenschaften *)
    E = Energy;
    
%% (* Vorbereitung *)
    %St�chiometrieanteile der Elemente
    n = [obj.ChemicalElements(:).Stoichiometry];
    %Ordnungszahlen der Elemente
    Z = [obj.ChemicalElements(:).AtomicNumber];
    %Atommassen der Elemente
    M = [obj.ChemicalElements(:).AtomicMass];
    %Konstanten-Faktor N_0*e^2/(2*pi*m_e*c^2),
    %mol^-1*(esu)^2*g^-1*cm^-2*s^2
    const = (Tools.Science.Physics.e.esu)^2 *...
             Tools.Science.Physics.N_0 / (2 * pi * ...
             Tools.Science.Physics.c.cmps^2 *...
             Tools.Science.Physics.m_e.g);

%% (* Compute *)
    %cgs-Faktor berechnen, nm
    cgsfactor = 1.0e-014 * const * obj.MaterialDensity...
        * (n * Z.') / (n * M.');
    %delta(E) berechnen
    delta = cgsfactor*(Tools.Science.Physics.EWR(E)).^2;
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode f�r den Plot
function rtn = StandardRangeX(obj)
    %############### ToDo: sinnvoller Bereich
    rtn = [30 150];
end
%--------------------------------------------------------------------------
% Labels-Methode f�r den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['\delta(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Dielectric Susceptibility [no unit]');
end