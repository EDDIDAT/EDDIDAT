% Diese Funktion wandelt einen Text in einen einzeiligen String um.
% Input: Text, 2dim. Char-Array, char|va
% Output: rtn, einzeiliger String, string|va
function rtn = Text2String(Text)

%% (* Stringenzprüfung *)
    validateattributes(Text,{'char'},{'2d'});

%% (* Umwandeln in einen Zeilenvektor *)
    %Transponieren des Textes, damit die erste Dimension auch die
    %Zeile ist und nicht die Spalte
    Text = Text';
    %Umwandeln in einen Zeilenvektor und Zurücktransponieren
    rtn = Text(:)';
end