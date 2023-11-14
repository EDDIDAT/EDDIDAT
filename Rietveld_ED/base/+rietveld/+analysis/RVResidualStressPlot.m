classdef RVResidualStressPlot < hgsetget
%% (* RVResidualStressPlot *)
% Diese Klasse kann zur Auswertung und graphischen Überwachung der 
% Parameter der verfeinerten Spannungskoeffizienten benutzt werden.
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
		
		function obj = RVResidualStressPlot(rvContainer)
		% Default-Konstruktor erwarten einen "RVContainer".
			
			obj.setRVContainer(rvContainer);
		end
	end

%% Residual Stress Plot
	
	methods(Access = public)
		
		function rs = plotResidualStress(obj, tauboundary)
			
			% Auslesen der Spannungskoeffizienten aus dem
			% Parameter Container.
			
			Sigmatau11_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef1').value;
			Sigmatau11_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef2').value;
			Sigmatau11_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef3').value;
			Sigmatau11_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef4').value;
			Sigmatau11_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef5').value;
			
			Sigmatau22_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef1').value;
			Sigmatau22_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef2').value;
			Sigmatau22_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef3').value;
			Sigmatau22_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef4').value;
			Sigmatau22_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef5').value;
			
			Sigmatau33_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef1').value;
			Sigmatau33_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef2').value;
			Sigmatau33_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef3').value;
			Sigmatau33_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef4').value;
			Sigmatau33_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef5').value;
			
			% Anordnen der Parameter.
			
			Sigmatau11 = [Sigmatau11_StressCoef1, Sigmatau11_StressCoef2, Sigmatau11_StressCoef3, Sigmatau11_StressCoef4, Sigmatau11_StressCoef5]';
			Sigmatau22 = [Sigmatau22_StressCoef1, Sigmatau22_StressCoef2, Sigmatau22_StressCoef3, Sigmatau22_StressCoef4, Sigmatau22_StressCoef5]';
			Sigmatau33 = [Sigmatau33_StressCoef1, Sigmatau33_StressCoef2, Sigmatau33_StressCoef3, Sigmatau33_StressCoef4, Sigmatau33_StressCoef5]';
			
			Sigmatau_all = [Sigmatau11, Sigmatau22, Sigmatau33];
			
			% Vorgabe für den tau- bzw. z-Bereich.
			
			tau = linspace(0, tauboundary, 600);
			
			rscalc_Laplace = ([length(Sigmatau_all), length(tau)]);
			
			% Berechnung der Spannungsverlaeufe im Laplace-Raum.
			
			for p = 1:3
				for i = 1:length(tau)
					rscalc_Laplace(p,i) = Sigmatau_all(1,p)./(Sigmatau_all(5,p).*tau(i) + 1) + ...
					(Sigmatau_all(2,p).*tau(i))./(Sigmatau_all(5,p).*tau(i) + 1).^2 + ...
					(2.* Sigmatau_all(3,p).*tau(i).^2)./(Sigmatau_all(5,p).*tau(i) + 1).^3 + ...
					(6.* Sigmatau_all(4,p).*tau(i).^3)./(Sigmatau_all(5,p).*tau(i) + 1).^4;
