function ResultsTable = Sin2PsiZScanEvaluation(h, varargin)
% SIN2PSIZSCANEVALUATION  sin2psi-Spannungsauswertung fuer einen Z-Scan,
% gemessen bei zwei psi-Stellungen (0 deg und -90 deg), automatisiert
% ueber alle Z-Positionen.
%
% Repliziert die in tabbedGUI.m eingebaute Rechnung (siehe
% buttoncreatepsi1 "Load fit data" / buttonloadstressdata "Load stress
% data", insbes. DiffractionLine.m LatticeSpacing/-Delta, ~Zeile 15900
% [fitlm d vs sin^2psi], ~Zeile 16085 [d0 ueber psi*-Methode],
% ~Zeile 16113 [sigma = slope/d0/halbS2]) -- die GUI selbst iteriert
% dabei NICHT ueber Z-Positionen, das uebernimmt dieses Skript.
%
% Voraussetzung: In EDDIDAT wurde "Load fit data" (Fitting-Tab) bereits
% ausgefuehrt, sodass h.Psidata (bzw. h.PsidataDet1/h.PsidataDet2 bei
% LEDDI_KETEK_TWODET) gefuellt ist. h.Psidata.<Feld>(k,l) ist dabei
% [NumPeaks x NumScans], als cellstr (String) abgelegt:
%   Energy_Max, Energy_Max_Delta, twotheta, phi, psi,
%   SampleStagePos1/2/3 (= x/y/z)
%
% Input:
%   h                EDDIDAT-GUI-Struktur (z.B. per "guidata" oder
%                     "assignin('base','h',h)" im Workspace verfuegbar)
%   Name-Value:
%     'PsidataField'  'Psidata' (Default), 'PsidataDet1' oder
%                      'PsidataDet2' (LEDDI_KETEK_TWODET)
%     'DEK'            [NumPeaks x 2]-Matrix [s1, halbS2] falls
%                      h.Params.DEK nicht (passend) vorhanden ist.
%                      h.Params.DEK ist sonst [hkl, s1, halbS2] pro Peak.
%     'ZComponent'     1, 2 oder 3 fuer SampleStagePos-Komponente, die
%                      die Z-Achse ist (Default 3)
%
% Output:
%   ResultsTable     Tabelle mit einer Zeile pro (Peak, Z-Position):
%                     Peak, Z, Sigma, D0, PsiStar, Slope, D_psi0, D_psi90
%                     Zusaetzlich wird ein Plot Sigma vs. Z erzeugt.

%% (* Eingaben pruefen *)
    ip = inputParser;
    ip.addParameter('PsidataField','Psidata',@(x)ischar(x)||isstring(x));
    ip.addParameter('DEK',[],@(x)isempty(x) || (ismatrix(x) && size(x,2)==2));
    ip.addParameter('ZComponent',3,@(x)isscalar(x) && ismember(x,[1 2 3]));
    ip.parse(varargin{:});
    PsidataField = char(ip.Results.PsidataField);
    DEK = ip.Results.DEK;
    ZComponent = ip.Results.ZComponent;

    if ~isfield(h,PsidataField)
        error('Sin2PsiZScanEvaluation:NoPsidata', ...
            'h.%s nicht gefunden. Erst "Load fit data" im Fitting-Tab ausfuehren.', PsidataField);
    end
    Psidata = h.(PsidataField);

    % Psidata.<Feld> ist [NumScans x NumPeaks] -- Zeile = Scan, Spalte =
    % Peak (bestaetigt ueber FilterDiffLine/DiffractionLines{Scan}(Peak)
    % in tabbedGUI.m, buttoncreatepsi1)
    NumScans = size(Psidata.Energy_Max,1);
    NumPeaks = size(Psidata.Energy_Max,2);

%% (* DEK (Diffraktions-Elastizitaetskonstanten) besorgen *)
    if isempty(DEK)
        if isfield(h,'Params') && isfield(h.Params,'DEK') && size(h.Params.DEK,1) >= NumPeaks
            % h.Params.DEK = [hkl, s1, halbS2] pro Peak-Zeile
            DEK = h.Params.DEK(1:NumPeaks,2:3);
        else
            error('Sin2PsiZScanEvaluation:NoDEK', ...
                ['Keine DEK-Werte gefunden. Entweder h.Params.DEK im GUI ' ...
                 '(Stress Analysis-Tab, "Load DEK") fuellen, oder direkt ' ...
                 'uebergeben: Sin2PsiZScanEvaluation(h,''DEK'',[s1_Peak1 halbS2_Peak1; s1_Peak2 halbS2_Peak2])']);
        end
    end
    if size(DEK,1) < NumPeaks
        error('Sin2PsiZScanEvaluation:DEKSizeMismatch', ...
            'DEK hat nur %d Zeile(n), es werden aber %d (fuer %d Peaks) benoetigt.', size(DEK,1), NumPeaks, NumPeaks);
    end

    hc2 = 0.6199; % keV*nm, hc/2 (identisch zu DiffractionLine.m get.LatticeSpacing)

