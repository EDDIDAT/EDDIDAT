function [meas,MeasurementBackup,DataTmp,Diffractometer,P,T] = LoadXFlashFileGUI(FullFilePath,P,SampleInput,T)
% LOADXFLASHFILEGUI  Eigenstaendiger Import fuer Bruker XFlash 430 (Esprit)
% Spektren-Dateien (Diffraktometer "Xlab-IKZ"), als Alternative
% zur SPEC-Format-Routine SpecFileConversionGUI/LoadFromSpecFile_neu, die
% fuer Mehrfach-Scan-Dateien mit Motorpositionen (P61A, ETA3000, LEDDI...)
% gedacht ist und auf dieses Dateiformat nicht anwendbar ist.
%
% Unterstuetzte Formate:
%
% (1) Einzelspektrum (Esprit 1.9 .txt-Export): Text-Header mit "Real time:"
%     und "Life time:" (in ms), gefolgt von einer Zeile "Energy Counts" und
%     danach zwei Spalten Energie [keV] / Zaehlrate je Kanal -- die
%     Energiewerte liegen bereits kalibriert vor, es wird keine externe
%     Kalibrierdatei benoetigt.
%
% (2) Mehrspektren-Textdatei (Mapping): Jedes Spektrum beginnt mit einer
%     Zeile "#S <Nr>  <Name>" und enthaelt dieselben Schluesselzeilen wie (1):
%
%         #S 1  Simap6_x12006um_y3014um
%         Real time: 70
%         Life time: 70
%         2theta: 125.9
%         X position [mm]: 12.0056
%         Y position [mm]: 3.0136
%         Energy Counts
%          5.0042     0
%          ...
%
%     Zeilen vor dem ersten "#S" gelten als globaler Kopf (dort kann z.B.
%     "2theta:" einmalig fuer alle Spektren stehen). Weitere, unbekannte
%     Zeilen werden ignoriert.
%
% (3) Mehrspektren-MAT-Datei (.mat, platzsparend, schnell). Variablen:
%         E            Energieachse [keV], N_E Werte (gemeinsam fuer alle)
%         Counts       N x N_E Counts-Matrix (z.B. uint16), eine Zeile je Spektrum
%         RealTimeMs   Real time [ms], Skalar oder N Werte           (Pflicht)
%         LifeTimeMs   Life time [ms], Skalar oder N Werte           (optional)
%         TwoTheta     2theta [deg], Skalar oder N Werte             (optional)
%         X, Y         Position [mm], N Werte                        (optional)
%         Names        N Namen (Zellarray)                           (optional)
%
% Optionale Angaben (alle Formate):
%   2theta        Beugungswinkel; fehlt er, wird er per Dialog (einmal fuer
%                 alle Spektren) abgefragt.
%   X, Y          Ortskoordinaten des Messpunkts [mm]. Werden in
%                 meas(k).SampleStagePos = [x y 0] abgelegt.
%
% Input:
%   FullFilePath  Vollstaendiger Pfad zur .txt- oder .mat-Datei (auch
%                 ausserhalb von Data/Measurements moeglich)
%   P             h.P-Struktur (wird unveraendert durchgereicht, bis auf
%                 P.Calibration)
%   SampleInput   h.Sample (wie bei SpecFileConversionGUI)
%   T             h.T-Struktur (wird unveraendert durchgereicht)
%
% Output: wie SpecFileConversionGUI (meas,MeasurementBackup,DataTmp,
%         Diffractometer,P,T), damit okbuttonloadmeasurement fuer beide
%         Ladepfade denselben nachgelagerten Code verwenden kann. meas ist
%         ein Zeilenvektor mit einem Measurement-Objekt je Spektrum,
%         DataTmp ein Zellarray {EDSpectrum} derselben Laenge.

    [~,BaseName,Ext] = fileparts(FullFilePath);

    %% (* Datei einlesen -- je nach Format *)
    if strcmpi(Ext,'.mat')
        [Names,Spectra,RealTimeS,DeadTimePc,TwoTheta,PosX,PosY] = LocalReadMatFile(FullFilePath,BaseName);
    else
        [Names,Spectra,RealTimeS,DeadTimePc,TwoTheta,PosX,PosY] = LocalReadTextFile(FullFilePath,BaseName);
    end
    nScan = numel(Names);

    %% (* 2theta abfragen, falls in der Datei nicht enthalten *)
    if any(isnan(TwoTheta))
        if nScan == 1
            prompt = '2theta [deg] (nicht im Dateiheader enthalten):';
        else
            prompt = sprintf('2theta [deg] fuer %d Spektren (nicht im Dateiheader enthalten):', sum(isnan(TwoTheta)));
        end
        answer = inputdlg({prompt}, 'Xlab-IKZ: Beugungswinkel', 1, {'100'});
        if isempty(answer)
            error('LoadXFlashFileGUI:Cancelled', ...
                'Laden abgebrochen (2theta nicht angegeben).');
        end
        TwoThetaInput = str2double(answer{1});
        if isnan(TwoThetaInput)
            error('LoadXFlashFileGUI:InvalidTwoTheta', '2theta muss eine Zahl sein.');
        end
        TwoTheta(isnan(TwoTheta)) = TwoThetaInput;
    end

    %% (* Measurement-Objekte aufbauen *)
    measCell = cell(1,nScan);
    for k = 1:nScan
        m = Measurement.Measurement();
        m.Name = Names{k};
        m.EDSpectrum = Spectra{k};
        m.twotheta = TwoTheta(k);
        m.RealTime = RealTimeS(k);
        m.DeadTime = DeadTimePc(k);
        m.Sample = SampleInput;
        if ~isnan(PosX(k)) && ~isnan(PosY(k))
            m.SampleStagePos = [PosX(k) PosY(k) 0];
        end
        measCell{k} = m;
    end
    meas = [measCell{:}];

    MeasurementBackup = meas.Clone;
    DataTmp = cell(1,nScan);
    for k = 1:nScan
        DataTmp{k} = meas(k).EDSpectrum;
    end

    %% (* Diffractometer-Objekt *)
    Diffractometer = Measurement.Diffractometer.LoadFromFile('Xlab-IKZ', Measurement.Diffractometer);

    % Energiewerte liegen bereits kalibriert vor -- keine externe
    % Kalibrierdatei noetig. P.Calibration darf nur nicht 'Channel_scale'
    % sein, sonst wuerde TheoreticalPeakPositions den Kanal- statt den
    % Energiebereich fuer die Berechnung theoretischer Linienlagen nutzen.
    P.Calibration = 'Xlab-IKZ (direct energy values)';

    if nScan == 1
        disp(['Xlab-IKZ Spektrum geladen: ', BaseName, ' (2theta = ', num2str(TwoTheta(1)), ' deg, RealTime = ', num2str(RealTimeS(1)), ' s)']);
    else
        disp(['Xlab-IKZ Mehrspektren-Datei geladen: ', BaseName, ' (', num2str(nScan), ' Spektren, 2theta = ', num2str(TwoTheta(1)), ' deg, RealTime = ', num2str(RealTimeS(1)), ' s)']);
    end
