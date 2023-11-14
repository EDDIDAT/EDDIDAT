% Diese Funktion lieﬂt einen Textfile ein und gibt ihn als 2D-CharArray 
% aus.
% Input: Filename, kompletter Dateipfad, string|va /
%        Delimiter, Trennzeichen zwischen den Zeilen, string|va
% Output: rtn, konvertiertes Char-Array, Text, char|2d
function rtn = AsciiFile2Text(Filename,Delimiter)

%% (* Stringenzpr¸fung *)
    validateattributes(Filename,{'char'},{'row'});
    validateattributes(Delimiter,{'char'},{'row'});

%% (* Laden *)
    %Datei ˆffnen, Ergebnis ist der File-Identifier
    fid = fopen(Filename);
    %Anzahl der Zeilen ermitteln (NOL = NumberOfLines), hierbei kann es
    %sein, dass die letzte Zeile nicht gez‰hlt wird, was aber beim Einlesen
    %keinen Fehler hervorruft, da das Array einfach redimensioniert wird
    NOL = textscan(fid,'%s',NaN,'Delimiter',Delimiter);
    NOL = length(NOL{1});
    %Zur¸cksetzen des FilePositioners
    fseek(fid,0,'bof');
    %Prealloc des Cell-Arrays
    rtn = cell(NOL,1);
    %Z‰hler f¸r die Zeilen
    i_c = 0;
    %--> Durchlaufen der Files
    while ~feof(fid)
        i_c = i_c + 1;
        %Zeile einlesen
        rtn{i_c} = fgetl(fid);
    end
    %Datei schlieﬂen
    fclose(fid);
    
%% (* Konvertieren *)
    %Umwandeln in ein Char-Array
    rtn = char(rtn);
end