% 					rscalc(p,i) = rscalc';
				end
			end
			
			rscalc_Real = ([length(Sigmatau_all), length(tau)]);
			
			% Berechnung der Spannungsverlaeufe im Real-Raum.
			
			for p = 1:3
				for i = 1:length(tau)
					rscalc_Real(p,i) = (Sigmatau_all(1,p) + Sigmatau_all(2,p).*tau(i) + ...
					Sigmatau_all(3,p).*tau(i).^2 + Sigmatau_all(4,p).*tau(i).^3).*exp(-Sigmatau_all(5,p).*tau(i));
				end
			end
			
			rs_Laplace = rscalc_Laplace';
			rs_Real = rscalc_Real';
			
			rs = [rs_Laplace, rs_Real];
			assignin('base', 'residual_stresses', rs);
			
			figure(2)
			hold on
			plot(tau,rs(:,1),'b--','Linewidth',2); % Plot von Sigma_11(tau)
			plot(tau,rs(:,4),'b-','Linewidth',2); % Plot von Sigma_11(z)
			plot(tau,rs(:,2),'g--','Linewidth',2); % Plot von Sigma_22(tau)
			plot(tau,rs(:,5),'g-','Linewidth',2); % Plot von Sigma_22(z)
			plot(tau,rs(:,3),'r--','Linewidth',2); % Plot von Sigma_33(tau)
			plot(tau,rs(:,6),'r-','Linewidth',2); % Plot von Sigma_33(z)
			hold off
			legend('\sigma_{11}(\tau)','\sigma_{11}(z)', '\sigma_{22}(\tau)', '\sigma_{22}(z)', '\sigma_{33}(\tau)', '\sigma_{33}(z)',...
				   'Location', 'SouthEast'); % Legende
			title('Residual Stress Distribution'); % Titel
			ylabel('residual stress [MPa]'); xlabel('\tau, z [µm]'); % Achsenbeschriftung
			grid
		end
		
		function exportData(obj, tauboundary)
			% Dieses Modul erzeugt eine Text-Datei, die die ermittelten
			% Eigenspannungsverlaeufe für die einzelnen
			% Spannungstensorkomponenten auflistet. Zusaetzlich werden noch
			% die aktuellen Spannungskoeffizienten aufgelistet.
			
			% Auslesen der Eigenspannungsverlaeufe.
			residualstresses = evalin('base', 'residual_stresses');
			
			% Festlegen der Eindringtiefe (muss identisch sein mit tau aus
			% dem Modul "plotResidualStress".
			tau = linspace(0, tauboundary, 600);
			
			% Auslesen der aktuellen Spannungskoeffizienten.
			Sigmatau11_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef1').value;
			Sigmatau11_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef2').value;
			Sigmatau11_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef3').value;
			Sigmatau11_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef4').value;
			Sigmatau11_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma11_StressCoef5').value;
			
			Sigmatau22_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef1').value;
			Sigmatau22_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef2').value;
			Sigmatau22_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef3').value;
			Sigmatau22_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef4').value;
			Sigmatau22_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma22_StressCoef5').value;
			
			Sigmatau33_StressCoef1 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef1').value;
			Sigmatau33_StressCoef2 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef2').value;
			Sigmatau33_StressCoef3 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef3').value;
			Sigmatau33_StressCoef4 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef4').value;
			Sigmatau33_StressCoef5 = obj.getRVContainer.getParam('phase','Sigma33_StressCoef5').value;
			
			% Anordnen der Parameter.
			
			Sigmatau11 = [Sigmatau11_StressCoef1, Sigmatau11_StressCoef2, Sigmatau11_StressCoef3, Sigmatau11_StressCoef4, Sigmatau11_StressCoef5]';
			Sigmatau22 = [Sigmatau22_StressCoef1, Sigmatau22_StressCoef2, Sigmatau22_StressCoef3, Sigmatau22_StressCoef4, Sigmatau22_StressCoef5]';
			Sigmatau33 = [Sigmatau33_StressCoef1, Sigmatau33_StressCoef2, Sigmatau33_StressCoef3, Sigmatau33_StressCoef4, Sigmatau33_StressCoef5]';
			
			Sigmatau_all = [Sigmatau11, Sigmatau22, Sigmatau33];
			
			% Die Spannungskoeffizienten werden an die Laenge von "tau"
			% angepasst, d.h. es werden Nullen angefuegt.
			C = zeros((length(tau)-length(Sigmatau_all)),3);
			Sigmatau_export = [Sigmatau_all; C];
			
			% Erzeugen der Spalte mit der Bezeichnung der
			% Spannungskoeffizienten.
			Parameter = [1; 2; 3; 4; 5];
			D = zeros((length(tau)-length(Sigmatau_all)),1);
			Parameter_exp = [Parameter; D];
			
			% Header für die zu exportierende Datei erzeugen.
			Header = {'tau,z[µm]', 'Parameter' 'StressCoef_sigma(11)', 'StressCoef_sigma(22)', 'StressCoef_sigma(33)',...
					  'sigma(11)_(tau)', 'sigma(22)_(tau)', 'sigma(33)_(tau)', 'sigma(11)_(z)', 'sigma(22)_(z)', 'sigma(33)_(z)'};
			
			% Zusammenfassen der zu speichernden Daten.
			Dat = [tau', Parameter_exp, Sigmatau_export(:,1), Sigmatau_export(:,2), Sigmatau_export(:,3), residualstresses];
			
			% Vorbereitung der Daten zum speichern.
				% TODO: "Speicher Unter..." einfuegen, sprich Angabe eines
				% Dateinamens, unter dem gespeichert werden soll.
			Data = cellfun(@num2str, num2cell(Dat), 'UniformOutput', false);
			Final = [Header;Data];
			% Speichern der Daten in einer Textdatei.
			fid = fopen('ResidualStress_Analysis.txt','wt');
			
			for i = 1:size(Final,1)
					fprintf(fid,'%s ', Final{i,:});
					fprintf(fid,'\n');
			end
			
			fclose(fid);
			
		end
	end
	
end

