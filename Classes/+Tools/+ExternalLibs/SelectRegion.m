% Diese Vereinfachung von selectdata ermöglicht eine Region in einem Axes
% zu selektieren. Ausgabe sind die Grenzen des benutzten Rechtecks.
function [X,Y] = SelectRegion(Axes,Figure)
    
    %Normaler Mauszeiger
    h = pan(Figure);
    set(h,'Enable','on');
    set(h,'Enable','off');

    %Warte auf einen Klick
    waitforbuttonpress;
    
    %Akutelle Mausposition bzgl. der Axes
    CP_tmp = get(Axes,'CurrentPoint');
    P1 = CP_tmp(1,1:2);
    P2 = P1 + eps(P1);
    
    %Rechteckgröße ermitteln und zeichnen
    X_Rect = [P1(1), P2(1), P2(1), P1(1), P1(1)];
    Y_Rect = [P1(2), P1(2), P2(2), P2(2), P1(2)];
    Rect = plot(X_Rect,Y_Rect,'r:');
    
    %Callbacks für Mousemove und Mouseup der FIGURE (nicht Axes)
    set(Figure,'WindowButtonMotionFcn',@RectMotion);
    set(Figure,'WindowButtonUpFcn',@selectdone);
    
    uiwait;
        
    function RectMotion(hObject,eventdata)
        %Rechteck entsprechend der Mausposition ausrichten
        CP_tmp = get(Axes,'CurrentPoint');
        P2 = CP_tmp(1,1:2);
        X_Rect = [P1(1), P2(1), P2(1), P1(1), P1(1)];
        Y_Rect = [P1(2), P1(2), P2(2), P2(2), P1(2)];
        set(Rect,'xdata',X_Rect,'ydata',Y_Rect);
    end

    function selectdone(hObject,eventdata)
        %Callbacks zurücksetzen
        set(Figure,'WindowButtonMotionFcn',[]);
        set(Figure,'WindowButtonUpFcn',[]);
        uiresume;
        %Rechteck entfernen
        delete(Rect);
    end
    %Ausgabe
    X = [P1(1), P2(1)];
    Y = [P1(2), P2(2)];

end

