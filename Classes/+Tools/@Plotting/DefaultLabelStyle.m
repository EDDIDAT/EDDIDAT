% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften
% für die Beschriftung.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultLabelStyle(Axis)

%% (* Handles der Objekte ermitteln *)
    %Titel
    Title = get(Axis,'Title');
    %Achsen
    XLabel = get(Axis,'XLabel');
    YLabel = get(Axis,'YLabel');
    ZLabel = get(Axis,'ZLabel');
    
%% (* Setzen der Eigenschaften *)
    %Schriftart und -stil
    set(Axis,'FontName','Arial');
    set(Title,'FontWeight','bold');
    %Schriftgrößen
    set(Axis,'FontSize',12);
    set(Title,'FontSize',14);
    set(XLabel,'FontSize',14);
    set(YLabel,'FontSize',14);
    set(ZLabel,'FontSize',14);
end