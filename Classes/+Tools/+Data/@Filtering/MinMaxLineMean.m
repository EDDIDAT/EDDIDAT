% Diese Gläätungsmethode bildet mit Hilfe von ReductionFilter eine
% Minimum-Linie und eine Maximum-Linie des Datensatzes. Das Ergebnis ist
% dann das Mittel aus diesen beiden.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        FilterWidth, Filterbreite (Min und Max), Unit1, double|va /
%        StepSize, Schrittgröße beim Filter, double|va
% Output: X_out, DB der geglätteten Daten, Unit1, double|[size(X)]
%         Y_out, Geglättete Daten, Unit2, double|[size(Y)]
function [X_out,Y_out] = MinMaxLineMean(X,Y,FilterWidth,StepSize)

%% (* Stringenzprüfung *)
    validateattributes(X,{'double'},{'real','finite','column'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(FilterWidth,{'double'},...
        {'real','scalar','positive'});
    validateattributes(StepSize,{'double'},...
        {'integer','finite','positive','scalar'});

%% (* Glätten *)
    %Minimum-Linie und Interpolation auf DB
    [X_min,Y_min] = Tools.Data.Filtering.ReductionFilter(X,Y,...
        'StepSize',StepSize,'FilterWidth',FilterWidth,'FilterFunction',...
        @(in)min(in,[],2));
    Y_min = interp1(X_min,Y_min,X,'linear','extrap');
    %Maximum-Linie und Interpolation auf DB
    [X_max,Y_max] = Tools.Data.Filtering.ReductionFilter(X,Y,...
        'StepSize',StepSize,'FilterWidth',FilterWidth,'FilterFunction',...
        @(in)max(in,[],2));
    Y_max = interp1(X_max,Y_max,X,'linear','extrap');
    %X bleibt unverändert
    X_out = X;
    %Mitteln
    Y_out = (Y_min + Y_max) ./ 2;
end