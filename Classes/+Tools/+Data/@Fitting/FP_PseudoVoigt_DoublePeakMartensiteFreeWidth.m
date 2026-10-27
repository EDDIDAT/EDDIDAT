% Wie FP_PseudoVoigt_DoublePeakMartensite, aber mit UNABHAENGIGER Breite
% je Teilpeak ({002} und {200}/{020}) statt einer gemeinsamen Breite.
% Der Gauss/Lorentz-Anteil bleibt weiterhin fuer beide Teilpeaks
% gekoppelt (ein gemeinsamer Wert), und die Intensitaet von {200}/{020}
% bleibt weiterhin fest an die von {002} gekoppelt: I({200}/{020}) =
% 2 * I({002}) (Multiplizitaet, siehe FP_PseudoVoigt_DoublePeakMartensite).
%
% WICHTIG: Index_Peaks(1) muss der {002}-Position entsprechen (der
% schwaechere der beiden Teilpeaks), Index_Peaks(2) der {200}/{020}-
% Position (der doppelt so intensive Teilpeak).
%
% Intern wird mit 6 Parametern gefittet; das Ergebnis wird anschliessend
% auf das aus FP_PseudoVoigt_DoublePeak bekannte 8-Spalten-Format
% [I1,pos1,w1,GL,I2,pos2,w2,GL] aufgeblasen (GL dupliziert, I2 = 2*I1),
% damit nachgelagerter Code unveraendert weiterverwendet werden kann.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        Index_Peaks, Peak-Indizies [002, 200/020], double|va /
%        PeakPosBoundarys, [lb;ub] fuer die 6 internen Parameter
%         [I_002,pos_002,pos_200020,Breite_002,Breite_200020,GL],
%         double|[2 6] /
%        RelationGaussLorentz, Start-Anteilverhaeltnis zwischen Gauss und
%         Lorentz, double|va /
%        PeakProps, zusaetzliche Peak-Informationen (Hoehe von {002}),
%         falls offen NaN, double|[1 2]|va
% Output: FitParam, [I1,pos1,w1,GL,I2,pos2,w2,GL] (8 Spalten, kompatibel
%          zu FP_PseudoVoigt_DoublePeak), double|[1 8] /
%         CI, Confident-Intervals, double|[size(FitParam)] /
%         SE, Standard-Error, double|[size(FitParam)]
function [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakMartensiteFreeWidth(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
    PeakProps)

%% (* Stringenzpruefung *)
    validateattributes(X,{'double'},{'real','finite','column'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(Index_Peaks,{'double'},...
        {'vector','integer','positive','<=',length(X),'numel',2});
    validateattributes(RelationGaussLorentz,{'double'},...
        {'real','scalar','>=',0,'<=',1});
    %--> Kontrolle der zusaetzlichen Peakeigenschaften
    if nargin >= 6
        validateattributes(PeakProps,{'double'},...
            {'real','size',[1 2]});
    else
        PeakProps = nan(1,2);
    end

%% (* Startwerte suchen *)
    p = zeros(1,6);
    %Intensitaet {002} (Startwert, {200}/{020} wird im Modell als 2*p(1)
    %berechnet)
    p(1) = Y(Index_Peaks(1));
    if ~isnan(PeakProps(1)), p(1) = PeakProps(1); end
    %Positionen (unabhaengig je Teilpeak)
    p(2) = X(Index_Peaks(1));  % Position {002}
    p(3) = X(Index_Peaks(2));  % Position {200}/{020}
    %Breiten (unabhaengig je Teilpeak)
    p(4) = 0.25;  % Breite {002}
    p(5) = 0.25;  % Breite {200}/{020}
    %Gemeinsamer Gauss/Lorentz-Anteil
    p(6) = RelationGaussLorentz;

%% (* function_handle *)
    % p(1)=Intensitaet {002}, p(2)=Position {002}, p(3)=Position
    % {200}/{020}, p(4)=Breite {002}, p(5)=Breite {200}/{020},
    % p(6)=gemeinsamer GL-Anteil. Intensitaet {200}/{020} = 2*p(1)
    % (Multiplizitaet).
    fun = @(p,x)(Tools.Science.Math.FF_PseudoVoigt(x,p(1),p(2),p(4),p(6)) + ...
                 Tools.Science.Math.FF_PseudoVoigt(x,2.*p(1),p(3),p(5),p(6)));

%% (* LSQ-Fit *)
    [FitParamInt,~,residual,~,~,~,jacobian] = lsqcurvefit(fun,p,X,Y,...
        PeakPosBoundarys(1,:),... % lb
        PeakPosBoundarys(2,:),... % ub
        optimset('Display','off'));

    %Confident Intervals
    CIInt = abs(nlparci(FitParamInt, residual, 'jacobian', jacobian) - [FitParamInt', FitParamInt']);
    CIInt = (max(CIInt,[],2)/1.96)';
    %Calculation of standard error
    [~,R] = qr(jacobian,0);
    Rinv = R\eye(size(R));
    diag_info = sum(Rinv.*Rinv,2);
    n_res = length(residual);
    p_res = numel(FitParamInt);
    v = n_res-p_res;
    rmse = norm(residual) / sqrt(v);
    SEInt = sqrt(diag_info) * rmse;
    SEInt = SEInt';

%% (* Auf 8-Spalten-Format aufblasen (kompatibel zu FP_PseudoVoigt_DoublePeak) *)
    % Interne Reihenfolge: [I_002,pos_002,pos_200020,w_002,w_200020,GL]
    % Ziel-Reihenfolge:    [I1,pos1,w1,GL,I2,pos2,w2,GL] (GL dupliziert,
    % I2 = 2*I1)
    FitParam = [FitParamInt(1), FitParamInt(2), FitParamInt(4), FitParamInt(6), ...
        2.*FitParamInt(1), FitParamInt(3), FitParamInt(5), FitParamInt(6)];
    CI = [CIInt(1), CIInt(2), CIInt(4), CIInt(6), ...
        2.*CIInt(1), CIInt(3), CIInt(5), CIInt(6)];
    SE = [SEInt(1), SEInt(2), SEInt(4), SEInt(6), ...
        2.*SEInt(1), SEInt(3), SEInt(5), SEInt(6)];
end
