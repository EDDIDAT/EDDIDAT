% Diese Funktion sucht Peakregionen in einem Spektrum. Dabei wird einen
% Minimum-Linie gebildet, die knapp unter dem Spektrum verläuft. Ein
% Datenpunkt befindet sich genau dann ein einer Peakregion, wenn sich
% Differenz von Minimum-Linie und Spektrum um einen gewissen Wert
% unterscheidet (Delta_min). Als Glättungsfunktion wird DCTSmoothing 
% empfohlen.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        varargin, Optionen, ip
% Output: X_out, DB der Peakregionen, Unit1, double|column /
%         Y_out, DB der Peakregionen, Unit2, double|[size(X_out)] /
%         ReakRegions, die gefundenen Peakregionen, LogicalRegions
function [X_out,Y_out,PeakRegions] = SearchPeakRegions(X,Y,varargin)

%% (* Stringenzprüfung *)
% + InputParser
    ip = inputParser;
% + Definitions- und Wertebereich
    ip.addRequired('X',@(x)validateattributes(x,{'double'},...
        {'real','finite','column'}));
    ip.addRequired('Y',@(x)validateattributes(x,{'double'},...
        {'real','finite','size',size(X)}));
% + Filtereigenschaften
    %Breite des Suchintervalls, Unit1
    ip.addParamValue('FilterWidth',1.5,...
        @(x)validateattributes(x,{'double'},...
        {'real','scalar','positive'}));
    %Schrittgröße beim Schieben des Intervalls
    ip.addParamValue('StepSize',4,...
        @(x)validateattributes(x,{'double'},...
        {'integer','finite','positive','scalar'}));
% + Weitere Suchkriterien
    %Minimale Differenz zwischen Minimum-Linie und dem Datensatz, Unit2
    ip.addParamValue('Delta_min',50,...
        @(x)validateattributes(x,{'double'},...
        {'real','scalar','finite','positive'}));
    %Verbreiterungsfaktor, siehe EnlargeRegions
    ip.addParamValue('EnlargementFactor',0,...
        @(x)validateattributes(x,{'double'},{'real','finite','scalar'}));
% + Parse
    ip.parse(X,Y,varargin{:});
    
%% (* Minimum-Linie finden *)
    %Reduktionsfilter
    [X_min,Y_min] = Tools.Data.Filtering.ReductionFilter(X,Y,...
        'StepSize',ip.Results.StepSize,'FilterWidth',...
        ip.Results.FilterWidth,'FilterFunction',@(in)min(in,[],2));
    %Auf Definitionsbereich interpolieren
    Y_min = interp1(X_min,Y_min,X,'linear','extrap');
    
%% (* Differenzkriterium anwenden *)
    PeakRegions = abs(Y - Y_min) >= ip.Results.Delta_min;
    
%% (* Korrekturen *)
    %Erzeugen eine LogicalRegion-Objektes
    PeakRegions = Tools.LogicalRegions(PeakRegions);
    %Verbreiterung bzw. Verkleinerung der Regionen
    PeakRegions = PeakRegions.Enlarge(ip.Results.EnlargementFactor);
    %Korrektur der Länge
    PeakRegions.Length = length(X);

%% (* Rückgabewerte *)
    X_out = X(PeakRegions.Regions);
    Y_out = Y(PeakRegions.Regions);
end