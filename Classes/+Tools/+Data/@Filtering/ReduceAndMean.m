% Zunächst wird lowess, dann der Mittelwertfilter genutzt. SF = SmootFactor
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        SF_Reduce, Glättungsfakor für lowess, double|va /
%        SF_Mean, Glättungsfaktor für MW, double|va
% Output: X_out, DB der geglätteten Daten, Unit1, double|[size(X)]
%         Y_out, Geglättete Daten, Unit2, double|[size(Y)]
function [X_out,Y_out] = ReduceAndMean(X,Y,SF_Reduce,SF_Mean)

%% (* Stringenzprüfung *)
    validateattributes(X,{'double'},{'real','finite','vector'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(SF_Reduce,{'double'},...
        {'integer','even','nonnegative','scalar'});
    validateattributes(SF_Mean,{'double'},...
        {'integer','even','nonnegative','scalar'});

%% (* Glätten *)
    %Falls alle Faktoren = 0
    X_out = X;
    Y_out = Y;
    %--> Reduktion, wenn Faktor > 0
    if (SF_Reduce ~= 0), Y_out = smooth(Y_out,'lowess',SF_Reduce); end
    %--> Mitteln, wenn Faktor > 0
    if (SF_Mean ~= 0), Y_out = smooth(Y_out,SF_Mean); end
end