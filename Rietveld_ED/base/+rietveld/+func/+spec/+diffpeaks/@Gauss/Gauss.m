classdef Gauss < rietveld.func.spec.diffpeaks.PeakInterface

	methods (Access = public)
		
		function Y = execute(obj, X, general, meas, phase, spec)
			
			ep = obj.sfwc.EnergyPos.execute([], general, meas, phase, spec);
			sigmatau = obj.sfwc.StressMod.execute([], general, meas, phase, spec);
			
			% Abkuerzung, da doppelt benoetigt
			acm = obj.sfwc.AttenuationCoeffMat.execute(ep, general, meas, phase, spec);
			
			% TODO: das ist auch eine Konstante
			INorm = 300;
			corr = (INorm / spec.RingCurrent) * (100 / (100 - spec.DeadTime));
			
			Intensity = general.ScaleFactor * corr * (...
				obj.sfwc.FHKL.execute([], general, meas, phase, spec) .* ...
				general.Multiplicity .* ...
				obj.sfwc.Wiggler.execute(ep) .* ...
				1 ./ (2 * phase.Density * acm) .* ...
				exp(- meas.DensityAir * meas.DetectorDistance * obj.sfwc.AttenuationCoeffAir.execute(ep, general, meas, phase, spec)) .* ...
				(12.398 ./ ep).^3);
						
			FWHM = general.U_Gauss .* ep + general.W_Gauss;
			
			eps_hkl = ((sind(spec.Psi)^2) * general.DEK_S2 + 2 * general.DEK_S1) .* sigmatau;
			
			Y = 0;
			for i = 1:size(general.H, 1)
				X_shift = X - ep(i);
				Y = Y + Intensity(i) * (2.*sqrt(log(2)./pi)./FWHM(i)) * ...
					exp(-4 * log(2) * ((X_shift + eps_hkl(i) * ep(i))/FWHM(i)).^2);
			end
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'Density',...
				'Category', 'Material',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', false);
			% TODO: Kategorie?
			obj.addParameter(pc, 'DEK_S1',...
				'Category', 'Material',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'DEK_S2',...
				'Category', 'Material',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			
			obj.addParameter(pc, 'TwoTheta',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', false);
			obj.addParameter(pc, 'DensityAir',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', false);
			obj.addParameter(pc, 'DetectorDistance',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', false);
			obj.addParameter(pc, 'RingCurrent',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
			obj.addParameter(pc, 'DeadTime',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
			obj.addParameter(pc, 'Psi',...
				'Category', 'Measurement',...
				'ParamSize', [1, 1],...
				'Constant', true,...
				'PhaseDep', false,...
				'SpecDep', true);
			
			obj.addParameter(pc, 'ScaleFactor',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'Multiplicity',...
				'Category', 'Peaks',...
				'ParamSize', [NaN, 1],...
				'Constant', true,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'U_Gauss',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
			obj.addParameter(pc, 'W_Gauss',...
				'Category', 'Peaks',...
				'ParamSize', [1, 1],...
				'Constant', false,...
				'PhaseDep', true,...
				'SpecDep', true);
		end
	end
	
	methods (Access = protected)
		
		function obj = initSubFunctions(obj)
			
			obj.addSubFunction('AttenuationCoeffMat', 'rietveld.func.spec.corr.AttenuationCoeffMat', rietveld.func.spec.corr.AttenuationCoeffMat());
			obj.addSubFunction('AttenuationCoeffAir', 'rietveld.func.spec.corr.AttenuationCoeffAir', rietveld.func.spec.corr.AttenuationCoeffAir());
			obj.addSubFunction('EnergyPos', 'rietveld.func.spec.EnergyPosInterface', rietveld.func.spec.EnergyPosInterface());
			obj.addSubFunction('Wiggler', 'rietveld.func.spec.corr.WigglerInterface', rietveld.func.spec.corr.WigglerInterface());
			obj.addSubFunction('FHKL', 'rietveld.func.spec.diffpeaks.fhkl.FHKLInterface', rietveld.func.spec.diffpeaks.fhkl.LeBail());
			obj.addSubFunction('StressMod', 'rietveld.func.spec.diffpeaks.stressmod.StressModInterface', rietveld.func.spec.diffpeaks.stressmod.StressModInterface());
		end
	end
end
