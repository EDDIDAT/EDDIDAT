% Diese Funktion liest einen SpecFile ein und extrahiert daraus ein Vektor 
% mit den einzelen Messreihen. Eine Messungsspezifische Anpassung erfolgt
% mit Hilfe des Diffraktometers.
% Input: Filename, Dateiname (ohne Endung), string|va /
%        Diffractometer, Diffraktometer-Konfiguration mit der gemessen
%        wurde, Diffractometer|va
% Output: obj, geladene Messungen, Measurement|row
function obj = LoadFromSpecFile_neu(Filename,Diffractometer,ScanMode,Calibration)
% assignin('base','Filename',Filename)
% assignin('base','Diffractometer',Diffractometer)
% assignin('base','ScanMode',ScanMode)
% assignin('base','Calibration',Calibration)

%% (* Stringenzprüfung *)
%     validateattributes(Filename,{'char'},{'row'});
%     validateattributes(Diffractometer,{'Measurement.Diffractometer'},...
%         {'scalar'});
%     validateattributes(Calibration,{'char'},{'row'});

%% Einlesen der Kalibrierung
    calib = Calibration;
%% (* Einlesen des Dateiinhaltes *)
    %Pfad bilden
    Path = fullfile(Measurement.Measurement.FilePath, Filename);
    %Laden der Datei und speichern in ein CharArray M
    M = Tools.StringOperations.AsciiFile2Text(Path,'\r\n'); 
    % Delimiter: \Zeilenende\Neue Zeile
    % Die Funktion AsciiFile2Text braucht als Input den Dateipfad und einen
    % Delimiter. 
    assignin('base','M',M)
    assignin('base','Diffractometer',Diffractometer)
%% (* File und Scan Header *)
    %Ermitteln der File und Scan Header
    Index_FileHeader = Tools.StringOperations.SearchString(M,'#C'); % 2. Index Ende FileHeader
    Index_ScanHeaderStart = Tools.StringOperations.SearchString(M,'#S');
    Index_ScanHeaderEnd = Tools.StringOperations.SearchString(M,'@A');
%% (* Counts und Indizies *)
    %Ermitteln der Scanindizies anhand des #S Literals
    Index_Scan = Tools.StringOperations.SearchString(M,Diffractometer.ImportLiterals.ScanName);
%     Index_Scan = Tools.StringOperations.SearchString(M,'#S');
    %Ermitteln der Anzahl der Scans
    Count_Scans = size(Index_Scan,1);
    %Indizies der Leerzeilen
    Index_BlankLines = Tools.StringOperations.SearchBlankLines(M);
    if ~isempty(Index_BlankLines)
        %--> Imaginäre Leerzeile am Ende des SpecFiles anfügen
        if Index_BlankLines(end) ~= size(M,1)
            Index_BlankLines(end+1) = size(M,1) + 1;
        end
    end
%% (* Finden der allgemeinen Eigenschaften (Header) *)
% Index_tmp wird in der Folge für das Auslesen sämtlicher Eigenschaften
% benutzt
% + Messserie bzw. Dateiname (#F)
%     if size(Index_FileHeader,1) ~= 1
        Index_tmp = Tools.StringOperations.SearchString(M(1:Index_Scan(1,1)-2,:),Diffractometer.ImportLiterals.FileName);
%     else
%         Index_tmp = Tools.StringOperations.SearchString(M(1:Index_FileHeader(1,1),:),Diffractometer.ImportLiterals.FileName);
%     end
    if ~isempty(Index_tmp)
        MeasurementSeries = sscanf(M(Index_tmp(1),:),Diffractometer.ImportLiterals.FormatFileName);
    else
        MeasurementSeries = get(h.selectfilenameRV,'string');
    end 

    % Scans
    % Prealloc
    Scans = cell(Count_Scans,1);
    %--> Ein Scan geht von seinem Startpunkt aus bis zur nächsten Leerzeile
    for i_c = 1:Count_Scans
        if Diffractometer.CheckSPECformat == 1
            %Index der kommenden Leerzeilen > als Index des Scans
            Index_NextBlankLine = find(Index_BlankLines > Index_Scan(i_c),...
                1,'first');
            %Kleinstes Intervall ist der Scan
            Scans{i_c} = M(Index_Scan(i_c):Index_BlankLines(...
                Index_NextBlankLine)-1,:);
        else
            if i_c == Count_Scans
                Scans{i_c} = M(Index_Scan(i_c):end,:);
            else
                Index_BlankLinePrior = find(Index_BlankLines < Index_Scan(i_c+1),1,'last');
                %Kleinstes Intervall ist der Scan
                Scans{i_c} = M(Index_Scan(i_c):Index_BlankLines(Index_BlankLinePrior)-1,:);
            end
        end
    end
%     assignin('base','Scans',Scans)
    
    if Diffractometer.CheckSPECformat == 1
        % + Einlesen alle eingetragenen Motornamen (#O)
        Index_tmp = Tools.StringOperations.SearchString(M(1:Index_Scan(1,1)-2,:),Diffractometer.ImportLiterals.MotorNames);
%         Index_tmp = Tools.StringOperations.SearchString(M(1:Index_FileHeader(2,1),:),Diffractometer.ImportLiterals.MotorNames);
        %Prealloc, jede Zeile enthält die Motornamen
        MotorNames = cell(size(Index_tmp,1),1);
        %--> Scannen aller Zeilen
        for i_c = 1:size(Index_tmp,1)
            MotorNames{i_c} = Tools.StringOperations.ScanWords(...
                M(Index_tmp(i_c),4:end));
        end
        
        % Phi-Winkel
        Index_tmp = Tools.StringOperations.SearchString(M,Diffractometer.ImportLiterals.PhiStressInternal);
        Index_tmpPhi = Index_tmp;

        if size(Index_tmp,1) == 0
%             phiP = zeros(Count_Scans,1)';
            Index_tmp1 = Tools.StringOperations.SearchString(M,'#P0');
            for j_c = 1:size(Index_tmp1,1)
                phiP(j_c) = sscanf(M(Index_tmp1(j_c),:),'%*s %*f %*f %*f %f %*f %*f %*f %*f');
            end
        else
            for j_c = 1:size(Index_tmp,1)
                phiP(j_c) = sscanf(M(Index_tmp(j_c),:),[Diffractometer.ImportLiterals.PhiStressInternal, ' %f']);
            end
        end
        
        if strcmp(Diffractometer.Name,'ETA3000')
            % PhiStrich-Winkel ETA
            Index_tmp1 = Tools.StringOperations.SearchString(M,'#P1');
            for j_c = 1:size(Index_tmp1,1)
                phiS(j_c) = abs(sscanf(M(Index_tmp1(j_c),:),'%*s %f %*f %*f'));
            end
            
            if size(unique(phiP,'stable'),2) == 1 && size(unique(phiS,'stable'),2) ~= 1
                phiP_ETA = phiP;
                phiP = phiS;
                VarChangePhi = 1;
            else
                VarChangePhi = 0;
            end

        
        end
        % Psi-Winkel
        Index_tmp = Tools.StringOperations.SearchString(M,Diffractometer.ImportLiterals.PsiStressInternal);
        if size(Index_tmp,1) == 0
%             psiP = zeros(Count_Scans,1)';
            Index_tmp1 = Tools.StringOperations.SearchString(M,'#P0');
            for j_c = 1:size(Index_tmp1,1)
                psiP(j_c) = sscanf(M(Index_tmp1(j_c),:),'%*s %*f %*f %f %*f %*f %*f %*f %*f');
            end
        else
            for j_c = 1:size(Index_tmp,1)
                psiP(j_c) = sscanf(M(Index_tmp(j_c),:),[Diffractometer.ImportLiterals.PsiStressInternal, ' %f']);
            end
        end

        % Eta-Winkel
        Index_tmp = Tools.StringOperations.SearchString(M,Diffractometer.ImportLiterals.EtaStressInternal);
        if size(Index_tmp,1) == 0
            etaP = 90*ones(Count_Scans,1)'; 
        else
            for j_c = 1:size(Index_tmp,1)
                etaP(j_c) = sscanf(M(Index_tmp(j_c),:),[Diffractometer.ImportLiterals.EtaStressInternal, ' %f']);
            end
        end
    end
    
% assignin('base','M',M)
% assignin('base','psiP',psiP)
% assignin('base','phiP',phiP)
% assignin('base','phiS',phiS)
% assignin('base','phiP_ETA',phiP_ETA)
% assignin('base','etaP',etaP)
% assignin('base','Scans',Scans)

    % Read phi and psi angles and scans. Sort scans according to phi angle
    % and than according to psi angle 
    if Diffractometer.CheckSPECformat == 1
        if all(etaP==90) || all(etaP==0)       
            % Finde Index von psi = 0 (b)
            [~,b] = find(psiP==0);
            % Finde gemessene phi winkel
            phiwinkelcount = unique(phiP);
            if length(phiwinkelcount) <= 4 && length(phiwinkelcount) > 1
            % Finde phi winkel, bei dem es kein psi = 0 gibt
            phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phiP(b)));
            % Fehlende psi Messungen kopieren und einsetzen
            psiP_tmp = psiP;
            phiP_tmp = phiP;
            etaP_tmp = etaP;
            Scans_tmp = Scans;
            for k = 1:length(phimissingpsi)
                % Füge die fehlenden psi = 0 winkel dazu
                psiP_tmp(length(phiP)+k) = 0;
                % Füge entsprechendes phi mit fehlendem psi dazu
                phiP_tmp(length(phiP)+k) = phimissingpsi(k);
                % Füge eta winkel dazu
                etaP_tmp(length(phiP)+k) = 90;
                % Kopiere entsprechende scans mit fehlenden psi
                Scans_tmp{length(phiP)+k} = Scans{b(k)};
            end
            psiP = psiP_tmp;
            phiP = phiP_tmp;
            etaP = etaP_tmp;
            if strcmp(Diffractometer.Name,'ETA3000')
                if phimissingpsi == 180
