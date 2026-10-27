% Diese Funktion fittet zwei sich stark ueberlappende Peaks (z.B. Ferrit-
% und Austenit-Reflexe mit aehnlicher Gitterkonstante), die nur noch als
% EIN gemeinsames Maximum sichtbar sind, als Summe zweier PseudoVoigt-
% Funktionen mit UNABHAENGIGER Position und Intensitaet, aber GEKOPPELTER
% (gemeinsamer) Breite und Gauss/Lorentz-Anteil. Das reduziert die Anzahl
% freier Parameter von 8 (zwei unabhaengige PV-Peaks) auf 6 und
% stabilisiert den Fit, wenn keine zwei getrennten Maxima mehr zu sehen
% sind. Intern wird mit 6 Parametern gefittet; das Ergebnis wird
% anschliessend auf das aus FP_PseudoVoigt_DoublePeak bekannte 8-Spalten-
% Format [I1,pos1,w,GL,I2,pos2,w,GL] aufgeblasen (w und GL werden dabei
% dupliziert), damit nachgelagerter Code (PrepareFitPeaksPlot, Tabellen-
% und Export-Funktionen), der ein Ergebnis mit 4 Parametern pro Peak
% erwartet, unveraendert weiterverwendet werden kann.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        Index_Peaks, Peak-Indizies der beiden Phasenreflexe (genau 2!),
%         double|va /
%        PeakPosBoundarys, [lb;ub] fuer die 6 internen Parameter
%         [I1,pos1,I2,pos2,Breite,GL], double|[2 6] /
%        RelationGaussLorentz, Start-Anteilverhaeltnis zwischen Gauss und
%         Lorentz, double|va /
%        PeakProps, optionale Vorgabe-Hoehen [H1,H2], falls offen NaN,
%         double|[1 2]|va
% Output: FitParam, [I1,pos1,w,GL,I2,pos2,w,GL] (8 Spalten, kompatibel zu
%          FP_PseudoVoigt_DoublePeak), double|[1 8] /
%         CI, Confident-Intervals, double|[size(FitParam)] /
%         SE, Standard-Error, double|[size(FitParam)]
function [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakCoupled(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
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
    %Intensitaeten und Positionen (unabhaengig je Phase)
    p(1) = Y(Index_Peaks(1));  % Intensitaet Phase 1
    p(2) = X(Index_Peaks(1));  % Position Phase 1
    p(3) = Y(Index_Peaks(2));  % Intensitaet Phase 2
    p(4) = X(Index_Peaks(2));  % Position Phase 2
    %--> Vorgabewerte (Hoehe), falls gesetzt
    if ~isnan(PeakProps(1)), p(1) = PeakProps(1); end
    if ~isnan(PeakProps(2)), p(3) = PeakProps(2); end
    %Gemeinsame Breite und Gauss/Lorentz-Anteil (gekoppelt)
    p(5) = 0.25;
    p(6) = RelationGaussLorentz;

%% (* function_handle *)
    fun = @(p,x)(Tools.Science.Math.FF_PseudoVoigt(x,p(1),p(2),p(5),p(6)) + ...
                 Tools.Science.Math.FF_PseudoVoigt(x,p(3),p(4),p(5),p(6)));
    % p(1)=Intensity Phase1, p(2)=Position Phase1, p(3)=Intensity Phase2,
    % p(4)=Position Phase2, p(5)=gemeinsame Breite, p(6)=gemeinsamer GL-Anteil

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
    % Interne Reihenfolge: [I1,pos1,I2,pos2,w,GL]
    % Ziel-Reihenfolge:    [I1,pos1,w,GL,I2,pos2,w,GL] (w,GL dupliziert)
    expandIdx = [1 2 5 6 3 4 5 6];
    FitParam = FitParamInt(expandIdx);
    CI = CIInt(expandIdx);
    SE = SEInt(expandIdx);
end
