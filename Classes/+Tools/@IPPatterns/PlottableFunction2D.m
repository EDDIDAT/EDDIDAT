% Gibt einen IP wieder, der Anwendung bei eindimensionalen Funktionen, die 
% geplotten werden sollen, findet.
% Input: none
% Output: ip, InputParser, inputParser
function ip = PlottableFunction2D()

%% (* Definition und Allgemeines *)
    ip = inputParser;
    %Strukturen als Eingabeoption zulassen
    ip.StructExpand = true;

%% (* Bereiche und Genauigkeit *)
    %Definitionsbereich
    ip.addParamValue('RangeX',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'size',[1 2],'finite','real'}));
    %Wertebereich
    ip.addParamValue('RangeY',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'size',[1 2],'finite','real'}));
    %Anzahl der Stützstellen (wird nur bei nicht-kontinuierlichen
    %Nährungsplots verwendet)
    ip.addParamValue('Resolution',1000,...
        @(x)validateattributes(x,{'double'},...
        {'integer','scalar','positive','finite'}));

%% (* Darstellung *)
    %Skalierungen der Achen (true = logarithmisch, false = linear)
    ip.addParamValue('XLog',false,...
        @(x)validateattributes(x,{'logical'},{'scalar'}))
    ip.addParamValue('YLog',false,...
        @(x)validateattributes(x,{'logical'},{'scalar'}))
    %Neue Figure (= 0) oder eine Vorgegebene (= positive int)?
    ip.addParamValue('Figure',0,...
        @(x)validateattributes(x,{'double'},...
        {'integer','scalar','nonnegative'}));
    %In neue Achsen zeichnen ('off') oder nicht ('on')?, string
    ip.addParamValue('Hold','off',...
        @(x)any(strcmp(x,{'on','off'})));
    %Ermöglich die Eingabe einer Funktion, die individuelle
    %Grafikoptionen ausführt, cell|function_handle
    ip.addParamValue('PlotOptions',...
        {@Tools.Plotting.DefaultPlotOptions2D},...
        @(x)validateattributes(x,{'cell'},{}));
end