% Diese Funktion liest einen SpecFile ein und extrahiert daraus ein Vektor 
% mit den einzelen Messreihen. Eine Messungsspezifische Anpassung erfolgt
% mit Hilfe des Diffraktometers.
% Input: Filename, Dateiname (ohne Endung), string|va /
%        Diffractometer, Diffraktometer-Konfiguration mit der gemessen
%        wurde, Diffractometer|va
% Output: obj, geladene Messungen, Measurement|row
function obj = LoadFromSpecFile_without_angles(Filename,Diffractometer,Mode)

%% (* Stringenzprüfung *)
    validateattributes(Filename,{'char'},{'row'});
    validateattributes(Diffractometer,{'Measurement.Diffractometer'},...
        {'scalar'});
    validateattributes(Mode,{'double'},...
        {'real','scalar','positive','finite'})

%% Einlesen des Diffraktometertyps
    diffractometerMode = Mode;
%% (* Einlesen des Dateiinhaltes *)
    %Pfad bilden
    Path = fullfile(Measurement.Measurement.FilePath, Filename);
    %Laden der Datei und speichern in ein CharArray M
    M = Tools.StringOperations.AsciiFile2Text(Path,'\r\n'); 
    % Delimiter: \Zeilenende\Neue Zeile
    % Die Funktion AsciiFile2Text braucht als Input den Dateipfad und einen
    % Delimiter. 

