% Diese Funktion liest einen SpecFile ein und extrahiert daraus ein Vektor 
% mit den einzelen Messreihen. Eine Messungsspezifische Anpassung erfolgt
% mit Hilfe des Diffraktometers.
% Input: Filename, Dateiname (ohne Endung), string|va /
%        Diffractometer, Diffraktometer-Konfiguration mit der gemessen
%        wurde, Diffractometer|va
% Output: obj, geladene Messungen, Measurement|row
function obj = LoadFromSpecFile(Filename,Diffractometer,DiffMode,Calibration)

%% (* Stringenzprüfung *)
    validateattributes(Filename,{'char'},{'row'});
    validateattributes(Diffractometer,{'Measurement.Diffractometer'},...
        {'scalar'});
    validateattributes(DiffMode,{'double'},...
        {'real','scalar','positive','finite'});
    validateattributes(Calibration,{'char'},{'row'});

%% Einlesen des Diffraktometertyps
    diffractometerMode = DiffMode;
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
%     assignin('base','M',M)
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
    
%% (* Finden der allgemeinen Eigenschaften (Header) *)
% Index_tmp wird in der Folge für das Auslesen sämtlicher Eigenschaften
% benutzt
% + Messserie bzw. Dateiname (#F)
    Index_tmp = Tools.StringOperations.SearchString(M,'#F');
    if diffractometerMode == 4
        MeasurementSeries = sscanf(M(Index_tmp(1),:),'#F /%*[^/]/%*[^/]/%*[^/]/%[^.]');
    else
        MeasurementSeries = sscanf(M(Index_tmp(1),:),'#F %*[^/]/%*[^/]/%[^.]');
    end
    
% + Einlesen alle eingetragenen Motornamen (#O)
    Index_tmp = Tools.StringOperations.SearchString(M,'#O');
    %Prealloc, jede Zeile enthält die Motornamen
    MotorNames = cell(size(Index_tmp,1),1);
    %--> Scannen aller Zeilen
    for i_c = 1:size(Index_tmp,1)
        MotorNames{i_c} = Tools.StringOperations.ScanWords(...
            M(Index_tmp(i_c),4:end));
    end
    
    % Scans
    % Prealloc
    Scans = cell(Count_Scans,1);
    %--> Ein Scan geht von seinem Startpunkt aus bis zur nächsten Leerzeile
    for i_c = 1:Count_Scans
        %Index der kommenden Leerzeilen > als Index des Scans
        Index_NextBlankLine = find(Index_BlankLines > Index_Scan(i_c),...
            1,'first');
        %Kleinstes Intervall ist der Scan
        Scans{i_c} = M(Index_Scan(i_c):Index_BlankLines(...
            Index_NextBlankLine)-1,:);
%         % Hier muss noch eine Literalabfrage eingebaut werden, für den Fall
%         % dass es eine Leerzeile zwischen Scanheader und Messdaten gibt -
%         % sonst kann man die einzelnen Scans nicht separieren.
%         % Wenn es eine Leerzeile zwischen Scanhead und Messdaten gibt, müsste die
%         % Anzahl der Blank lines doppelt so groß sein wie die Scananzahl. Um den
%         % Scan korrekt zu filtern, muss eine Leerzeile ausgelassen werden und der
%         % Index der letzten Leerzeile vor dem nächsten Scan benutzt werden.
%         if i_c == Count_Scans
%             Scans{i_c} = M(Index_Scan(i_c):end-1,:);
%         else
%             Index_BlankLinePrior = find(Index_BlankLines < Index_Scan(i_c+1),1,'last');
%             %Kleinstes Intervall ist der Scan
%             Scans{i_c} = M(Index_Scan(i_c):Index_BlankLines(Index_BlankLinePrior)-1,:);
%         end
    end
    
    % Read phi and psi angles and scans. Sort scans according to phi angle
    % and than according to psi angle
    
    % Phi-Winkel
    Index_tmp = Tools.StringOperations.SearchString(M,'#phiP');
    Index_tmpPhi = Index_tmp;
    
    if size(Index_tmp,1) == 0
        phiP = zeros(Count_Scans,1)';
    else
        for j_c = 1:size(Index_tmp,1)
            phiP(j_c) = sscanf(M(Index_tmp(j_c),:),'#phiP %f');
        end
    end

    % Psi-Winkel
    Index_tmp = Tools.StringOperations.SearchString(M,'#psiP');
    if size(Index_tmp,1) == 0
        psiP = zeros(Count_Scans,1)'; 
    else
        for j_c = 1:size(Index_tmp,1)
            psiP(j_c) = sscanf(M(Index_tmp(j_c),:),'#psiP %f');
        end
    end
    
    % Eta-Winkel
    Index_tmp = Tools.StringOperations.SearchString(M,'#eta');
    if size(Index_tmp,1) == 0
        etaP = 90*ones(Count_Scans,1)'; 
    else
        for j_c = 1:size(Index_tmp,1)
            etaP(j_c) = sscanf(M(Index_tmp(j_c),:),'#eta %f');
        end
    end
    
% assignin('base','M',M)
% assignin('base','psiP',psiP)
% assignin('base','phiP',phiP)
% assignin('base','etaP',etaP)
% assignin('base','Scans',Scans)
    
    if all(etaP==90) || all(etaP==0)
        % If data was measured under more than one phi angle and psi = 0° was
        % only measured for one phi angle, copy the corresponding scan for the
        % respective phi angles
        % Get value and index of phi and psi angles of measurement
        [valphiP,indphiP] = unique(phiP);
        [valpsiP,indpsiP] = unique(psiP);
%         assignin('base','indphiP',indphiP)
%         assignin('base','indpsiP',indpsiP)
%         assignin('base','valphiP',valphiP)
%         assignin('base','valpsiP',valpsiP)
%         assignin('base','psiP',psiP)
%         assignin('base','phiP',phiP)
        % Check if the measurement for psi = 0° was done for all phi angles. If
        % not, copy the measurement for psi = 0° to the missing phi angle.
        % Check measurements depending on the number of phi angles
        if length(valphiP) == 2
            % get length of number of phi angles
            phiVal1tmp = find(phiP == valphiP(1));
            phiVal2tmp = find(phiP == valphiP(2));
            % Get psi values for each phi angle.
            PsiPhi1 = psiP(phiVal1tmp);
            PsiPhi2 = psiP(phiVal2tmp);
            % Compare psi values and check if psi = 0° exists for all phi
            % angle. If yes, skip code for copying scan for psi = 0°. This
            % way, measurements with different numbers of psi angles can be
            % analyzed.
            % To do: what if besides psi = 0° another psi angle is missing?
            IndPsiZeroCell = {find(PsiPhi1==0),find(PsiPhi2==0)};
            IndPsiZero = ~cellfun(@isempty,IndPsiZeroCell);
            
            if ~all(IndPsiZero == 1)
                % If number of phi angles 1 and 2 is different, copy the missing
                % measurement to the respective phi angle
                if ~isequal(length(phiVal1tmp),length(phiVal2tmp))
                    % Find index of psi = 0°
                    indpsizero = find(psiP == 0);
                    % Find index of highest psi angle
                    indpsilow = find(psiP == min(valpsiP));
                    indpsihigh = find(psiP == max(valpsiP));
                    if abs(numel(phiVal1tmp) - numel(phiVal2tmp)) == 1
                        % Check for which phi angle the scan for psi = 0° has to be added
                        idx = ismember(phiP(indpsihigh),phiP(indpsilow));
                        % Delete indices of highest psi angles for phi angles that already have a
                        % scan at psi = 0°
                        indpsihigh(idx) = [];
                        % Create empty cell and matrix in order to copy the measurements
                        Scanstmp = cell(size(Scans,1)+length(indpsihigh),1);
                        phiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                        psiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                        % Count variable. Once the place of the missing measurement was
                        % found, copy it to the corresponding position and add 1 to the
                        % counter.
                        % Counter for indpsihigh
                        cnt = 1;
                        % Counter for adding correct scans
                        cnt1 = 0;
                        cnt2 = 0;
                        for k = 1:length(Scanstmp)
                            if k == indpsihigh(cnt) + cnt1 + 1 - cnt2
                                % Copy scan with index psi = 0°.
                                Scanstmp{k} = Scans{indpsizero(cnt)};
                                % Check which phi angle has to be added, according to the
                                % phi angle under which there is no measurement for psi =
                                % 0°.
                                phiPtmp(k) = phiP(indpsihigh(cnt));
                                psiPtmp(k) = 0;
                                % Change counter values
                                cnt2 = cnt2 + 1;
                                cnt1 = cnt1 + 1;
                            else
                                % Add remaining scans.
                                Scanstmp{k} = Scans{k-cnt1};
                                phiPtmp(k) = phiP(k-cnt1);
                                psiPtmp(k) = psiP(k-cnt1);
                            end
                        end
                    else
                        % If measurement was not finished yet, the number of
                        % psi angles differs more than 1. In this case, do not
                        % try to copy the psi = 0° scan and take the scans as
                        % they are. Only considered for the case for two
                        % different phi angles.
                        phiPtmp = phiP;
                        psiPtmp = psiP;
                        Scanstmp = Scans;
                    end

                    phiP = phiPtmp;
                    psiP = psiPtmp;
                    etaP = ones(size(phiP))*90;
                    Scans = Scanstmp;
                    Count_Scans = size(Scans,1);
                end
            end
        elseif length(valphiP) == 3
            % get length of number of phi angles
            phiVal1tmp = find(phiP == valphiP(1));
            phiVal2tmp = find(phiP == valphiP(2));
            phiVal3tmp = find(phiP == valphiP(3));
            
            PsiPhi1 = psiP(phiVal1tmp);
            PsiPhi2 = psiP(phiVal2tmp);
            PsiPhi3 = psiP(phiVal3tmp);

            IndPsiZeroCell = {find(PsiPhi1==0),find(PsiPhi2==0),find(PsiPhi3==0)};
            IndPsiZero = ~cellfun(@isempty,IndPsiZeroCell);
            
            if ~all(IndPsiZero == 1)
                if ~isequal(length(phiVal1tmp),length(phiVal2tmp),length(phiVal3tmp))
                    % Find index of psi = 0°
                    indpsizero = find(psiP == 0);
                    % Find index of highest psi angle
                    indpsilow = find(psiP == min(valpsiP));
                    indpsihigh = find(psiP == max(valpsiP));
                    % Check for which phi angle the scan for psi = 0° has to be added
                    idx = ismember(phiP(indpsihigh),phiP(indpsilow));
                    % Delete indices of highest psi angles for phi angles that already have a
                    % scan at psi = 0°
                    indpsihigh(idx) = [];
                    % Create empty cell and matrix in order to copy the measurements
                    Scanstmp = cell(size(Scans,1)+length(indpsihigh),1);
                    phiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                    psiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                    % Count variable. Once the place of the missing measurement was
                    % found, copy it to the corresponding position and add 1 to the
                    % counter.
                    % Counter for indpsizero
                    cnt = 1;
                    % Counter for indpsihigh
                    cnt1 = 1;
                    % Counter for adding correct scans
                    cnt2 = 0;
                    for k = 1:length(Scanstmp)
                        if k == indpsihigh(cnt1) + cnt2 + 1
                            % Copy scan with index psi = 0°.
                            Scanstmp{k} = Scans{indpsizero(cnt)};
                            % Check which phi angle has to be added, according to the
                            % phi angle under which there is no measurement for psi =
                            % 0°.
                            phiPtmp(k) = phiP(indpsihigh(cnt1));
                            psiPtmp(k) = 0;
                            if length(indpsihigh) ~= 1
                                cnt1 = cnt1 + 1;
                            end
                            cnt2 = cnt2 + 1;
                        else
                            % Add remaining scans.
                            Scanstmp{k} = Scans{k-cnt2};
                            phiPtmp(k) = phiP(k-cnt2);
                            psiPtmp(k) = psiP(k-cnt2);
                        end
                    end
                    phiP = phiPtmp;
                    psiP = psiPtmp;
                    etaP = ones(size(phiP))*90;
                    Scans = Scanstmp;
                    Count_Scans = size(Scans,1);
                end
            end
        elseif length(valphiP) == 4
            % get length of number of phi angles
            phiVal1tmp = find(phiP == valphiP(1));
            phiVal2tmp = find(phiP == valphiP(2));
            phiVal3tmp = find(phiP == valphiP(3));
            phiVal4tmp = find(phiP == valphiP(4));
            
            PsiPhi1 = psiP(phiVal1tmp);
            PsiPhi2 = psiP(phiVal2tmp);
            PsiPhi3 = psiP(phiVal3tmp);
            PsiPhi4 = psiP(phiVal4tmp);

            IndPsiZeroCell = {find(PsiPhi1==0),find(PsiPhi2==0),find(PsiPhi3==0),find(PsiPhi4==0)};
            IndPsiZero = ~cellfun(@isempty,IndPsiZeroCell);
            
            if ~all(IndPsiZero == 1)
                if ~isequal(length(phiVal1tmp),length(phiVal2tmp),length(phiVal3tmp),length(phiVal4tmp))
                    % Find index of psi = 0°
                    indpsizero = find(psiP == 0);
                    % Find index of highest psi angle
                    indpsilow = find(psiP == min(valpsiP));
                    indpsihigh = find(psiP == max(valpsiP));
                    % Check for which phi angle the scan for psi = 0° has to be added
                    idx = ismember(phiP(indpsihigh),phiP(indpsilow));
                    % Delete indices of highest psi angles for phi angles that already have a
                    % scan at psi = 0°
                    indpsihigh(idx) = [];
                    % Create empty cell and matrix in order to copy the measurements
                    Scanstmp = cell(size(Scans,1)+length(indpsihigh),1);
                    phiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                    psiPtmp = zeros(1,size(Scans,1)+length(indpsihigh));
                    % Count variable. Once the place of the missing measurement was
                    % found, copy it to the corresponding position and add 1 to the
                    % counter.
%                     % Counter for indpsizero
%                     cnt = 1;
%                     % Counter for indpsihigh
%                     cnt1 = 1;
%                     % Counter for adding correct scans
%                     cnt2 = 0;
%                     for k = 1:length(Scanstmp)
%                         if k == indpsihigh(cnt1) + cnt2 + 1
%                             % Copy scan with index psi = 0°.
%                             Scanstmp{k} = Scans{indpsizero(cnt)};
%                             % Check which phi angle has to be added, according to the
%                             % phi angle under which there is no measurement for psi =
%                             % 0°.
%                             phiPtmp(k) = phiP(indpsihigh(cnt1));
%                             psiPtmp(k) = 0;
%                             if length(indpsizero) ~= 1 && cnt ~= 2
%                                 cnt = cnt +1;
%                             end
%                             cnt1 = cnt1 + 1;
%                             cnt2 = cnt2 + 1;
%                         else
%                             % Add remaining scans.
%                             Scanstmp{k} = Scans{k-cnt2};
%                             phiPtmp(k) = phiP(k-cnt2);
%                             psiPtmp(k) = psiP(k-cnt2);
%                         end
%                     end

                    cnt1 = 1;
                    cnt2 = 0;

                    for k = 1:length(Scanstmp)
                        if k == indpsihigh(cnt1)
                            % Copy scan with index psi = 0°.
                            Scanstmp{k} = Scans{indpsizero(cnt1)};
                            % Check which phi angle has to be added, according to the
                            % phi angle under which there is no measurement for psi =
                            % 0°.
                            phiPtmp(k) = phiP(indpsihigh(cnt1));
                            psiPtmp(k) = 0;
                            % add 1 to counter
                            if cnt1 < length(indpsihigh)
                                cnt1 = cnt1 + 1;
                            end
                            cnt2 = cnt2 + 1;
                        else
                            % Add remaining scans.
                            Scanstmp{k} = Scans{k-cnt2};
                            phiPtmp(k) = phiP(k-cnt2);
                            psiPtmp(k) = psiP(k-cnt2);
                        end
                    end

                    phiP = phiPtmp;
                    psiP = psiPtmp;
                    etaP = ones(size(phiP))*90;
                    Scans = Scanstmp;
                    Count_Scans = size(Scans,1);
                end
            end
        end
    else
        % If eta mode ist used, 2theta angle has to be defined by the user
        prompt = {'Enter a value of 2\theta (in degrees)'};
        dlgtitle = '2Theta Value';
        definput = {'16'};
        opts.Interpreter = 'tex';
        twothetauser = inputdlg(prompt,dlgtitle,[1 40],definput,opts);
    end
    
%     assignin('base','psiP1',psiP)
%     assignin('base','phiP1',phiP)
%     assignin('base','etaP1',etaP)
%     assignin('base','Scans1',Scans)

    % Create table consisting of phi and psi angles and scans
    Tabletmp = [num2cell(phiP)' num2cell(psiP)' num2cell(etaP)' Scans];
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
        phiPneu1 = cell2mat(Tabletmp(:,1)');
        psiPneu1 = cell2mat(Tabletmp(:,2)');
        etaneu1 = cell2mat(Tabletmp(:,3)');
        
        psiPrepmat = repmat(psiPneu1,2,1)';
        phiPrepmat = repmat(phiPneu1,2,1)';
        etaPrepmat = repmat(etaneu1,2,1)';
        % psiPrepmat sortieren
        psiPneu = reshape(psiPrepmat',1,[]);
        phiPneu = reshape(phiPrepmat',1,[]);
        etaneu = reshape(etaPrepmat',1,[]);
        
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
        % Create variables for psi and Scans
        psiP = cell2mat(TableSorted(:,2)');
        eta = cell2mat(TableSorted(:,3)');
        Scans = TableSorted(:,4);
        
        % For LEDDI: check if one or two detectors have been used for the
        % measurement
        
        Index_tmpNoD = Tools.StringOperations.SearchString(M,'#@MCADEV 0');
        
        % Phi-werte mit Index aus PhiTable in phiP eintragen
        if diffractometerMode == 1 || diffractometerMode == 3 || diffractometerMode == 4
            if length(phiIndex) == 1
                phiPneu = [phiP(sortTable(1,2):sortTable(1,3))];
            elseif length(phiIndex) == 2
                phiPneu = [phiP(sortTable(1,2):sortTable(1,3)) ...
                    phiP(sortTable(2,2):sortTable(2,3))];
            elseif length(phiIndex) == 3
                phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                    phiP(sortTable(2,2):sortTable(2,3))...
                    phiP(sortTable(3,2):sortTable(3,3))];
            else
                phiPneu = [phiP(sortTable(1,2):sortTable(1,3))...
                    phiP(sortTable(2,2):sortTable(2,3))...
                    phiP(sortTable(3,2):sortTable(3,3))...
                    phiP(sortTable(4,2):sortTable(4,3))];
            end
        elseif diffractometerMode == 2
            if isempty(Index_tmpNoD)
                phiPneu = phiP;
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
            
        end

    %3. Psi-Winkel
        if diffractometerMode == 1 || diffractometerMode == 3 || diffractometerMode == 4
            if length(phiIndex) == 1
                    psiPneu = psiP(sortTable(1,2):sortTable(1,3));
                elseif length(phiIndex) == 2
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3))];
                elseif length(phiIndex) == 3
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3)) ...
                        psiP(sortTable(3,2):sortTable(3,3))];
                else
                    psiPneu = [psiP(sortTable(1,2):sortTable(1,3)) ...
                        psiP(sortTable(2,2):sortTable(2,3)) ...
                        psiP(sortTable(3,2):sortTable(3,3)) ...
                        psiP(sortTable(4,2):sortTable(4,3))];
            end    
        end

        if diffractometerMode == 2
            if isempty(Index_tmpNoD)
                psiPneu = psiP;
            else          
%                 if length(phiIndex) == 1
%                     % psiP entsprechend der Laenge von phiIndex erweitern
%                     psiPrepmat = repmat(psiP,2*length(phiIndex),1)';
%                     % psiPrepmat sortieren
%                     psiPneu = reshape(psiPrepmat',1,[]);
%                 else
                    % psiP entsprechend der Laenge von phiIndex erweitern
                    psiPrepmat = repmat(psiP,2,1)';
                    % psiPrepmat sortieren
                    psiPneu = reshape(psiPrepmat',1,[]);
%                 end
            end
            
        end
%         psiPneu = psiP;
     %4. Eta-Winkel
        if diffractometerMode == 1 || diffractometerMode == 3 || diffractometerMode == 4
            if length(phiIndex) == 1
                    etaneu = eta(sortTable(1,2):sortTable(1,3));
                elseif length(phiIndex) == 2
                    etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                        eta(sortTable(2,2):sortTable(2,3))];
                elseif length(phiIndex) == 3
                    etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                        eta(sortTable(2,2):sortTable(2,3)) ...
                        eta(sortTable(3,2):sortTable(3,3))];
                else
                    etaneu = [eta(sortTable(1,2):sortTable(1,3)) ...
                        eta(sortTable(2,2):sortTable(2,3)) ...
                        eta(sortTable(3,2):sortTable(3,3)) ...
                        eta(sortTable(4,2):sortTable(4,3))];
            end    
        end

        if diffractometerMode == 2
            if isempty(Index_tmpNoD)
                etaneu = eta;
            else            
%                 if length(phiIndex) == 1
%                     % psiP entsprechend der Laenge von phiIndex erweitern
%                     etarepmat = repmat(eta,2*length(phiIndex),1)';
%                     % psiPrepmat sortieren
%                     etaneu = reshape(etarepmat',1,[]);
%                 else
                    % psiP entsprechend der Laenge von phiIndex erweitern
                    etarepmat = repmat(eta,2,1)';
                    % psiPrepmat sortieren
                    etaneu = reshape(etarepmat',1,[]);
%                 end
            end
        end
    end

% assignin('base','psiPneu',psiPneu)
% assignin('base','phiPneu',phiPneu)
% assignin('base','etaneu',etaneu)
%% (* Extrahieren der einzelnen Scans *)
% assignin('base','sortTable',sortTable)
    if length(phiIndex) == 1
        Scans = Scans;
    elseif length(phiIndex) == 2
       Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)}}';
    elseif length(phiIndex) == 3
        Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
        Scans{sortTable(3,2):sortTable(3,3)}}';
    elseif length(phiIndex) == 4
        Scans = {Scans{sortTable(1,2):sortTable(1,3)} Scans{sortTable(2,2):sortTable(2,3)} ...
        Scans{sortTable(3,2):sortTable(3,3)} Scans{sortTable(4,2):sortTable(4,3)}}';
    else
        Scans = Scans;
    end

% assignin('base','psiP1',psiP)
% assignin('base','phiP1',phiP)
% assignin('base','etaP1',etaP)
% assignin('base','Scans1',Scans)
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
        
        if diffractometerMode ~= 4
            % Calculate DT correction using user selected function
            CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
            CalibParam_a = CalibParams.a(1) + exp(CalibParams.a(2)*(CalibParams.a(3) + obj.DeadTime)) - (CalibParams.a(4)/(CalibParams.a(5)+obj.DeadTime));
            CalibParam_b = CalibParams.b(1) + CalibParams.b(2)*obj.DeadTime + CalibParams.b(3)*obj.DeadTime.^2;
            CalibParam_c = CalibParams.c(1) + CalibParams.c(2)*obj.DeadTime;
        end
        
        if diffractometerMode == 4
            CalibParams = [5.59139e-09;0.00401;0.47711];
%         elseif diffractometerMode == 3
%             CalibParams = [7.82036393192218e-9;0.0111599247349075;0.0552567316053713];
        else
            CalibParams = [CalibParam_c;CalibParam_b;CalibParam_a];
        end
        Energies_tmp = polyval(...
            CalibParams,...
            obj.ChannelRange(1):obj.ChannelRange(1)...
            +length(Intensities_tmp)-1);
    % + Energiedispersives Spektrum
        obj.EDSpectrum = [Energies_tmp',Intensities_tmp];
    end
%% ------------------------------------------------------------------------
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
        
%         % Calculate DT correction using user selected function
%         CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
%         assignin('base','CalibParams',CalibParams)
%         CalibParam_a = CalibParams.a(1) + exp(CalibParams.a(2)*(CalibParams.a(3) + obj.DeadTime(1))) - (CalibParams.a(4)/(CalibParams.a(5)+obj.DeadTime(1)));
%         CalibParam_b = CalibParams.b(1) + CalibParams.b(2)*obj.DeadTime(1) + CalibParams.b(3)*obj.DeadTime(1).^2;
%         CalibParam_c = CalibParams.c(1) + CalibParams.c(2)*obj.DeadTime(1);
%         
%         CalibParams = [CalibParam_c;CalibParam_b;CalibParam_a];
%         Energies_tmp = polyval(...
%             CalibParams,...
%             obj.ChannelRange(1):obj.ChannelRange(1)...
%             +length(Intensities_tmp)-1);
%         Energies = Energies_tmp;
        
%     %2. Energien berechnen
%         %Berechnung mit Hilfe der Kalibirierungswerte des Detektors
%         Energies = polyval(...
%             Diffractometer.Detector.EnergyCalibrationParameters,...
%             obj(1).ChannelRange(1):obj(1).ChannelRange(2));
        % Calculate DT correction using user selected function
            CalibParams = load(fullfile('Data','Calibration',[calib,'.mat']));
    %% (* Durchlaufen der AScans *)
        for j_c = 1:Count_AScans
            %Motoren replizieren
            obj(j_c).Motors_all = Motors_all;
            
        %% (* Einlesen der Scan-Veränderlichen *)
            %Einlesen aller relevanten Daten aus dem AScan
            %(2 Zeilen über dem @A)
            AScanVariables = sscanf(Scan(Index_AScan(j_c)-1,:),'%f',inf)';
            %Veränderlicher Motor (Hier statisch, da sonst nirgenwo steht,
            %wie der variable Motor heißt)
            obj(j_c).Motors_all.(AScanVariablesNames{1}) = ...
                AScanVariables(1);
            %Ringstrom
            obj(j_c).RingCurrent = AScanVariables(...
                find(strcmp(AScanVariablesNames,'R_strom'),1,'first'));
            %RealTime
            obj(j_c).RealTime = AScanVariables(...
                find(strcmp(AScanVariablesNames,'Real_1'),1,'first'));
            %DeadTime (Aus der LiveTime berechnen)
            obj(j_c).DeadTime = (1 - AScanVariables(...
                find(strcmp(AScanVariablesNames,'Live_1'),1,'first'))...
                / obj(j_c).RealTime) * 100;
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
% assignin('Base','Scans',Scans)
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
        ScanType = char(sscanf(Scans{i_c}(1,:),'#S %*d %s')');
        %--> Analyse entsprechen dem Scan-Typ
        if diffractometerMode == 1 || diffractometerMode == 3 || diffractometerMode == 4
            if any(strcmp(ScanType,{'ascan','dscan'}))
                obj_new = AnalyzeAScan(Scans{i_c});
            elseif any(strcmp(ScanType,{'mcaacq','twinmcaacq','loopscan'}))
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
            elseif any(strcmp(ScanType,{'mcaacq','twinmcaacq','loopscan'}))
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
    elseif diffractometerMode == 2 || diffractometerMode == 3 || diffractometerMode == 4
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
%         assignin('base','obj',obj)
        %% (* Winkel aus den Motoren berechnen *)
        % Muss NOCH je nach Messtyp angepasst werden. Sollte später in
        % Detector geschehen
        if diffractometerMode == 1
            if size(Index_tmpPhi,1) == 0
                obj(i_c).twotheta = obj(i_c).Motors_all.zwei_theta;
                obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.chi; %obj(i_c).Motors_all.chi; %abs(psiPneu(i_c));
                obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.phi);
                obj(i_c).SCSAngles.eta = etaneu(i_c);
            else
                obj(i_c).twotheta = obj(i_c).Motors_all.zwei_theta;
                obj(i_c).SCSAngles.psi = psiPneu(i_c); %obj(i_c).Motors_all.chi; %abs(psiPneu(i_c));
                obj(i_c).SCSAngles.phi = phiPneu(i_c);
                obj(i_c).SCSAngles.eta = etaneu(i_c);
            end
        elseif diffractometerMode == 2
            if size(Index_tmpPhi,1) == 0
                if ~all(etaP==90) && ~all(etaP==0)
                    obj(i_c).twotheta = str2double(twothetauser{1});
                else
                    if obj(i_c).Motors_all.Omega == 0
                        if obj(i_c).Motors_all.Det1_rot == 0
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Det2_rot);
                        elseif obj(i_c).Motors_all.Det2_rot == 0
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Det1_rot);
                        end
                    else
                        if mod(i_c,2)
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Omega);
                        else
                            obj(i_c).twotheta = abs(obj(i_c).Motors_all.Det1);
                        end
                    end
                end
                obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.Chi;
                obj(i_c).SCSAngles.chi = obj(i_c).Motors_all.Chi;
                obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.Phi);
                obj(i_c).SCSAngles.eta = etaneu(i_c);
            else
                if ~all(etaP==90) && ~all(etaP==0)
                    obj(i_c).twotheta = str2double(twothetauser{1});
                else
                    if obj(i_c).Motors_all.Omega == 0
                        if obj(i_c).Motors_all.Det1_rot == 0
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Det2_rot);
                        elseif obj(i_c).Motors_all.Det2_rot == 0
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Det1_rot);
                        end
                    else
                        if mod(i_c,2)
                            obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Omega);
                        else
                            obj(i_c).twotheta = abs(obj(i_c).Motors_all.Det1);
                        end
                    end
                end
                obj(i_c).SCSAngles.psi = psiPneu(i_c);
                obj(i_c).SCSAngles.chi = obj(i_c).Motors_all.Chi;
                obj(i_c).SCSAngles.phi = abs(phiPneu(i_c));
                obj(i_c).SCSAngles.eta = etaneu(i_c);
            end
        elseif diffractometerMode == 3
            if size(Index_tmpPhi,1) == 0
                if ~all(etaP==90) && ~all(etaP==0)
                    obj(i_c).twotheta = str2double(twothetauser{1});
                else
                    obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Omega);
                end
                obj(i_c).SCSAngles.psi = abs(obj(i_c).Motors_all.Chi);
                obj(i_c).SCSAngles.phi = abs(obj(i_c).Motors_all.Phi);
                if size(etaneu,1) == 1
                    obj(i_c).SCSAngles.eta = 90;
                else
                    obj(i_c).SCSAngles.eta = etaneu(i_c);
                end
            else
                if ~all(etaP==90) && ~all(etaP==0)
                    obj(i_c).twotheta = str2double(twothetauser{1});
                else
                    obj(i_c).twotheta = 2*abs(obj(i_c).Motors_all.Omega);
                end
                obj(i_c).SCSAngles.psi = psiPneu(i_c);
                obj(i_c).SCSAngles.phi = abs(phiPneu(i_c));
                obj(i_c).SCSAngles.eta = etaneu(i_c);
            end
        elseif diffractometerMode == 4
            obj(i_c).twotheta = obj(i_c).Motors_all.TTH;
            obj(i_c).SCSAngles.psi = obj(i_c).Motors_all.CHI;
            obj(i_c).SCSAngles.phi = obj(i_c).Motors_all.PHI;
            obj(i_c).SCSAngles.eta = 90;
        end
    end
end