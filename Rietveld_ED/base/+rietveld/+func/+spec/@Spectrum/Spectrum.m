classdef Spectrum < rietveld.base.RVFunction
%% (* Spectrum *)
% Hier wird das Spektrum berechnet. Neben dem Untergrund werden die Peaks
% von den zugehoerigen Untermodulen berechnet. Dabei wird auch nach
% Material-Phasen aufgeteilt.
% -------------------------------------------------------------------------
	
	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)

			phaseCnt = obj.getFitContainer().getPhaseCnt();
			
			Y = 0;
			
			% Fluoressenz-, Escape- und Diffraktionspeaks
			for p = 1:phaseCnt
					
				Y = Y + obj.sfwc.Fluorescence.execute(X, general(p), meas, phase(p), spec) + ...
						obj.sfwc.Escape.execute(X, general(p), meas, phase(p), spec) + ...
						obj.sfwc.DiffPeaks.execute(X, general(p), meas, phase(p), spec);
			end

% 			Untergrund, Wigglerspektrum und Dummys
			Y = Y + obj.sfwc.Background.execute(X, general, meas, phase, spec) + ...
				obj.sfwc.DummyPeaks.execute(X, general, meas, phase, spec);
			
% 			Y = Y + obj.sfwc.Background.execute(X, general, meas, phase, spec) + ...
% 				obj.sfwc.DummyPeaks.execute(X, general, meas, phase, spec) + ...
% 				obj.sfwc.SinglePeakAnalysis.execute(X, general, meas, phase, spec);
			
% 			assignin('base', 'X_DataEnergy', X);
			
% 			Y = Y .* obj.sfwc.Wiggler.execute(X);
		end
		
		function obj = addFunctionParameters(obj, pc) %#ok
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('Background', 'rietveld.func.spec.bkg.BkgInterface', rietveld.func.spec.bkg.BkgInterface());
			obj.addSubFunction('Fluorescence', 'rietveld.func.spec.fluor.FluorInterface', rietveld.func.spec.fluor.FluorInterface());
			obj.addSubFunction('Escape', 'rietveld.func.spec.escape.EscapeInterface', rietveld.func.spec.escape.EscapeInterface());
			obj.addSubFunction('DiffPeaks', 'rietveld.func.spec.diffpeaks.PeakInterface', rietveld.func.spec.diffpeaks.PeakInterface());
% 			obj.addSubFunction('EnergyCalibCorr', 'rietveld.func.spec.corr.EnergyCalibCorrInterface', rietveld.func.spec.corr.EnergyCalibCorrInterface());
			obj.addSubFunction('DummyPeaks', 'rietveld.func.spec.dummy.DummyInterface', rietveld.func.spec.dummy.DummyInterface());
% 			obj.addSubFunction('SinglePeakAnalysis', 'rietveld.func.spec.dummy.DummyInterface', rietveld.func.spec.dummy.DummyInterface());
% 			obj.addSubFunction('Wiggler', 'rietveld.func.spec.corr.WigglerInterface', rietveld.func.spec.corr.WigglerInterface());
		end
	end
end

