% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften 
% für 2D-Plots. Mit dem übergebenen Achsenhandle ruft sie die
% entsprechenden kategorisierten Standardmethoden auf.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultPlotOptions2D(Axis)

%% (* Funktionsaufrufe *)
    %Beschriftung
    Tools.Plotting.DefaultLabelStyle(Axis);
    %Gitter
    Tools.Plotting.DefaultGridStyle(Axis);
    %Achsen
    Tools.Plotting.DefaultAxesStyle(Axis);
    %Graphen
    Tools.Plotting.DefaultCurve2DStyle(Axis);
end