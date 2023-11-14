% Ähnlich wie bei SearchPeakRegions werden hier Peak-Regionen gesucht. Die
% Voraussetzung sind dabei Daten, bei denen der Untergrund bereits
% abgezogen wurde (,bzw. etwa konstant ist) (BR = BackgroundReduced). Dafür
% ist der Algorithmus zuverlässiger und genauer. Er sollte für das Suchen
% der Fitregionen eingesetzt werden. Intern werden zunächst per
% ReductionFilter die Peaks gesucht. Anschließend wird geschaut, ab wann
% von diesen Stellen ausgehend der Untergrund (also ein konstanter Wert)
% erreicht ist. Als Glättungsfunktion wird DCTSmoothing empfohlen.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        varargin, Optionen, ip
% Output: X_out, DB der Peakregionen, Unit1, double|column /
%         Y_out, DB der Peakregionen, Unit2, double|[size(X_out)] /
%         PeakRegions, die ermittelten Peakregionen, LogicalRegions /
%         Index_Peaks, die ermittelten Peakindizies,
%          double|column|integer|positive|[size(PREdges,1)]
function [X_out,Y_out,PeakRegions,Index_Peaks] = SearchPeakRegions_BR(...
    X,Y,varargin)

%% (* Stringenzprüfung *)
% + InputParser
    ip = inputParser;
% + Definitions- und Wertebereich
    ip.addRequired('X',@(x)validateattributes(x,{'double'},...
        {'real','finite','column'}));
    ip.addRequired('Y',@(x)validateattributes(x,{'double'},...
        {'real','finite','size',size(X)}));
    %Sollen geglättete Daten benutzt werden?, Standard: nein
    ip.addOptional('Y_smoothed',Y,@(x)validateattributes(x,{'double'},...
        {'real','finite','size',size(X)}));
% + Peak-Filtereigenschaften
    %Breite des Suchintervalls, Unit1
    ip.addParamValue('FilterWidth',1.5,...
        @(x)validateattributes(x,{'double'},...
        {'real','scalar','positive'}));
    %Schrittgröße beim Schieben des Intervalls
    ip.addParamValue('StepSize',4,...
        @(x)validateattributes(x,{'double'},...
        {'integer','finite','positive','scalar'}));
    %Mindestdifferenz zwischen Peak und Untergrund, Unit2
    ip.addParamValue('Delta_min',50,...
        @(x)validateattributes(x,{'double'},...
        {'real','scalar','finite','nonnegative'}));
    %Mindesthöhe damit ein Peak als solcher erkannt wird, Unit2
    ip.addParamValue('MinPeakHeight',0,...
        @(x)validateattributes(x,{'double'},...
        {'real','scalar','finite'}));
% + Weitere Suchkriterien
    %Konstante, die die Höhe des Untergrunds angibt, kann sich auch von der
    %echten Höhe unterscheiden
    ip.addParamValue('BackgroundHeight',0,...
        @(x)validateattributes(x,{'double'},{'real','finite','scalar'}));
    %Verbreiterungsfaktor, siehe EnlargeRegions
    ip.addParamValue('EnlargementFactor',0,...
        @(x)validateattributes(x,{'double'},{'real','finite','scalar'}));
% + Parse
    ip.parse(X,Y,varargin{:});
    
%% (* Übergabe der relevanten Eigenschaften *)
    %Eigenschaften einlesen
    Y_smoothed = ip.Results.Y_smoothed;
    BackgroundHeight = ip.Results.BackgroundHeight;
   
%% (* Peak-Positionen ermitteln *)
    [~,~,Index_Peaks] = Tools.Data.Filtering.ReductionFilter(...
        X,Y_smoothed,'FilterWidth',ip.Results.FilterWidth,...
        'StepSize',ip.Results.StepSize,'FilterFunction',...
        @(in)Tools.Data.Filtering.RF_SearchPeaks(...
        in,ip.Results.Delta_min,ip.Results.MinPeakHeight,...
        @(in)min(in,[],2),@(in)max(in,[],2)));
    
%% (* Peak-Regionen ermitteln *)
    %Prealloc
    PRLimits_tmp(1:2,length(Index_Peaks)) = 0;
    %--> Die jeweils zu den Peaks nächsten (linken und rechten) Werte, die
    %    die Bedingung erfüllen werden ermitteln
    for i_c = 1:length(Index_Peaks)
        PRLimits_tmp(1,i_c) = find(Y(1:Index_Peaks(i_c)) <= ...
            BackgroundHeight,1,'last');
        PRLimits_tmp(2,i_c) = Index_Peaks(i_c) - 1 + ...
            find(Y(Index_Peaks(i_c):end) <= BackgroundHeight,1,'first');
    end
    %PeakRegionen-Objekt erzeugen
    PeakRegions = Tools.LogicalRegions(PRLimits_tmp,length(X));
    
%% (* Korrekturen *)
    PeakRegions = PeakRegions.Enlarge(ip.Results.EnlargementFactor);
    PeakRegions.Length = length(X);
    
%% (* Rückgabewerte *)
    %Teilmengen aus DB und WB
    X_out = X(PeakRegions.Regions);
    Y_out = Y(PeakRegions.Regions);
end