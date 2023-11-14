% In dieser Funktion wird ein kleines Intervall (Breite = FilterWidth)
% durch den Definitionsbereich "geschoben". Auf dieses Intervall wird die
% FilterFunction angewendet und der herauskommende Wert an der zugehörigen 
% Stelle im Defintionsbereich abgespeichert. Für die Vektorisierung dieses
% Algorithmuss wurden alle Intervalle zeilenweise untereinander in eine
% Matrix geschrieben. FilterFunction arbeitet also zeilenweise und gibt
% dann einen Wertevektor und einen Indexvektor zurück (Die Größe ist
% jeweils die Anzahl der Intervalle). Es handelt sich dabei um eine
% wichtige Funktion, um den Untergrund eines Datensatzes zu fitten und
% dessen Peaks zu finden.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        varargin, Optionen, ip
% Output: X_out, DB zu den gefilterten, reduzierten Daten, Unit1, 
%          double|column /
%         Y_out, Gefilterte, reduzierte Daten, Unit2, double|[size(X_out)]/
%         Index, Indizies in Bezug auf den ursprünglichen DB, 
%          double|[size(X_out)]
function [X_out,Y_out,Index] = ReductionFilter(X,Y,varargin)

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
    %Funktion die benutzt wird, um den Datensatz zu filtern
    ip.addParamValue('FilterFunction',@(in)min(in,[],2),...
        @(x)validateattributes(x,{'function_handle'},{'scalar'}));
% + Parse
    ip.parse(X,Y,varargin{:});

%% (* Übergabe der relevanten Eigenschaften *)
    %FilterWidth einlesen, Umrechnen des Bereiches in eine ganze Zahl
    %anhand des Definitionsbereichs
    FilterWidth = round(length(X) * ip.Results.FilterWidth / ...
        (X(end)-X(1)));
    
%% (* Intervall-Matrix erzeugen *)
    %Grundintervall
    FR_X = 1:FilterWidth;
    %Anfangspositionen des Grundintervalls
    FR_Y = 1:ip.Results.StepSize:length(X)-FilterWidth+1;
    %Erzeugen des passenenden Filter-Bereiches(Zeilen sind die Intervalle)
    [FR_X,FR_Y] = meshgrid(FR_X,FR_Y);
    %FilterRange ist die oben beschriebene Intervallmatrix
    FilterRange = FR_X + FR_Y - 1;
    
%% (* Anwenden der Filterfunktion *)
    %Die Funktion muss Zeilenweise arbeiten (z. B. @(x)min(x,[],2))
    [Y_out,Index] = ip.Results.FilterFunction(Y(FilterRange));
    %Indizies bezogen auf den gesamen Definitionsbereich
    Index = FilterRange(:,1) + Index - 1;

%% (* Wiedergabe des gefilterten Datensatzes *)
% Eine einfache Zuweisungs genügt an dieser Stelle nicht, denn es kann
% durchaus sein, dass es zu bestimmten Intervallen keine Werte (NaN) gibt,
% so dass diese natürlich entfernt werden müssen
    %NaNs und doppelte Werte entfernen, UniqueIndex = Indizies der nicht 
    %doppelten Werte von Index 
    [Index,UniqueIndex] = unique(Index(~isnan(Index)));
    %Definitionsbereich
    X_out = X(Index);
    %Wertebereich (NaNs entfernen und die passenden Indizies nehmen)
    Y_out = Y_out(~isnan(Y_out));
    Y_out = Y_out(UniqueIndex);
end