% Bragg Gleichung f�r Energiedispersive Messungen, d. h. die Energie 
% (und nicht die Wellenl�nge) ist eine abh�ngige Gr��e. Vorgegeben
% werden jeweils 3 der folgenden Gr��en:
% (BraggAngle, Winkel,� / Energy, Energie, keV / LatticeSpacing, 
% Netzebenenabstand, nm / DiffractionOrder, Beugungsordnung, no unit)
% Die fehlende Gr��e ist dann rtn. Die Reihenfolge der Eingabeargumente ist
% unten zu sehen, das Outputargument wird einfach [] gesetzt.
% Input: Beschreibung siehe oben, Outputargument ist [], double|va
% Output: rtn, berechnetes fehlendes Argument, double
function rtn = BraggEq_E(DiffractionOrder,BraggAngle,Energy,LatticeSpacing)

%% (* Stringenzpr�fung *)
    if ~isempty(DiffractionOrder)
        validateattributes(DiffractionOrder,{'double'},...
            {'positive','integer','finite'});
    end
    if ~isempty(BraggAngle)
        validateattributes(BraggAngle,{'double'},{'real','finite'})
    end
    if ~isempty(Energy)
        validateattributes(Energy,{'double'},{'positive','real','finite'});
    end
    if ~isempty(LatticeSpacing)
        validateattributes(LatticeSpacing,{'double'},...
            {'positive','real','finite'});
    end
    
%% (* �bergabe der relevanten Eigenschaften *)
    n = DiffractionOrder;
    theta = BraggAngle;
    %Intern wird mit der Wellenl�nge (in nm) gerechnet (klassisch)
    lambda = Tools.Science.Physics.EWR(Energy); 
    d = LatticeSpacing;

%% (* Compute *)
    %Kontrolle, welche Gr��e NICHT gegeben ist
    %--> E gesucht
    if isempty(lambda)
        rtn = Tools.Science.Physics.EWR(...
            2 .* d .* sind(theta) ./ n);
    %--> d gesucht
    elseif isempty(d)
        rtn = n .* lambda ./ (2 .* sind(theta));
    %--> theta gesucht
    elseif isempty(theta)
        rtn = asind(n .* lambda ./ (2 .* d));
    %--> n gesucht
    elseif isempty(n)
        rtn = 2 .* d .* sind(theta) ./ lambda;
    end
end