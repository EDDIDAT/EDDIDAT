% Diese Funktion fittet die martensitische Aufspaltung eines kubischen
% {200}-Reflexes (Ferrit/Martensit) in die tetragonalen Komponenten
% {002} und {200}/{020}. Beide Komponenten bekommen unabhaengige
% Positionen, aber gekoppelte (gemeinsame) Breite und Gauss/Lorentz-
% Anteil (wie FP_PseudoVoigt_DoublePeakCoupled). Zusaetzlich wird die
% Intensitaet NICHT unabhaengig gefittet, sondern aufgrund der
% Multiplizitaet fest an die von {002} gekoppelt: I({200}/{020}) =
% 2 * I({002}) (2 aequivalente Ebenen {200},{020} gegenueber 1
% aequivalenten Ebene {002}, unter der Annahme einer statistischen/
% texturfreien Orientierungsverteilung des Martensits). Das reduziert
% die Anzahl freier Parameter von 8 (unabhaengige PV-Peaks) auf 5 und
% macht den Fit bei der typischerweise sehr geringen tetragonalen
% Aufspaltung deutlich robuster.
%
% WICHTIG: Index_Peaks(1) muss der {002}-Position entsprechen (der
% schwaechere der beiden Teilpeaks), Index_Peaks(2) der {200}/{020}-
% Position (der doppelt so intensive Teilpeak). Bei vertauschter
% Reihenfolge wird die 1:2-Kopplung auf den falschen Peak angewendet.
%
% Intern wird mit 5 Parametern gefittet; das Ergebnis wird anschliessend
% auf das aus FP_PseudoVoigt_DoublePeak bekannte 8-Spalten-Format
% [I1,pos1,w,GL,I2,pos2,w,GL] aufgeblasen (w, GL dupliziert, I2 = 2*I1),
% damit nachgelagerter Code unveraendert weiterverwendet werden kann.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        Index_Peaks, Peak-Indizies [002, 200/020], double|va /
%        PeakPosBoundarys, [lb;ub] fuer die 5 internen Parameter
%         [I_002,pos_002,pos_200020,Breite,GL], double|[2 5] /
%        RelationGaussLorentz, Start-Anteilverhaeltnis zwischen Gauss und
%         Lorentz, double|va /
%        PeakProps, zusaetzliche Peak-Informationen (Hoehe von {002}),
%         falls offen NaN, double|[1 2]|va
% Output: FitParam, [I1,pos1,w,GL,I2,pos2,w,GL] (8 Spalten, kompatibel zu
%          FP_PseudoVoigt_DoublePeak), double|[1 8] /
%         CI, Confident-Intervals, double|[size(FitParam)] /
%         SE, Standard-Error, double|[size(FitParam)]
function [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakMartensite(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
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
    p = zeros(1,5);
    %Intensitaet {002} (Startwert, {200}/{020} wird im Modell als 2*p(1)
    %berechnet)
    p(1) = Y(Index_Peaks(1));
    if ~isnan(PeakProps(1)), p(1) = PeakProps(1); end
    %Positionen (unabhaengig je Teilpeak)
    p(2) = X(Index_Peaks(1));  % Position {002}
    p(3) = X(Index_Peaks(2));  % Position {200}/{020}
    %Gemeinsame Breite und Gauss/Lorentz-Anteil (gekoppelt)
    p(4) = 0.25;
    p(5) = RelationGaussLorentz;

%% (* function_handle *)
    % p(1)=Intensitaet {002}, p(2)=Position {002}, p(3)=Position
    % {200}/{020}, p(4)=gemeinsame Breite, p(5)=gemeinsamer GL-Anteil.
    % Intensitaet {200}/{020} = 2*p(1) (Multiplizitaet).
    fun = @(p,x)(Tools.Science.Math.FF_PseudoVoigt(x,p(1),p(2),p(4),p(5)) + ...
                 Tools.Science.Math.FF_PseudoVoigt(x,2.*p(1),p(3),p(4),p(5)));

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
    % Interne Reihenfolge: [I_002,pos_002,pos_200020,w,GL]
    % Ziel-Reihenfolge:    [I1,pos1,w,GL,I2,pos2,w,GL] (w,GL dupliziert,
    % I2 = 2*I1)
    FitParam = [FitParamInt(1), FitParamInt(2), FitParamInt(4), FitParamInt(5), ...
        2.*FitParamInt(1), FitParamInt(3), FitParamInt(4), FitParamInt(5)];
    CI = [CIInt(1), CIInt(2), CIInt(4), CIInt(5), ...
        2.*CIInt(1), CIInt(3), CIInt(4), CIInt(5)];
    SE = [SEInt(1), SEInt(2), SEInt(4), SEInt(5), ...
        2.*SEInt(1), SEInt(3), SEInt(4), SEInt(5)];
end
