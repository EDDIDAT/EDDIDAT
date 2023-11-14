classdef Chebfun < rietveld.func.spec.bkg.BkgInterface
	
	methods (Access = public)
		
		function Y = execute(obj, X, ~, ~, ~, spec)
			
            dataY = obj.fitContainer.getDataY;
            [~,Y] = airPLS(dataY', spec.Background,1,0.5);
            Y = Y';
            assignin('base','Yfitted',Y)
		end
		
		function obj = addFunctionParameters(obj, pc)
			
			obj.addParameter(pc, 'Background',...
				'Category', 'Background',...
				'ParamSize', [NaN, 1],...
				'Constant', false,...
				'PhaseDep', false,...
				'SpecDep', true);
		end
	end
end

