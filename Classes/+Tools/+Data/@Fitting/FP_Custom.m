% Diese Funktion bietet die Möglichkeit einen "universellen" Fit
% durchzuführen. Neben den Eingabeargumenten X,Y und dem Operator zwischen
% den einzelnen Fit-Funktion kann man eine bliebige Anzahl von
% Fit-Funktionen vorgeben. Eine solche wir in einer Struktur
% zusammengefasst und muss die folgenden Eigenschaften belegen: 
%   Func = Funktionsname als Handle, die Funktion muss die Form
%   fun(x,p(1),...p(n)) haben, wobei alles Arrays sein dürfen
%   StartParams = Array mit den Startwerten, die 1. Dimension entspricht
%   den Funktionsparametern, die 2. Dimension der Anzahl der Funktionen
%   FitParams_Min = Enhält die unteren Fitgrenzen, 
%   gleiche Anordnung wie StartParams, NaN bedeutet der Parameter wird nach
%   unten festgehalten
%   FitParams_Max = Enhält die oberen Fitgrenzen, 
%   gleiche Anordnung wie StartParams, NaN bedeutet der Parameter wird nach
%   oben festgehalten
%   Operator = Operation zwischen den Funktionen (falls es mehrere gibt)
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        Operator, Operator zwischen den Handles, z. B '+', string|va
%        varargin, die oben beschriebenen Fit-Funktionen, struct|va
% Output: FitParam, die gefitteten Parameter
function FitParam = FP_Custom(X,Y,Operator,varargin)

