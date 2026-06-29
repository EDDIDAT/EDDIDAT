function tau2excel(folderPath, outputExcel)
%TAU2EXCEL  Exportiert .tau-Dateien ab "hkl" nach Excel
%   - Spalte 1 bleibt STRING
%   - "--" bleibt "--"
%   - numerische Werte werden korrekt übernommen

    if nargin < 1 || isempty(folderPath)
        folderPath = '.';
    end
    if nargin < 2 || isempty(outputExcel)
        outputExcel = 'tau_export.xlsx';
    end

    files = dir(fullfile(folderPath,'*.tau'));
    if isempty(files)
        error('Keine .tau-Dateien gefunden.');
    end

    allRows = {};
    headers  = {};

    for f = 1:numel(files)
        filename = fullfile(folderPath, files(f).name);

        fid = fopen(filename,'r');
        lines = textscan(fid,'%s','Delimiter','\n','Whitespace','');
        fclose(fid);
        lines = strtrim(lines{1});

        % hkl-Zeile finden
        startRow = find(startsWith(lines,'hkl'),1,'first');
        if isempty(startRow)
            warning('Keine hkl-Zeile in %s', files(f).name);
            continue
        end

        % Header einmal einlesen
        if isempty(headers)
            headers = split(lines{startRow});
            headers = matlab.lang.makeValidName(headers);
            headers = matlab.lang.makeUniqueStrings(headers);
            headers = ['Datei'; headers];
        end

        % Datenzeilen
        dataLines = lines(startRow+1:end);
        dataLines = dataLines(~cellfun('isempty',dataLines));

        for i = 1:numel(dataLines)
            tokens = split(dataLines{i});
            row = cell(1,numel(headers));
            row{1} = files(f).name;   % Dateiname

            for c = 1:numel(tokens)
                if tokens(c) == "--"
                    row{c+1} = "--";
                else
                    val = str2double(tokens(c));
                    if isnan(val)
                        row{c+1} = string(tokens(c)); % z.B. String in Spalte 1
                    else
                        row{c+1} = val;
                    end
                end
            end

            allRows(end+1,:) = row; %#ok<SAGROW>
        end
    end

    % Tabelle erzeugen
    T = cell2table(allRows, 'VariableNames', headers);

    % emptyRow = T(1,:);   % Struktur kopieren
    % 
    % for v = 1:width(T)
    %     if iscellstr(T{:,v}) || isstring(T{:,v})
    %         emptyRow{1,v} = missing;
    %     else
    %         emptyRow{1,v} = NaN;
    %     end
    % end
    % 
    % T = [T; emptyRow];

    % Export nach Excel
    writetable(T, outputExcel);

    fprintf('✔ Export abgeschlossen: %s\n', outputExcel);
end
