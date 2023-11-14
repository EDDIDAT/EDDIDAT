% Diese Funktion erstellt eine echte Kopie eines Objektes, d. h. es wird 
% ein leeres Objekt erstellt und alle öffentlichen, initialisierten 
% Eigenschaften von obj werden dem neuen Objekt obj_out zugewiesen.
% Input: obj, zu kopierendes Objekt, class>ICloneable /
%        CloneProperties, Sollen auch die Eigenschaften tief kopiert  
%         werden?, logical|opt|va 
% Output: obj_out, kopiertes Objekt, class>ICloneable
function obj_out = Clone(obj,CloneProperties)

%% (* Stringenzprüfung *)
    if nargin == 2
        validateattributes(CloneProperties,{'logical'},{'scalar'});
    else
        CloneProperties = false;
    end

%% (* Vorbereitung *)
    %Meta-Klasse auslesen
    MetaClass = metaclass(obj);
    %Instanzierung
    obj_out = obj.CloneConstruction(str2func(MetaClass.Name),size(obj));
    
%% (* Eigenschaften zuweisen *)
    %--> Durchlaufen aller Eigenschaften
    for i_c = 1:length(MetaClass.Properties)
        %--> Alle Öffentlichen
        if strcmp(MetaClass.Properties{i_c}.SetAccess,'public') && ...
           strcmp(MetaClass.Properties{i_c}.GetAccess,'public') && ...
           MetaClass.Properties{i_c}.Dependent == 0
            %Zur besseren Übersicht
            Name = MetaClass.Properties{i_c}.Name;
            %--> Durchlaufen aller Objekte
            for j_c = 1:numel(obj)
                try
                    %--> Tiefe Kopie der Eigenschaften?
                    if CloneProperties && ismethod(obj(j_c).(Name),'Clone')
                        obj_out(j_c).(Name) = obj(j_c).(Name).Clone(true);
                    %--> Sonst flache Kopie
                    else
                        obj_out(j_c).(Name) = obj(j_c).(Name);
                    end
                catch
                end
            end %--> for j_c = 1:numel(obj)
        end %--> if strcmp(MetaClass.Properties...
    end %--> for i_c = 1:length(MetaClass.Properties)
end