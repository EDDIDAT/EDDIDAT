% Diese Funktion fittet einen gegeben Datensatz (in der Regel ein Peak aus
% einem Spektrum mit abgezogenem Untergrund) mit der PseudoVoigt-Funktion.
% Die Startwerte werden dabei weitestgehend automatisch gesucht. Wenn
% mehrere Peaks im DB sind, werden entsprechend viele Funktionen genommmen.
% Input: X, Defintionsbereich, Unit1, double|va /
%        Y, Wertebereich, Unit2, double|va /
%        Index_Peaks, Peak-Indizies in der Region, double|va /
%        RelationGaussLorentz, Start-Anteilverhältnis zwischen Gauss und 
%         Lorentz, double|va /
%        PeakProps, zusätzliche Peak-Informationen, 
%         [Peak-Höhen;Peak-Breiten (Sigma)], falls offen den entsprechenden
%         Wert NaN lassen, wenn komplett offen [], double|va
% Output: FitParam, Funktionsparameter, die die Optimierung ergab, wobei
%          pro Spalte immer eine Funktion steht, double|[NaN 4] /
%         CI, Confident-Intervals, double|[size(FitParam)]
function [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
    PeakProps)

%% (* Stringenzprüfung *)
    validateattributes(X,{'double'},{'real','finite','column'});
    validateattributes(Y,{'double'},{'real','finite','size',size(X)});
    validateattributes(Index_Peaks,{'double'},...
        {'vector','integer','positive','<=',length(X)});
%     validateattributes(PeakPosBoundarys,{'double'},...
%         {'real','finite'});
    validateattributes(RelationGaussLorentz,{'double'},...
        {'real','scalar','>=',0,'<=',1});
    %--> Kontrolle der zusätzlichen Peakeigenschaften
    if nargin >= 6
        validateattributes(PeakProps,{'double'},...
            {'real','size',[2 length(Index_Peaks)]});
    else
        %Wenn die Eigenschaft nicht gesetzt wurde, dann NaN-Array erzeugen
        PeakProps = nan([2 length(Index_Peaks)]);
    end
    
%% (* Vorbereitung *)
    %Zur besseren Übersicht
    L = length(Index_Peaks);
    %Prealloc der Fitparameter
    p(1:4,1:L) = 0;
    %--> Wenn es nur einen Peak gibt, nimm genauere Startwerte
    if L == 1
        
    %% (* Startwerte suchen *)
        %Maximale Stelle und zugehöriger Funktionswert
        [p(1),p(2)] = max(Y);
        p(2) = X(p(2));
        %--> Vorgabewert (Höhe)
        if ~isnan(PeakProps(1))
            p(1) = PeakProps(1); 
            p(2) = X(Index_Peaks(1)); 
        end
        %sigma (Flächenintegral / (I_max * sqrt(2pi)))
%         p(3) = sum(Y(1:end-1) .* diff(X)) / (p(1) * sqrt(2*pi));
        p(3) = 0.25;
        %--> Vorgabewert (Breite)
%         if ~isnan(PeakProps(2)), p(3) = PeakProps(2); end
        %Anteil von Gauss und Lorentz
        p(4) = RelationGaussLorentz;
        
    %% (* function_handle *)
        fun = @(p,x)Tools.Science.Math.FF_PseudoVoigt(...
            x,p(1),p(2),p(3),p(4)); % p(1)=Intensity, p(2)=PeakPosition, p(3)= PeakWidth, p(4)=RelationGaussLorentz
    %--> Wenn es mehrere Peaks gibt
    else
        
    %% (* Erstellen eines Summen-Handles *)
        %Anfang des Handles
        fun = '@(p,x)(0';
        %--> Erzeugen der Summanden
        for i_c = 1:L
            fun = [fun, '+Tools.Science.Math.FF_PseudoVoigt(x,p(',...
                num2str(i_c*4-3),'),p(',num2str(i_c*4-2),'),p(',...
                num2str(i_c*4-1),'),p(',num2str(i_c*4),'))'];
        end
        %Zusammenfügen
        fun = str2func([fun,')']);
        
    %% (* Startwerte suchen *)
        %Maxima und ihre Stellen
        p(1,:) = Y(Index_Peaks);
        p(2,:) = X(Index_Peaks);
        %Vorgabewerte (Höhe)
        p(1,~isnan(PeakProps(1,:))) = PeakProps(1,~isnan(PeakProps(1,:))); 
        p(2,~isnan(PeakProps(1,:))) = ...
            X(Index_Peaks(~isnan(PeakProps(1,:)))); 
        %Die relative Breite ist konstant (,wenn man annimmt, dass
        %Intensität und Flächeninhalt gleichmäßig sinken).
        %Damit kürzt sich die Abhänigkeit von der Intensität des Peaks
        %heraus.
%         p(3,:) = sum(Y(1:end-1) .* diff(X)) ./ (sum(p(1,:)) * sqrt(2*pi));
        p(3,:) = 0.25;
        %Vorgabewerte (Breite)
%         p(3,~isnan(PeakProps(2,:))) = PeakProps(2,~isnan(PeakProps(2,:)));
        %Anteil von Gauss und Lorentz
        p(4,:) = RelationGaussLorentz;
    end

%% (* LSQ-Fit *)
    %p(4*k) ist zwischen 0 und 1
    [FitParam,~,residual,~,~,~,jacobian] = lsqcurvefit(fun,(p(:))',X,Y,...
        PeakPosBoundarys(1,:),... % lb
        PeakPosBoundarys(2,:),... % ub
        optimset('Display','off'));
    
    %Confident Intervals
    CI = abs(nlparci(FitParam, residual, 'jacobian', jacobian) - [FitParam', FitParam']);
        % Aenderung 09.05.2016: CI hat vorher den gesamten Fehlerbereich
        % angegeben, da wir aber +/- Fehlerangabe machen, muss der CI-Wert
        % noch durch 2 geteilt werden. Der korrekte Fehler ergibt sich auch
        % durch die unten ausgeklammerte Vorgehensweise (se).
    CI = (max(CI,[],2)/1.96)';
    %Calculation of standard error
%     [CI] = nlparci(FitParam, residual, 'jacobian', jacobian);
    [~,R] = qr(jacobian,0);
    Rinv = R\eye(size(R));
    diag_info = sum(Rinv.*Rinv,2);
    n_res = length(residual);
    p_res = numel(FitParam);
    v = n_res-p_res;
    rmse = norm(residual) / sqrt(v);
    SE = sqrt(diag_info) * rmse;
    SE = SE';
end
