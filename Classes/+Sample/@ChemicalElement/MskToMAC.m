% Diese Funktion ist für den Übergang von Mathematica zu MatLab gedacht.
% Sie importiert unter Angabe eines Dateinamens (*.msk) die passende
% Eigenschaft (MAC) für das chemische Element.
% Input: Filename, Dateiname (ohne Endung), string|va
% Output: rtn, MAC_Data (siehe Eigenschaft), double|[NaN 2]
function rtn = MskToMAC(Filename)

%% (* Stringenzprüfung *)
    validateattributes(Filename,{'char'},{'row'});
    
%% (* Importieren *)
    %Pfad bilden
    Path = fullfile(General.ProgramInfo.Path,...
                    General.ProgramInfo.Path_Data,...
                    'MSK-Files (Mathematica)', [Filename '.msk']);
    %Öffnen der Datei (readonly)
    fid = fopen(Path,'r');
    %Auslesen der Wertepaare bis zum Ende der Datei
    rtn = fscanf(fid,'%f  %f',[2 inf]);
    %Schließen der Datei
    fclose(fid);
    %Transponieren
    rtn = rtn.';
end