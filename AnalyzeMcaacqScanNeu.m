function obj = AnalyzeAScan(Scan, Diffractometer)
    %% (* Anzahl und Index der AScans *)

        Index_AScan = Tools.StringOperations.SearchString(Scan,'@A');
        Count_AScans = size(Index_AScan,1);
        
        CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
        
    %% (* Instanzen und allgemeine Eigenschaften *)
        %--> Prealloc der Messobjekte
        obj = Measurement.Measurement.CloneConstruction(...
            @Measurement.Measurement,[1,Count_AScans]);
    % + Name (#S), wird später ergänzt
        set(obj,'Name',['AScan ', ...
            num2str(sscanf(Scan(1,:),'#S %d'))])
    %2. Scan-Veränderliche (#L)
        Index_tmp = Tools.StringOperations.SearchString(Scan,'#L');
        AScanVariablesNames = Tools.StringOperations.ScanWords(...
            Scan(Index_tmp(1),4:end));
%         if strcmp(Diffractometer.Name,'ETA3000')
%             AScanVariables = sscanf(Scan(Index_tmp(1)+1,:),'%f');
%             AScanVariables(7)
%             obj(j_c).CountingTime = AScanVariables(7);
%         end  

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
        if strcmp(Diffractometer.Name,'ETA3000')
            [obj(:).HeatRate] = deal(0);
        else
            [obj(:).HeatRate] = deal(sscanf(Scan(Index_tmp(1),:),...
                '#@TEMP %*f %*f %f'));
        end
  
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
  
    %% (* Durchlaufen der AScans *)

        for j_c = 1:Count_AScans
            %Motoren replizieren
            obj(j_c).Motors_all = Motors_all;
            
            % + Anode (#@HV_ANODE)
            if strcmp(Diffractometer.Name,'ETA3000')
                Index_tmp = Tools.StringOperations.SearchString(M,'#@HV_ANODE');
                obj(j_c).Anode = sscanf(M(Index_tmp(1),:),'#@HV_ANODE %s');
            end  
            
        %% (* Einlesen der Scan-Veränderlichen *)
            %Einlesen aller relevanten Daten aus dem AScan
            %(2 Zeilen über dem @A)
            
            if strcmp(Diffractometer.Name,'ETA3000')
                AScanVariables = sscanf(Scan(Index_AScan(j_c)-3,:),'%f',inf)';
            else
                AScanVariables = sscanf(Scan(Index_AScan(j_c)-1,:),'%f',inf)';
            end
            %Veränderlicher Motor (Hier statisch, da sonst nirgenwo steht,
            %wie der variable Motor heißt)
            obj(j_c).Motors_all.(AScanVariablesNames{1}) = ...
                AScanVariables(1);
            %Ringstrom
%             obj(j_c).RingCurrent = AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'R_strom'),1,'first'));
            %RealTime
            if strcmp(Diffractometer.Name,'ETA3000')
                obj(j_c).RealTime = 1;
                obj(j_c).DeadTime = 0;
                obj(j_c).CountingTime = AScanVariables(7);
            else
                obj(j_c).RealTime = AScanVariables(...
                find(strcmp(AScanVariablesNames,'Real'),1,'first'));
                %DeadTime (Aus der LiveTime berechnen)
                obj(j_c).DeadTime = (1 - AScanVariables(...
                    find(strcmp(AScanVariablesNames,'Live'),1,'first'))...
                    / obj(j_c).RealTime) * 100;
            end
            
            %Temperaturen
%             obj(j_c).Temperatures(1) = AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'Temp_1'),1,'first'));
%             obj(j_c).Temperatures(2) = AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'Temp_2'),1,'first'));
            
        %% (* Namen anpassen *)
            %AScan-Motor
            obj(j_c).Name = [obj(j_c).Name , ', ',...
                AScanVariablesNames{1},' = ',num2str(AScanVariables(1))];
            
        %% (* Erstellen des ED-Spektrums *)
            if strcmp(Diffractometer.Name,'ETA3000')                
                LineCount_tmp = ceil((obj(j_c).ChannelRange(2) -...
                    obj(j_c).ChannelRange(1)) / 16);
                Intensities = Scan(...
                    Index_AScan(j_c):Index_AScan(j_c)+LineCount_tmp-1,:);
                %Transponieren
                Intensities = Intensities';
                %@A entfernen und zu einer Row machen
                Intensities = Intensities(3:end);
                %Backslashs entfernens
                Intensities = strrep(Intensities,'\','');
                %In eine double-Array verwandeln
                Intensities = sscanf(Intensities,'%d', inf);
                 % Create vector with channel numbers 
                Angles_tmp = obj(j_c).ChannelRange(1):obj(j_c).ChannelRange(2);
                % Create EDSpectrum
                obj(j_c).EDSpectrum = [Angles_tmp',Intensities];                
            else
                CalibParam_a(j_c) = CalibParams.a(1) + exp(CalibParams.a(2)*(CalibParams.a(3) + obj(j_c).DeadTime)) - (CalibParams.a(4)/(CalibParams.a(5)+obj(j_c).DeadTime));
                CalibParam_b(j_c) = CalibParams.b(1) + CalibParams.b(2)*obj(j_c).DeadTime + CalibParams.b(3)*obj(j_c).DeadTime.^2;
                CalibParam_c(j_c) = CalibParams.c(1) + CalibParams.c(2)*obj(j_c).DeadTime;
    
                CalibParamstmp = [CalibParam_c(j_c);CalibParam_b(j_c);CalibParam_a(j_c)];
    
                %Anzahl der Zeilen in denen die Intensitäten stehen (Berechnet 
                %aus der ChannelRange)
                LineCount_tmp = ceil((obj(j_c).ChannelRange(2) -...
                    obj(j_c).ChannelRange(1)) / 16);
                %Speichern des Scans in ein CharArray
                Intensities = Scan(...
                    Index_AScan(j_c):Index_AScan(j_c)+LineCount_tmp-1,:);
                %Transponieren
                Intensities = Intensities';
                %@A entfernen und zu einer Row machen
                Intensities = Intensities(3:end);
                %Backslashs entfernens
                Intensities = strrep(Intensities,'\','');
                %In eine double-Array verwandeln
                Intensities = sscanf(Intensities,'%d', inf);
    
                Energies_tmp = polyval(...
                    CalibParamstmp,...
                    obj(j_c).ChannelRange(1):obj(j_c).ChannelRange(1)...
                    +length(Intensities)-1);
    
                %Zuweisen des ED-Spektrums
                obj(j_c).EDSpectrum = [Energies_tmp',Intensities];
            end
        end   
end