%% (* DATENOPERATIONEN-KLASSE *)
%--------------------------------------------------------------------------
% Diese statische Klasse stellt einige generelle Methoden bzw. Operationen
% zum Umgang mit Datens�tzen (Arrays von doubles) bereit.
%--------------------------------------------------------------------------
classdef DataSetOperations

%% (* Methoden *)
    %--> �ffentliche, statische Methoden
    methods (Static = true, Access = public)
    %% (* Indexierung von Datens�tzen *)
        %Gibt den Index des am n�chstengelegensten Datenwertes wieder
        [Index,Value] = FindNearestIndex(X,x)
    end
    
%% (* Konstruktor *)
    methods (Access = public)
        %Privater Konstruktor, um die Instanzierung zu verhindern
        function obj = DataSetOperations(), end
    end
end