%% (* Finden der allgemeinen Eigenschaften (Header) *)
% Index_tmp wird in der Folge für das Auslesen sämtlicher Eigenschaften
% benutzt
% + Messserie bzw. Dateiname (#F)
    Index_tmp = Tools.StringOperations.SearchString(M,'#F');
    MeasurementSeries = sscanf(M(Index_tmp(1),:),'#F %*[^/]/%*[^/]/%[^.]');
% + Einlesen alle eingetragenen Motornamen (#O)
    Index_tmp = Tools.StringOperations.SearchString(M,'#O');
    %Prealloc, jede Zeile enthält die Motornamen
    MotorNames = cell(size(Index_tmp,1),1);
    %--> Scannen aller Zeilen
    for i_c = 1:size(Index_tmp,1)
        MotorNames{i_c} = Tools.StringOperations.ScanWords(...
            M(Index_tmp(i_c),4:end));
    end
    
% %2. Phi-Winkel
%     Index_tmp = Tools.StringOperations.SearchString(M,'#phiP');
%     for j_c = 1:size(Index_tmp,1)
%         phiP(j_c) = sscanf(M(Index_tmp(j_c),:),'#phiP %f');
%     end
%     
%     phiIndex = unique(phiP, 'stable');
%     
%     for i=1:length(phiIndex)
%         IndexMin(i) = arrayfun(@(x) find(phiP == x,1,'first'), phiIndex(i) );
%         IndexMax(i) = arrayfun(@(x) find(phiP == x,1,'last'), phiIndex(i) );
%         PhiTable = [IndexMin; IndexMax]';
%     end
%     
%     sortTable = [phiIndex' PhiTable(:,1) PhiTable(:,2)];
%     sortTable = sortrows(sortTable);
%     % Phi-werte mit Index aus PhiTable in phiP eintragen
%     if diffractometerMode == 1
%         if length(phiIndex) == 1
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3))];
%         elseif length(phiIndex) == 2
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) ...
%                 phiP(sortTable(2,2):sortTable(2,3))];
%         elseif length(phiIndex) == 3
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
%                 phiP(sortTable(2,2):sortTable(2,3))...
%                 phiP(sortTable(3,2):sortTable(3,3))];
%         else
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
%                 phiP(sortTable(2,2):sortTable(2,3))...
%                 phiP(sortTable(3,2):sortTable(3,3))...
%                 phiP(sortTable(4,2):sortTable(4,3))];
%         end
%     else
%         if length(phiIndex) == 1
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3))];
%         elseif length(phiIndex) == 2
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
%                 phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3))];
%         elseif length(phiIndex) == 3
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
%                 phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3)) ...
%                 phiP(sortTable(3,2):sortTable(3,3)) phiP(sortTable(3,2):sortTable(3,3))];
%         else
%             phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
%                 phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3)) ...
%                 phiP(sortTable(3,2):sortTable(3,3)) phiP(sortTable(3,2):sortTable(3,3)) ...
%                 phiP(sortTable(4,2):sortTable(4,3)) phiP(sortTable(4,2):sortTable(4,3))];
%         end
%     end
%     
% %3. Psi-Winkel
%     if diffractometerMode == 1
%         Index_tmp = Tools.StringOperations.SearchString(M,'#psiP');
%         for j_c = 1:size(Index_tmp,1)
%             psiP(j_c) = sscanf(M(Index_tmp(j_c),:),'#psiP %f');
%         end
%     
%         if length(phiIndex) == 1
%                 psiPneu = [psiP(sortTable(1,2):sortTable(1,3))];
%             elseif length(phiIndex) == 2
%                 psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
%                     psiP(sortTable(2,2):sortTable(2,3))];
%             elseif length(phiIndex) == 3
%                 psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
%                     psiP(sortTable(2,2):sortTable(2,3)) ...
%                     psiP(sortTable(3,2):sortTable(3,3))];
%             else
%                 psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
%                     psiP(sortTable(2,2):sortTable(2,3)) ...
%                     psiP(sortTable(3,2):sortTable(3,3)) ...
%                     psiP(sortTable(4,2):sortTable(4,3))];
%         end    
%         
%     end
%     
%     if diffractometerMode == 2
%         Index_tmp = Tools.StringOperations.SearchString(M,'#psiP');
%         for j_c = 1:size(Index_tmp,1)
%             psiP(j_c) = sscanf(M(Index_tmp(j_c),:),'#psiP %f');
%         end
%         
%         if length(phiIndex) == 1
%             % psiP entsprechend der Laenge von phiIndex erweitern
%             psiPrepmat = repmat(psiP,2*length(phiIndex),1)';
%             % psiPrepmat sortieren
%             psiPneu = reshape(psiPrepmat',1,[]);
%         else
%             % psiP entsprechend der Laenge von phiIndex erweitern
%             psiPrepmat = repmat(psiP,2,1)';
%             % psiPrepmat sortieren
%             psiPneu = reshape(psiPrepmat',1,[]);
%         end
%     end
    
 %4. Eta-Winkel
%     if diffractometerMode == 1
%         Index_tmp = Tools.StringOperations.SearchString(M,'#eta');
%         for j_c = 1:size(Index_tmp,1)
%             etaP(j_c) = sscanf(M(Index_tmp(j_c),:),'#eta %f');
%         end
%     end
 
%% (* Counts und Indizies *)
    %Ermitteln der Scanindizies anhand des #S Literals
    Index_Scan = Tools.StringOperations.SearchString(M,'#S');
    %Ermitteln der Anzahl der Scans
    Count_Scans = size(Index_Scan,1);
    %Indizies der Leerzeilen
    Index_BlankLines = Tools.StringOperations.SearchBlankLines(M);
    %--> Imaginäre Leerzeile am Ende des SpecFiles anfügen
    if Index_BlankLines(end) ~= size(M,1)
        Index_BlankLines(end+1) = size(M,1) + 1;
    end
    
%% (* Extrahieren der einzelnen Scans *)
    %Prealloc
    Scans = cell(Count_Scans,1);
    %--> Ein Scan geht von seinem Startpunkt aus bis zur nächsten Leerzeile
    for i_c = 1:Count_Scans
        %Index der kommenden Leerzeilen > als Index des Scans
        Index_NextBlankLine = find(Index_BlankLines > Index_Scan(i_c),...
            1,'first');
        %Kleinstes Intervall ist der Scan
        Scans{i_c} = M(Index_Scan(i_c):Index_BlankLines(...
            Index_NextBlankLine)-1,:);
    end

%     if length(phiIndex) == 1
%         Scans = Scans;
%     elseif length(phiIndex) == 2
%        Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)}}';
%     elseif length(phiIndex) == 3
%         Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
%         Scans{sortTable(3,2):sortTable(3,3)}}';
%     else
%         Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
%         Scans{sortTable(3,2):sortTable(3,3)} Scans{sortTable(4,2):sortTable(4,3)}}';
%     end

