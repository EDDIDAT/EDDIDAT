% Diese Funktion sucht aus einem Text einen vorgegebenen String. Dabei wird
% �ber die Zeilengrenzen hinweg gesucht.
% Input: Text, 2dim. CharArray, char|va /
%        SearchString, Such-String, string|va
% Output: rtn, 2dim. IndexArray mit allen �bereinstimmungen (1. Sp. = 
%          Zeilennummer, 2. Sp. = Spaltennummer), double|integer|[NaN 2]
function Index = SearchString(Text,SearchString)

%% (* Stringenzpr�fung *)
    validateattributes(Text,{'char'},{'2d'});
    validateattributes(SearchString,{'char'},{'row'});

%% (* Suchen *)
    %Suchen von SearchString, dabei Umformung zu einem Vektor
    Index_tmp = regexp(Tools.StringOperations.Text2String(Text),...
        SearchString);
    %--> �berpr�fung, ob �berpaupt etwas gefunden wurde
    if ~isempty(Index_tmp)
        %Korrekte 2dim. Indizies (Zeile,Spalte) ermitteln
        [Index(:,2),Index(:,1)] = ind2sub(fliplr(size(Text)),Index_tmp);
    else
        Index = [];
    end
end