%% (* Pro Peak und Z-Position auswerten *)
    Results = struct('Peak',{},'Z',{},'Sigma',{},'D0',{},'PsiStar',{}, ...
        'Slope',{},'D_psi0',{},'D_psi90',{},'Psi_psi0',{},'Psi_psi90',{});
    rowIdx = 0;

    for k = 1:NumPeaks
        E     = str2double(Psidata.Energy_Max(:,k))';
        dE    = str2double(Psidata.Energy_Max_Delta(:,k))';
        twoth = str2double(Psidata.twotheta(:,k))';
        psi   = str2double(Psidata.psi(:,k))';
        zpos  = str2double(Psidata.(sprintf('SampleStagePos%d',ZComponent))(:,k))';

        % Wie DiffractionLine.m: Delta=0 wuerde Gewicht/Fehlerfortpfl.
        % unbrauchbar machen, daher Mindestwert
        dE(dE == 0) = 0.01;

        % Bragg-Gleichung (energiedispersiv, fester 2theta), siehe
        % DiffractionLine.m get.LatticeSpacing (nicht-ETA3000-Zweig)
        d = hc2 ./ sind(twoth/2) ./ E;
        % Fehlerfortpflanzung, siehe DiffractionLine.m get.LatticeSpacing_Delta
        dDelta = d .* dE ./ E; %#ok<NASGU> -- aktuell nur informativ, nicht gewichtet (2 Punkte)

        s1 = DEK(k,1);
        halfS2 = DEK(k,2);
        psiStar = asind(sqrt(-2*s1/halfS2));

        zRound = round(zpos,6);
        zUnique = unique(zRound);
        for iz = 1:length(zUnique)
            m = zRound == zUnique(iz);
            if sum(m) ~= 2
                warning('Sin2PsiZScanEvaluation:UnexpectedCount', ...
                    'Peak %d, Z=%.4f: %d Eintraege statt 2 -- uebersprungen.', k, zUnique(iz), sum(m));
                continue
            end
            psi_m = psi(m); d_m = d(m);

            % Robuste Zuordnung zu psi=0 / psi=-90 (unabhaengig von
            % Reihenfolge der beiden Eintraege)
            [~,idx0] = min(abs(psi_m - 0));
            [~,idx90] = min(abs(psi_m - (-90)));
            if idx0 == idx90
                warning('Sin2PsiZScanEvaluation:AmbiguousPsi', ...
                    'Peak %d, Z=%.4f: psi-Werte (%.2f, %.2f) nicht eindeutig 0/-90 zuordenbar -- uebersprungen.', ...
                    k, zUnique(iz), psi_m(1), psi_m(2));
                continue
            end
            d0v = d_m(idx0); d90v = d_m(idx90);
            psi0v = psi_m(idx0); psi90v = psi_m(idx90);

            % Steigung d vs. sin^2(psi) -- bei genau 2 Punkten identisch
            % zur gewichteten Regression im GUI (fitlm), da eine Gerade
            % durch 2 Punkte eindeutig ist
            slope = (d90v - d0v) / (sind(psi90v)^2 - sind(psi0v)^2);

            % d0 ueber psi*-Methode: lineare Interpolation/Extrapolation
            % von d vs. rohem psi (Grad), ausgewertet bei psi*
            % (klassische psi*-Methode, siehe tabbedGUI.m ~16085)
            slopePsi = (d90v - d0v) / (psi90v - psi0v);
            d0Value = d0v + slopePsi * (psiStar - psi0v);

            sigma = slope / d0Value / halfS2;

            rowIdx = rowIdx + 1;
            Results(rowIdx).Peak = k;
            Results(rowIdx).Z = zUnique(iz);
            Results(rowIdx).Sigma = sigma;
            Results(rowIdx).D0 = d0Value;
            Results(rowIdx).PsiStar = psiStar;
            Results(rowIdx).Slope = slope;
            Results(rowIdx).D_psi0 = d0v;
            Results(rowIdx).D_psi90 = d90v;
            Results(rowIdx).Psi_psi0 = psi0v;
            Results(rowIdx).Psi_psi90 = psi90v;
        end
    end

    if rowIdx == 0
        error('Sin2PsiZScanEvaluation:NoResults', ...
            'Keine gueltigen (Peak,Z)-Paare gefunden. Psidata/DEK/ZComponent pruefen.');
    end

    ResultsTable = struct2table(Results);

%% (* Plot: Sigma vs. Z, getrennt nach Peak *)
    figure('Name','sin^2\psi Spannungsauswertung ueber Z-Scan');
    hold on
    markers = {'o-','s-','^-','d-'};
    for k = 1:NumPeaks
        mkPeak = ResultsTable.Peak == k;
        [zsorted,order] = sort(ResultsTable.Z(mkPeak));
        sigmaPeak = ResultsTable.Sigma(mkPeak);
        sigmaPeak = sigmaPeak(order);
        plot(zsorted, sigmaPeak, markers{mod(k-1,numel(markers))+1}, ...
            'DisplayName', sprintf('Peak %d',k), 'LineWidth', 1.5, 'MarkerSize', 6);
    end
    xlabel('Z-Position');
    ylabel('\sigma');
    title('sin^2\psi Spannung vs. Z-Position');
    legend show
    grid on
end