%% (* Scananalyse *)
%--------------------------------------------------------------------------
    % Diese Nested-Funktion erzeugt aus einem Mcaacq-Scan ein Messobjekt.
    function obj = AnalyzeMcaacqScan(Scan)
        
    %% (* Instanzen und allgemeine Eigenschaften *)
        %Prealloc
        obj = Measurement.Measurement();
    % + Name mit Hilfe der Scannummer in der 1. Zeile (#S)
        obj.Name = ['Scan ' num2str(sscanf(Scan(1,:),'#S %d'))];
            
    %% (* Einlesen der Zeiten *)
    % + Zeitpunkt (#D)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#D');
        %Einlesen der Bestandteile
        Time_tmp = Tools.StringOperations.ScanWords(...
            strtrim(Scan(Index_tmp(1),4:end)));
        %Datums-Vektor erzeugen
        obj.Time = datevec([Time_tmp{3},'-',Time_tmp{2},'-',Time_tmp{5},...
            ' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS');
    % + Real- und DeadTime (#@CTIME)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CTIME');
        obj.RealTime = sscanf(Scan(Index_tmp(1),:),'#@CTIME %f %*f %*f');
        %Aus der LiveTime berechnen
        obj.DeadTime = (1 - sscanf(Scan(Index_tmp(1),:),...
            '#@CTIME %*f %f %*f') / obj.RealTime) * 100;
        
    %% (* Einlesen der Rahmenbedingungen *)
    % + Ringstrom (#@RC)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@RC');
        obj.RingCurrent = sscanf(Scan(Index_tmp(1),:),'#@RC %f');
    % + Temperaturen (#@TEMP)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@TEMP');
        obj.HeatRate = sscanf(Scan(Index_tmp(1),:),'#@TEMP %*f %*f %f');
        obj.Temperatures = sscanf(Scan(Index_tmp(1),:),...
            '#@TEMP %f %f %*f')';
        
    %% (* Einlesen der Winkel und Positionen *)
    % + Motoren (#P)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#P');
        %--> Durchlaufen aller Zeilen
        for j_c = 1:size(Index_tmp,1)
            %Formatierungsstring erstellen, um die zugehörigen Positionen
            %auszulesen
            Format = repmat('%f ',size(MotorNames{j_c},1));
            %Auslesen der Positionen
            Positions = sscanf(Scan(Index_tmp(j_c),4:end),Format);
            %--> Erstellen und Zuweisen der Motorobjekte
            for k_c = 1:size(MotorNames{j_c},2)
                obj.Motors_all.(MotorNames{j_c}{k_c}) = Positions(k_c);
            end
        end
        
    %% (* Einlesen der Messdaten *)
    % + Channelrange (#@CHANN)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CHANN');
        Channel_tmp = sscanf(Scan(Index_tmp(1),:),'#@CHANN %d %d');
        %Range bestimmen
        obj.ChannelRange = [Channel_tmp(2),...
            Channel_tmp(2)+Channel_tmp(1)-1];
    % + Intensitäten (@A)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'@A');
        %Anzahl der Zeilen in denen die Intensitäten stehen (Berechnet aus 
        %der ChannelRange)
        LineCount_tmp = ceil((obj.ChannelRange(2) -...
            obj.ChannelRange(1)) / 16);
        %Speichern des Scans in ein CharArray
        Intensities_tmp = Scan(Index_tmp(1):Index_tmp(1) + ...
            LineCount_tmp-1,:);
        %Transponieren
        Intensities_tmp = Intensities_tmp';
        %@A entfernen und zu einer Row machen
        Intensities_tmp = Intensities_tmp(3:end);
        %Backslashs entfernen
        Intensities_tmp = strrep(Intensities_tmp,'\','');
        %In eine double-Array verwandeln
        Intensities_tmp = sscanf(Intensities_tmp,'%d', inf);
    % + Energien berechnen
        %Berechnung mit Hilfe der Kalibirierungswerte des Detektors
%         Energies_tmp = polyval(...
%             Diffractometer.Detector.EnergyCalibrationParameters,...
%             obj.ChannelRange(1):obj.ChannelRange(1)...
%             +length(Intensities_tmp)-1);
%         Energies_tmp = linspace(obj.ChannelRange(1),obj.ChannelRange(2),obj.ChannelRange(2)-1);
    % + Energien berechnen - neu 2015
        %Berechnung mit Hilfe der Kalibirierungsfunktionen der Parameter
        %a,b und c.
        % Anfang 2015
%         CalibParam_a = 0.01401 + exp(0.01543*(-260.48858 + ...
%             obj.DeadTime)) - (0.11759/(1.89065+obj.DeadTime));
%         CalibParam_b = 0.0082 - 4.90133e-10*obj.DeadTime + ...
%             2.33226e-12*obj.DeadTime.^2;
%         CalibParam_c = -1.72537e-9 - 3.78725e-26*obj.DeadTime;
        % April 2015
%         CalibParam_a = -0.03767 + exp(0.01543*(-260.48841 + ...
%             obj.DeadTime)) - (0.1176/(1.89065+obj.DeadTime));
%         CalibParam_b = 0.0082 - 3.15213e-10*obj.DeadTime;
%         CalibParam_c = -1.72537e-9 + 2.97789e-25*obj.DeadTime;
        % September 2015
%         CalibParam_a = -0.0214 + exp(0.02354*(-208.09989 + ...
%             obj.DeadTime)) - (0.17511/(2.94224+obj.DeadTime));
%         CalibParam_b = 0.008119 - 5.16723e-10*obj.DeadTime + 2.37589e-12*obj.DeadTime.^2;
%         CalibParam_c = -1.8617e-9 - 3.7839e-25*obj.DeadTime;
        % Februar 2016
        CalibParam_a = -0.02402 + exp(0.02355*(-208.15056 + ...
            obj.DeadTime)) - (0.17486/(2.94249+obj.DeadTime));
        CalibParam_b = 0.00818 - 5.17547e-10*obj.DeadTime + 2.37964e-12*obj.DeadTime.^2;
        CalibParam_c = -1.86469e-9 + 6.22393e-25*obj.DeadTime;        
        CalibParams = [CalibParam_c;CalibParam_b;CalibParam_a];
        Energies_tmp = polyval(...
            CalibParams,...
            obj.ChannelRange(1):obj.ChannelRange(1)...
            +length(Intensities_tmp)-1);
    % + Energiedispersives Spektrum
        obj.EDSpectrum = [Energies_tmp',Intensities_tmp];
    end
%--------------------------------------------------------------------------
    % Diese Nested-Funktion erzeugt aus einem Ascan-Scan ein Messobjekt. 
    % Zunächst werden Eigenschaften eingelesen, die für alle Objekte gleich
    % sind und dann die Scan-Veränderlichen.
    function obj = AnalyzeAScan(Scan)
        
    %% (* Anzahl und Index der AScans *)
        Index_AScan = Tools.StringOperations.SearchString(Scan,'@A');
        Count_AScans = size(Index_AScan,1);
        
    %% (* Instanzen und allgemeine Eigenschaften *)
        %--> Prealloc der Messobjekte
        obj = Measurement.Measurement.CloneConstruction(...
            @Measurement.Measurement,[1,Count_AScans]);
    % + Name (#S), wird später ergänzt
        set(obj,'Name',['AScan ', ...
            num2str(sscanf(Scan(1,:),'#S %d'))]);
    %2. Scan-Veränderliche (#L)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#L');
        AScanVariablesNames = Tools.StringOperations.ScanWords(...
            Scan(Index_tmp(1),4:end));
        
    %% (* Einlesen der Zeiten *)
    %1. Zeitpunkt (#D)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#D');
        %Einlesen der Bestandteile
        Time_tmp = Tools.StringOperations.ScanWords(...
            strtrim(Scan(Index_tmp(1),4:end)));
        %Datums-Vektor erzeugen
        set(obj(:),'Time',datevec([Time_tmp{3},'-',Time_tmp{2},'-',...
            Time_tmp{5},' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS'))
        
    %% (* Einlesen der Rahmenbedingungen *)
    %1. Temperaturen (#@TEMP)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@TEMP');
        [obj(:).HeatRate] = deal(sscanf(Scan(Index_tmp(1),:),...
            '#@TEMP %*f %*f %f'));
        
    %% (* Einlesen der Winkel und Positionen *)
    %1. Motoren (#P)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#P');
        %--> Durchlaufen aller Zeilen
        for j_c = 1:size(Index_tmp,1)
            %Formatierungsstring erstellen, um die zugehörigen Positionen
            %auszulesen
            Format = repmat('%f ',size(MotorNames{j_c},1));
            %Auslesen der Positionen
            Positions = sscanf(Scan(Index_tmp(j_c),4:end),Format);
            %--> Erstellen der Motorstruktur und zwischenspeichern
            for k_c = 1:size(MotorNames{j_c},2)
                Motors_all.(MotorNames{j_c}{k_c}) = Positions(k_c);
            end
        end       
        
    %% (* Einlesen der Messdaten *)
    %1. Channelrange (#@CHANN)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CHANN');
        Channel_tmp = sscanf(Scan(Index_tmp(1),:),'#@CHANN %d %d');
        %Range bestimmen
        [obj(:).ChannelRange] = deal([Channel_tmp(2)...
            Channel_tmp(2)+Channel_tmp(1)-1]);
    %2. Energien berechnen
        %Berechnung mit Hilfe der Kalibirierungswerte des Detektors
        Energies = polyval(...
            Diffractometer.Detector.EnergyCalibrationParameters,...
            obj(1).ChannelRange(1):obj(1).ChannelRange(2));
        
    %% (* Durchlaufen der AScans *)
        for j_c = 1:Count_AScans
            %Motoren replizieren
            obj(j_c).Motors_all = Motors_all;
            
        %% (* Einlesen der Scan-Veränderlichen *)
            %Einlesen aller relevanten Daten aus dem AScan
            %(2 Zeilen über dem @A)
            AScanVariables = sscanf(Scan(Index_AScan(j_c)-2,:),'%f',inf)';
            %Veränderlicher Motor (Hier statisch, da sonst nirgenwo steht,
            %wie der variable Motor heißt)
            obj(j_c).Motors_all.(AScanVariablesNames{1}) = ...
                AScanVariables(1);
            %Ringstrom
            obj(j_c).RingCurrent = AScanVariables(...
                find(strcmp(AScanVariablesNames,'R_strom'),1,'first'));
            %RealTime
            obj(j_c).RealTime = AScanVariables(...
                find(strcmp(AScanVariablesNames,'MCA_Real'),1,'first'));
            %DeadTime (Aus der LiveTime berechnen)
            obj(j_c).DeadTime = (1 - AScanVariables(...
                find(strcmp(AScanVariablesNames,'MCA_Live'),1,'first'))...
                / obj(j_c).RealTime) * 100;
            %Temperaturen
            obj(j_c).Temperatures(1) = AScanVariables(...
                find(strcmp(AScanVariablesNames,'Temp_1'),1,'first'));
            obj(j_c).Temperatures(2) = AScanVariables(...
                find(strcmp(AScanVariablesNames,'Temp_2'),1,'first'));
            
        %% (* Namen anpassen *)
            %AScan-Motor
            obj(j_c).Name = [obj(j_c).Name , ', ',...
                AScanVariablesNames{1},' = ',num2str(AScanVariables(1))];
            
        %% (* Erstellen des ED-Spektrums *)
            %Anzahl der Zeilen in denen die Intensitäten stehen (Berechnet 
            %aus der ChannelRange)
            LineCount_tmp = ceil((obj(j_c).ChannelRange(2) -...
                obj(j_c).ChannelRange(1)) / 16);
            %Speichern des Scans in ein CharArray
            Intensities = Scan(...
                Index_AScan(j_c):Index_AScan(j_c)+LineCount_tmp-1,:);
            %Tranponieren
            Intensities = Intensities';
            %@A entfernen und zu einer Row machen
            Intensities = Intensities(3:end);
            %Backslashs entfernen
            Intensities = strrep(Intensities,'\','');
            %In eine double-Array verwandeln
            Intensities = sscanf(Intensities,'%d', inf);
            %Zuweisen des ED-Spektrums
            obj(j_c).EDSpectrum = [Energies',Intensities];
        end    
    end

%--------------------------------------------------------------------------
% Diese Nested-Funktion erzeugt aus einem Mcaacq-Scan ein Messobjekt.
    function obj = AnalyzeLEDDIMcaacqScan(Scan)
	
%% (* Anzahl und Index der LEDDIMcaacqScans *)
        Index_LEDDIScan = Tools.StringOperations.SearchString(Scan,'@A');
        Count_LEDDIScans = size(Index_LEDDIScan,1);

%% (* Instanzen und allgemeine Eigenschaften *)
        %--> Prealloc der Messobjekte
        obj = Measurement.Measurement.CloneConstruction(...
            @Measurement.Measurement,[1,Count_LEDDIScans]);
			
%% (* Einlesen der Zeiten *)
%1. Zeitpunkt (#D)
    Index_tmp = Tools.StringOperations.SearchString(Scan,'#D');
    %Einlesen der Bestandteile
    Time_tmp = Tools.StringOperations.ScanWords(...
        strtrim(Scan(Index_tmp(1),4:end)));
    %Datums-Vektor erzeugen
    set(obj(:),'Time',datevec([Time_tmp{3},'-',Time_tmp{2},'-',...
        Time_tmp{5},' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS'))	

%% (* Einlesen der Winkel und Positionen *)
%1. Motoren (#P)
    Index_tmp = Tools.StringOperations.SearchString(Scan,'#P');
    %--> Durchlaufen aller Zeilen
    for j_c = 1:size(Index_tmp,1)
        %Formatierungsstring erstellen, um die zugehörigen Positionen
        %auszulesen
        Format = repmat('%f ',size(MotorNames{j_c},1));
        %Auslesen der Positionen
        Positions = sscanf(Scan(Index_tmp(j_c),4:end),Format);
        %--> Erstellen der Motorstruktur und zwischenspeichern
        for k_c = 1:size(MotorNames{j_c},2)
            Motors_all.(MotorNames{j_c}{k_c}) = Positions(k_c);
        end
    end
   
%% (* Einlesen der Messdaten *)
%1. Channelrange (#@CHANN)
    Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CHANN');
    Channel_tmp = sscanf(Scan(Index_tmp(1),:),'#@CHANN %d %d');
    %Range bestimmen
    [obj(:).ChannelRange] = deal([Channel_tmp(2)...
        Channel_tmp(2)+Channel_tmp(1)-1]);
	
for j_c = 1:Count_LEDDIScans
        %Motoren replizieren
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CHANN');
        Channel_tmp = sscanf(Scan(Index_tmp(j_c),:),'#@CHANN %d %d');
        %Range bestimmen
        [obj(j_c).ChannelRange] = deal([Channel_tmp(2)...
        Channel_tmp(2)+Channel_tmp(1)-1]);
    
        obj(j_c).Motors_all = Motors_all;
		Index_tmp = Tools.StringOperations.SearchString(Scan,'#@ROI');
		% Name (#ROI BSI), wird später ergänzt
        set(obj(j_c),'Name',['Det ', ...
            num2str(sscanf(Scan(Index_tmp(j_c),:),'#@ROI BSI%d %*d %*d')),...
            ' Scan ' num2str(sscanf(Scan(1,:),'#S %d'))]);

		% RealTime
		Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CTIME');
		obj(j_c).RealTime = sscanf(Scan(Index_tmp(j_c),:),'#@CTIME %f %*f %*f');
		%Aus der LiveTime berechnen
        obj(j_c).DeadTime = (1 - sscanf(Scan(Index_tmp(j_c),:),...
            '#@CTIME %*f %f %*f') / obj(j_c).RealTime) * 100;
		% Ringstrom (#@RC)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@RC');
        obj(j_c).RingCurrent = sscanf(Scan(Index_tmp(j_c),:),'#@RC %f');
		% Temperaturen
		Index_tmp = Tools.StringOperations.SearchString(Scan,'#@TEMP');
        [obj(j_c).HeatRate] = sscanf(Scan(Index_tmp(j_c),:),...
            '#@TEMP %*f %*f %f');
		[obj(j_c).Temperatures] = sscanf(Scan(Index_tmp(j_c),:),...
            '#@TEMP %f %f %*f')';
		% Hochspannung
% 		obj(1,1).addprop('HV');
% 		obj(1,2).addprop('HV');
		Index_tmp = Tools.StringOperations.SearchString(Scan,'#@HV');
        obj(1,j_c).addprop('HV');
        [obj(j_c).HV] = sscanf(Scan(Index_tmp(j_c),:),...
            '#@HV %f %f');
%% (* Erstellen des ED-Spektrums *)
		% Energien berechnen
        % Berechnung mit Hilfe der Kalibirierungswerte des Detektors
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CALIB');
        obj(1,j_c).addprop('EnergyCalibrationParameters');
        obj(j_c).EnergyCalibrationParameters = sscanf(Scan(Index_tmp(j_c),:),...
            '#@CALIB %f %f %f');
        Energies = polyval(...
            flipud(obj(j_c).EnergyCalibrationParameters),...
            obj(j_c).ChannelRange(1):obj(j_c).ChannelRange(2));
%         size(Energies,2)
        %Anzahl der Zeilen in denen die Intensitäten stehen (Berechnet 
        %aus der ChannelRange)
		LineCount_tmp = ceil((obj(j_c).ChannelRange(2) -...
                obj(j_c).ChannelRange(1)) / 16);
		Intensities = Scan(...
				Index_LEDDIScan(j_c):Index_LEDDIScan(j_c)+LineCount_tmp-1,:);
		Intensities = Intensities';
		%@A entfernen und zu einer Row machen
		Intensities = Intensities(3:end);
		%Backslashs entfernen
		Intensities = strrep(Intensities,'\','');
		%In eine double-Array verwandeln
		Intensities = sscanf(Intensities,'%d', inf);
%         size(Intensities,1)
		%Zuweisen des ED-Spektrums
		obj(j_c).EDSpectrum = [Energies',Intensities];
end
end
%--------------------------------------------------------------------------

%% (* Durchlaufen aller Scans und Erstellen der Messobjekte*)
    %Prealloc
    obj = [];
    %--> Durchlauf
    for i_c = 1:Count_Scans
    %% (* Analyse je nach Scan-Typ *)
        ScanType = char(sscanf(Scans{i_c}(1,:),'#S %*d %s')');
        %--> Analyse entsprechen dem Scan-Typ
        if diffractometerMode == 1
            if any(strcmp(ScanType,{'ascan','dscan'}))
                obj_new = AnalyzeAScan(Scans{i_c});
            elseif any(strcmp(ScanType,{'mcaacq','twinmcaacq'}))
                obj_new = AnalyzeMcaacqScan(Scans{i_c});
                % Hier muss noch eine weiter if-Bedingung eingefügt werden. Und
                % ausserdem muss noch ein weiteres Unterscheidungsmerkmal des
                % LEDDI Scans definiert werden ('mcaacq').
            else
                obj_new = [];
            end
        else
            if any(strcmp(ScanType,{'ascan','dscan'}))
                obj_new = AnalyzeAScan(Scans{i_c});
            elseif any(strcmp(ScanType,{'mcaacq','twinmcaacq'}))
                obj_new = AnalyzeLEDDIMcaacqScan(Scans{i_c});
                % Hier muss noch eine weiter if-Bedingung eingefügt werden. Und
                % ausserdem muss noch ein weiteres Unterscheidungsmerkmal des
                % LEDDI Scans definiert werden ('mcaacq').
            else
                obj_new = [];
            end
        end
    %% (* Hinzufügen der neuen Messobjekte *)
        obj = [obj, obj_new];
    end
    
%% (* Weitere Eigenschaften zuweisen *)
    %Messserie
    set(obj(:),'MeasurementSeries',MeasurementSeries);
    %Diffraktometer
    set(obj(:),'Diffractometer',Diffractometer);
    
%% (* Motoren übergeben *)
    if diffractometerMode == 1
        %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
        SP_tmp = struct2cell(Diffractometer.SamplePositioner);
        SP_tmp = get([SP_tmp{:}],'Position');
        if ~iscell(SP_tmp), SP_tmp = num2cell(SP_tmp); end
        %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
        DP_tmp = struct2cell(Diffractometer.DetectorPositioner);
        DP_tmp = get([DP_tmp{:}],'Position');
        if ~iscell(DP_tmp), DP_tmp = num2cell(DP_tmp); end
        %Motor-Struktur erzeugen, indem die SP und DP zusammengefügt werden
        Motors_tmp = cell2struct(cat(1,SP_tmp,DP_tmp),...
            cat(1,fieldnames(Diffractometer.SamplePositioner),...
            fieldnames(Diffractometer.DetectorPositioner)));
    else
        %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
        SP_tmp = struct2cell(Diffractometer.SamplePositioner);
        SP_tmp = get([SP_tmp{:}],'Position');
        if ~iscell(SP_tmp), SP_tmp = num2cell(SP_tmp); end
        %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
        SouP_tmp = struct2cell(Diffractometer.SourcePositioner);
        SouP_tmp = get([SouP_tmp{:}],'Position');
        if ~iscell(SouP_tmp), SouP_tmp = num2cell(SouP_tmp); end
        %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
        DP_tmp = struct2cell(Diffractometer.DetectorPositioner);
        DP_tmp = get([DP_tmp{:}],'Position');
        if ~iscell(DP_tmp), DP_tmp = num2cell(DP_tmp); end
        %Motor-Struktur erzeugen, indem die SP und DP zusammengefügt werden
        Motors_tmp = cell2struct(cat(1,SP_tmp,SouP_tmp,DP_tmp),...
            cat(1,fieldnames(Diffractometer.SamplePositioner),...
            fieldnames(Diffractometer.DetectorPositioner),...
            fieldnames(Diffractometer.SourcePositioner)));
    end
    %Motornamen temporär abspeichern
    Motor_Names_tmp = fieldnames(Motors_tmp);
    %--> Durchlaufen der Messungen
    for i_c = 1:length(obj)
        %Standard-Motor zuweisen
        obj(i_c).Motors = Motors_tmp;
        %--> Durchlaufen der Motoren
        for j_c = 1:length(Motor_Names_tmp)
            %--> Falls kein Vorgabewert im Diffraktometer geben ist...
            if isnan(Motors_tmp.(Motor_Names_tmp{j_c}))
                %...Motor-Position aus Motors_all kopieren
                obj(i_c).Motors.(Motor_Names_tmp{j_c}) = ...
                    obj(i_c).Motors_all.(Motor_Names_tmp{j_c});
            end
        end %--> for j_c = 1:length(Motor_Names_tmp)
        
        %% (* Winkel aus den Motoren berechnen *)
        % Muss NOCH je nach Messtyp angepasst werden. Sollte später in
        % Detector geschehen
        if diffractometerMode == 1
            obj(i_c).twotheta = obj(i_c).Motors_all.zwei_theta;
            obj(i_c).SCSAngles.psi = abs(psiPneu(i_c)); %obj(i_c).Motors_all.chi;
            obj(i_c).SCSAngles.phi = phiPneu(i_c);
            obj(i_c).SCSAngles.eta = 90;
        else
            obj(i_c).twotheta = -2*obj(i_c).Motors_all.Det2_rot;
            obj(i_c).SCSAngles.psi = psiPneu(i_c);
            obj(i_c).SCSAngles.chi = abs(obj(i_c).Motors_all.Chi);
            obj(i_c).SCSAngles.phi = phiPneu(i_c);
            obj(i_c).SCSAngles.eta = 90;   
        end   
    end %--> for i_c = 1:length(obj)
end