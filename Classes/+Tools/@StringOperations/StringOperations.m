%% (* STRINGOPERATIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt dem Benutzer einige weitere
% Char-Array-Funktionen zur Verfügung, die in der MATLAB-Bibliothek fehlen.
% Vor allem für Texte, also zweidimensionale Char-Arrays werden Funktionen 
% ergänzt. Im Allgemeinen wird unter einem String ein Char-Array
% verstanden.
%--------------------------------------------------------------------------
classdef StringOperations

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Such-Funktionen *)
        %Finden von Strings in Texten
        Index = SearchString(Text,SearchString)
        %Suchen von Leerzeilen in Texten
        Index = SearchBlankLines(Text)
        
    %% (* Scan- und Trennfunktionen *)
        %Sucht aus einem String die Wörter
        rtn = ScanWords(String)
        %String an gegebenen Positionen splitten
        rtn = SplitString(String,Index)
        
    %% (* Konvertierungs-Funktionen *)
        %AsciiFile laden und in ein 2D-CharArray verwandeln
        rtn = AsciiFile2Text(Filename,Delimiter)
        %Ein 2D-CharArray in einen einzeiligen String verwandeln
        rtn = Text2String(String)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = StringOperations(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - AsciiFile2Text besser in Import/Export-Klasse oder ISaveLoad