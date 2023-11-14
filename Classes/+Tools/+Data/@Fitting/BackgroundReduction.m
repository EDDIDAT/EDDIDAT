% Diese Funktion zieht den Untergrund vom Spektrum ab. Dabei ist die
% Übergabe der Kanten der Peakregionen (siehe SearchPeakRegions) elementar,
% denn diese werden aus dem Untergrund ausgeschlossen und linear
% interpoliert. Eine empfohlene Glättung ist die Funktion MinMaxLineMean.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        PeakRegions, Peak-Regionen, double|va /
%        varargin, Optionen, ip
% Output: X_out, DB der Peakregionen, Unit1, double|[size(X)] /
%         Y_out, WB der Peakregionen, Unit2, double|[size(Y)] /
%         Y_Background, Untergrundlinie, die abgezogen wurde, Unit2,
%          double|[size(Y)]
function [X_out,Y_out,Y_Background] = BackgroundReduction(...
    X,Y,PeakRegions,varargin)
    
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
% + Peak-Regionen
    ip.addRequired('PeakRegions',@(x)validateattributes(x,...
        {'Tools.LogicalRegions'},{'scalar'}));
% + Parse
    ip.parse(X,Y,PeakRegions,varargin{:});
    
%% (* Übergabe der relevanten Eigenschaften *)
    %Eigenschaften einlesen
    Y_smoothed = ip.Results.Y_smoothed;
    
%% (* Untergrund abziehen *)
    %Peakregionen abziehen
    PeakRegions.Length = length(X);
    [~,Index] = setdiff(X,X(PeakRegions.Regions),'rows');
    %Auf den gesamten Definitionsbereich interpolieren
    Y_Background = interp1(X(Index),Y_smoothed(Index),X,'linear','extrap');
    
%% (* Eigentliches Abziehen und Wiedergabe *)
    %Abziehen des Untergrundes
    Y_out = Y - Y_Background;
    %X bleibt unverändert
    X_out = X;
end