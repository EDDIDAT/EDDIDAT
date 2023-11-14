classdef FitContainer < base.ParameterContainer
%% (* FitContainer *)
% Diese Klasse fasst alle Informationen ueber den Fit zusammen. Sie
% enthaelt die Parameter-Objekte, Fit-Daten und -Funktionen. Wird ein Fit
% mit einem Fitter fuer diesen Container ausgeführt, so werden die
% Ergebnisse gerade in den Parametern gespeichert. Fuer die Verwaltung der
% Parameter erbt diese Klasse von "ParameterContainer".
% TODO: executeFitFunction
% -------------------------------------------------------------------------
	
%% Felder

	properties (GetAccess = public, SetAccess = private)
		
		% Die zu fittenden X-Daten
		% Muss nicht die Groesse von dataY haben.
		dataX = 0;
		% Die zu fittenden Y-Daten
		% Muss nicht die Groesse von dataX haben.
		dataY = 0;
		
		% Die Fit-Funktion. 
		% Ein Objekt, welches von "FitFunction" erbt.
		fitFunction = [];
	end
	
	methods (Access = public)
		
		function obj = setDataX(obj, dataX)
			
			validateattributes(dataX, {'double'}, {'nonempty', 'finite'});
			obj.dataX = dataX;
		end
		
		function dataX = getDataX(obj, varargin)
		% Mit "varargin" kann "dataX" subindexed werden.
			
			dataX = obj.dataX(varargin{:});
		end
		
		function obj = setDataY(obj, dataY)
			
			validateattributes(dataY, {'double'}, {'nonempty', 'finite'});
			obj.dataY = dataY;
		end
		
		function dataY = getDataY(obj, varargin)
		% Mit "varargin" kann "dataY" subindexed werden.
			
			dataY = obj.dataY(varargin{:});
		end
		
		function obj = setFitFunction(obj, fitFunction)
			
			validateattributes(fitFunction, {'fitting.FitFunction'}, {'scalar'});
			obj.fitFunction = fitFunction;
		end
		
		function fitFunction = getFitFunction(obj)
			
			fitFunction = obj.fitFunction;
		end
	end
end

