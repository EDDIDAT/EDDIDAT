% Diese Funktion berechnet die Zeitdifferenzen zwischen den Messungen.
% Input: Index_Measurement, falls man nicht alle Messungen benötigt, kann
%         man die Indizies vorgeben, double|opt|va
% Output: none
function rtn = DeltaTime(obj,Index_Measurement)

%% (* Stringenzprüfung *)
    if nargin == 2
        validateattributes(Index_Measurement,{'double'},...
            {'integer','vector','nonnegative'});
    else
        %Wenn keine Vorgabe, dann über alle Messungen
        Index_Measurement = 1:size(obj.DiffractionLines,1);
    end
    %--> Falls nur eine Messung vorhanden ist
    if size(obj.DiffractionLines,1) == 1, rtn = zeros(size(obj.DiffractionLines,2),1); return; end
    
%% (* Zeit-Differenzen berechnen *)
    %Dimension anpassen (Eine Zeit pro Zeile)
    Time_tmp = reshape([obj.DiffractionLines(:,1).Time],6,[])';
    %Prealloc des DeltaTime Vektors
    rtn = zeros(length(Time_tmp),1);
    %--> Zeitdifferenzen bilden und eintragen
    for i_c = 2:size(Time_tmp,1)
        rtn (i_c) = etime(Time_tmp(i_c,:),Time_tmp(i_c-1,:));
    end
    %Kumulative Summe und Ausgabe
    rtn = cumsum(rtn);
    rtn = rtn(Index_Measurement);
end