% Diese Funktion erwartet als Eingabe die Fitparameter bzw.
% Funktionsparameter einer Pseudo-Voigt-Funktion. Daraus werden dann die
% peak-relevanten Werte berechnet. Man kann auch mehrere Peaks auf einmal
% erzeugen, in dem man in die mehrere Zeilen mit jeweils 4 Parametern
% angibt.
% Input: FitParam, Fitparameter, double|va /
%        CI, Confident Intervals, double|va /     
%        Measurement_in, Mess-Objekt als Zusatzinformation, 
%         Measurement|opt|va
% Output: obj, neue(s) Peak-Objekt(e), DiffractionLine|scalar,
function obj = CreateFromFitParam_PV(FitParam,CI,Measurement_in)

%% (* Stringenzprüfung *)
%     validateattributes(FitParam,{'double'},{'real','size',[NaN 7]});
%     validateattributes(CI,{'double'},{'real','size',[NaN 4]});
    if nargin == 3
        validateattributes(Measurement_in,...
            {'Measurement.Measurement'},{'scalar'});
    else
        Measurement_in = Measurement.Measurement();
    end
    % Check if measurement was done with ETA3000, then size of FitParam is
    % [x,8] instead of [x,7] - change order of FitParam matrix
    if size(FitParam,2) == 8
        FitParam = FitParam(:, [1 2 3 4 6 7 8 5]);
    end
%% (* Erzeugen des Objektes *)
    obj = SpectraAnalysis.DiffractionLine.CloneConstruction(...
        @SpectraAnalysis.DiffractionLine,[size(FitParam,1) 1]);
    %--> Durchlaufen aller Objekte
    for i_c = 1:size(FitParam,1) 
        %Direkte Übergaben
        obj(i_c).Energy_Max = FitParam(i_c,2);
        obj(i_c).Energy_Max_Delta = CI(i_c,2);
        obj(i_c).Intensity_Max = FitParam(i_c,1);
        obj(i_c).Intensity_Int_calc = FitParam(i_c,7);
        obj(i_c).Intensity_Max_Delta = CI(i_c,1);
        obj(i_c).WeightingFactor = FitParam(i_c,4);
        %Intergrale Breite ermitteln
        obj(i_c).IntegralWidth = sqrt(2*pi) * FitParam(i_c,4) * ...
            FitParam(i_c,3) + pi * (1 - FitParam(i_c,4)) * ...
            FitParam(i_c,3) / 2;
        %FWHM ermitteln
        obj(i_c).FWHM = 2 * sqrt(2 * log(2)) * FitParam(i_c,4) * ...
            FitParam(i_c,3) + (1 - FitParam(i_c,4)) * FitParam(i_c,3);
        %Linien-Nummer bezüglich des Spektrums eintragen
        obj(i_c).LineNumber = [i_c 0];
        obj(i_c).Measurement = Measurement_in;
    end %--> for i_c = 1:size(FitParam,1)
end

