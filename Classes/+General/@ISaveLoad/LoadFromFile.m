% Diese Funktion lädt unter Eingabe einen Dateinamens ein Objekt vom Typ 
% Caller aus einer Datei.
% Input: Filename, Dateiname (ohne Endung), string|va /
%        Caller, Aufrufende Klasse, class>ISaveLoad
% Output: obj, Geladenes Objekt, class>ISaveLoad
function obj = LoadFromFile(Filename,Caller)
    
%% (* Stringenzprüfung *)
    validateattributes(Filename,{'char'},{'row'});

%% (* Laden *)
    %--> Pfad bilden
    if isempty(fileparts(Filename))
        Path = fullfile(Caller.FilePath, [Filename Caller.FileExtension]);
    else
        Path = [Filename Caller.FileExtension];
    end
    %Laden der Struktur aus dem File, das obj-Feld der geladenen
    %Struktur ist das gewollte Objekt
    obj = getfield(load(Path,'-mat'),'obj');
end