%                     assignin('base','Scans_tmp',Scans_tmp)
                    ScanNew = strrep(Scans_tmp{end}(10,:),'#P1 0','#P1 -180');
                    Pos = sscanf(Scans_tmp{end}(10,:),'%*s %*f %*f %f');
                    PosStr = num2str(Pos);
                    ScanNew = strrep(ScanNew,[PosStr,'   '],PosStr);
                    Scans_tmp{end}(10,:) = ScanNew;
                elseif phimissingpsi == 0
                    ScanNew = strrep(Scans_tmp{end}(10,:),'#P1 -180','#P1 0');
                    Pos = sscanf(Scans_tmp{end}(10,:),'%*s %*f %*f %f');
                    PosStr = num2str(Pos);
                    ScanNew = strrep(ScanNew,PosStr,[PosStr,'   ']);
                    Scans_tmp{end}(10,:) = ScanNew;
                end
            end
            Scans = Scans_tmp;
            end
        else
            % If eta mode ist used, 2theta angle has to be defined by the user
            prompt = {'Enter a value of 2\theta (in degrees)'};
            dlgtitle = '2Theta Value';
            definput = {'16'};
            opts.Interpreter = 'tex';
            twothetauser = inputdlg(prompt,dlgtitle,[1 40],definput,opts);
        end