%% (* Stringenzprüfung *)
    validateattributes(X,{'double'},{'real','finite','column'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(Operator,{'char'},{'row'});
    %--> Auswertung der Fit-Funktionen
    if nargin >= 4
        %--> Überprüfen und Anpassen der Funktionen
        for i_c = 1:nargin-3
            validateattributes(varargin{i_c},{'struct'},{'scalar'});
            %Übertragen der Struktur (Felder sortieren)
            FitFuncs(i_c) = orderfields(varargin{i_c});
            %function_handle
            validateattributes(FitFuncs(i_c).Func,...
                {'function_handle'},{'scalar'});
            %Operator
            validateattributes(FitFuncs(i_c).Operator,{'char'},{'row'});
            %Startwerte
            validateattributes(FitFuncs(i_c).StartParams,...
                {'double'},{'real','2d','finite'});
            %Alle NaNs oder zu große Werte durch den Startwert ersetzen
%             FitFuncs(i_c).FitParams_Min(isnan(...
%                 FitFuncs(i_c).FitParams_Min) |...
%                 FitFuncs(i_c).FitParams_Min > FitFuncs(i_c).StartParams)...
%                 = FitFuncs(i_c).StartParams(isnan(...
%                 FitFuncs(i_c).FitParams_Min) |...
%                 FitFuncs(i_c).FitParams_Min > FitFuncs(i_c).StartParams);
            validateattributes(FitFuncs(i_c).FitParams_Min,...
                {'double'},{'real','2d',...
                'size',size(FitFuncs(i_c).StartParams)});
            %Alle NaNs oder zu kleine Werte durch den Startwert ersetzen
%             FitFuncs(i_c).FitParams_Max(isnan(...
%                 FitFuncs(i_c).FitParams_Max) |...
%                 FitFuncs(i_c).FitParams_Max < FitFuncs(i_c).StartParams)...
%                 = FitFuncs(i_c).StartParams(isnan(...
%                 FitFuncs(i_c).FitParams_Max) |...
%                 FitFuncs(i_c).FitParams_Max < FitFuncs(i_c).StartParams);
            validateattributes(FitFuncs(i_c).FitParams_Max,...
                {'double'},{'real','2d',...
                'size',size(FitFuncs(i_c).StartParams)});
        end
    else
        error('There has to be at least one fit-function!');
    end

%% (* Fit-Parameter vektorisieren *)
    %Prealloc
    p = [];
    p_Min = [];
    p_Max = [];
    %--> Alle Fit-Parameter in jeweils einen Vektor zusammenfassen
    for i_c = 1:length(FitFuncs)
        p = [p FitFuncs(i_c).StartParams(:)'];
        p_Min = [p_Min FitFuncs(i_c).FitParams_Min(:)'];
        p_Max = [p_Max FitFuncs(i_c).FitParams_Max(:)'];
    end

%% (* Summenhandle erstellen *)
    %Beginn des Handles
    SumHandle = '@(p,x)(';
    %Absoluter Counter für die Startwerte
    p_c = 1;
    %--> Durchlaufen der Fit-Funktionen
    for i_c = 1:length(FitFuncs)
        %--> Operator und Klammer setzen
        if i_c > 1, SumHandle = [SumHandle Operator '('];
        else SumHandle = [SumHandle '(']; end
        %--> Durchlaufen der Anzahl der jeweiligen Fit-Funktion
        for j_c = 1:size(FitFuncs(i_c).StartParams,2)
            %--> Operator setzen
            if j_c > 1, SumHandle = [SumHandle FitFuncs(i_c).Operator]; end
            %Einzelne Funktion mit den passenden Argumente hinzufügen
            SumHandle = [SumHandle func2str(FitFuncs(i_c).Func)...
              CreateFuncArgs(p_c:p_c-1+size(FitFuncs(i_c).StartParams,1))];
            %Absoluten Counter inkrementieren
            p_c = p_c + size(FitFuncs(i_c).StartParams,1);
        end
        SumHandle(end+1) = ')';
    end
    %Handle schließen
    SumHandle = str2func([SumHandle,')']);
    
    nan_c = 1;
    FitParams = '[';
    for i_c = 1:length(p)
        if isnan(p_Min(i_c))
            FitParams = [FitParams, num2str(p(i_c)),' '];
        else
            FitParams = [FitParams, 'p(',num2str(nan_c),') '];
            nan_c = nan_c + 1;
        end
    end
    
    FitHandle = str2func(['@(p,x)SumHandle(', FitParams ,'],x)']);
    
    disp(feval(SumHandle,[0,0,0,0,0,4.1569,0.8],X));
    disp(FitHandle);
    disp(FitHandle([1 2 3 4 5],X));
    disp(p);
    disp(p_Min);
    disp(p_Max);
    
%% (* Fitten *)
    FitParam_tmp = lsqcurvefit(FitHandle,p(~isnan(p_Min)),X,Y,...
        p_Min(~isnan(p_Min)),p_Max(~isnan(p_Min)),optimset('Display','off'));
    
    FitParam = p;
    FitParam(~isnan(p_Min)) = FitParam_tmp;

%% (* Ausgabe *)
    %Abkürzung
    L = length(FitFuncs);
    %Prealloc, Ausgabe ist eine Zelle, die Nummer entspricht der
    %zugeordneten Fit-Funktion
    FitParam_tmp = cell(1,L);
    %--> Durchlaufen der Fit-Funktionen
    for i_c = 1:L
        %Abkürzung
        S = size(FitFuncs(i_c).StartParams);
        %Auslesen und Reshapen der Parameter so, dass die Form von
        %FitFuncs(i_c).StartParams haben
        FitParam_tmp{i_c} = reshape(FitParam(1:S(1)*S(2)),S(1),[]);
        %Die bearbeiteten Parameter entfernen
        FitParam = FitParam(S(1)*S(2)+1:end);
    end
    %Rückgabewert
    FitParam = FitParam_tmp;
end
%--------------------------------------------------------------------------
% Hilfsfunktion, um die Funktionsargumente zu erzeugen, Range ist ein
% Vektor mit natürlichen Zahlen.
% Input: Range, Vektor mit natürlichen Zahlen, Indizies der Argumente,
%         double|interger|vector|positive
% Output: Argument-String der Form (x,p(Range(1)),...,Range(n)), string|row
function rtn = CreateFuncArgs(Range)
    rtn = '(x,';
    for i_c = 1:length(Range)
        rtn = [rtn, 'p(',num2str(Range(i_c)),'),'];
    end
    rtn(end) = ')';
end