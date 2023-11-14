% Diese Funktion berechnet den Totalreflexionswinkel alpha_crit (�) in 
% Abh�ngigkeit von der Energie, wobei dazu die dielektrische
% Suszeptibilit�t benutzt wird.
% Input: Energy, Energie, keV, double|va
% Output: alpha_crit, Totalreflexionswinkel, �, double|[size(Energy)]
function alpha_crit = TotalReflectionAngle(obj,Energy)

%% (* Stringenzpr�fung *)
    %--> M�glichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        alpha_crit = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'positive','real','finite'});
        
%% (* �bergabe der relevanten Eigenschaften *)
    E = Energy;
    
%% (* Compute *)
    alpha_crit = sqrt(2 * obj.DielectricSusceptibility(E))...
        .* Tools.Science.Math.Radian;
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
    title(['\alpha_{krit}(E) = {(2\delta)}^{1/2}(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Total Reflection Angle [�]');
end