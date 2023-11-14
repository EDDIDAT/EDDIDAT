% Gibt einen IP wieder, der alle initialisierbaren Eigenschaften von 
% MetaClass, als ParamValue besitzt.
% Input: MetaClass, Meta-Klasse der aufrufendes Klasse, meta.class
% Output: ip, InputParser, inputParser
function ip = ObjectProperties(MetaClass)

%% (* Stringenzprüfung *)
    validateattributes(MetaClass,{'meta.class'},{'scalar'});
    
%% (* Definition und Allgemeines *)
    ip = inputParser;
    %Strukturen als Eingabeoption zulassen
    ip.StructExpand = true;
    %Für den Fall, dass Argumente von abgeleiteten Klassen kommen
    ip.KeepUnmatched = true;
    
%% (* Objekteigenschaften hinzufügen *)
    %--> Durchlaufen aller Eigenschaften
    for i_c = 1:length(MetaClass.Properties)
        %--> Alle Öffentlichen werden ...
        if strcmp(MetaClass.Properties{i_c}.SetAccess,'public') && ...
           strcmp(MetaClass.Properties{i_c}.GetAccess,'public')
            %...hinzugefügt
            ip.addParamValue(MetaClass.Properties{i_c}.Name,[]);
        end
    end
end