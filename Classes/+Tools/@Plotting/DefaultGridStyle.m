% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften 
% für das Gitter.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultGridStyle(Axis)

%% (* Setzen der Eigenschaften *)
    %Gitter anschalten
    grid(Axis,'on');
    set(Axis,'XGrid','on','YGrid','on','ZGrid','on');
    %Linienstil
    set(Axis,'GridLineStyle','-');
end