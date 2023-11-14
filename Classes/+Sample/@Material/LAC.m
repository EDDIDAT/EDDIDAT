% Diese Funktion berechnet den linearen Absorptionskoeffizienten mu (cm^-1) 
% des Materials fuer eine vorgegebene Energie (keV). Dabei werden vor
% allem die Massenschwaechungskoeffizienten der einzelnen Elemente benutzt.
% Input: Energy, Energie, keV, double|va
% Output: mu, Linearer Absorptionskoeffizient, cm^-1, double|[size(E)]
function mu = LAC(obj,Energy)

%% (* Stringenzpruefung *)
    %--> Moeglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        mu = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'real','finite'});
        
%% (* Uebergabe der relevanten Eigenschaften *)
    % Als Row
    E = Energy(:);
    
%% (* Vorbereitung *)
    %Gewichtete molekulare Massen
    M = [obj.ChemicalElements(:).AtomicMass] .* ...
        [obj.ChemicalElements(:).Stoichiometry];
    %MSK der Elemente
    mu_ele = cellfun(@(obj)MAC(obj,E),...
        num2cell(obj.ChemicalElements),'UniformOutput',false);
    %Fuer den Fall, dass man einen Zeilenvektor als Argument uebergibt
    mu_ele = reshape([mu_ele{:}],length(mu_ele{1}),[]);
  
%% (* Compute *)
    mu = obj.MaterialDensity * (mu_ele * (M/sum(M)).').';
    %Zurueck dimensionieren
    mu = reshape(mu,size(Energy));
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode fuer den Plot
function rtn = StandardRangeX(obj)
    %Kleinstes bzw. groesstes Element der MAC_Data fuer jedes Element
    %einlesen
    E_Min = cell2mat(cellfun(@min,{obj.ChemicalElements(:).MAC_Data},...
        'UniformOutput',false));
    E_Max = cell2mat(cellfun(@max,{obj.ChemicalElements(:).MAC_Data},...
        'UniformOutput',false));
    %Vergleichskriterium ist die Energie nicht der MSK
    rtn = [max(E_Min(1:2:end)) min(E_Max(1:2:end))];
end
%--------------------------------------------------------------------------
% Labels-Methode fuer den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['\mu(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Linear absorption coefficient [cm^{-1}]');
end