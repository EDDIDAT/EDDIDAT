%% (* DATENOPERATIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt einige generelle Methoden bzw. Operationen
% zum Umgang mit Datensätzen (Arrays von doubles) bereit.
%--------------------------------------------------------------------------
classdef DataSetOperations

%% (* Methoden *)
    %--> Öffentliche, statische Methoden
    methods (Static = true, Access = public)
    %% (* Indexierung von Datensätzen *)
        %Gibt den Index des am nächstengelegensten Datenwertes wieder
        [Index,Value] = FindNearestIndex(X,x)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = DataSetOperations(), end
    end
end

