% Diese Funktion bietet ein Äquivalent zu sscanf für Strings, d. h. es 
%werden alle alleinstehende Wörter gefiltert und in einem Cell-Array 
% wiedergegeben.
% Input: String, zu filternder String, string|va
% Output: rtn, Cell-String-Array mit den gefilterten Strings,
%          cell|string|row
function rtn = ScanWords(String)

%% (* Stringenzprüfung *)
    validateattributes(String,{'char'},{'row'});

%% (* Einzelne Strings herausfiltern *)
    %Blanks entfernen
    String = strtrim(String);
    %Wortlücken finden (Leerzeichen, Nicht-Leerzeichen)
    Index = regexp(String,'\s\S') + 1;
    %Splitten des Strings und gleichzeitiges Entfernen der Blanks
    rtn = cellfun(@strtrim,...
        Tools.StringOperations.SplitString(String,Index),...
        'UniformOutput',false);
end