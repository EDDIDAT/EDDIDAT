% Bragg Gleichung für Energiedispersive Messungen, d. h. die Energie 
% (und nicht die Wellenlänge) ist eine abhängige Größe. Vorgegeben
% werden jeweils 3 der folgenden Größen:
% (BraggAngle, Winkel,° / Energy, Energie, keV / LatticeSpacing, 
% Netzebenenabstand, nm / DiffractionOrder, Beugungsordnung, no unit)
% Die fehlende Größe ist dann rtn. Die Reihenfolge der Eingabeargumente ist
% unten zu sehen, das Outputargument wird einfach [] gesetzt.
% Input: Beschreibung siehe oben, Outputargument ist [], double|va
% Output: rtn, berechnetes fehlendes Argument, double
function rtn = BraggEq_E(DiffractionOrder,BraggAngle,Energy,LatticeSpacing)

%% (* Stringenzprüfung *)
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
    
%% (* Übergabe der relevanten Eigenschaften *)
    n = DiffractionOrder;
    theta = BraggAngle;
    %Intern wird mit der Wellenlänge (in nm) gerechnet (klassisch)
    lambda = Tools.Science.Physics.EWR(Energy); 
    d = LatticeSpacing;

%% (* Compute *)
    %Kontrolle, welche Größe NICHT gegeben ist
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