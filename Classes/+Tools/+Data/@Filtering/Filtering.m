% (* FILTER-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt einige komlexere Filter- und 
% Glättungsfunktionen zur Verfügung.
%--------------------------------------------------------------------------
classdef Filtering

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
        
    %% (* Eigener Reduktionsfilter *)
    % Neben der Hauptfilterfunktion gibt es noch einige Filterbausteine,
    % die in den ReductionFilter eingesetzt werden können (RF =
    % ReductionFilter)
        %Hauptfilterfunktion
        [X_out,Y_out,Index] = ReductionFilter(X,Y,varargin)
        %Diese Funktion sucht nach einem Peak
        [Max,Index_Max] = RF_SearchPeaks(...
            Y,Delta_min,MinPeakHeight,MinimumFun,MaximumFun)
        
    %% (* Kombinationen mit "smooth" *)
        %Erst Reduktion, dann Mittelwertglättung
        [X_out,Y_out] = ReduceAndMean(X,Y,SF_Reduce,SF_Mean)
        
    %% (* Weitere Methoden *)
        %Daten-Filter der einen Mittelwert aus einer Minimum- und
        %Maximumlinie nutzt
        [X_out,Y_out] = MinMaxLineMean(X,Y,FilterWidth,StepSize)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = Filtering(), end
    end
end

%% ##### TO BE IMPLEMENTED #####
% - RF_SearchPeaks: for-Schleifen entfernen, ohne langsamer zu werden
% - Eine bessere Variante für die Datenwiedergabe bei ReductionFilter (das
%   NaN-Entfernen sollte sich nur auf den Index beziehen (Y_out kann ja
%   trotzdem NaN sein, obwohl Index nicht NaN ist)