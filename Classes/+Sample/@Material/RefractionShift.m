% Diese zweidimensionale Funktion berechnet die Brechungswinkelverschiebung 
% epsilon (°) in Abhängigkeit von E bzw. delta und einem (konstanten)
% Winkel alpha (Winkel zwischen dem bettrachteten Teilstrahl und der
% Oberfläche).
% Input: Energy, Energie, keV, double|va /
%        IncidentAngle, alpha, °, double|va
% Output: epsilon, Brechungswinkelverschiebung, °, double|[size(Energy)]
function epsilon = RefractionShift(obj,Energy,IncidentAngle)

%% (* Stringenzprüfung *)
    %--> Möglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        epsilon = {@Labels,@StandardRangeX,@StandardRangeY};
        return;
    end
    validateattributes(Energy,{'double'},{'positive','real','finite'});
    validateattributes(IncidentAngle,{'double'},{'real','>=',0,'<=',180});
    
%% (* Übergabe der relevanten Eigenschaften *)
    E = Energy;
    alpha = IncidentAngle;
    
%% (* Vorbereitung *)
    delta = obj.DielectricSusceptibility(E);
    %Zur besseren Lesbarkeit
    deg = Tools.Science.Math.Degree;
    rad = Tools.Science.Math.Radian;
    %Größen der Eingabevektoren anpassen
    [alpha,delta] = Tools.ArrayOperations.MatchSize({alpha,delta});
%     %Alte Variante (ca. 10x schneller)
%     if isscalar(alpha), alpha = alpha(ones(size(delta))); end
%     if isscalar(delta), delta = delta(ones(size(alpha))); end
    
%% (* Compute *)
    %Ergebnismatrix dimensionieren
    epsilon = zeros(size(alpha));
    %Bedingungsvektoren, abhängig von alpha und delta
    Cond_1 = find(alpha * deg < sqrt(2*delta));
    Cond_2 = find(sqrt(2*delta) <= alpha * deg & alpha < 3);
    Cond_3 = find(3 <= alpha & alpha <= 90);
    %Berechnung der Werte für die jeweiligen Fälle
    epsilon(Cond_1) = alpha(Cond_1) * 2;       
    epsilon(Cond_2) = alpha(Cond_2) - sqrt((alpha(Cond_2) * deg).^2 ...
        - 2 * delta(Cond_2)) * rad;
    epsilon(Cond_3) = delta(Cond_3) .* cotd(alpha(Cond_3)) * rad;
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode für den Plot
function rtn = StandardRangeX(obj)
    %############### ToDo: sinnvoller Bereich
    rtn = [30 150];
end
%--------------------------------------------------------------------------
% StandardRangeY-Methode für den Plot
function rtn = StandardRangeY(obj)
    %############### ToDo: sinnvoller Bereich
    rtn = [0 0.14];
end
%--------------------------------------------------------------------------
% Labels-Methode für den 3D-Plot
function Labels(obj,ip)
    %Beschriftung
    title(['\epsilon(E,\alpha) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('\alpha [°]');
    zlabel('Refraction Shift [°]');
end