end

%% (* Lokale Funktionen: Dateiformate *)

function [Names,Spectra,RealTimeS,DeadTimePc,TwoTheta,PosX,PosY] = LocalReadTextFile(FullFilePath,BaseName)
    % Einzelspektrum (Esprit) oder Mehrspektren-Textdatei mit "#S"-Bloecken
    raw = fileread(FullFilePath);
    raw = strrep(raw, sprintf('\r\n'), newline);
    % Fuehrender Zeilenumbruch, damit "#S" in der ersten Zeile mitgefunden wird
    raw = [newline raw];

    idxS = strfind(raw, [newline '#S ']);
    if isempty(idxS)
        Blocks = {raw};
        HeaderText = '';
    else
        % jeder Block laeuft von "#S" bis vor das naechste "#S"
        HeaderText = raw(1:idxS(1));
        idxEnd = [idxS(2:end), numel(raw)+1];
        Blocks = cell(1,numel(idxS));
        for k = 1:numel(idxS)
            Blocks{k} = raw(idxS(k)+1 : idxEnd(k)-1);
        end
    end
    nScan = numel(Blocks);

    GlobalTwoTheta = LocalParseNumber(HeaderText, '2theta:');
    Names      = cell(1,nScan);
    Spectra    = cell(1,nScan);
    RealTimeS  = nan(1,nScan);
    DeadTimePc = zeros(1,nScan);
    TwoTheta   = nan(1,nScan);
    PosX       = nan(1,nScan);
    PosY       = nan(1,nScan);

    for k = 1:nScan
        txt = Blocks{k};
        if nScan == 1
            where = '';
        else
            where = sprintf(' (Spektrum %d)', k);
        end

        % Name aus der "#S"-Zeile
        Names{k} = BaseName;
        if nScan > 1
            tok = regexp(txt, '^#S[ \t]+(\d+)[ \t]*([^\n]*)', 'tokens', 'once');
            if isempty(tok) || isempty(strtrim(tok{2}))
                Names{k} = sprintf('%s_%d', BaseName, k);
            else
                Names{k} = strtrim(tok{2});
            end
        end

        % Real time / Life time (ms)
        RealTimeMs = LocalParseNumber(txt, 'Real time:');
        LifeTimeMs = LocalParseNumber(txt, 'Life time:');
        if isnan(RealTimeMs) || RealTimeMs == 0
            error('LoadXFlashFileGUI:NoRealTime', ...
                '"Real time:" nicht im Header gefunden%s -- Dateiformat nicht erkannt.', where);
        end
        RealTimeS(k) = RealTimeMs / 1000;
        if ~isnan(LifeTimeMs)
            DeadTimePc(k) = (1 - LifeTimeMs/RealTimeMs) * 100;
        end

        % Beugungswinkel und Ortskoordinaten (optional)
        TwoTheta(k) = LocalParseNumber(txt, '2theta:');
        if isnan(TwoTheta(k))
            TwoTheta(k) = GlobalTwoTheta;
        end
        PosX(k) = LocalParseNumber(txt, 'X position \[mm\]:');
        PosY(k) = LocalParseNumber(txt, 'Y position \[mm\]:');

        % Spektrum-Datenblock ("Energy Counts")
        Spectra{k} = LocalParseSpectrum(txt);
        if isempty(Spectra{k})
            error('LoadXFlashFileGUI:NoData', ...
                'Zeile "Energy Counts" bzw. gueltige Energie/Counts-Zeilen nicht gefunden%s.', where);
        end
    end