% 
%         assignin('base','psiP1',psiP)
%         assignin('base','phiP',phiP)
%         assignin('base','etaP',etaP)
%         assignin('base','Scans',Scans)

        % Create table consisting of phi and psi angles and scans
        Tabletmp = [num2cell(phiP)' num2cell(psiP)' num2cell(etaP)' Scans];
%         assignin('base','Tabletmp',Tabletmp)
        % Sort table according to phi angles, except if texture measurements
        % were conducted.
        if length(unique(phiP)) > 4
            Tabletmp = sortrows(Tabletmp,2);
            % Extract phiP
            phiP = cell2mat(Tabletmp(:,1)');

            % Get unique phi angles
            phiIndex = unique(phiP, 'stable');
            Scans = Tabletmp(:,4);
            % Extract phiP
            phiPneu = cell2mat(Tabletmp(:,1));
            psiPneu = cell2mat(Tabletmp(:,2));
            etaneu = cell2mat(Tabletmp(:,3));

%             phiPneu1 = cell2mat(Tabletmp(:,1)');
%             psiPneu1 = cell2mat(Tabletmp(:,2)');
%             etaneu1 = cell2mat(Tabletmp(:,3)');

%             psiPrepmat = repmat(psiPneu1,2,1)';
%             phiPrepmat = repmat(phiPneu1,2,1)';
%             etaPrepmat = repmat(etaneu1,2,1)';
%             % psiPrepmat sortieren
%             psiPneu = reshape(psiPrepmat',1,[]);
%             phiPneu = reshape(phiPrepmat',1,[]);
%             etaneu = reshape(etaPrepmat',1,[]);

        else
            Tabletmp = sortrows(Tabletmp,1);
            
            % Extract phiP
            phiP = cell2mat(Tabletmp(:,1)');

            % Get unique phi angles
            phiIndex = unique(phiP, 'stable');

            % Find indices of phi angles
            for i=1:length(phiIndex)
                IndexMin(i) = arrayfun(@(x) find(phiP == x,1,'first'), phiIndex(i) );
                IndexMax(i) = arrayfun(@(x) find(phiP == x,1,'last'), phiIndex(i) );
                PhiTable = [IndexMin; IndexMax]';
            end

            % Save to matrix
            sortTable = [phiIndex' PhiTable(:,1) PhiTable(:,2)];
            % Create new table where scans are sorted according to psi angles for
            % each phi angle
            if length(phiIndex) == 1
                for i = 1:length(phiIndex)
        %             Table{i} = Tabletmp;
                    Table{i} = sortrows(Tabletmp,2);
                end
            else
                for i = 1:length(phiIndex)
                    Table{i} = sortrows(Tabletmp(sortTable(i,2):sortTable(i,3),:),2);
                end
            end
            % Unnest cell array
            TableSorted = vertcat(Table{:});
%             assignin('base','TableSorted',TableSorted)
            % Create variables for psi and Scans
            psiP = cell2mat(TableSorted(:,2)');
            eta = cell2mat(TableSorted(:,3)');
            Scans = TableSorted(:,4);

            % For LEDDI: check if one or two detectors have been used for the
            % measurement -> #@MCADEV 1 for second detector
            Index_tmpNoD = Tools.StringOperations.SearchString(M(Index_ScanHeaderStart(1):Index_ScanHeaderEnd(1),:),'#@MCADEV 1');

            if isempty(Index_tmpNoD)
            % Phi-werte mit Index aus PhiTable in phiP eintragen
%             if diffractometerMode == 1 || diffractometerMode == 3 || diffractometerMode == 4
                if length(phiIndex) == 1
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3))];
                elseif length(phiIndex) == 2
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) ...
                        phiP(sortTable(2,2):sortTable(2,3))];
                elseif length(phiIndex) == 3
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                        phiP(sortTable(2,2):sortTable(2,3))...
                        phiP(sortTable(3,2):sortTable(3,3))];
                elseif length(phiIndex) == 4
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                        phiP(sortTable(2,2):sortTable(2,3))...
                        phiP(sortTable(3,2):sortTable(3,3))...
                        phiP(sortTable(4,2):sortTable(4,3))];
                else
                    phiPneu = phiP;
                end
            else
                if length(phiIndex) == 1
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3))];
                elseif length(phiIndex) == 2
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
                        phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3))];
                elseif length(phiIndex) == 3
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
                        phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3)) ...
                        phiP(sortTable(3,2):sortTable(3,3)) phiP(sortTable(3,2):sortTable(3,3))];
                elseif length(phiIndex) == 4
                    phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) phiP(sortTable(1,2):sortTable(1,3)) ...
                        phiP(sortTable(2,2):sortTable(2,3)) phiP(sortTable(2,2):sortTable(2,3)) ...
                        phiP(sortTable(3,2):sortTable(3,3)) phiP(sortTable(3,2):sortTable(3,3)) ...
                        phiP(sortTable(4,2):sortTable(4,3)) phiP(sortTable(4,2):sortTable(4,3))];
                else
                    % Anpassen
                    phiPneu = vertcat(phiP,phiP);
                    phiPneu = phiPneu(:)';
                end
            end

        %3. Psi-Winkel
            if isempty(Index_tmpNoD)
                if length(phiIndex) == 1
                    psiPneu = psiP(sortTable(1,2):sortTable(1,3));
                elseif length(phiIndex) == 2
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3))];
                elseif length(phiIndex) == 3
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3)) ...
                        psiP(sortTable(3,2):sortTable(3,3))];
                elseif length(phiIndex) == 4
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3)) ...
                        psiP(sortTable(3,2):sortTable(3,3)) ...
                        psiP(sortTable(4,2):sortTable(4,3))];
                else
                    psiPneu = psiP;
                end    
            else
                % psiP entsprechend der Laenge von phiIndex erweitern
                psiPrepmat = repmat(psiP,2,1)';
                % psiPrepmat sortieren
                psiPneu = reshape(psiPrepmat',1,[]);
            end
            
         %4. Eta-Winkel
            if isempty(Index_tmpNoD)
                if length(phiIndex) == 1
                        etaneu = eta(sortTable(1,2):sortTable(1,3));
                    elseif length(phiIndex) == 2
                        etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                            eta(sortTable(2,2):sortTable(2,3))];
                    elseif length(phiIndex) == 3
                        etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                            eta(sortTable(2,2):sortTable(2,3)) ...
                            eta(sortTable(3,2):sortTable(3,3))];
                elseif length(phiIndex) == 4
                        etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                            eta(sortTable(2,2):sortTable(2,3)) ...
                            eta(sortTable(3,2):sortTable(3,3)) ...
                            eta(sortTable(4,2):sortTable(4,3))];
                else
                    etaneu = eta;
                end    
            else
                % psiP entsprechend der Laenge von phiIndex erweitern
                etarepmat = repmat(eta,2,1)';
                % psiPrepmat sortieren
                etaneu = reshape(etarepmat',1,[]);
            end
        end

%     assignin('base','psiPneu',psiPneu)
%     assignin('base','phiPneu',phiPneu)
%     assignin('base','etaneu',etaneu)
    %% (* Extrahieren der einzelnen Scans *)
    % assignin('base','sortTable',sortTable)
        if length(phiIndex) == 2
           Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)}}';
        elseif length(phiIndex) == 3
            Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
            Scans{sortTable(3,2):sortTable(3,3)}}';
        elseif length(phiIndex) == 4
            Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
            Scans{sortTable(3,2):sortTable(3,3)} Scans{sortTable(4,2):sortTable(4,3)}}';
        end
        Count_Scans = size(Scans,1);
    else
        % Find motor literal for phi
        IndphiLit = find(strcmp(Diffractometer.ImportLiterals.MotorNames,Diffractometer.VirtualMotors.phi));
        phiLit = Diffractometer.ImportLiterals.Motorvalues(IndphiLit);

        IndpsiLit = find(strcmp(Diffractometer.ImportLiterals.MotorNames,Diffractometer.VirtualMotors.psi));
        psiLit = Diffractometer.ImportLiterals.Motorvalues(IndpsiLit);

        % Search Scans for phi and psi
        for m_c = 1:size(Scans,1)
            Index_phitmp = Tools.StringOperations.SearchString(Scans{m_c},phiLit{1});
            phitmp(m_c,:) = extractNumFromStr(Scans{m_c}(Index_phitmp(1),Index_phitmp(2):end));
            Index_psitmp = Tools.StringOperations.SearchString(Scans{m_c},psiLit{1});
            psitmp(m_c,:) = extractNumFromStr(Scans{m_c}(Index_psitmp(1),Index_psitmp(2):end));
        end
        % Get results from first column and set eta angle
        phiload = phitmp(:,1)';
        psiload = psitmp(:,1)';
        etaload = 90*ones(size(phitmp,1),1)';

        % Get number of phi angles
        [phiVal, phiInd] = unique(phiload);

        % Check if all psi are positive and only one phi angle exists
        if ~all(psiload >= 0) && length(phiVal) == 1
            % Find indices of negative psi values
            IndpsiNeg = find(psiload < 0);
            % Set corresponding phi angle
            if phiVal(1) == 0
                phiload(IndpsiNeg) = 180;
            elseif phiVal(1) == 180
                phiload(IndpsiNeg) = 0;
            elseif phiVal(1) == 90
                phiload(IndpsiNeg) = 270;
            elseif phiVal(1) == 270
                phiload(IndpsiNeg) = 90;    
            end
            % Set all psi positive
            psiload = abs(psiload);
        elseif ~all(psiload >= 0) && length(phiVal) == 2
            IndpsiNeg = find(psiload < 0);
            % Find negative psi for each phival
            IndpsiNegPhi1 = find(phiload(IndpsiNeg) == phiVal(1));
            IndpsiNegPhi2 = find(phiload(IndpsiNeg) == phiVal(2));
            if phiload(IndpsiNeg(IndpsiNegPhi1)) == 0
                phiload(IndpsiNeg(IndpsiNegPhi1)) = 180;
            elseif phiload(IndpsiNeg(IndpsiNegPhi1)) == 180
                phiload(IndpsiNeg(IndpsiNegPhi1)) = 0;
            elseif phiload(IndpsiNeg(IndpsiNegPhi1)) == 90
                phiload(IndpsiNeg(IndpsiNegPhi1)) = 270;
            elseif phiload(IndpsiNeg(IndpsiNegPhi1)) == 270
                phiload(IndpsiNeg(IndpsiNegPhi1)) = 90;    
            end

            if phiload(IndpsiNeg(IndpsiNegPhi2)) == 0
                phiload(IndpsiNeg(IndpsiNegPhi2)) = 180;
            elseif phiload(IndpsiNeg(IndpsiNegPhi2)) == 180
                phiload(IndpsiNeg(IndpsiNegPhi2)) = 0;
            elseif phiload(IndpsiNeg(IndpsiNegPhi2)) == 90
                phiload(IndpsiNeg(IndpsiNegPhi2)) = 270;
            elseif phiload(IndpsiNeg(IndpsiNegPhi2)) == 270
                phiload(IndpsiNeg(IndpsiNegPhi2)) = 90;    
            end
            psiload = abs(psiload);
        end

        % Check for missing psi = 0° scan
        % Finde Index von psi = 0 (b)
        [~,b] = find(psiload==0);
        % Finde gemessene phi winkel
        phiwinkelcount = unique(phiload);
        if length(b) ~= length(phiwinkelcount)
            % Finde phi winkel, bei dem es kein psi = 0 gibt
            phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phiload(b)));
            % Fehlende psi Messungen kopieren und einsetzen
            psiP_tmp = psiload;
            phiP_tmp = phiload;
            etaP_tmp = etaload;
            Scans_tmp = Scans;

            for k = 1:length(phimissingpsi)
                % Füge die fehlenden psi = 0 winkel dazu
                psiP_tmp(length(phiload)+k) = 0;
                % Füge entsprechendes phi mit fehlendem psi dazu
                phiP_tmp(length(phiload)+k) = phimissingpsi(k);
                % Füge eta winkel dazu
                etaP_tmp(length(phiload)+k) = 90;
                % Kopiere entsprechenden scan mit fehlenden psi
                Scans_tmp{length(phiload)+k} = Scans{b(k)};
            end
        else
            psiP_tmp = psiload;
            phiP_tmp = phiload;
            etaP_tmp = etaload;
            Scans_tmp = Scans;
        end
