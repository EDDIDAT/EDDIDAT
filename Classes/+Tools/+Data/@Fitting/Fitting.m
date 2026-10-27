%% (* FIT-HELFER-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt dem Benutzer Funktionen zur Verf�gung, die
% helfen sollen, einen Datensatz, wie ein ED-Spektrum, zu fitten.
%--------------------------------------------------------------------------
classdef Fitting

%% (* Methoden *)
    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Fit vorbereiten *)
        %Sucht Peakregionen aus einem Rohdatensatz
        [X_out,Y_out,ReakRegions] = SearchPeakRegions(X,Y,varargin)
        %Sucht Peakregionen bei Untergrundreduzierten Daten
        [X_out,Y_out,ReakRegions,Index_Peaks] = SearchPeakRegions_BR(...
            X,Y,varargin)
        %Sucht und entfernt den Untergrund aus einem Spektrum
        [X_out,Y_out,Y_Background] = BackgroundReduction(...
            X,Y,ReakRegions,varargin)
        %Schaetzt den Untergrund automatisch mittels SNIP (Ryan et al.
        %1988), ohne manuell markierte Peakregionen
        Y_Background = SNIPBackground(Y,MaxHalfWindow,varargin)

    %% (* Fitvorgang *)
    % FP = FitPeak
        %Gauss-Fit
        [FitParam, CI, SE] = FP_Gauss(X,Y,Index_Peaks,PeakProps)
        %Gauss-Fit eines mehrfachen Peaks
        [FitParam, CI, SE] = FP_Gauss_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,PeakProps)
        %Lorentz-Fit
        [FitParam, CI, SE] = FP_Lorentz(X,Y,Index_Peaks,PeakProps)
        %Lorentz-Fit eines mehrfachen Peaks
        [FitParam, CI, SE] = FP_Lorentz_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,PeakProps)
        %Pseudo-Voigt-Fit eines einzelnen Peaks
        [FitParam, CI, SE] = FP_PseudoVoigt(X,Y,Index_Peaks,RelationGaussLorentz,...
            PeakProps)
        %Pseudo-Voigt-Fit eines mehrfachen Peaks
        [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
            PeakProps)
        %Pseudo-Voigt-Fit zweier sich ueberlappender Phasenreflexe
        %(gekoppelte Breite/GL-Anteil, z.B. Ferrit/Austenit)
        [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakCoupled(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
            PeakProps)
        %Pseudo-Voigt-Fit der martensitischen Aufspaltung eines
        %kubischen {200}-Reflexes in {002} und {200}/{020} (gekoppelte
        %Breite/GL-Anteil, feste 1:2-Intensitaetskopplung)
        [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakMartensite(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
            PeakProps)
        %Wie FP_PseudoVoigt_DoublePeakMartensite, aber mit unabhaengiger
        %Breite je Teilpeak (nur GL-Anteil gekoppelt)
        [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakMartensiteFreeWidth(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
            PeakProps)
        %Asymmetrischer Pseudo-Voigt-Fit (Sigmoid-Breite) eines einzelnen
        %Peaks
        [FitParam, CI, SE] = FP_AsymPseudoVoigt(X,Y,Index_Peaks,RelationGaussLorentz,AsymmetryStart,...
            PeakProps)
        %Asymmetrischer Pseudo-Voigt-Fit (Sigmoid-Breite) eines mehrfachen
        %Peaks
        [FitParam, CI, SE] = FP_AsymPseudoVoigt_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,AsymmetryStart,...
            PeakProps)
        %Split-Pseudo-Voigt-Fit (zwei Halbwertsbreiten) eines einzelnen
        %Peaks
        [FitParam, CI, SE] = FP_SplitPseudoVoigt(X,Y,Index_Peaks,RelationGaussLorentz,...
            PeakProps)
        %Split-Pseudo-Voigt-Fit (zwei Halbwertsbreiten) eines mehrfachen
        %Peaks
        [FitParam, CI, SE] = FP_SplitPseudoVoigt_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,...
            PeakProps)
        %TCH-Fit eines einzelnen Peaks
        [FitParam, CI, SE] = FP_TCH(X,Y,Index_Peaks,GammaGauss,GammaLorentz,...
            PeakProps)
        %TCH-Voigt-Fit eines mehrfachen Peaks
        [FitParam, CI, SE] = FP_TCH_DoublePeak(X,Y,Index_Peaks,PeakPosBoundarys,GammaGauss,GammaLorentz,...
             PeakProps)
        %Pseudo-Voigt-Fit eines einzelnen Peaks
        [FitParam, CI, SE] = FP_PseudoVoigtETA(X,Y,Index_Peaks,RelationGaussLorentz,...
            PeakProps)
        %Pseudo-Voigt-Fit eines mehrfachen Peaks ETA Messung
        [FitParam, CI, SE] = FP_PseudoVoigt_DoublePeakETA(X,Y,Index_Peaks,PeakPosBoundarys,RelationGaussLorentz,lambdaka1,lambdaka2,...
            PeakProps)
        %Komplett benutzerdefinierte Fitfunktion
        FitParam = FP_Custom(X,Y,varargin)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = Fitting(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - Versuch innere Peaks qualitativ zu finden: Peak-Positionen finden und
%   fitten, alle Funktionen, bis auf eine Abziehen (Herausl�schen aller 
%   umliegenden Peaks) ==> Schwer Punkt des �brigen Peaks finden und die
%   x-Koordinate mit dem Energie-Maximum vergleichen ==> Bei zu gro�er
%   Abweichung zweiter Peak