end

function [Names,Spectra,RealTimeS,DeadTimePc,TwoTheta,PosX,PosY] = LocalReadMatFile(FullFilePath,BaseName)
    % Mehrspektren-MAT-Datei: gemeinsame Energieachse E, Counts (N x N_E)
    S = load(FullFilePath);
    if ~isfield(S,'E') || ~isfield(S,'Counts')
        error('LoadXFlashFileGUI:NoMatData', ...
            'MAT-Datei enthaelt nicht die Variablen "E" und "Counts" -- Dateiformat nicht erkannt.');
    end
    E = double(S.E(:));
    C = S.Counts;
    if size(C,2) ~= numel(E) && size(C,1) == numel(E)
        C = C.';                 % transponiert abgelegt
    end
    if size(C,2) ~= numel(E)
        error('LoadXFlashFileGUI:MatSize', ...
            'Anzahl der Kanaele in "Counts" (%d) passt nicht zu "E" (%d).', size(C,2), numel(E));
    end
    nScan = size(C,1);

    RealTimeMs = LocalMatVector(S,'RealTimeMs',nScan,NaN);
    if any(isnan(RealTimeMs)) || any(RealTimeMs == 0)
        error('LoadXFlashFileGUI:NoRealTime', ...
            'MAT-Datei: "RealTimeMs" fehlt oder enthaelt 0/NaN.');
    end
    LifeTimeMs = LocalMatVector(S,'LifeTimeMs',nScan,NaN);
    RealTimeS  = RealTimeMs / 1000;
    DeadTimePc = zeros(1,nScan);
    hasLife = ~isnan(LifeTimeMs);
    DeadTimePc(hasLife) = (1 - LifeTimeMs(hasLife)./RealTimeMs(hasLife)) * 100;
    TwoTheta = LocalMatVector(S,'TwoTheta',nScan,NaN);
    PosX = LocalMatVector(S,'X',nScan,NaN);
    PosY = LocalMatVector(S,'Y',nScan,NaN);

    if isfield(S,'Names') && numel(S.Names) == nScan
        Names = cellstr(S.Names(:)).';
    else
        Names = arrayfun(@(k) sprintf('%s_%d',BaseName,k), 1:nScan, 'UniformOutput', false);
    end

    Spectra = cell(1,nScan);
    for k = 1:nScan
        Spectra{k} = [E, double(C(k,:)).'];
    end
end

function v = LocalMatVector(S, name, n, default)
    % Liest Skalar oder Vektor aus der MAT-Struktur als 1 x n double
    if ~isfield(S,name) || isempty(S.(name))
        v = repmat(default,1,n);
    elseif isscalar(S.(name))
        v = repmat(double(S.(name)),1,n);
    elseif numel(S.(name)) == n
        v = double(S.(name)(:)).';
    else
        error('LoadXFlashFileGUI:MatSize', ...
            'MAT-Variable "%s" hat %d Werte, erwartet 1 oder %d.', name, numel(S.(name)), n);
    end
end

%% (* Lokale Funktionen: Textparsing *)

function val = LocalParseNumber(txt, keyPattern)
    % Liest die Zahl hinter "<key>" am Zeilenanfang; NaN, wenn nicht vorhanden.
    % keyPattern ist ein regulaerer Ausdruck (Sonderzeichen wie [ ] maskieren).
    tok = regexp(txt, ['(?m)^[ \t]*' keyPattern '[ \t]*([-+]?(?:\d+\.?\d*|\.\d+)(?:[eE][-+]?\d+)?)'], ...
        'tokens', 'once', 'ignorecase');
    if isempty(tok)
        val = NaN;
    else
        val = str2double(tok{1});
    end
end

function D = LocalParseSpectrum(txt)
    % Liest die Zeilen hinter "Energy Counts" als [Energie, Counts]-Matrix.
    D = [];
    iEnd = regexp(txt, '(?m)^[ \t]*Energy Counts[ \t]*$', 'end', 'once', 'ignorecase');
    if isempty(iEnd)
        return
    end
    v = sscanf(txt(iEnd+1:end), '%f', [2 Inf]);
    if isempty(v)
        return
    end
    D = v';
end
