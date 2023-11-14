% Diese Funktion plottet die zweidimensionale Funktion Fun. Um 
% funktionsspezifische Eigenschaften, wie die Beschriftung zu erhalten,
% muss die Funktion selbst eine Möglichkeit (Fun()) implementieren, um
% ein Cellarray mit ihren Unterfunktionen wiederzugeben.
% Input: obj, Aufrufendes Objekt, class /
%        Fun, Zu plottende Funktion von obj, function_handle|va /
%        varargin, Plot-Optionen, ip
% Output: Curve, Graphen-Handle, double
function Curve = PlotCurve3D(obj,Fun,varargin)

%% (* Stringenzprüfung *)
    %InputParser für 3D-Funktionen
    ip = Tools.IPPatterns.PlottableFunction3D();
    %Zu plottende Funktion hinzufügen
    ip.addRequired('Function',...
        @(x)validateattributes(x,{'function_handle'},{'scalar'}));
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
    %Suchen nach der 1. DB-funktion
    StandardRangeX = find(~cellfun(@isempty,strfind(...
        Subfun_Names,'StandardRangeX')),1);
    if ~isempty(StandardRangeX)
        StandardRangeX = Subfun{StandardRangeX};
    else
        %Standard-Funktion
        StandardRangeX = @(x)[0 1];
    end
    %Suchen nach der 2. DB-funktion
    StandardRangeY = find(~cellfun(@isempty,strfind(...
        Subfun_Names,'StandardRangeY')),1);
    if ~isempty(StandardRangeY)
        StandardRangeY = Subfun{StandardRangeY};
    else
        %Standard-Funktion
        StandardRangeY = @(x)[0 1];
    end
    
%% (* Plot *)
    %Definitonsbereich
    RangeX = sort(ip.Results.RangeX);
    RangeY = sort(ip.Results.RangeY);
    %--> Wenn nicht vorhanden, StandardRangeX aufrufen
    if isnan(RangeX), RangeX = StandardRangeX(obj); end
    %--> Wenn nicht vorhanden, StandardRangeY aufrufen
    if isnan(RangeY), RangeY = StandardRangeY(obj); end
    %Meshgrid berechnen, die Auflösung ist absolut
    RangeX = linspace(RangeX(1),RangeX(2),ip.Results.Resolution);
    RangeY = linspace(RangeY(1),RangeY(2),ip.Results.Resolution);
    [RangeX,RangeY] = meshgrid(RangeX,RangeY);
    %Plot und Graphenhandle (Curve) als Ergebnis
    Curve = surf(RangeX,RangeY,Fun(RangeX,RangeY));
    
%% (* Nachbearbeitungen *)
    %Achsenhandle (Axes) der Kurve
    Axis = get(Curve,'Parent');
    %--> Setzen der y-Grenzen, wenn gegeben
    if ~isnan(ip.Results.RangeZ)
        set(Axis,'ZLim',sort(ip.Results.RangeZ));
    end
    %Skalierung der Achsen
    Tools.Plotting.SetAxesScale(Axis,'XLog',ip.Results.XLog,...
        'YLog',ip.Results.YLog,'ZLog',ip.Results.ZLog);
    %Beschriftung
    Labels(obj,ip);
    %--> Aufrufen der Plotoptionen
    for i_c = 1:numel(ip.Results.PlotOptions)
        ip.Results.PlotOptions{i_c}(Axis);
    end
end