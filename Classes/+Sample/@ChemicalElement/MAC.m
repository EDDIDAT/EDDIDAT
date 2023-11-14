% Hierbei handelt es sich um eine Funktion, die den MSK in Abhängigkeit
% von der Energie berechnet. Die Werte werden mit Hilfe einer Interpolation
% der Daten aus der Eigenschaft MAC_Data berechnet.
% Input: Energy, Energie, keV, double|va
% Output: mu, MSK, cm^2/g, double|[size(Energy)]
function mu = MAC(obj,Energy)

%% (* Stringenzprüfung *)
    %--> Möglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        mu = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'real','finite'});
        
%% (* Übergabe der relevanten Eigenschaften *)
    E = Energy;
    
%% (* Compute *)
    %Interpolation der Daten
    mu = interp1(obj.MAC_Data(:,1),obj.MAC_Data(:,2),E,...
        'linear','extrap');
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode für den Plot
function rtn = StandardRangeX(obj)
    %Experimentell abgesicherter Bereich
    rtn = [min(obj.MAC_Data(:,1)) max(obj.MAC_Data(:,1))]; 
end
%--------------------------------------------------------------------------
% Labels-Methode für den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['\mu\cdot\rho^{-1}(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Mass attenuation coefficient [cm^2 \cdot g^{-1}]');
end