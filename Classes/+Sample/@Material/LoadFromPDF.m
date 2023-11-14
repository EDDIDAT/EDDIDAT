% Diese Funktion bietet die Mˆglichkeit einen Eintrag aus der PDF-Datenbank
% zu importieren. Dabei werden alle wichtigen Informationen selbstst‰ndig
% ausgelesen und zugewiesen. Die Werte werden anhand von festen
% Zeichenfolgen ausgelesen (AID-Format). 
% Input: Filename, Dateiname (ohne Endung), string|va
% Output: obj, geladenes Objekt, Material
function obj = LoadFromPDF(Filename)

%% (* Stringenzpr¸fung *)
    validateattributes(Filename,{'char'},{'row'});

%% (* Vorbereitung *)
    %Pfad bilden
    Path = fullfile(Sample.Material.FilePath, [Filename '.aid']);
    %Datei ˆffnen, Ergebnis ist der File-Identifier
    fid = fopen(Path);
    %Leeres Material- und Gitter-Objekt erstellen
    obj = Sample.Material();
    CL = Sample.CrystalLattice();
    %Ausgelesene Zeile
    Line(1,1:80) = 0; 
% + Initialisierungen f¸r die HKLDI-Wertliste
    %Z‰hler f¸r HKLD-Werte
    HKLDI_c = 1;
    %Zur tempor‰ren Ablage der HKLDI-Werte
    HKLDI_tmp(1,1:5) = 0; 
    
%% (* Einlese-Schleife *)
    %--> Abbruchbedingung der Einleseschleife: Letztes Zeichen ist ein '*'
    while ~strcmp(Line(80),'*')
        %Auslesen der Zeile
        Line = fgetl(fid);
        %--> Auswerten der Zeile, anhand des letzten Zeichens
        switch Line(80)
            case '1'
            % + Zellparameter einlesen (Hilfsvariable CP), dabei wird ein
            %   NaN in eine 0 umgewandelt
                CP = zeros(2,3);
                CP(1,1) = str2double(Line(1:9)); %a
                CP(1,2) = str2double(Line(10:18)); %b
                CP(1,3) = str2double(Line(19:27)); %c
                CP(2,1) = str2double(Line(28:35)); %alpha
                CP(2,2) = str2double(Line(36:43)); %beta
                CP(2,3) = str2double(Line(44:51)); %gamma
                CP(1,1:3) = CP(1,1:3) ./ 10; %Angstrˆm to nm
                CP(isnan(CP)) = 0;
                CL.CellParameters = CP;
            % + Gittertyp
                CL.Lattice = Line(72);
            % + PDF-Nummer
                obj.PDFNumber = str2double(Line(73:78));
            % + Gittersystem
                CL.System = Line(79);
            case '2'
%             % + Fehler der Zellparameter
%                 err_a = str2double(Line(1:9)) / 10;
%                 err_b = str2double(Line(10:18)) / 10;
%                 err_c = str2double(Line(19:27)) / 10;
%                 err_alpha = str2double(Line(28:35));
%                 err_beta = str2double(Line(36:43));
%                 err_gamma = str2double(Line(44:51));
            case '4'
            % + Raumgruppe, Zusammensetzen der einzelnen Teile
                CL.SpaceGroup = strtrim(Line(1:7));
                CL.SpaceGroup = [CL.SpaceGroup,...
                    ' (',strtrim(Line(12:14)),')'];
            % + Materialdichte
                obj.MaterialDensity = str2double(Line(37:43));
            % + Mol-Masse
                obj.MolecularWeight = str2double(Line(51:58));
            % + Einheitszellvolumen, Umrechnen von A^3 in nm^3
                CL.CellVolume = str2double(Line(61:69)) / 1000;
            case '6'
            % + Name (Beschreibung), Zusammensetzen der einzelnen Teile
                if strcmp(obj.Name,'unnamed')
                    obj.Name = strtrim(Line(1:31));
                else
                    obj.Name = [obj.Name,', ',strtrim(Line(1:31))];
                end
            case '8'
            % + Chemische Summenformel
                obj.ElementalFormula = strtrim(Line(1:31));
            case 'I'
            % + Beugungsspektrum
                %--> HKLDI-Werte in einer zun‰chst tempor‰ren
                %    Variable speichern (3 St¸ck pro Spalte)
                for i = 1:3
                    %Zur ‹bersicht
                    k = (i-1)*23;
                    %--> Nur wenn die Werte auch da sind
                    if ~isnan(str2double(Line(1+k:7+k)))
                        %Einlesen eines Datensatzes
                        HKLDI_tmp(HKLDI_c,1) =...
                            str2double(Line(1+k:7+k)) / 10; %A -> nm
                        HKLDI_tmp(HKLDI_c,2) =...
                            str2double(Line(8+k:10+k));
                        HKLDI_tmp(HKLDI_c,3) =...
                            str2double(Line(12+k:14+k));
                        HKLDI_tmp(HKLDI_c,4) =...
                            str2double(Line(15+k:17+k));
                        HKLDI_tmp(HKLDI_c,5) =...
                            str2double(Line(18+k:20+k));
                        %Inkrementieren
                        HKLDI_c = HKLDI_c + 1;
                    end %--> if ~isnan(str2double(...
                end %--> for i = 1:3
        end %--> switch Line(80)
    end %--> while ~strcmp(Line(80),'*')
    %Datei schlieﬂen
    fclose(fid);
    
%% (* Theoretische Beugungslinien erzeugen *)
    %Prealloc
    CL.DiffractionLines = General.ICloneable.CloneConstruction(...
        @SpectraAnalysis.DiffractionLine,[size(HKLDI_tmp,1),1]);
    %In eine Zelle unwandeln (HKL-Werte in eine einzige zusammenfassen)
    HKLDI_tmp = cat(2,num2cell(HKLDI_tmp(:,1:2)),...
        num2cell(HKLDI_tmp(:,3:5),2));
    %Gitterabst‰nde zuordnen
    [CL.DiffractionLines(:).LatticeSpacing] = deal(HKLDI_tmp{:,1});
    %Intensit‰ten zuordnen
    [CL.DiffractionLines(:).Intensity_Max] = deal(HKLDI_tmp{:,2});
    %HKL-Werte zurordnen
    [CL.DiffractionLines(:).HKL] = deal(HKLDI_tmp{:,3});
    
%% (* Objekt vervollst‰ndigen *)
    %Dem Gitter einen Standard-Namen zuordnen
    CL.Name = 'Unnamed';
    %Zuweisen des gesamten Gitters
    obj.CrystalLattice = CL;
    %Ermitteln der Elemente anhand der Summenformel
    obj.GetElementsFromFormula();
end