% Diese Funktion erwartet als Eingabe die Fitparameter bzw.
% Funktionsparameter einer Split- (bifurkierten) Pseudo-Voigt-Funktion
% (zwei Halbwertsbreiten, siehe Tools.Science.Math.FF_SplitPseudoVoigt).
% Daraus werden dann die peak-relevanten Werte berechnet. Man kann auch
% mehrere Peaks auf einmal erzeugen, in dem man mehrere Zeilen mit jeweils
% 8 Werten angibt: [Intensitaet,Position,Breite_links,Breite_rechts,
% GL-Anteil,IntegralBreite,FWHM,Integrierte Intensitaet].
% Die beiden Halbwertsbreiten werden in die Eigenschaften WidthLeft/
% WidthRight uebernommen. IntegralWidth/FWHM werden wie bei
% CreateFromFitParam_PV naeherungsweise ueber die effektive Breite
% w_eff = (Breite_links+Breite_rechts)/2 berechnet.
% Input: FitParam, Fitparameter, double|va /
%        CI, Confident Intervals, double|va /
%        Measurement_in, Mess-Objekt als Zusatzinformation,
%         Measurement|opt|va
% Output: obj, neue(s) Peak-Objekt(e), DiffractionLine|scalar,
function obj = CreateFromFitParam_SplitPV(FitParam,CI,Measurement_in)

%% (* Stringenzpr�fung *)
    if nargin == 3
        validateattributes(Measurement_in,...
            {'Measurement.Measurement'},{'scalar'});
    else
        Measurement_in = Measurement.Measurement();
    end
%% (* Erzeugen des Objektes *)
    obj = SpectraAnalysis.DiffractionLine.CloneConstruction(...
        @SpectraAnalysis.DiffractionLine,[size(FitParam,1) 1]);
    %--> Durchlaufen aller Objekte
    for i_c = 1:size(FitParam,1)
        %Direkte �bergaben
        obj(i_c).Energy_Max = FitParam(i_c,2);
        obj(i_c).Energy_Max_Delta = CI(i_c,2);
        obj(i_c).Intensity_Max = FitParam(i_c,1);
        obj(i_c).Intensity_Int_calc = FitParam(i_c,8);
        obj(i_c).Intensity_Max_Delta = CI(i_c,1);
        obj(i_c).WeightingFactor = FitParam(i_c,5);
        obj(i_c).WidthLeft = FitParam(i_c,3);
        obj(i_c).WidthRight = FitParam(i_c,4);
        %Effektive Breite (Mittelwert aus Breite links/rechts)
        WEff = (FitParam(i_c,3) + FitParam(i_c,4)) / 2;
        %Intergrale Breite ermitteln (naeherungsweise ueber die
        %effektive Breite, wie bei der symmetrischen Pseudo-Voigt-Funktion)
        obj(i_c).IntegralWidth = sqrt(2*pi) * FitParam(i_c,5) * ...
            WEff + pi * (1 - FitParam(i_c,5)) * WEff / 2;
        %FWHM ermitteln
        obj(i_c).FWHM = 2 * sqrt(2 * log(2)) * FitParam(i_c,5) * ...
            WEff + (1 - FitParam(i_c,5)) * WEff;
        %Linien-Nummer bez�glich des Spektrums eintragen
        obj(i_c).LineNumber = [i_c 0];
        obj(i_c).Measurement = Measurement_in;
    end %--> for i_c = 1:size(FitParam,1)
end
