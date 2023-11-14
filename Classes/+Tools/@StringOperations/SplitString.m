% Diese Funktion teilt einen String an den vorgegebenen 
% Indexpositionen. Es werden automatische Korrekturen vorgenommen.
% Input: String, zu splittener String, string|va /
%        Index, Indextrennerpositionen, double|va
% Output: rtn, Cell-String-Array mit den getrennen Strings, cell|string|row
function rtn = SplitString(String,Index)

%% (* Stringenzprüfung *)
    validateattributes(String,{'char'},{'row'});
    validateattributes(Index,{'double'},...
        {'integer','positive','row','<=',length(String)});

%% (* Strings an den Indizies trennen *)
    %Sortierung, Filtern von doppelten Werten und Hinzufügen der
    %benötigten Indizies
    Index = unique([1, Index, length(String)]);
    %Letzter Index + 1
    Index(end) = Index(end)+1;
    %Prealloc des Ergebnisarrays
    rtn = cell(1,length(Index) - 1);
    %--> Auslesen und Zuweisen der Teilstrings
    for i_c = 1:length(Index)-1
        rtn{i_c} = String(Index(i_c):Index(i_c+1)-1);
    end
end