classdef RVMicrostructure < hgsetget
%% (* RVMicrostructure *)
% Diese Klasse kann zur Auswertung der Parameter der Mikrostruktur benutzt
% werden.
% ------------------------------------------------------------------------
	
%% Felder
	
	properties (GetAccess = public, SetAccess = private)
		
		% zugrunde liegender "RVContainer"
		rvContainer;
	end
	
	methods (Access = public)
		
		function obj = setRVContainer(obj, rvContainer)
			
			validateattributes(rvContainer, {'rietveld.base.RVContainer'}, {'scalar'});
			obj.rvContainer = rvContainer;
		end
		
		function rvContainer = getRVContainer(obj)
			
			rvContainer = obj.rvContainer;
		end
	end
	
%% Konstruktor
	
	methods (Access = public)
		
		function obj = RVMicrostructure(rvContainer)
		% Default-Konstruktor erwarten einen "RVContainer".
			
			obj.setRVContainer(rvContainer);
		end
	end

%% Export
	
	methods(Access = public)
		
		function ms = computeMicrostructure(obj)
			
% 			specSize = obj.getRVContainer().getSpecSize();
			
			Instr_P = [obj.getRVContainer.getParam('general','P_Size').lowerConstraint];
			Meas_P = [obj.getRVContainer.getParam('general','P_Size').value];
			Phys_P = (Meas_P - Instr_P)';

			Instr_X = [obj.getRVContainer.getParam('general','X_Size').lowerConstraint];
			Meas_X = [obj.getRVContainer.getParam('general','X_Size').value];
			Phys_X = (Meas_X - Instr_X)';

			Instr_U = [obj.getRVContainer.getParam('general','U_Strain').lowerConstraint];
			Meas_U = [obj.getRVContainer.getParam('general','U_Strain').value];
			Phys_U = (Meas_U - Instr_U)';

			Instr_Y = [obj.getRVContainer.getParam('general','Y_Strain').lowerConstraint];
			Meas_Y = [obj.getRVContainer.getParam('general','Y_Strain').value];
			Phys_Y = (Meas_Y - Instr_Y)';
			
% 			TwoTheta = obj.getRVContainer.getParam('spec','TwoTheta').value;
			TwoTheta = obj.getRVContainer.getParam('meas','TwoTheta').value;
	
			beta_L_size = pi./2.*Phys_X;

			beta_G_size = sqrt(pi./4./log(2).*Phys_P);

			beta_L_strain = pi./2.*Phys_Y;

			beta_G_strain = sqrt(pi./4./log(2).*Phys_U);

			beta_Size = beta_G_size./(-0.5.*beta_L_size./beta_G_size+0.5.*sqrt(pi.*(beta_L_size./(sqrt(pi).*beta_G_size)).^2+4)-0.234.*beta_L_size./(sqrt(pi).*beta_G_size).*exp(-2.176.*beta_L_size./(sqrt(pi).*beta_G_size)));

			beta_Strain = beta_G_strain./(-0.5.*beta_L_strain./beta_G_strain+0.5.*sqrt(pi.*(beta_L_strain./(sqrt(pi).*beta_G_strain)).^2+4)-0.234.*beta_L_strain./(sqrt(pi).*beta_G_strain).*exp(-2.176.*beta_L_strain./(sqrt(pi).*beta_G_strain)));

			Size = (6.199)./(beta_Size.*sind(TwoTheta./2));
% 			Size = (6.199)./(beta_Size.*sin(TwoTheta./2.*pi./180));
			
			Strain = beta_Strain./2;
			
			% Header fuer die gespeicherte Textdatei.
            % Den Eintrag 'Phi' hab ich rausgelöscht, da der Parameter
            % nicht definiert war. Unten muss es auch wieder auskommentiert
            % werden.
			Headers = {'Psi', 'P_measured', 'P_sample', 'X_measured', 'X_sample', ...
		   'U_measured', 'U_sample', 'Y_measured', 'Y_sample', ...
		   'beta_L_size', 'beta_G_size', 'beta_L_strain', 'beta_G_strain', ...
		   'beta_Size', 'beta_Strain', 'Size_[A]', 'Strain'};
			% Matrix erstellt aus den verwendeten Daten.
			ms = [Meas_P', Phys_P, Meas_X', Phys_X, Meas_U', Phys_U, Meas_Y', Phys_Y, beta_L_size, beta_G_size, beta_L_strain, beta_G_strain, beta_Size, beta_Strain, Size, Strain];		   
			
			% Parametercontainer auslesen.
			params = struct2cell(obj.getRVContainer().getParamStruct());
			SpecSize = obj.getRVContainer.getSpecSize;
			% Psi auslesen.
			PsiTmp = zeros(SpecSize);
			for i = 1:SpecSize
				PsiTmp(i,:) = params{4,1}(i,1).Psi;
			end
			PsiTmp = reshape(PsiTmp,SpecSize);

			% Phi auslesen.
% 			PhiTmp = zeros(SpecSize);
% 			for i = 1:SpecSize
% 				PhiTmp(i,:) = params{4,1}(i,1).Phi;
% 			end
			
% 			Dat = [PsiTmp, PhiTmp, ms];
            Dat = [PsiTmp, ms];
			% Numbers are converted to strings using num2str, because 
			% fprintf expects just strings. By using cellfun every element
			% of num2cell(...) is converted iteratively in strings,
			% obtaining a cell.
			Data = cellfun(@num2str, num2cell(Dat), 'UniformOutput', false);
			Final = [Headers;Data];
			% Speichern der Daten in einer Textdatei.
			fid = fopen('MicrostructureAnalysis.txt','wt');
% 			[filenamePattern, num2str(i), '.dat']
			
			for i = 1:size(Final,1)
				fprintf(fid,'%s ', Final{i,:});
				fprintf(fid,'\n');
			end
			
			fclose(fid);
						
        end
	end
	
end

