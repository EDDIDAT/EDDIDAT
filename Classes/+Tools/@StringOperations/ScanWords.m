% Diese Funktion bietet ein �quivalent zu sscanf f�r Strings, d. h. es 
%werden alle alleinstehende W�rter gefiltert und in einem Cell-Array 
% wiedergegeben.
% Input: String, zu filternder String, string|va
% Output: rtn, Cell-String-Array mit den gefilterten Strings,
%          cell|string|row
function rtn = ScanWords(String)

%% (* Stringenzpr�fung *)
    validateattributes(String,{'char'},{'row'});

%% (* Einzelne Strings herausfiltern *)
    %Blanks entfernen
    String = strtrim(String);
    %Wortl�cken finden (Leerzeichen, Nicht-Leerzeichen)
    Index = regexp(String,'\s\S') + 1;
    %Splitten des Strings und gleichzeitiges Entfernen der Blanks
    rtn = cellfun(@strtrim,...
        Tools.StringOperations.SplitString(String,Index),...
        'UniformOutput',false);
end