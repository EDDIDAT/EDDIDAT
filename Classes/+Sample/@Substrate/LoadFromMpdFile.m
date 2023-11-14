% Diese Funktion liest einen SpecFile ein und extrahiert daraus ein Vektor 
% mit den einzelen Messreihen. Eine Messungsspezifische Anpassung erfolgt
% mit Hilfe des Diffraktometers.
% Input: Filename, Dateiname (ohne Endung), string|va /
%        Diffractometer, Diffraktometer-Konfiguration mit der gemessen
%        wurde, Diffractometer|va
% Output: obj, geladene Messungen, Measurement|row
function obj = LoadFromMpdFile(Filename)

%% (* Stringenzpr�fung *)
%     validateattributes(Filename,{'char'},{'row'});

%% (* Einlesen des Dateiinhaltes *)
    %Leeres Material- und Gitter-Objekt erstellen
    obj = Sample.Material();
    %Pfad bilden
    Path = fullfile(Sample.Material.FilePath, [Filename '.mpd']);
    %Laden der Datei und speichern in ein CharArray M
    M = Tools.StringOperations.AsciiFile2Text(Path,'\r\n'); 
    % Delimiter: \Zeilenende\Neue Zeile
    % Die Funktion AsciiFile2Text braucht als Input den Dateipfad und einen
    % Delimiter. 
    %% (* Finden der allgemeinen Eigenschaften (Header) *)
    % Index_tmp wird in der Folge f�r das Auslesen s�mtlicher Eigenschaften
    % benutzt
    % Einlesen der Materialdichte
    Index_tmp = Tools.StringOperations.SearchString(M,'Materialdichte');
    obj.MaterialDensity = sscanf(M(Index_tmp(1)+1,:),'%f');
    % Einlesen des Gittertyps
    Index_tmp = Tools.StringOperations.SearchString(M,'Gittertyp');
    obj.CrystalStructure = sscanf(M(Index_tmp(1)+1,:),'%s');
    % Einlesen des Gitterparameters (falls 'none', wird anders weiter verfahren)
    Index_tmp = Tools.StringOperations.SearchString(M,'Gitterparameter');
    LatticeParameter = sscanf(M(Index_tmp(1)+1,:),'%f');
    obj.LatticeParameter = LatticeParameter';
    % Einlesen des Gitterparameters (falls 'none', wird anders weiter verfahren)
    Index_tmp = Tools.StringOperations.SearchString(M,'Atomgewichtsliste');
    MolecularWeight = sscanf(M(Index_tmp(1)+1,:),'%f');
    obj.MolecularWeight = MolecularWeight';
    if strcmp(obj.CrystalStructure,'none')
    % Einlesen der hkl- und d-Werteliste
    Index_tmp = Tools.StringOperations.SearchString(M,'hkl- und d-Wertliste');
    % Neues Char Array erzeugen, dass nur die hkl- und d-Werte enth�lt
    M1 = M(Index_tmp+1:size(M,1),:);
    % Werte einlesen (cell) um d-spacing Werte zu extrahieren
    for i = 1:size(M1,1)
        hkldtmp(:,i) = textscan(M1(i,:),'%f');
    end
    % Werte in eine Matrix schreiben
    hkl_d_spacing = cell2mat(hkldtmp);
    % Matrix umstellen, nur d-Werte einschreiben
    d_spacing = [hkl_d_spacing(2,:)]';
    % h- k- und l-Werte speichern
    h = str2num(M1(:,1));
    k = str2num(M1(:,2));
    l = str2num(M1(:,3));
    % h-, k-, l- und d-Werte sortieren und zusammenf�gen und f�r den Plot vorbereiten
    obj.HKLdspacing = [h k l d_spacing];
    % Der Plot setzt nun bei der Berechnung der theoretischen Energielagen ein (f�r den Fall Gittertyp = 'none') 
    end
end