%         assignin('base','psiload',psiload)
%         assignin('base','phiload',phiload)
%         assignin('base','etaload',etaload)
%         assignin('base','Scans',Scans)
        % Create table
        Tabletmp = [num2cell(phiP_tmp)' num2cell(psiP_tmp)' num2cell(etaP_tmp)' Scans_tmp];
        % Sort rows according to phi angles
        Tabletmp = sortrows(Tabletmp,1);
        % Find different number of phi angles
        phiP = cell2mat(Tabletmp(:,1)');
        phiIndex = unique(phiP, 'stable');
        % Find indices of phi angles
        for i=1:length(phiIndex)
            IndexMin(i) = arrayfun(@(x) find(phiP == x,1,'first'), phiIndex(i) );
            IndexMax(i) = arrayfun(@(x) find(phiP == x,1,'last'), phiIndex(i) );
            PhiTable = [IndexMin; IndexMax]';
        end
        % Table for sorting psi angles of each phi angle
        sortTable = [phiIndex' PhiTable(:,1) PhiTable(:,2)];
        for i = 1:length(phiIndex)
            Table{i} = sortrows(Tabletmp(sortTable(i,2):sortTable(i,3),:),2);
        end
        % Reshape Sorted table
        TableSorted = vertcat(Table{:});
%         assignin('base','TableSorted',TableSorted)
        % Create variables for psi and Scans
        psiP = cell2mat(TableSorted(:,2)');
        etaP = cell2mat(TableSorted(:,3)');
        Scans = TableSorted(:,4);

        if length(phiIndex) == 1
            phiPneu = [phiP(sortTable(1,2):sortTable(1,3))];
        elseif length(phiIndex) == 2
            phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) ...
                phiP(sortTable(2,2):sortTable(2,3))];
        elseif length(phiIndex) == 3
            phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                phiP(sortTable(2,2):sortTable(2,3))...
                phiP(sortTable(3,2):sortTable(3,3))];
        elseif length(phiIndex) == 4
            phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                phiP(sortTable(2,2):sortTable(2,3))...
                phiP(sortTable(3,2):sortTable(3,3))...
                phiP(sortTable(4,2):sortTable(4,3))];
        else
            phiPneu = phiP;
        end

        if length(phiIndex) == 1
            psiPneu = psiP(sortTable(1,2):sortTable(1,3));
        elseif length(phiIndex) == 2
            psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                psiP(sortTable(2,2):sortTable(2,3))];
        elseif length(phiIndex) == 3
            psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                psiP(sortTable(2,2):sortTable(2,3)) ...
                psiP(sortTable(3,2):sortTable(3,3))];
        elseif length(phiIndex) == 4
            psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                psiP(sortTable(2,2):sortTable(2,3)) ...
                psiP(sortTable(3,2):sortTable(3,3)) ...
                psiP(sortTable(4,2):sortTable(4,3))];
        else
            psiPneu = psiP;
        end

        if length(phiIndex) == 1
                etaneu = etaP(sortTable(1,2):sortTable(1,3));
            elseif length(phiIndex) == 2
                etaneu = [etaP(sortTable(1,2):sortTable(1,3)) ...
                    etaP(sortTable(2,2):sortTable(2,3))];
            elseif length(phiIndex) == 3
                etaneu = [etaP(sortTable(1,2):sortTable(1,3)) ...
                    etaP(sortTable(2,2):sortTable(2,3)) ...
                    etaP(sortTable(3,2):sortTable(3,3))];
        elseif length(phiIndex) == 4
                etaneu = [etaP(sortTable(1,2):sortTable(1,3)) ...
                    etaP(sortTable(2,2):sortTable(2,3)) ...
                    etaP(sortTable(3,2):sortTable(3,3)) ...
                    etaP(sortTable(4,2):sortTable(4,3))];
        else
            etaneu = etaP;
        end

        if length(phiIndex) == 2
           Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)}}';
        elseif length(phiIndex) == 3
            Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
            Scans{sortTable(3,2):sortTable(3,3)}}';
        elseif length(phiIndex) == 4
            Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
            Scans{sortTable(3,2):sortTable(3,3)} Scans{sortTable(4,2):sortTable(4,3)}}';
        end
        Count_Scans = size(Scans,1);
    end
