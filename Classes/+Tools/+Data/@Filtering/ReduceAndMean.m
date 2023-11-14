% Zun�chst wird lowess, dann der Mittelwertfilter genutzt. SF = SmootFactor
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        SF_Reduce, Gl�ttungsfakor f�r lowess, double|va /
%        SF_Mean, Gl�ttungsfaktor f�r MW, double|va
% Output: X_out, DB der gegl�tteten Daten, Unit1, double|[size(X)]
%         Y_out, Gegl�ttete Daten, Unit2, double|[size(Y)]
function [X_out,Y_out] = ReduceAndMean(X,Y,SF_Reduce,SF_Mean)

%% (* Stringenzpr�fung *)
    validateattributes(X,{'double'},{'real','finite','vector'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(SF_Reduce,{'double'},...
        {'integer','even','nonnegative','scalar'});
    validateattributes(SF_Mean,{'double'},...
        {'integer','even','nonnegative','scalar'});

%% (* Gl�tten *)
    %Falls alle Faktoren = 0
    X_out = X;
    Y_out = Y;
    %--> Reduktion, wenn Faktor > 0
    if (SF_Reduce ~= 0), Y_out = smooth(Y_out,'lowess',SF_Reduce); end
    %--> Mitteln, wenn Faktor > 0
    if (SF_Mean ~= 0), Y_out = smooth(Y_out,SF_Mean); end
end