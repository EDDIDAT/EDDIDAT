classdef RVPlotRecalcDistrib < hgsetget
%% (* RVRecalcDistrib *)
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
		
		function obj = RVPlotRecalcDistrib(rvContainer)
		% Default-Konstruktor erwarten einen "RVContainer".
			
			obj.setRVContainer(rvContainer);
		end
	end
	
	methods (Access = public)
		
		function sf = getSubFunction(obj, name)
		% Diese Hilfsfunktion dient dazu, benutzte Unterfunktionen zu
		% finden, um mit diesen wiederum Auswertungen zu machen. Der Name
		% "name" muss den Unterfunktionsnamen in den Modulen selbst
		% entsprechen.
			
			validateattributes(name, {'char'}, {'row'});
			
			% Rekursive Liste
			list = obj.getRVContainer().getFitFunction().getSubFunctionList(true);
			
			sf = list(strcmp(name, list(:,1)), 3);
			
			assert(~isempty(sf), ['The sub function ', name, ' was not found']);
			
			sf = sf{1};
		end
	end	

%% Residual Stress Plot
	
	methods(Access = public)
		
		function ep = computeEnergyPosCalc(obj)
		% Berechnet die theoretischen Linienlagen entsprechend der Vorgabe.
		% Da pro Phase und Spektrum unterschiedlich viele Linien auftreten
		% koennen, wird ein Cell-Array zurueckgegeben. Der erste Index
		% bestimmt die Phase, alle weiteren das Spektrum. Auf den
		% berechneten Wert wird noch ein Wert deltaE (aus quadratischer
		% Korrekturfunktion) dazugerechnet, um die tatsächliche Fitposition
		% zu bestimmen.
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
			params = obj.getRVContainer().getParamStruct();
			
			% Speichern des Parametercontainers im Workspace, da spaeter
			% auf ihn zurueckgegriffen wird. Spart sehr viel Zeit.
			assignin('base', 'params', params);
			
			modEP = obj.getSubFunction('EnergyPos');
			ep = cell([phaseCnt, specSize]);
						
			% Durchlaufe alle Phasen und Spektren
			for p = 1:phaseCnt
				
				for s = 1:prod(specSize)
					
					ep{p, s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
					ep{p, s} = ep{p, s};% + deltaE{p, s};
				end
			end
		end
		
		function ep = computeEnergyPosReal(obj)
		% Berechnet die "echten" Energielagen (nach dem Fit) mit Hilfe der
		% Fitmodule. Die Struktur entspricht der von
		% "computeEnergyPosCalc".
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
			% Dieser Befehl erfordert zuviel Zeit. Wird ersetzt durch den
			% untenstehenden Befehl.
			params = obj.getRVContainer().getParamStruct();
			assignin('base', 'params', params);
% 			params = evalin('base', 'params');
			
			modACM = obj.getSubFunction('AttenuationCoeffMat');
			modStrain = obj.getSubFunction('Strain');
			
			epCalc = obj.computeEnergyPosCalc();
			
			% Berechne die Dehnung
			eps_hkl = cell([phaseCnt, specSize]);
			for p = 1:phaseCnt
				
				for s = 1:prod(specSize)
					
					acm = modACM.execute(epCalc{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
					eps_hkl{p, s} = modStrain.execute(acm, params.general(p,s), params.meas, params.phase(p), params.spec(s));
				end
			end
			ep = cellfun(@times, epCalc, eps_hkl, 'UniformOutput', false);
			ep = cellfun(@minus, epCalc, ep, 'UniformOutput', false);
		end
		
		function tau = computeInformationDepth(obj, ep)
		% Berechnet die Informationstiefe tau der uebergebenen Linienlagen
		% "ep". Sowohl die Rueckgabe "tau", als auch "ep" haben eine
		% Cell-Array-Struktur (siehe "computeEnergyPosCalc").
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
% 			params = obj.getRVContainer().getParamStruct();
			params = evalin('base', 'params');
			
			modACM = obj.getSubFunction('AttenuationCoeffMat');
			modTau = obj.getSubFunction('Tau');
			
			tau = cell([phaseCnt, specSize]);
			
			for p = 1:phaseCnt
				
				for s = 1:prod(specSize)
					
					acm = modACM.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
					tau{p,s} = modTau.execute(acm, params.general(p,s), params.meas, params.phase(p), params.spec(s));
				end
			end
		end
				
		function de = computedspacingExp(obj)
			% Dieses Modul verarbeitet die experimentell ermittelten
			% d-Werte. Dazu muessen aber die vorher bestimmten Werte in den
			% Workspace geladen werden. Das Modul sortiert sie dann gemaess
			% ihrer hkl-Reihenfolge.
						
			SpecSize = obj.getRVContainer.getSpecSize;
			TwoTheta = obj.getRVContainer.getParam('meas','TwoTheta').value;
			
			EPosExp = evalin('base', 'EPosExp');
			
			% Das cell-array mit den Energypositionen in eine Matrix
			% umwandeln, die die fehlenden Stellen mit Nullen fuellt.
			% Anschließend werden die Matrizen gemaeß ihrer Nullstellen
			% sortiert.
			
			lmax=max(cellfun(@length,EPosExp));
			ncol=cellfun(@length,EPosExp);
			
			EPositionsExp=zeros(lmax,numel(EPosExp));
			for k=1:numel(ncol)
				EPositionsExp(end:-1:end-ncol(k)+1,k)=flipud(EPosExp{k}); % hinten einfügen
			end
			
			% Sortieren der Matrixelemente gemäß ihres Auftretens in den
			% Spektren. (Hier: hkl Reihenfolge)
			EPositionsExpsorted = zeros(size(EPositionsExp));
			A_logical = cell(size(EPositionsExp,1),1);
			for i = 1:size(EPositionsExp,1)
				for j = 1:size(EPositionsExp,1)
					C = ismemberf(EPositionsExp,EPositionsExp(i,1),'tol',0.5);
					A_logical{i,1} = C;
					D = C.*EPositionsExp;
					EPositionsExpsorted(i,:) = EPositionsExpsorted(i,:) + C(j,:).*D(j,:);
				end
			end
			
			assignin('base', 'A_logical', A_logical); %Speichern von A_logical im Workspace, da spaeter darauf zugegriffen werden muss.
			
			dspacingExp = 6.199./sind(TwoTheta/2).*(1./EPositionsExpsorted);
			
			dspacingExptrans = dspacingExp';
			
			m = SpecSize(1)/2;
			n = size(dspacingExptrans,2)*2;
			
			dspacingExpsorted = reshape(dspacingExptrans,m,n);

			dexp_odd = dspacingExpsorted(:,1:2:end);
			dexp_even = dspacingExpsorted(:,2:2:end);
			dspacingExpsorted = [dexp_odd, dexp_even];
			
			de = dspacingExpsorted;
			
		end
		
		function Y = computeTauReal(obj)
			% Das Modul berechnet die tau-Werte der aktuell gefitteten
			% Energielagen und sortiert diese gemaeß der hkl Reihenfolge.
			% Sortierung erfolgt nach dem gleichen Muster wie vorher bei
			% den experimentell bestimmten d-Werten.
			
			SpecSize = obj.getRVContainer.getSpecSize;
			
			% Tau berechnen für die aktuell gefitteten Energielagen.
			EnergyPosReal = obj.computeEnergyPosReal();
			InformationDepth = obj.computeInformationDepth(EnergyPosReal);
			
			% Laden der Indizes, benoetigt fuer die Indizierung der
			% Positionen der tau-Werte gemaeß ihrer hkl-Reihenfolge.
			A_logical = evalin('base', 'A_logical');
			
			% Das cell-array mit den Tauwerten in eine Matrix
			% umwandeln, und die fehlenden Stellen mit Nullen fuellen.
			% Anschließend werden die Matrizen gemäß ihrer Werte (hkl)
			% sortiert.
			lmax=max(cellfun(@length,InformationDepth));
			ncol=cellfun(@length,InformationDepth);
			
			InformationDepthReal=zeros(lmax,numel(InformationDepth));
			for k=1:numel(ncol)
				InformationDepthReal(end:-1:end-ncol(k)+1,k)=flipud(InformationDepth{k}); % hinten einfügen
			end
			
			% Sortieren der Matrixelemente gemäß ihres Auftretens in den
			% Spektren (hkl Reihenfolge).
			Informationdepthsorted = zeros(size(InformationDepthReal));
			for i = 1:size(InformationDepthReal,1)
				for j = 1:size(InformationDepthReal,1)
					C = A_logical{i,1};
					D = C.*InformationDepthReal;
					Informationdepthsorted(i,:) = Informationdepthsorted(i,:) + C(j,:).*D(j,:);
				end
			end
						
			Informationdepthsortedtrans = Informationdepthsorted';
			
			m = SpecSize(1)/2;
			n = size(Informationdepthsortedtrans,2)*2;
			
			Informationdepthsorted = reshape(Informationdepthsortedtrans,m,n);
			
			Y = Informationdepthsorted;
		end
		
		function Y = computeDspacingSigmaTau(obj)
			% Dieses Modul berechnet unter Verwendung der aktuellen
			% StressKoefficienten die d-sin²Psi Verteilungen, wie sie sich
			% aus dem verfeinerten Eigenspannungsmodell ergeben. Es wird
			% dazu genutzt, die Guete des verfeinerten Modells zu
			% beurteilen.
			
			SpecSize = obj.getRVContainer.getSpecSize;
			% Parametercontainer initialisieren.
% 			params = struct2cell(obj.getRVContainer().getParamStruct());
% 			
% 			assignin('base', 'params', params);
			params = evalin('base', 'params');
			
			% DEK auslesen.
% 			DEK_S1Tmp = params{1,1}(1,1).DEK_S1(:);
			DEK_S1Tmp = params.general(1,1).DEK_S1;
			DEK_S1 = repmat(DEK_S1Tmp,evalin('base', 'numberOfPhiAngles'),1);
% 			DEK_S2Tmp = params{1,1}(1,1).DEK_S2(:);
			DEK_S2Tmp = params.general(1,1).DEK_S2;
			DEK_S2 = repmat(DEK_S2Tmp,evalin('base', 'numberOfPhiAngles'),1);
			
			% Psi und Phi auslesen und an die hkl-Groeße anpassen.
			PhiCount = evalin('base', 'numberOfPhiAngles');
			PsiTmp = zeros(SpecSize);
			for i = 1:SpecSize
% 			PsiTmp(i,:) = params{4,1}(i,1).Psi;
			PsiTmp(i,:) = params.spec(i,1).Psi;
			end
			PsiTmp = reshape(PsiTmp,32,PhiCount);
			Psi = repmat(PsiTmp,1,size(DEK_S1Tmp));
			
			PhiTmp = zeros(SpecSize);
			for i = 1:SpecSize
% 			PhiTmp(i,:) = params{4,1}(i,1).Phi;
			PhiTmp(i,:) = params.spec(i,1).Phi;
			end
			PhiTmp = reshape(PhiTmp,32,PhiCount);
			Phi = [repmat(PhiTmp(:,1),1,size(DEK_S1Tmp)),repmat(PhiTmp(:,2),1,size(DEK_S1Tmp))];
			
			% d0 auslesen.
% 			dzeroTmp = params{1,1}(1,1).d0(:);
			dzeroTmp = params.general(1,1).d0;
			dzero = repmat(dzeroTmp,evalin('base', 'numberOfPhiAngles'),1);
			
			% Auslesen der Stresskoeffizienten.
% 			Sigmatau11_StressCoef1 = params{3,1}.Sigma11_StressCoef1;
% 			Sigmatau11_StressCoef2 = params{3,1}.Sigma11_StressCoef2;
% 			Sigmatau11_StressCoef3 = params{3,1}.Sigma11_StressCoef3;
% 			Sigmatau11_StressCoef4 = params{3,1}.Sigma11_StressCoef4;
% 			Sigmatau11_StressCoef5 = params{3,1}.Sigma11_StressCoef5;
% 			
% 			Sigmatau22_StressCoef1 = params{3,1}.Sigma22_StressCoef1;
% 			Sigmatau22_StressCoef2 = params{3,1}.Sigma22_StressCoef2;
% 			Sigmatau22_StressCoef3 = params{3,1}.Sigma22_StressCoef3;
% 			Sigmatau22_StressCoef4 = params{3,1}.Sigma22_StressCoef4;
% 			Sigmatau22_StressCoef5 = params{3,1}.Sigma22_StressCoef5;
% 			
% 			Sigmatau33_StressCoef1 = params{3,1}.Sigma33_StressCoef1;
% 			Sigmatau33_StressCoef2 = params{3,1}.Sigma33_StressCoef2;
% 			Sigmatau33_StressCoef3 = params{3,1}.Sigma33_StressCoef3;
% 			Sigmatau33_StressCoef4 = params{3,1}.Sigma33_StressCoef4;
% 			Sigmatau33_StressCoef5 = params{3,1}.Sigma33_StressCoef5;
			
			Sigmatau11_StressCoef1 = params.phase.Sigma11_StressCoef1;
			Sigmatau11_StressCoef2 = params.phase.Sigma11_StressCoef2;
			Sigmatau11_StressCoef3 = params.phase.Sigma11_StressCoef3;
			Sigmatau11_StressCoef4 = params.phase.Sigma11_StressCoef4;
			Sigmatau11_StressCoef5 = params.phase.Sigma11_StressCoef5;

			Sigmatau22_StressCoef1 = params.phase.Sigma22_StressCoef1;
			Sigmatau22_StressCoef2 = params.phase.Sigma22_StressCoef2;
			Sigmatau22_StressCoef3 = params.phase.Sigma22_StressCoef3;
			Sigmatau22_StressCoef4 = params.phase.Sigma22_StressCoef4;
			Sigmatau22_StressCoef5 = params.phase.Sigma22_StressCoef5;

			Sigmatau33_StressCoef1 = params.phase.Sigma33_StressCoef1;
			Sigmatau33_StressCoef2 = params.phase.Sigma33_StressCoef2;
			Sigmatau33_StressCoef3 = params.phase.Sigma33_StressCoef3;
			Sigmatau33_StressCoef4 = params.phase.Sigma33_StressCoef4;
			Sigmatau33_StressCoef5 = params.phase.Sigma33_StressCoef5;
			
			% Anordnen der Parameter.
			Sigmatau11Coef = [Sigmatau11_StressCoef1, Sigmatau11_StressCoef2, Sigmatau11_StressCoef3, Sigmatau11_StressCoef4, Sigmatau11_StressCoef5]';
			Sigmatau22Coef = [Sigmatau22_StressCoef1, Sigmatau22_StressCoef2, Sigmatau22_StressCoef3, Sigmatau22_StressCoef4, Sigmatau22_StressCoef5]';
			Sigmatau33Coef = [Sigmatau33_StressCoef1, Sigmatau33_StressCoef2, Sigmatau33_StressCoef3, Sigmatau33_StressCoef4, Sigmatau33_StressCoef5]';
			
			Sigmatau_all = [Sigmatau11Coef, Sigmatau22Coef, Sigmatau33Coef];
			
			% Berechnen von sigmatau_ii.
			tau = obj.computeTauReal();
			tau0 = tau(:,1:2:end);
			tau90 = tau(:,2:2:end);
			tau_all = [tau0, tau90];
% 			tau_all(find(~tau_all))=NaN;
			tau_all(tau_all == 0) = NaN;
			sigmatau11 = zeros(size(tau_all,1),size(tau_all,2));
			sigmatau22 = zeros(size(tau_all,1),size(tau_all,2));
			sigmatau33 = zeros(size(tau_all,1),size(tau_all,2));

			for i = 1:size(tau_all,1)
				for p = 1:size(tau_all,2)
					sigmatau11(i,p) = Sigmatau_all(1,1)./(Sigmatau_all(5,1).*tau_all(i,p) + 1) + ...
					Sigmatau_all(2,1).*tau_all(i,p)./(Sigmatau_all(5,1).*tau_all(i,p) + 1).^2 + ...
					2.* Sigmatau_all(3,1).*tau_all(i,p).^2./(Sigmatau_all(5,1).*tau_all(i,p) + 1).^3 + ...
					6.* Sigmatau_all(4,1).*tau_all(i,p).^3./(Sigmatau_all(5,1).*tau_all(i,p) + 1).^4;
				end 
			end

			for i = 1:size(tau_all,1)
				for p = 1:size(tau_all,2)
					sigmatau22(i,p) = Sigmatau_all(1,2)./(Sigmatau_all(5,2).*tau_all(i,p) + 1) + ...
					Sigmatau_all(2,2).*tau_all(i,p)./(Sigmatau_all(5,2).*tau_all(i,p) + 1).^2 + ...
					2.* Sigmatau_all(3,2).*tau_all(i,p).^2./(Sigmatau_all(5,2).*tau_all(i,p) + 1).^3 + ...
					6.* Sigmatau_all(4,2).*tau_all(i,p).^3./(Sigmatau_all(5,2).*tau_all(i,p) + 1).^4;
				end 
			end

			for i = 1:size(tau_all,1)
				for p = 1:size(tau_all,2)
					sigmatau33(i,p) = Sigmatau_all(1,3)./(Sigmatau_all(5,3).*tau_all(i,p) + 1) + ...
					Sigmatau_all(2,3).*tau_all(i,p)./(Sigmatau_all(5,3).*tau_all(i,p) + 1).^2 + ...
					2.* Sigmatau_all(3,3).*tau_all(i,p).^2./(Sigmatau_all(5,3).*tau_all(i,p) + 1).^3 + ...
					6.* Sigmatau_all(4,3).*tau_all(i,p).^3./(Sigmatau_all(5,3).*tau_all(i,p) + 1).^4;
				end 
			end
			
			% Berechnung der aktuellen d-sin²Psi Verteilungen, wie sie sich
			% unter Verwendung der aktuellen Stresskoeffizienten ergeben.
			
			% length(DEK_S1) liefert die Anzahl der gefitteten hkl Reflexe
			% fuer alle Phi-Winkel.
			dsigmatau = zeros(length(DEK_S1),length(Psi));
			
			for j = 1:length(DEK_S1)
				for i = 1:length(Psi)
				dsigmatau(j,i) = (DEK_S2(j) .* (sind(Psi(i,j)).^2 .* (sigmatau11(i,j) .* cosd(Phi(i,j)).^2 + sigmatau22(i,j) .* sind(Phi(i,j)).^2 ...
									- sigmatau33(i,j)) + sigmatau33(i,j)) + DEK_S1(j) .* (sigmatau11(i,j) + sigmatau22(i,j) + sigmatau33(i,j))) .* dzero(j) ...
									+ dzero(j);
				end
			end
			
			Y = dsigmatau';
			% Speichern von Y als Varibale "d_meas" im Workspace, um
			% spaeter einfacher darauf zurückgreifen zu koennen. (Vorher
			% wurde der Plot nicht separat, sondern direkt im Anschluss an
			% "computeDspacingSigmaTau" ausgegeben. Das allerdings fuehrt
			% dazu, dass der Plot auch beim speichern der Ergebnissdatei
			% ausgegeben wird.)
			assignin('base', 'd_meas', Y);
		end
		
		function plot(obj)
			% Vorbereitungen fuer die grafische Ausgabe der Ergebnisse in
			% Form von Subplots, deren Anzahl sich aus der Anzahl der hkl
			% Reflexe ergibt.
			params = evalin('base', 'params');
			% Laden der experimentell ermittelten d-Werte.
			d_exp = obj.computedspacingExp;
			d_meas = evalin('base', 'd_meas'); %obj.computeDspacingSigmaTau; %Y;
			dzeroTmp = params.general(1,1).d0;
			SpecSize = obj.getRVContainer.getSpecSize;
			
			% Alte Darstellung mit Leerzeichen zwischen hkl-Werten.
% 			Reflex = [params.general(1,1).H, params.general(1,1).K, params.general(1,1).L];
% % 			HKL = zeros(size(Reflex));
% 			for i = 1:length(dzeroTmp)
% 				HKL(i,:) = num2str([Reflex(i,1),Reflex(i,2),Reflex(i,3)]);
% 			end
			
			% Einlesen der hkl Reflexbezeichnungen. Dabei wird erneut davon
			% ausgegangen, dass im ersten Spektrum die maximale Anzahl an
			% Reflexen vorliegt. Es wird eine Matrix erstellt, die die H-
			% K- und L-Werte des entsprechenden Reflexes beinhaltet.
			Reflex = [params.general(1,1).H, params.general(1,1).K, params.general(1,1).L];
			
			% Es wird ein Char Array erzeugt, welches die
			% Reflexbezeichnungen als 'String' enthaelt. Diese Strings
			% werden dann zur Erstellung einer Header-Zeile benutzt.
			Head = num2str(Reflex);
			
			% Aus dem Char Array wird ein Cell-Array erzeugt.
			for i = 1:length(dzeroTmp)
			HeadersTmp(i) = {Head(i,:)};
			end
			
			% Dieses Cell-Array wird an die Groeße von (d_exp + d_meas)
			% angepasst, unter Beruecksichtigung der Anzahl der Phi-Winkel. 
% 			HeadersTmp = repmat(HeadersTmp,1,2*PhiCount);
			
			% Die Leerzeichen in den Strings werden gelöscht.
			for i = 1:size(HeadersTmp,2)
				HeadersChar(i,:) = strrep(HeadersTmp{1,i}, ' ', '');
			end
			
			% Wird hier nicht benötigt!
% 			% Der Inhalt des Cell-Arrays wird in Strings umgewandelt. (wird
% 			% fuer das Speichern in einer Text-Datei benoetigt.)
% 			Headers = cellstr(HeadersChar);
						
			PhiCount = evalin('base', 'numberOfPhiAngles');
			PsiTmp = zeros(SpecSize);
			for i = 1:SpecSize
% 			PsiTmp(i,:) = params{4,1}(i,1).Psi;
			PsiTmp(i,:) = params.spec(i,1).Psi;
			end
			PsiTmp = reshape(PsiTmp,32,PhiCount);
			Psi = repmat(PsiTmp,1,size(dzeroTmp));
			
			% Erzeugen der Plots. Bisher nur für Messungen unter einem oder
			% zwei verschiedenen Phi-Winkeln ausgelegt.
			figure;
			NumberOfhkl = length(dzeroTmp);
			for i = 1:length(dzeroTmp)
			subplot(3, 3, i)
			hold on
			if PhiCount == 1				
				plot(sind(Psi(:,1)).^2,d_exp(:,i), 'ks', 'LineWidth', 1.25, 'MarkerSize', 6);
				plot(sind(Psi(:,1)).^2,d_meas(:,i), 'r-', 'LineWidth', 2); 
			else
				plot(sind(Psi(:,1)).^2,d_exp(:,i), 'ks', 'LineWidth', 1.25, 'MarkerSize', 6);
				plot(sind(Psi(:,1)).^2,d_exp(:,i+NumberOfhkl), 'ks', 'LineWidth', 1.25, 'MarkerSize', 6);
				plot(sind(Psi(:,1)).^2,d_meas(:,i), 'r-', 'LineWidth', 2); 
				plot(sind(Psi(:,1)).^2,d_meas(:,i+NumberOfhkl), 'b-', 'LineWidth', 2);
			end
			xlabel('sin²\psi');
			ylabel(['d_{' HeadersChar(i,:) '}' ' [', char(197), ']'],'Interpreter','tex','FontSize',10);
			title('d-sin²\psi distribution');
			grid
			end
			legend('experimental d-sin²\psi distribution, \phi = 0°', ...
				   'experimental d-sin²\psi distribution, \phi = 90°', ...
				   'recalculated d-sin²\psi distribution, \phi = 0°', ...
				   'recalculated d-sin²\psi distribution, \phi = 90°', ...
				   'Location', 'BestOutside'); % Legende						
		end
		
		function exportData(obj)
					
			params = evalin('base', 'params');
			
			SpecSize = obj.getRVContainer().getSpecSize();
			
			d_exp = obj.computedspacingExp;
			d_meas = evalin('base', 'd_meas');
% 			d_meas = obj.computeDspacingSigmaTau;
			PhiCount = evalin('base', 'numberOfPhiAngles');
			
			% Einlesen der hkl Reflexbezeichnungen. Dabei wird erneut davon
			% ausgegangen, dass im ersten Spektrum die maximale Anzahl an
			% Reflexen vorliegt. Es wird eine Matrix erstellt, die die H-
			% K- und L-Werte des entsprechenden Reflexes beinhaltet.
			Reflex = [params.general(1,1).H, params.general(1,1).K, params.general(1,1).L];
			
			% Es wird ein Char Array erzeugt, welches die
			% Reflexbezeichnungen als 'String' enthaelt. Diese Strings
			% werden dann zur Erstellung einer Header-Zeile benutzt.
			Head = num2str(Reflex);
			
			% Aus dem Char Array wird ein Cell-Array erzeugt.
% 			HeadersTmp = cell(7,7);
			for i = 1:(size(d_exp,2)/PhiCount)
			HeadersTmp(i) = {Head(i,:)};
			end
			
			% Dieses Cell-Array wird an die Groeße von (d_exp + d_meas)
			% angepasst, unter Beruecksichtigung der Anzahl der Phi-Winkel. 
			HeadersTmp = repmat(HeadersTmp,1,2*PhiCount);
			
			% Die Leerzeichen in den Strings werden gelöscht.
			for i = 1:size(HeadersTmp,2)
				HeadersChar(i,:) = strrep(HeadersTmp{1,i}, ' ', '');
			end
			
			% Der Inhalt des Cell-Arrays wird in Strings umgewandelt. (wird
			% fuer das Speichern in einer Text-Datei benoetigt.)
			Headers = cellstr(HeadersChar);
			
			% Einfügen einer Spalte am Anfang des Cell-Arrays mit den
			% Werten der Psi-Winkel.
			HeadersFinal = {'Psi', Headers{:,1}};
			
			% Auslesen der Psi-Winkel.
			for i = 1:(prod(SpecSize)/PhiCount)
			PsiTmp(i,:) = params.spec(i,1).Psi;
			end
% 			PsiTmp = PsiTmp;
			
			% Zusammenfassen der zu speichernden Daten.
			d_export = [PsiTmp, d_exp, d_meas];
% 			assignin('base', 'd_export', d_export);
			
			% Numbers are converted to strings using num2str, because 
			% fprintf expects just strings. By using cellfun every element
			% of num2cell(...) is converted iteratively in strings,
			% obtaining a cell.
			Data = cellfun(@num2str, num2cell(d_export), 'UniformOutput', false);
			Final = [HeadersFinal;Data];
			
			% Speichern der Daten in einer Textdatei.
			fid = fopen('Recalculated_d-sin2psi_distributions.txt','wt');
			
			for i = 1:size(Final,1)
					fprintf(fid,'%s ', Final{i,:});
					fprintf(fid,'\n');
			end
			
			fclose(fid);
		end
	end
	
end