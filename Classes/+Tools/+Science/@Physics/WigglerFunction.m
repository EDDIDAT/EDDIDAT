% Diese Funktion dient zur Wigglerkorrektur eines EDSpektrums. Man erhält
% bei Eingabe einer Energie einen Korrekturfaktor durch den man den
% zugehörigen Wert im Spektrum teilen muss.
% Input: Energy, Energie, keV, double|va
% Output: f, Korrekturfaktor, no unit, double|[size(Energy)]
function f = WigglerFunction(Energy, Mode)
    
%% (* Stringenzprüfung *)
    %--> Möglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 0
        f = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'finite','real'});

%% (* Übergabe der relevanten Eigenschaften *)
    E = Energy;
    ModeCorr = Mode;
%% (* Compute *)
    %Pre-Alloc
    f = zeros(size(E));
    % Korrektur aus Mathematica
%     p1 = [5.56339671283320e-11;-1.83356703038030e-08;2.52952284691310e-06;-0.000188212991763570;0.00807383150138530;-0.195643012122700;2.35377897946780;-8.43695061253230;-28.3170153655710;233.882063481900];
    if ModeCorr == 1
    %Funktion
        f(E<=20) = 1;
        f(E>20) = (3422.94/632.112) * exp(-E(E>20) / 11.84);
    else
%         f(E<=60) = polyval(p1,E(E<=60))./407.914;
%         f(E>60) = 9.45658/407.914;
        f(E<1.14) = 1;
        ftmp = (-24641.8180869513 + 78391.3340463194.*E(E>=1.14) - 96795.3745448957.*E(E>=1.14).^2 + 65820.8463107603.*E(E>=1.14).^3 - 27586.6782673135.*E(E>=1.14).^4 + 7563.40169949789.*E(E>=1.14).^5 - 1401.98210077555.*E(E>=1.14).^6 + 178.870297070744.*E(E>=1.14).^7 - 15.8010749142335.*E(E>=1.14).^8 + 0.960586097458702.*E(E>=1.14).^9 - 0.0393139513010334.*E(E>=1.14).^10 + 0.00103254711238244.*E(E>=1.14).^11 - 0.0000157059544483296.*E(E>=1.14).^12 + 0.000000105350136521926.*E(E>=1.14).^13).*exp(-E(E>=1.14).*0.55114015453069);
        f(E>=1.14) = ftmp./929.8;
%         f = ftmp./872.3;
    end
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode für den Plot
function rtn = StandardRangeX(obj)
%##########: Sinnvoller Bereich
    rtn = [1 150];
end
%--------------------------------------------------------------------------
% Labels-Methode für den Plot
function Labels(obj,ip)
    %Beschriftung
    title('Wiggler Function(E)');
    xlabel('Energy [keV]');
    ylabel('Correction Factor [no unit]');
end