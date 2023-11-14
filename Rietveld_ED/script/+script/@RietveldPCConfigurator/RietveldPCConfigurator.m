classdef RietveldPCConfigurator < hgsetget
	
	properties (Access = private)
		
		pc;
	end
	
	methods (Access = public)
		
		function obj = configParameter(obj, name, varargin)
			
			ip = inputParser();
			ip.addRequired('Name', @ischar);
			ip.addParamValue('Value', NaN, @isnumeric);
			ip.addParamValue('PhaseIndex',: , @isnumeric);
			ip.addParamValue('SpecIndex',: , @isnumeric);
			ip.addParamValue('LowerConstraint', NaN, @isnumeric);
			ip.addParamValue('UpperConstraint', NaN, @isnumeric);
			ip.addParamValue('Refinable', true, @islogical);
			ip.parse(name, varargin{:});
			res = ip.Results;
			
			p = [];
			% finde Parameter mit Durchlauf der Gruppen
			for groupName = obj.pc.getGroupNames()
				
				% wenn Parameter vorhanden,...
				if any(strcmp(res.Name, obj.pc.getParamNames(groupName{1})))
					
					% ...lies die Parameter mit den entsprechenden Indizes
					% aus
					if (strcmp(groupName{1}, 'meas'))
				
						p = obj.pc.getParam(groupName{1}, res.Name);
					elseif (strcmp(groupName{1}, 'phase'))
						
						p = obj.pc.getParam(groupName{1}, res.Name, res.PhaseIndex);
					elseif (strcmp(groupName{1}, 'spec'))
						
						p = obj.pc.getParam(groupName{1}, res.Name, res.SpecIndex);
					else
						
						p = obj.pc.getParam(groupName{1}, res.Name, res.PhaseIndex, res.SpecIndex);
					end
				end
			end
			
			% Trage in die Parameter ein
			for i = 1:numel(p)
				if all(~isnan(res.Value))
					p(i).setValue(res.Value);
				end
				if (isa(p, 'fitting.FitParameter'))
					if all(~isnan(res.LowerConstraint))
						p(i).setLowerConstraint(res.LowerConstraint);
					end
					if all(~isnan(res.UpperConstraint))
						p(i).setUpperConstraint(res.UpperConstraint);
					end
					if (res.Refinable)
						p(i).setLinking(0);
					else
						p(i).setLinking(-1);
					end
				end
			end
		end
	end
	
	methods (Access = public)
		
		function obj = RietveldPCConfigurator(pc)
			
			validateattributes(pc, {'base.ParameterContainer'}, {'scalar'});
			
			obj.pc = pc;
		end
	end
end

