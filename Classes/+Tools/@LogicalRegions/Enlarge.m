% Diese Funktion verbreitert die Regionen um einen relativen Faktor.
% Input: Factor, Verbreiterungfaktor (1 = 100%), double|va
% Output: obj, der korrigierte Objekt, LogicalRegions
function obj = Enlarge(obj,Factor)

%% (* Korrektur *)
    %Breiten der Regionen ermitteln
    RegionWidths = obj.Limits(2,:) - obj.Limits(1,:) + 1;
    %Aus dem relativen Korrekturfaktor einen Absoluten entwickeln
    RegionWidths = RegionWidths * Factor / 2;
    %Korrektur vornehmen
    Limits_out(1,:) = round(obj.Limits(1,:) - RegionWidths);
    Limits_out(2,:) = round(obj.Limits(2,:) + RegionWidths);
    %Falls die neuen Regionen über den negativen Rand gehen
    Limits_out(Limits_out <= 0) = 1;
    %Übergabe von Limits_out
    obj.Limits = Limits_out;
end