% assignin('base','psiP1',psiP)
% assignin('base','phiP1',phiP)
% assignin('base','etaP1',etaP)
assignin('base','Scans1',Scans)
%% (* Scananalyse *)
%--------------------------------------------------------------------------
    function obj = AnalyzeMcaacqScanNeu(Scan, Diffractometer)
        
    %% (* Instanzen und allgemeine Eigenschaften *)
        %Prealloc
        obj = Measurement.Measurement();
    % + Name mit Hilfe der Scannummer in der 1. Zeile (#S)
        obj.Name = ['Scan ' num2str(sscanf(Scan(1,:),[Diffractometer.ImportLiterals.ScanName '%d']))];
        if Diffractometer.CheckSPECformat == 1
            %% (* Einlesen der Zeiten *)
            % + Zeitpunkt (#D)
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.Date);
                %Einlesen der Bestandteile
                Time_tmp = Tools.StringOperations.ScanWords(...
                    strtrim(Scan(Index_tmp(1),4:end)));
                %Datums-Vektor erzeugen
                obj.Time = datevec([Time_tmp{3},'-',Time_tmp{2},'-',Time_tmp{5},...
                    ' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS');
%                 assignin('base','Diffractometer',Diffractometer)
            % + Real- und DeadTime (#@CTIME)
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.Times);
%                 obj.RealTime = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.Times '%f %*f %*f']);
                if strcmp(Diffractometer.Name,'LEDDI_KETEK_new_format') || strcmp(Diffractometer.Name,'LEDDI_KETEK')
                   obj.RealTime = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.Times '%f %*f %*f']) + 0.5;
                elseif strcmp(Diffractometer.Name,'ETA3000')
                    obj.RealTime = 1;
                else
                    obj.RealTime = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.Times '%f %*f %*f']);
                end
                %Aus der LiveTime berechnen
                if strcmp(Diffractometer.Name,'ETA3000')
                    obj.DeadTime = 1;
                else
                    obj.DeadTime = (1 - sscanf(Scan(Index_tmp(1),:),...
                        [Diffractometer.ImportLiterals.Times '%*f %f %*f']) / obj.RealTime) * 100;
                end

            %% (* Einlesen der Rahmenbedingungen *)
            % + Ringstrom (#@RC)
                if strcmp(Diffractometer.Name,'ETA3000')
                    obj.RingCurrent = 0;
                else
                    Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.RingCurrent);
                    obj.RingCurrent = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.RingCurrent '%f']);
                end
            % + Temperaturen (#@TEMP)
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.Temp);
                if strcmp(Diffractometer.Name,'ETA3000')
                    obj.HeatRate = 0;
                    obj.Temperatures = 0;
                else
                    obj.HeatRate = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.Temp '%*f %*f %f']);
                    obj.Temperatures = sscanf(Scan(Index_tmp(1),:),...
                        [Diffractometer.ImportLiterals.Temp '%f %f %*f'])';
                end
             % + Anode (#@HV_ANODE) + Scan Mode of Mythen Detector
                if strcmp(Diffractometer.Name,'ETA3000')
                    Index_tmp = Tools.StringOperations.SearchString(Scan,'#HV_ANODE');
                    obj.Anode = sscanf(Scan(Index_tmp(1),:),'#HV_ANODE %s');
                    Index_tmp = Tools.StringOperations.SearchString(Scan,'#@MYTHEN2_MEASMODE');
                    obj.MythenScanMode = sscanf(Scan(Index_tmp(1),:),'#@MYTHEN2_MEASMODE %d');
                end

            %% (* Einlesen der Winkel und Positionen *)
            % + Motoren (#P)
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.MotorValues);
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
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.Channels);
                Channel_tmp = sscanf(Scan(Index_tmp(1),:),[Diffractometer.ImportLiterals.Channels '%d %d']);
                %Range bestimmen
                obj.ChannelRange = [Channel_tmp(2),...
                    Channel_tmp(2)+Channel_tmp(1)-1];
            % + Intensitäten (@A)
                Index_tmp = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.Intensities);
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
%                 assignin('base','Intensities_tmp',Intensities_tmp)
%                 assignin('base','obj',obj)
%                 if strcmp(Diffractometer.Name,'ETA3000')
%           
% %                     assignin('base','twothetatmp',twothetatmp)
%                     obj.EDSpectrum = [(0:639,Intensities_tmp];
%                 else
                    % Calculate DT correction using user selected function
                 if strcmp(Diffractometer.Name,'ETA3000')
                     % Create vector with channel numbers 
                    Angles_tmp = obj.ChannelRange(1):obj.ChannelRange(2);
                    % Create EDSpectrum
                    obj.EDSpectrum = [Angles_tmp',Intensities_tmp];
                 else
                    CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
                    if CalibParams.a(2:end) == 0
                        CalibParamstmp = [CalibParams.c(1);CalibParams.b(1);CalibParams.a(1)];
                    else
                        CalibParam_a = CalibParams.a(1) + exp(CalibParams.a(2)*(CalibParams.a(3) + obj.DeadTime)) - (CalibParams.a(4)/(CalibParams.a(5)+obj.DeadTime));
                        CalibParam_b = CalibParams.b(1) + CalibParams.b(2)*obj.DeadTime + CalibParams.b(3)*obj.DeadTime.^2;
                        CalibParam_c = CalibParams.c(1) + CalibParams.c(2)*obj.DeadTime;
        
                        CalibParamstmp = [CalibParam_c;CalibParam_b;CalibParam_a];
                    end
                    Energies_tmp = polyval(...
                        CalibParamstmp,...
                        obj.ChannelRange(1):obj.ChannelRange(1)...
                        +length(Intensities_tmp)-1);
    %                 Energies_tmp = obj.ChannelRange(1):obj.ChannelRange(2);
                % + Energiedispersives Spektrum
                    obj.EDSpectrum = [Energies_tmp',Intensities_tmp];
                 end
        else
            %% (* Einlesen der Winkel und Positionen *)
            % + Motoren (User defined literals)
            MotorNamesUser = Diffractometer.ImportLiterals.MotorNames;
            MotorLiterals = Diffractometer.ImportLiterals.Motorvalues;
            %--> Durchlaufen aller Zeilen
            for m_c = 1:size(MotorLiterals,1)
                Index_Literals(m_c,:) = Tools.StringOperations.SearchString(Scan,MotorLiterals{m_c});
            end
            % Extrahiere Motorpositionen aus Scan    
            for n_c = 1:length(Index_Literals)
                Positions(n_c,:) = extractNumFromStr(Scan(Index_Literals(n_c,1),Index_Literals(n_c,2):end));
            end
            %--> Erstellen und Zuweisen der Motorobjekte
            for k_c = 1:length(Index_Literals)
                obj.Motors_all.(MotorNamesUser{k_c}) = Positions(k_c,1);
            end
            
            % + Channelrange (ChannelStart - ChannelEnd)
            ChannelStart = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.ChannelStart);
            ChannelEnd = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.ChannelEnd);    
            ChannelStart_tmp = extractNumFromStr(Scan(ChannelStart(1),ChannelStart(2):end));
            ChannelEnd_tmp = extractNumFromStr(Scan(ChannelEnd(1),ChannelEnd(2):end));
            %Range bestimmen
            obj.ChannelRange = [ChannelStart_tmp(1), ChannelEnd_tmp(1)];
%             assignin('base','Channel',[ChannelStart_tmp(1), ChannelEnd_tmp(1)])
            % + Intensitäten (X,Y data)
            % Letzte Zeile des Scanheaders finden (Literal muss übergeben werden)
            Index_LastLineSH = Tools.StringOperations.SearchString(Scan,Diffractometer.ImportLiterals.LastLineSH);
            % Export meas data from scan (X,Y data)
            for l_c = 1:size(Scan,1)-Index_LastLineSH(1)
                MeasData(l_c,:) = sscanf(Scan(l_c+Index_LastLineSH(1),:),'%f');
            end
            
            if strcmp(Diffractometer.Name,'ETA')
                % Get information about which anode was used
%                 Index_Anode = Tools.StringOperations.SearchString(M,Diffractometer.ImportLiterals.Anode);
%                 obj.Anode = sscanf(M(Index_Anode(1),:),[Diffractometer.ImportLiterals.Anode, ' %s']);
                Angles_tmp = obj.ChannelRange(1):obj.ChannelRange(2);
%                 assignin('base','Angles_tmp',Angles_tmp)
%                 assignin('base','MeasData',MeasData)
                % + Energiedispersives Spektrum
                obj.EDSpectrum = [Angles_tmp, MeasData(:,2)];
            else
    %             assignin('base','MeasData',MeasData)
                % Calculate DT correction using user selected function
                CalibParams_tmp = load(fullfile('Data','Calibration',[calib,'.mat']));
                CalibParam_a = CalibParams_tmp.a(1);
                CalibParam_b = CalibParams_tmp.b(1);
                CalibParam_c = CalibParams_tmp.c(1);
    
                CalibParams = [CalibParam_c;CalibParam_b;CalibParam_a];
                
                Energies_tmp = polyval(CalibParams,obj.ChannelRange(1):obj.ChannelRange(2));
            
                % + Energiedispersives Spektrum
                obj.EDSpectrum = [Energies_tmp', MeasData(:,2)];
            end
%             assignin('base','obj',obj)
        end
    end

%% ------------------------------------------------------------------------
    % Diese Nested-Funktion erzeugt aus einem Ascan-Scan ein Messobjekt. 
    % Zunächst werden Eigenschaften eingelesen, die für alle Objekte gleich
    % sind und dann die Scan-Veränderlichen.
   
    function obj = AnalyzeAScan(Scan, Diffractometer)
    %% (* Anzahl und Index der AScans *)

        Index_AScan = Tools.StringOperations.SearchString(Scan,'@A');
        Count_AScans = size(Index_AScan,1);
        
        CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
        
        Index_ScanHeaderStart = Tools.StringOperations.SearchString(Scan,'#S');
        Index_ScanHeaderEnd = Tools.StringOperations.SearchString(Scan,'@A');
        

    %% (* Instanzen und allgemeine Eigenschaften *)
        %--> Prealloc der Messobjekte
        obj = Measurement.Measurement.CloneConstruction(...
            @Measurement.Measurement,[1,Count_AScans]);
    % + Name (#S), wird später ergänzt
        set(obj,'Name',['AScan ', ...
            num2str(sscanf(Scan(1,:),'#S %d'))])
    %2. Scan-Veränderliche (#L)
        Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#L');
        AScanVariablesNames = Tools.StringOperations.ScanWords(...
            Scan(Index_tmp(1),4:end));
%         if strcmp(Diffractometer.Name,'ETA3000')
%             AScanVariables = sscanf(Scan(Index_tmp(1)+1,:),'%f');
%             AScanVariables(7)
%             obj(j_c).CountingTime = AScanVariables(7);
%         end  

    %% (* Einlesen der Zeiten *)
    %1. Zeitpunkt (#D)

        Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#D');
        %Einlesen der Bestandteile
        Time_tmp = Tools.StringOperations.ScanWords(...
            strtrim(Scan(Index_tmp(1),4:end)));
        %Datums-Vektor erzeugen
        set(obj(:),'Time',datevec([Time_tmp{3},'-',Time_tmp{2},'-',...
            Time_tmp{5},' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS'))
        
    %% (* Einlesen der Rahmenbedingungen *)
    %1. Temperaturen (#@TEMP)
        Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#@TEMP');
        if strcmp(Diffractometer.Name,'ETA3000')
            [obj(:).HeatRate] = deal(0);
        else
            [obj(:).HeatRate] = deal(sscanf(Scan(Index_tmp(1),:),...
                '#@TEMP %*f %*f %f'));
        end
  
    %% (* Einlesen der Winkel und Positionen *)
    %1. Motoren (#P)
        Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#P');
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
    
        Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#@CHANN');
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
                Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#HV_ANODE');
                obj(j_c).Anode = sscanf(Scan(Index_tmp(1),:),'#HV_ANODE %s');
                Index_tmp = Tools.StringOperations.SearchString(Scan(Index_ScanHeaderStart:Index_ScanHeaderEnd,:),'#@MYTHEN2_MEASMODE');
                obj(j_c).MythenScanMode = sscanf(Scan(Index_tmp(1),:),'#@MYTHEN2_MEASMODE %d');
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

% %% ------------------------------------------------------------------------
%     % Diese Nested-Funktion erzeugt aus einem Ascan-Scan ein Messobjekt. 
%     % Zunächst werden Eigenschaften eingelesen, die für alle Objekte gleich
%     % sind und dann die Scan-Veränderlichen.
%     function obj = AnalyzeAScan(Scan)
%         
%     %% (* Anzahl und Index der AScans *)
%         Index_AScan = Tools.StringOperations.SearchString(Scan,'@A');
%         Count_AScans = size(Index_AScan,1);
%         
%         CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
%         
%     %% (* Instanzen und allgemeine Eigenschaften *)
%         %--> Prealloc der Messobjekte
%         obj = Measurement.Measurement.CloneConstruction(...
%             @Measurement.Measurement,[1,Count_AScans]);
%     % + Name (#S), wird später ergänzt
%         set(obj,'Name',['AScan ', ...
%             num2str(sscanf(Scan(1,:),'#S %d'))]);
%     %2. Scan-Veränderliche (#L)
%         Index_tmp = Tools.StringOperations.SearchString(Scan,'#L');
%         AScanVariablesNames = Tools.StringOperations.ScanWords(...
%             Scan(Index_tmp(1),4:end));
%         
%     %% (* Einlesen der Zeiten *)
%     %1. Zeitpunkt (#D)
%         Index_tmp = Tools.StringOperations.SearchString(Scan,'#D');
%         %Einlesen der Bestandteile
%         Time_tmp = Tools.StringOperations.ScanWords(...
%             strtrim(Scan(Index_tmp(1),4:end)));
%         %Datums-Vektor erzeugen
%         set(obj(:),'Time',datevec([Time_tmp{3},'-',Time_tmp{2},'-',...
%             Time_tmp{5},' ',Time_tmp{4}],'dd-mmm-yyyy HH:MM:SS'))
%         
%     %% (* Einlesen der Rahmenbedingungen *)
%     %1. Temperaturen (#@TEMP)
%         Index_tmp = Tools.StringOperations.SearchString(Scan,'#@TEMP');
%         [obj(:).HeatRate] = deal(sscanf(Scan(Index_tmp(1),:),...
%             '#@TEMP %*f %*f %f'));
%         
%     %% (* Einlesen der Winkel und Positionen *)
%     %1. Motoren (#P)
%         Index_tmp = Tools.StringOperations.SearchString(Scan,'#P');
%         %--> Durchlaufen aller Zeilen
%         for j_c = 1:size(Index_tmp,1)
%             %Formatierungsstring erstellen, um die zugehörigen Positionen
%             %auszulesen
%             Format = repmat('%f ',size(MotorNames{j_c},1));
%             %Auslesen der Positionen
%             Positions = sscanf(Scan(Index_tmp(j_c),4:end),Format);
%             %--> Erstellen der Motorstruktur und zwischenspeichern
%             for k_c = 1:size(MotorNames{j_c},2)
%                 Motors_all.(MotorNames{j_c}{k_c}) = Positions(k_c);
%             end
%         end       
%         
%     %% (* Einlesen der Messdaten *)
%     %1. Channelrange (#@CHANN)
%         Index_tmp = Tools.StringOperations.SearchString(Scan,'#@CHANN');
%         Channel_tmp = sscanf(Scan(Index_tmp(1),:),'#@CHANN %d %d');
%         %Range bestimmen
%         [obj(:).ChannelRange] = deal([Channel_tmp(2)...
%             Channel_tmp(2)+Channel_tmp(1)-1]);
%             
%     %% (* Durchlaufen der AScans *)
%         for j_c = 1:Count_AScans
%             %Motoren replizieren
%             obj(j_c).Motors_all = Motors_all;
%             
%         %% (* Einlesen der Scan-Veränderlichen *)
%             %Einlesen aller relevanten Daten aus dem AScan
%             %(2 Zeilen über dem @A)
%             AScanVariables = sscanf(Scan(Index_AScan(j_c)-1,:),'%f',inf)';
%             %Veränderlicher Motor (Hier statisch, da sonst nirgenwo steht,
%             %wie der variable Motor heißt)
%             obj(j_c).Motors_all.(AScanVariablesNames{1}) = ...
%                 AScanVariables(1);
%             %Ringstrom
%             obj(j_c).RingCurrent = AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'R_strom'),1,'first'));
%             %RealTime
%             obj(j_c).RealTime = AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'Real_1'),1,'first'));
%             %DeadTime (Aus der LiveTime berechnen)
%             obj(j_c).DeadTime = (1 - AScanVariables(...
%                 find(strcmp(AScanVariablesNames,'Live_1'),1,'first'))...
%                 / obj(j_c).RealTime) * 100;
%             %Temperaturen
% %             obj(j_c).Temperatures(1) = AScanVariables(...
% %                 find(strcmp(AScanVariablesNames,'Temp_1'),1,'first'));
% %             obj(j_c).Temperatures(2) = AScanVariables(...
% %                 find(strcmp(AScanVariablesNames,'Temp_2'),1,'first'));
%             
%         %% (* Namen anpassen *)
%             %AScan-Motor
%             obj(j_c).Name = [obj(j_c).Name , ', ',...
%                 AScanVariablesNames{1},' = ',num2str(AScanVariables(1))];
%             
%         %% (* Erstellen des ED-Spektrums *)          
%             CalibParam_a(j_c) = CalibParams.a(1) + exp(CalibParams.a(2)*(CalibParams.a(3) + obj(j_c).DeadTime)) - (CalibParams.a(4)/(CalibParams.a(5)+obj(j_c).DeadTime));
%             CalibParam_b(j_c) = CalibParams.b(1) + CalibParams.b(2)*obj(j_c).DeadTime + CalibParams.b(3)*obj(j_c).DeadTime.^2;
%             CalibParam_c(j_c) = CalibParams.c(1) + CalibParams.c(2)*obj(j_c).DeadTime;
% 
%             CalibParamstmp = [CalibParam_c(j_c);CalibParam_b(j_c);CalibParam_a(j_c)];
% 
%             %Anzahl der Zeilen in denen die Intensitäten stehen (Berechnet 
%             %aus der ChannelRange)
%             LineCount_tmp = ceil((obj(j_c).ChannelRange(2) -...
%                 obj(j_c).ChannelRange(1)) / 16);
%             %Speichern des Scans in ein CharArray
%             Intensities = Scan(...
%                 Index_AScan(j_c):Index_AScan(j_c)+LineCount_tmp-1,:);
%             %Transponieren
%             Intensities = Intensities';
%             %@A entfernen und zu einer Row machen
%             Intensities = Intensities(3:end);
%             %Backslashs entfernens
%             Intensities = strrep(Intensities,'\','');
%             %In eine double-Array verwandeln
%             Intensities = sscanf(Intensities,'%d', inf);
% 
%             Energies_tmp = polyval(...
%                 CalibParamstmp,...
%                 obj(j_c).ChannelRange(1):obj(j_c).ChannelRange(1)...
%                 +length(Intensities)-1);
% 
%             %Zuweisen des ED-Spektrums
%             obj(j_c).EDSpectrum = [Energies_tmp',Intensities];
%         end    
%     end

%% ------------------------------------------------------------------------
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
    %         obj(j_c).ChannelRange
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
            obj(1,j_c).addprop('NumberOfDetectors');
            [obj(j_c).NumberOfDetectors] = Count_LEDDIScans;
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
            LineCount_tmp = floor((obj(j_c).ChannelRange(2) -...
                    obj(j_c).ChannelRange(1)) / 16);
    %         LineCount_tmp
            Intensities = Scan(...
                    Index_LEDDIScan(j_c):Index_LEDDIScan(j_c)+LineCount_tmp,:);
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
%     obj_new = AnalyzeAScan(Scans{i_c},Diffractometer);
        ScanType = ScanMode;
        %--> Analyse entsprechen dem Scan-Typ
        if any(strcmp(ScanType,{'a/d-scan'}))
            obj_new = AnalyzeAScan(Scans{i_c},Diffractometer);
        elseif any(strcmp(ScanType,{'mcaacq','twinmcaacq','loopscan'}))
            if strcmp(Diffractometer.Name,'LEDDI_9axis_tth')
                obj_new = AnalyzeLEDDIMcaacqScan(Scans{i_c},Diffractometer);
            else
                obj_new = AnalyzeMcaacqScanNeu(Scans{i_c},Diffractometer);
            end
        else
            obj_new = [];
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
    %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
    if ~isempty(Diffractometer.SamplePositioner)
        SP_tmp = struct2cell(Diffractometer.SamplePositioner);
        SP_tmp = get([SP_tmp{:}],'Position');
        if ~iscell(SP_tmp), SP_tmp = num2cell(SP_tmp); end
    end
    %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
    if ~isempty(Diffractometer.SourcePositioner)
        SouP_tmp = struct2cell(Diffractometer.SourcePositioner);
        SouP_tmp = get([SouP_tmp{:}],'Position');
        if ~iscell(SouP_tmp), SouP_tmp = num2cell(SouP_tmp); end
    end
    %Motor-Position des Diffraktometers auslesen und ggf. korrigieren
    if ~isempty(Diffractometer.DetectorPositioner)
        DP_tmp = struct2cell(Diffractometer.DetectorPositioner);
        DP_tmp = get([DP_tmp{:}],'Position');
        if ~iscell(DP_tmp), DP_tmp = num2cell(DP_tmp); end
    end
    %Motor-Struktur erzeugen, indem die SP und DP zusammengefügt werden
    if isempty(Diffractometer.SourcePositioner) && ~isempty(Diffractometer.SamplePositioner) && ~isempty(Diffractometer.DetectorPositioner)
        Motors_tmp = cell2struct(cat(1,SP_tmp,DP_tmp),...
            cat(1,fieldnames(Diffractometer.SamplePositioner),...
            fieldnames(Diffractometer.DetectorPositioner)));
    elseif isempty(Diffractometer.SourcePositioner) && isempty(Diffractometer.DetectorPositioner) && ~isempty(Diffractometer.SamplePositioner)
        Motors_tmp = cell2struct(cat(1,SP_tmp),...
            cat(1,fieldnames(Diffractometer.SamplePositioner)));
    else
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
        end

        %% (* Winkel aus den Motoren berechnen *)
        % Muss NOCH je nach Messtyp angepasst werden. Sollte später in
        % Detector geschehen
        if strcmp(Diffractometer.Name,'ETA')
            obj(i_c).twotheta = 0;
            obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi);
            obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
            obj(i_c).SCSAngles.eta = 90;
            obj(i_c).SampleStagePos(1) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.x);
            obj(i_c).SampleStagePos(2) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.y);
            obj(i_c).SampleStagePos(3) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.z);
        else
            if isempty(Diffractometer.VirtualMotors.tth) || strcmp(Diffractometer.VirtualMotors.tth,Diffractometer.VirtualMotors.omega)
    %             if strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
                    if ~all(etaneu==90) && ~all(etaneu==0)
                        obj(i_c).twotheta = str2double(twothetauser{1});
                    else
                        obj(i_c).twotheta = 2.*abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.omega));
                    end
                    if  any(strcmp(ScanType,{'a/d-scan'})) % Check if a/d scan was conducted 
                        obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi);
                        obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
                        obj(i_c).SCSAngles.eta = 90;
                    else
                        obj(i_c).SCSAngles.psi = psiPneu(i_c);
                        obj(i_c).SCSAngles.phi = phiPneu(i_c);
                        obj(i_c).SCSAngles.eta = etaneu(i_c);
                    end
                    obj(i_c).SampleStagePos(1) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.x);
                    obj(i_c).SampleStagePos(2) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.y);
                    obj(i_c).SampleStagePos(3) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.z);
    %             else
    %                 if ~all(etaneu==90) && ~all(etaneu==0)
    %                     obj(i_c).twotheta = str2double(twothetauser{1});
    %                 else
    %                     obj(i_c).twotheta = 2.*abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.omega));
    %                 end
    % %                 obj(i_c).SCSAngles.psi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi));
    % %                 obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
    % %                 obj(i_c).SCSAngles.eta = 90;
    %                 obj(i_c).SCSAngles.psi = abs(psiPneu(i_c));
    %                 obj(i_c).SCSAngles.phi = abs(phiPneu(i_c));
    %                 obj(i_c).SCSAngles.eta = etaneu(i_c);
    %                 obj(i_c).SampleStagePos(1) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.x);
    %                 obj(i_c).SampleStagePos(2) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.y);
    %                 obj(i_c).SampleStagePos(3) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.z);
    %             end
            else
                if ~all(etaneu==90) && ~all(etaneu==0)
                    obj(i_c).twotheta = str2double(twothetauser{1});
                else
                    obj(i_c).twotheta = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.tth);
                end
    %             if strcmp(Diffractometer.Name,'EDDI_5axis_tth')
    %                 if isempty(Index_tmpPhi) % Check if psi and phi values are written separately to file
    %                     obj(i_c).SCSAngles.psi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi));
    %                     obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
    %                     obj(i_c).SCSAngles.eta = etaneu(i_c);
    %                 else
    %                     obj(i_c).SCSAngles.psi = psiPneu(i_c);
    %                     obj(i_c).SCSAngles.phi = phiPneu(i_c);
    %                     obj(i_c).SCSAngles.eta = etaneu(i_c);
    %                 end
    %             else
                    if  any(strcmp(ScanType,{'a/d-scan'})) % Check if a/d scan was conducted
                        if strcmp(Diffractometer.Name,'ETA3000')
                            obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi);
