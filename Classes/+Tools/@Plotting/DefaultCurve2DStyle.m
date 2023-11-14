% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften 
% für 2D-Graphen.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultCurve2DStyle(Axis)

%% (* Handles der Objekte ermitteln *)
    %Graphen der Achsen
    Curve = get(Axis,'Children');
    
%% (* Setzen der Eigenschaften *)
    %Linienstärke
    set(Curve,'LineWidth',2);
    %Graphenfarbenreihenfolge
    set(Axis,'ColorOrder',[0 0 0; 1 0 0; 0 1 0; 0 0 1; ...
                           1 1 0; 1 0 1; 0 1 1; 1 1 0.5;
                           1 0.5 1; 0.5 1 1]);
end