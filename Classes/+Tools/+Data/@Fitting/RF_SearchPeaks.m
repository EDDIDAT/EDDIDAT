% Diese Reduction-Funktion sucht in den Intervallen nach Peaks. Dabei wird
% nach dem Maximum (MaximumFun) des Datensatzes gesucht und zusätzlich nach
% den links- und rechtsseitigen Minimum (MinimumFun). Nur wenn die
% Differenz auf beiden Seiten hinreichen groß ist (>Delta_min), so wird das
% Maximum als Peak gewertet. Weiterhin kann man auch eine absolute
% Mindesthöhe für den Peak vorgeben (findet vor allem Anwendung bei
% entferntem Untergrund). Es kann ein ganzes Array von Intervallen
% übergeben werden (je Intervall eine Zeile).
% Input: Y, Intervall-Matrix ReductionFilter [In_1;In_2;...], Unit,
%         double|va /
%        Delta_min, Minimale Differenz zwischen Minimum und Maximum, Unit,
%         double|va /
%        MinPeakHeight, Minimale Höhe, damit das Maximum als Peak anerkannt
%         wird, Unit, double|va /
%        MinimumFun, Minimum des Datensatzes finden, function_handle|va /
%        MaximumFun, Maximum des Datensatzes finden, function_handle|va
% Output: Max, Maximalewerte des Intervalls, NaN, falls die Bedingungen 
%          nicht erfüllt sind, Unit, double|[size(Y,1)] /
%         Index_Max, Indizies der Maxima bezogen auf das Intevall, 
%          double|[size(Y,1)]
function [Max,Index_Max] = RF_SearchPeaks(Y,Delta_min,MinPeakHeight, ...
                                       MinimumFun, MaximumFun)
    
%% (* Stringenzprüfung *)
    validateattributes(Y,{'double'},{'real','finite'});
    validateattributes(Delta_min,{'double'},...
        {'real','scalar','finite','nonnegative'});
    validateattributes(MinPeakHeight,{'double'},...
        {'real','scalar','finite'});
    validateattributes(MinimumFun,{'function_handle'},{'scalar'});
    validateattributes(MaximumFun,{'function_handle'},{'scalar'});
                                   
%% (* Alogrithmus anwenden *)
    %Maxima ermitteln
    [Max,Index_Max] = MaximumFun(Y);
    %Prealloc
    Min_Left(1:size(Y,1),1) = 0;
    Min_Right(1:size(Y,1),1) = 0;
    %--> Zeilenweisen ermitteln der Minima
    for i_c = 1:size(Y,1)
        %Linkes Minimum ermitteln
        Min_Left(i_c,1) = MinimumFun(Y(i_c,1:Index_Max(i_c)));
        %Rechtes Minimum ermitteln
        Min_Right(i_c,1) = MinimumFun(Y(i_c,Index_Max(i_c):end));
    end
    %Sind die hinreichenden Bedingungen erfüllt?
    Cond = (Max - Min_Left >= Delta_min) &...
        (Max - Min_Right >= Delta_min) & (Max >= MinPeakHeight);
    %Alle übrigen Werte NaN setzen
    Max(~Cond) = NaN;
    Index_Max(~Cond) = NaN;
end

% Min_Left = cumsum(double(repmat(Max,1,size(Y,2)) == Y),2);
% Min_Left(Min_Left == 0) = NaN;
% Min_Left(~isnan(Min_Left)) = 1;
% Min_Left = MinimumFun(Y .* Min_Left);