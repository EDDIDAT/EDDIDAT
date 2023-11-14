function javaRVPC = import(rc, mode)

	% Validation
	validateattributes(rc, {'rietveld.base.RVContainer'}, {'scalar'});
	validatestring(mode, {'all', 'once phase', 'once spec', 'once'});

	% leere Liste anlegen (fuer die Parameter)
	list = java.util.ArrayList();
	
	% Nur im "all"-Modus, werden die Werte nicht mit NaNs aufgefuellt
	if (strcmp(mode, 'all'))
		
		fillWithNaN = false;
	else
		
		fillWithNaN = true;
	end
	
	% SpecSize vereinfachen
	specSize = rc.getSpecSize();
	if (length(specSize) > 1 && specSize(end) == 1)
		
		specSize = specSize(1:end-1);
    end
    
	% Durchlaufe die Parameter, Hinzufuegen je nach Modus und Gruppe
	
	for name = rc.getParamNames('meas')

		param = rc.getParam('meas', name{1});
		
		% weder Phase noch Spektrum
		list.add(createJavaParameter(param, -1, [], fillWithNaN));
	end
	
	for name = rc.getParamNames('phase')
		
		% weder Phase noch Spektrum
		if (strcmp(mode, 'once phase') || strcmp(mode, 'once'))
			
			param = rc.getParam('phase', name{1}, 1);
			list.add(createJavaParameter(param, -1, [], fillWithNaN));
			
		% mit Phase
		else

			for i = 1:rc.getPhaseCnt()

				param = rc.getParam('phase', name{1}, i);
				list.add(createJavaParameter(param, i, [], fillWithNaN));
			end
		end
	end
	
	for name = rc.getParamNames('spec')

		% weder Phase noch Spektrum
		if (strcmp(mode, 'once spec') || strcmp(mode, 'once'))
			
			param = rc.getParam('spec', name{1}, 1);
			list.add(createJavaParameter(param, -1, [], fillWithNaN));
			
		% mit Spektrum
		else
			
			for i = 1:prod(specSize)

				param = rc.getParam('spec', name{1}, i);
				ind = cell(length(specSize),1);
				[ind{:}] = ind2sub(specSize, i);
				list.add(createJavaParameter(param, -1, cell2mat(ind), fillWithNaN));
			end
		end
	end
	
	for name = rc.getParamNames('general')

		% weder Phase noch Spektrum
		if (strcmp(mode, 'once'))
			
			param = rc.getParam('general', name{1}, 1);
			list.add(createJavaParameter(param, -1, [], fillWithNaN));
		
		% nur Spektrum
		elseif (strcmp(mode, 'once phase'))
			
			for i = 1:prod(specSize)

				param = rc.getParam('general', name{1}, 1, i);
				ind = cell(length(specSize),1);
				[ind{:}] = ind2sub(specSize, i);
				list.add(createJavaParameter(param, -1, cell2mat(ind), fillWithNaN));
			end
		
		% nur Phase
		elseif (strcmp(mode, 'once spec'))
			
			for i = 1:rc.getPhaseCnt()

				param = rc.getParam('general', name{1}, i);
				list.add(createJavaParameter(param, i, [], fillWithNaN));
			end
			
		% alles
		else
		
			for i = 1:rc.getPhaseCnt

				for j = 1:prod(specSize)

					param = rc.getParam('general', name{1}, i, j);
					ind = cell(length(specSize),1);
					[ind{:}] = ind2sub(specSize, j);
					list.add(createJavaParameter(param, i, cell2mat(ind), fillWithNaN));
				end
			end
		end
	end

	javaRVPC = rvgui.param.RVParameterContainer(list);
end

function jParam = createJavaParameter(param, phase, specInd, fillWithNaN)
% Hilfsmethode, die einen Java-Parameter erstellt

	% FitParameter?
	if (isa(param, 'fitting.FitParameter'))
		
		jParam = rvgui.param.RVFitParameter();
		
		% passendes Eintragen der Werte, Konvertierungen mit
		% "createJavaArray"
		jParam.getPhaseIndex.setValue(java.lang.Integer(phase));
		jParam.getSpecIndex.setValue(rvgui.util.IndexVector(java.Utils.createJavaArray(specInd, 'java.lang.Integer', true)));
		paramSize = param.getParamSize();
		paramSize(isnan(paramSize)) = -1;
		jParam.getParamSize.setValue(rvgui.util.IndexVector(java.Utils.createJavaArray(...
			paramSize, 'java.lang.Integer', true)));
		jParam.getName.setValue(param.getName());
		jParam.getCategory.setValue(param.getCategory());
		
		jParam.getValue.setValue(createDoubleMatrix(param.getValue(), fillWithNaN));
		jParam.getLowerConstraint.setValue(createDoubleMatrix(param.getLowerConstraint(), fillWithNaN));
		jParam.getUpperConstraint.setValue(createDoubleMatrix(param.getUpperConstraint(), fillWithNaN));
		
		jParam.getConstant.setValue(java.lang.Boolean(false));
		if param.getLinking() >= 0

			jParam.getRefinable.setValue(java.lang.Boolean(true));
		end
	else

		jParam = rvgui.param.RVConstantParameter();
		
		% passendes Eintragen der Werte, Konvertierungen mit
		% "createJavaArray"
		jParam.getPhaseIndex.setValue(java.lang.Integer(phase));
		jParam.getSpecIndex.setValue(rvgui.util.IndexVector(java.Utils.createJavaArray(specInd, 'java.lang.Integer', true)));
		paramSize = param.getParamSize();
		paramSize(isnan(paramSize)) = -1;
		jParam.getParamSize.setValue(rvgui.util.IndexVector(java.Utils.createJavaArray(...
			paramSize, 'java.lang.Integer', true)));
		jParam.getName.setValue(param.getName());
		jParam.getCategory.setValue(param.getCategory());
		jParam.getValue.setValue(createDoubleMatrix(param.getValue(), fillWithNaN));
		jParam.getConstant.setValue(java.lang.Boolean(false));
	end	
end

function dm = createDoubleMatrix(matlabMatrix, fillWithNaN)
% Hilfsmethode, die eine "DoubleMatrix" (Java) erstellt.

	if (fillWithNaN)
		
		dm = rvgui.matrix.DoubleMatrix(java.lang.Double(NaN));
	else
		
		% Spezialfall einer leeren Matrix (1 x 0)
		if (isempty(matlabMatrix))
			
			dm = rvgui.matrix.DoubleMatrix(...
				java.Utils.createJavaArray(zeros(1,0), 'java.lang.Double'));
		else
			
			dm = rvgui.matrix.DoubleMatrix(...
				java.Utils.createJavaArray(matlabMatrix, 'java.lang.Double'));
		end
	end
end

