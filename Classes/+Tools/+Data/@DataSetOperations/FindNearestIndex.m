% Unter Vorgabe eines (oder mehrerer) Datenwerte findet diese Funktion den
% nächstgelegensten Datenwert bzw. dessen Index.
% Input: X, Datenvektor, Unit, double|va /
%        x, zu approximierende(r) Datenwert(e), Unit, double|va
% Output: Index, Indizies der appr. Datenwerte, double|[size(x)] /
%         Value, Datenwerte zu den Indizies, Unit, double|[size(x)]
function [Index,Value] = FindNearestIndex(X,x)

%% (* Stringenzprüfung *)
    validateattributes(X,{'double'},{'vector','real'});
    validateattributes(x,{'double'},{'vector','real'});
%% (* Ermitteln der Indizies *)
    %Interpolation des Datensatzes gegen seine Indizies, dann runden
    Index = round(interp1(X,1:length(X),x));
    %Werte zuordnen (Wenn OutOfRange: NaN)
    Value = nan(size(Index));
    Value(Index >= 1 & Index <= length(X)) =...
        X(Index(Index >= 1 & Index <= length(X)));
end