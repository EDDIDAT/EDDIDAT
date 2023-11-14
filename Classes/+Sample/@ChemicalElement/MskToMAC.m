% Diese Funktion ist f�r den �bergang von Mathematica zu MatLab gedacht.
% Sie importiert unter Angabe eines Dateinamens (*.msk) die passende
% Eigenschaft (MAC) f�r das chemische Element.
% Input: Filename, Dateiname (ohne Endung), string|va
% Output: rtn, MAC_Data (siehe Eigenschaft), double|[NaN 2]
function rtn = MskToMAC(Filename)

%% (* Stringenzpr�fung *)
    validateattributes(Filename,{'char'},{'row'});
    
%% (* Importieren *)
    %Pfad bilden
    Path = fullfile(General.ProgramInfo.Path,...
                    General.ProgramInfo.Path_Data,...
                    'MSK-Files (Mathematica)', [Filename '.msk']);
    %�ffnen der Datei (readonly)
    fid = fopen(Path,'r');
    %Auslesen der Wertepaare bis zum Ende der Datei
    rtn = fscanf(fid,'%f  %f',[2 inf]);
    %Schlie�en der Datei
    fclose(fid);
    %Transponieren
    rtn = rtn.';
end