%                             obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
                            % Es muss unterschieden werden, ob um phi oder
                            % phiS gedreht wurde.   
                            if VarChangePhi == 1
                                obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.PhiS);
%                                 if obj(i_c).SCSAngles.psi == 0 && obj(i_c).SCSAngles.phi == 0
%                                     % Wenn Scan für Psi = 0 kopiert wurde,
%                                     % ersetze phiS mit dem entsprechenden
%                                     % korrekten phi winkel, bei dem psi = 0
%                                     % fehlt. --> muss noch verbessert
%                                     % werden bzw. für den allgemein
%                                     % gültigen Fall programiert werden
%                                     PsiZeroScan = 1;
%                                 else
%                                     PsiZeroScan = 0;
%                                 end
%                                 if obj(i_c).SCSAngles.psi == 0 && obj(i_c).SCSAngles.phi == 0 && PsiZeroScan == 1
%                                     obj(i_c).SCSAngles.phi = 180;
%                                     obj(i_c).Motors_all.PhiS = 180;
%                                     obj(i_c).Motors.PhiS = 180;
%                                 end

                            else
                                obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
                            end
                            obj(i_c).SCSAngles.eta = 90;
                        else
                            obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.psi);
                            obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.(Diffractometer.VirtualMotors.phi));
                            obj(i_c).SCSAngles.eta = 90;
                        end
                    else
                        obj(i_c).SCSAngles.psi = psiPneu(i_c);
                        obj(i_c).SCSAngles.phi = phiPneu(i_c);
                        obj(i_c).SCSAngles.eta = etaneu(i_c);
                    end
                
                obj(i_c).SampleStagePos(1) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.x);
                obj(i_c).SampleStagePos(2) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.y);
                obj(i_c).SampleStagePos(3) = obj(i_c).Motors_all.(Diffractometer.VirtualMotors.z);
            end
        end
    end
end