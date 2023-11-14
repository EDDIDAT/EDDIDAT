% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften 
% f�r das Koordinatensystem.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultAxesStyle(Axis)
    
%% (* Setzen der Eigenschaften *)
    %Feinachsenelemente
    set(Axis,'XMinorTick','on','YMinorTick','on','ZMinorTick','on');
end