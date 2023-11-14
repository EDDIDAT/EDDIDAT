% Diese Funktion gibt einen Ausschnitt aus einer Matrix wieder, dabei wird
% eine Zeilenvektor für die Anfangs- und die Endindizies übergeben, wobei
% die jede Spalte die jeweilige Dimension darstellt.
% Input: M, beliebiges Array, variant /
%        Index_Min, Startindizies für das Ausschneiden, double|va /
%        Index_Max, Endindizies für das Ausschneiden, double|va
% Output: M_out, bearbeitete Matrix, variant|[Index_Min - Index_Max]
function M_out = CutMatrix(M,Index_Min,Index_Max)
   
%% (* Stringenzprüfung *)
    %Notwendige Übergabe zum Zugriff auf die Größe des Arrays
    Size_M = size(M);
    %--> Überprüfung, ob Index_min gegeben ist
    if isempty(Index_Min)
        %Wenn nicht bei 1 beginnen
        Index_Min = ones(size(Size_M));
    else
        validateattributes(Index_Min,{'double'},...
            {'positive','integer','finite','size',size(Size_M)});
    end
    %--> Überprüfung, ob Index_Max gegeben ist
    if isempty(Index_Max)
        %Wenn nicht größte Dimension wählen
        Index_Max = Size_M;
    else
        validateattributes(Index_Max,{'double'},...
            {'positive','integer','finite','size',size(Size_M)});
    end
    %Falls die Dimensionen zu groß sind
    Index_Max(Index_Max > Size_M) = Size_M(Index_Max > Size_M);
    Index_Min(Index_Min > Size_M) = Size_M(Index_Min > Size_M);
    
%% (* Subscript-Eval-String erstellen *)
    %Beginn des Ausdrucks und erstes Element
    EvalStr = ['M(',int2str(Index_Min(1)),':',int2str(Index_Max(1))];
    %--> Alle weiteren Elemente hinzufügen
    for i_c = 2:length(Index_Max)
        EvalStr = [EvalStr,',',int2str(Index_Min(i_c)),':',...
            int2str(Index_Max(i_c))];
    end
    %Schließen des Ausdrucks
    EvalStr = [EvalStr,');'];
    %Ausführen
    M_out = eval(EvalStr);
end