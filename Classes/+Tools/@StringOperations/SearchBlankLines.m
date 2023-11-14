% Diese Funktion sucht aus einem Text alle Leerzeilen und gibt ihre 
% Zeilennummer wieder.
% Input: Text, 2dim. CharArray, char|va
% Output: Index, Indizies der Leerzeilen, double|integer|column
function Index = SearchBlankLines(Text)

%% (* Stringenzprüfung *)
    validateattributes(Text,{'char'},{'2d'});

%% (* Suchen *)
    %Das zeilensweise Produkt aus dem Vergleich mit den Leerzeichen
    %muss 1 sein, wenn es eine Leerzeile ist
    Index = find(prod(double(Text == ' '),2));
end