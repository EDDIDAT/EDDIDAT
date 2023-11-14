% Diese Funktion setzt bestimmte immer wiederkehrende Standardeigenschaften 
% f�r 3D-Plots. Mit dem �bergebenen Achsenhandle ruft sie die
% entsprechenden kategorisierten Standardmethoden auf.
% Input: Axis, Achsenhandle, double
% Output: none
function DefaultPlotOptions3D(Axis)

%% (* Funktionsaufrufe *)
    %Beschriftung
    Tools.Plotting.DefaultLabelStyle(Axis);
    %Achsen
    Tools.Plotting.DefaultAxesStyle(Axis);
    %Graphen
    Tools.Plotting.DefaultCurve3DStyle(Axis);
end