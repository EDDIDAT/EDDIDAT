% Diese Funktion speichert unter Eingabe eines Dateinamens (ohne Endung)
% das aufrufende Objekt in eine Datei.
% Input: Filename, Dateiname (ohne Endung), string|va 
% Output: none
function SaveToFile(obj,Filename)

%% (* Stringenzpr¸fung *)
    validateattributes(Filename,{'char'},{'row'});

%% (* Speichern *)
    %--> Pfad bilden
    if isempty(fileparts(Filename))
        Path = fullfile(obj.FilePath,[Filename obj.FileExtension]);
    else
        Path = [Filename obj.FileExtension];
    end
    %Anwendung des save-Befehls. Wichtig: Beim Laden muss die Variable 
    %ebenfalls obj heiﬂen, da das Objekt daran erkannt wird
    save(Path,'obj');
end