%% (* FIT-HELFER-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt dem Benutzer Funktionen zur Verfügung, die
% helfen sollen, einen Datensatz, wie ein ED-Spektrum, zu fitten.
%--------------------------------------------------------------------------
classdef Fitting

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
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
%   fitten, alle Funktionen, bis auf eine Abziehen (Herauslöschen aller 
%   umliegenden Peaks) ==> Schwer Punkt des übrigen Peaks finden und die
%   x-Koordinate mit dem Energie-Maximum vergleichen ==> Bei zu großer
%   Abweichung zweiter Peak