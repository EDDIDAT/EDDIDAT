% Diese Funktion plottet die Funktion Fun des Objektes obj. Um 
% funktionsspezifische Eigenschaften, wie die Beschriftung zu erhalten,
% muss die Funktion selbst eine Möglichkeit (Fun()) implementieren, um
% ein Cellarray mit ihren Unterfunktionen wiederzugeben.
% Input: obj, Aufrufendes Objekt, class /
%        Fun, Zu plottende Funktion von obj, function_handle|va /
%        varargin, Plot-Optionen, ip
% Output: Curve, Graphen-Handle, double
function Curve = PlotCurve2D(obj,Fun,varargin)

%% (* Stringenzprüfung *)
    %InputParser für 2D-Funktionen
    ip = Tools.IPPatterns.PlottableFunction2D();
    %Zu plottende Funktion hinzufügen
    ip.addRequired('Function',...
        @(x)validateattributes(x,{'function_handle'},{'scalar'}));
    %Plot-Modus hinzufügen: kontinuierlich oder interpoliert?, string
    ip.addParamValue('PlotMode','interpolated',...
        @(x)any(strcmp(x,{'continuous','interpolated'})));
    %Parse
    ip.parse(Fun,varargin{:});
    
%% (* Vorbereitung *)
    %--> Auswertung von Figure
    if ip.Results.Figure, figure(ip.Results.Figure);
    else figure(); end
    %Auswertung von Hold
    hold(ip.Results.Hold);
% + Ermitteln der spezifizierenden Funktion von Fun
    %Falls try "schief geht"
    Subfun_Names = {};
    %--> Versuch die Subfunctions zu bekommen
    try
        %Grafik-Unterfunktionen der Hauptfunktion
        Subfun = Fun();
        Subfun_Names = cellfun(@func2str,Subfun,'UniformOutput',false);
    catch Exception
        warning(Exception.identifier,['The function you want is plot',...
            'has no descriptive methods!']);
    end
    %Suchen nach einer Labelsfunktion
    Labels = find(~cellfun(@isempty,strfind(Subfun_Names,'Labels')),1);
    if ~isempty(Labels)
        Labels = Subfun{Labels};
    else
        %Standard-Funktion
        Labels = @(x,y)[];
    end
    %Suchen nach einer DB-funktion
    StandardRangeX = find(~cellfun(@isempty,strfind(...
        Subfun_Names,'StandardRangeX')),1);
    if ~isempty(StandardRangeX)
        StandardRangeX = Subfun{StandardRangeX};
    else
        %Standard-Funktion
        StandardRangeX = @(x)[0 1];
    end
    
%% (* Plot *)
    %Definitonsbereich
    RangeX = sort(ip.Results.RangeX);
    %--> Wenn nicht vorhanden, StandardRangeX aufrufen
    if isnan(RangeX), RangeX = StandardRangeX(obj); end
    %--> Plot und Graphenhandle (Curve) als Ergebnis, Plot-Modus abfragen
    if strcmp(ip.Results.PlotMode,'continuous')
        Curve = Plot_con(obj,Fun,RangeX,ip.Results.Resolution);
    elseif strcmp(ip.Results.PlotMode,'interpolated')
        Curve = Plot_interp(obj,Fun,RangeX,ip.Results.Resolution);
    end
    
%% (* Nachbearbeitungen *)
    %Achsenhandle (Axis) der Kurve, wenn mehrere nur das Erste
    Axis = get(Curve(1),'Parent');
    %--> Setzen der y-Grenzen, wenn gegeben
    if ~isnan(ip.Results.RangeY)
        set(Axis,'YLim',sort(ip.Results.RangeY));
    end
    %Skalierung der Achsen
    Tools.Plotting.SetAxesScale(Axis,'XLog',ip.Results.XLog,...
        'YLog',ip.Results.YLog);
    %Beschriftung
    Labels(obj,ip);
    %--> Aufrufen der Plotoptionen
    for i_c = 1:numel(ip.Results.PlotOptions)
        ip.Results.PlotOptions{i_c}(Axis);
    end
end
%--------------------------------------------------------------------------
% Kontinuierlicher Plot.
% Input: obj, Aufrufendes Objekt, class /
%        Fun, Zu plottende Funktion von obj, function_handle|va /
%        RangeX, Def.-Bereich, double|va /
%        Resolution, Auflösung des Plots, double|va
% Output: Curve, Graphen-Handle, double
function Curve = Plot_con(obj,Fun,RangeX,Resolution)
    %ezplot
    Curve = ezplot(Fun,RangeX);
end
%--------------------------------------------------------------------------
% Interpolierter Plot.
% Input: obj, Aufrufendes Objekt, class /
%        Fun, Zu plottende Funktion von obj, function_handle|va /
%        RangeX, Def.-Bereich, double|va /
%        Resolution, Auflösung des Plots, double|va
% Output: Curve, Graphen-Handle, double
function Curve = Plot_interp(obj,Fun,RangeX,Resolution)
    %Definitionsbereich für "plot" berechnen, die Auflösung ist absolut
    RangeX = linspace(RangeX(1),RangeX(2),Resolution);
    %plot
    Curve = plot(RangeX,Fun(RangeX));
end