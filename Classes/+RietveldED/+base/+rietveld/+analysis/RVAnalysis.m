classdef RVAnalysis < hgsetget
%% (* RVAnalysis *)
% Diese Klasse kann zur Auswertung eines Fit benutzt werden. Gewissenmassen
% erweitert sie den "RVContainer" um einige wissenschaftliche Funktionen.
% Dieses Objekt kann ausserdem das Spektrum und die Residuen berechnen.
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
		
		function obj = RVAnalysis(rvContainer)
		% Default-Konstruktor erwarten einen "RVContainer".
			
			obj.setRVContainer(rvContainer);
		end
	end

%% Export
	
	methods(Access = public)
		
		function exportData(obj, filenamePattern)
		% Exportiert die Rohdaten und das gefittete Spektrum. Pro Spekrum
		% wird eine *.dat Datei erzeugt. Das "filenamePattern" gibt den
		% Pfad und den vorigen Dateinamen an. Aufbau der Datei:
		%	1. Spalte: X Rohdaten
		%	2. Spalte: Y Rohdaten
		%	3. Spalte: Y Spektrum, ausgewertet an den Stellen X
		%	4. Spalte: Residuum, ausgewertet an den Stellen X
			
			validateattributes(filenamePattern, {'char'}, {'row'});
			
			specSize = obj.getRVContainer().getSpecSize();
% 			EPos = evalin('base', 'EPos')';
%             int = evalin('base', 'int')';
			dataX = obj.getRVContainer().getDataX();
			dataY = obj.getRVContainer().getDataY();
			dataYCalc = obj.computeSpectrum();
			res = obj.computeResiduals();
			
            for i = 1:prod(specSize)
				
				data = [dataX(:,i), dataY(:,i), dataYCalc(:,i), res(:,i)]; %#ok
 				save([filenamePattern, num2str(i), '.dat'], 'data', '-ascii');
            end
            
%             Peaks = [EPos'; int'];
%             save('Peaks.dat', 'Peaks', '-ascii');
		end
	end
	
%% Mathematische Auswertung des Fits
	
	methods (Access = public)
		
		function Y = computeSpectrum(obj, X)
		% Berechnet das aktuelle Spektrum (mit den Parametern des
		% Containers) an den Stellen des Rohdatenvektors X. Gibt man ein
		% optionales "X" an, so wird anschliessend an diesen Stellen
		% interpoliert.
		
			params = struct2cell(obj.getRVContainer().getParamStruct());
% 			phaseCnt = obj.getRVContainer().getPhaseCnt();
            
            Y = obj.getRVContainer().getFitFunction().execute(obj.getRVContainer().getDataX(), params{:});
            
			% optionales X
			if (nargin == 2)
				
				Y = interp1(obj.getRVContainer().getDataX(), Y, X);
			end
		end
		
		function [res, absres] = computeResiduals(obj)
		% Berechnet das (punktweise) Residuum und als zweiten Output die
		% 2-norm dieses Residuums (und zwar ueber alle Spektren).
			
			res = obj.computeSpectrum - obj.getRVContainer().getDataY();
			absres = norm(res(:), 2);
		end
		
		function rf = computeReliabiltyFactors(obj)
		% Berechnet einige Gueteindikatoren fuer den Fit und zwar fuer
		% jedes Spektrum.
			
			dataYCalc = obj.computeSpectrum();
			dataY = obj.getRVContainer().getDataY();
			dataY(dataY<=0)=1;
			specSize = obj.getRVContainer().getSpecSize();
			
			rf = zeros([4, specSize]);
			
			for i = 1:prod(specSize)
				
				R_p = sum(abs(dataY(:,i) - dataYCalc(:,i))) / sum(dataY(:,i));
				R_wp = sqrt(sum(1./dataY(:,i).*(dataY(:,i)-dataYCalc(:,i)).^2) ./ sum(1./dataY(:,i).*dataY(:,i).^2));
				R_exp = sqrt((length(dataY(:,i))) ./ sum((1./dataY(:,i)).*dataY(:,i).^2));
				GOF = (R_wp ./ R_exp).^2;
				
				rf(1:4,i) = [R_p, R_wp, R_exp, GOF];
			end
		end	
			% 		disp('Profile Factor R_p:');
			% 		disp(Y(:,1).*100);
			% 		disp('weighted Profile Factor R_wp:');
			% 		disp(Y(:,2).*100);
			% 		disp('expected R-Factor R_exp:');
			% 		disp(Y(:,3).*100);
			% 		disp('Goodness of Fit:');
			% 		disp(Y(:,4));
				
		function sf = computeStressFactor(obj)
			
			StressCoef1 = obj.getRVContainer().getParam('phase', 'StressCoef1').value;
			StressCoef2 = obj.getRVContainer().getParam('phase', 'StressCoef2').value;
			StressCoef3 = obj.getRVContainer().getParam('phase', 'StressCoef3').value;
			StressCoefa = obj.getRVContainer().getParam('phase', 'StressCoefa').value;
			sf = [StressCoef1,StressCoef2,StressCoef3,StressCoefa];
		end
		
		function se = computeStressFactorErrors(obj)
				
			a0_Fehler = obj.getRVContainer().getParam('phase', 'StressCoef1').fitError;
			a1_Fehler = obj.getRVContainer().getParam('phase', 'StressCoef2').fitError;
			a2_Fehler = obj.getRVContainer().getParam('phase', 'StressCoef3').fitError;
			a_Fehler = obj.getRVContainer().getParam('phase', 'StressCoefa').fitError;
			se = [a0_Fehler,a1_Fehler,a2_Fehler,a_Fehler];
		end
	end
	
%% Physikalische Auswertung des Fits
	
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
	
	methods (Access = public)
        
		
	%% Calculated energy positions (from a0)
	
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
			
			modEP = obj.getSubFunction('EnergyPos');
            % EnergyCalib wird nicht mehr genutzt, da das deltaE auf eine
            % falsche Totzeitkorrektur zurueckzufuehren war
% 			modEnergyCalib = obj.getSubFunction('EnergyCalib');
			ep = cell([phaseCnt, specSize]);
			
% 			deltaE = cell([phaseCnt, specSize]);
			
			% Durchlaufe alle Phasen und Spektren
			for p = 1:phaseCnt
				
				for s = 1:prod(specSize)
					
					ep{p, s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
% 					deltaE{p, s} = modEnergyCalib.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
					ep{p, s} = ep{p, s};% + deltaE{p, s};
				end
% 				disp(ep{1})
			end
		end
		
% 		function deltaE = computedeltaE(obj)
% 		% Berechnet die theoretischen Linienlagen entsprechend der Vorgabe.
% 		% Da pro Phase und Spektrum unterschiedlich viele Linien auftreten
% 		% koennen, wird ein Cell-Array zurueckgegeben. Der erste Index
% 		% bestimmt die Phase, alle weiteren das Spektrum. Auf den
% 		% berechneten Wert wird noch ein Wert deltaE (aus quadratischer
% 		% Korrekturfunktion) dazugerechnet, um die tatsächliche Fitposition
% 		% zu bestimmen.
% 			
% 			phaseCnt = obj.getRVContainer().getPhaseCnt();
% 			specSize = obj.getRVContainer().getSpecSize();
% 			
% 			params = obj.getRVContainer().getParamStruct();
% 			
% 			modEnergyCalib = obj.getSubFunction('EnergyCalib');
% 			modEP = obj.getSubFunction('EnergyPos');
% 			
% 			ep = cell([phaseCnt, specSize]);
% 			deltaE = cell([phaseCnt, specSize]);
% 			
% 			% Durchlaufe alle Phasen und Spektren
% 			for p = 1:phaseCnt
% 				
% 				for s = 1:prod(specSize)
% 					
% 					ep{p, s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
% 					deltaE{p, s} = modEnergyCalib.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
% 				end
% 			end
% 		end
		
    %% Information depth
    
		function tau = computeInformationDepth(obj, ep)
		% Berechnet die Informationstiefe tau der uebergebenen Linienlagen
		% "ep". Sowohl die Rueckgabe "tau", als auch "ep" haben eine
		% Cell-Array-Struktur (siehe "computeEnergyPosCalc").
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
			params = obj.getRVContainer().getParamStruct();
			
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
    
    %% Fitted (real) energy positions
    
		function ep = computeEnergyPosReal(obj)
		% Berechnet die "echten" Energielagen (nach dem Fit) mit Hilfe der
		% Fitmodule. Die Struktur entspricht der von
		% "computeEnergyPosCalc".
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
			params = obj.getRVContainer().getParamStruct();
			
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
			% ep = epCalc - epCalc * eps_hkl
			ep = cellfun(@times, epCalc, eps_hkl, 'UniformOutput', false);
			ep = cellfun(@minus, epCalc, ep, 'UniformOutput', false);
        end

    %% Calculation of epsilon(hkl) from fitted strain model function
    
		function eps_hkl = computeEpsHKL(obj)
		% Berechnet die Dehnungswerte epsilon aus der gefitteten
		% Spannungsfunktion (Strain).
			
			phaseCnt = obj.getRVContainer().getPhaseCnt();
			specSize = obj.getRVContainer().getSpecSize();
			
			params = obj.getRVContainer().getParamStruct();
			
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
        end

    %% Calculation of sigma(tau) from the fitted epsilon values
        
        function sigmatau = computeSigmataufromeps(obj)
        % Berechnet die Spannungen im Laplaceraum aus dem gefitteten
        % Parameter "epsilon" unter Verwendung der Spannungsfaktoren.
        
            phaseCnt = obj.getRVContainer().getPhaseCnt();
% 			specSize = obj.getRVContainer().getSpecSize();
			
			params = obj.getRVContainer().getParamStruct();
            
            % Parameter needed for the calculation of the values f+, f-,
            % f13 and f23
            Psi = [params.spec.Psi];
            Phi = [params.spec.Phi];
            epsilon = [params.general.epsilon]';
            DEK_S2 = [params.general.DEK_S2]';
            DEK_S1 = [params.general.DEK_S1]';
            
            % Check under how many azimuths was measured (important for the
            % evaluation of sigma(tau), i.e. which directions are to be
            % calculated).
            phiIndex = unique(Phi, 'stable');
                % Find index where a new azimuth begins, save as table.
                for i=1:length(phiIndex)
                    IndexMin(i) = arrayfun(@(x) find(Phi == x,1,'first'), phiIndex(i) );
                    IndexMax(i) = arrayfun(@(x) find(Phi == x,1,'last'), phiIndex(i) );
                    PhiIndexTable = [IndexMin; IndexMax]';
                end

            % Sort the different variables and save as cell array. The 
            % number of spectra can vary from azimuth to azimuth.
            Phisorted = cell(phaseCnt, length(phiIndex));
            
                for i = 1:length(phiIndex)
                    Phisorted{i} = Phi(PhiIndexTable(i,1):PhiIndexTable(i,2))';
                end
               
            Psisorted = cell(phaseCnt, length(phiIndex));
            
                for i = 1:length(phiIndex)
                    Psisorted{i} = Psi(PhiIndexTable(i,1):PhiIndexTable(i,2))';
                end

            epsilonsorted = cell(1,length(phiIndex));

                for p = 1:length(phiIndex)
                    epsilonsorted{1,p} = epsilon(PhiIndexTable(p,1):PhiIndexTable(p,2),:);
                end
                
            DEK_S2sorted = cell(1,length(phiIndex));

                for p = 1:length(phiIndex)
                    DEK_S2sorted{1,p} = DEK_S2(PhiIndexTable(p,1):PhiIndexTable(p,2),:);
                end
            
            DEK_S1sorted = cell(1,length(phiIndex));

                for p = 1:length(phiIndex)
                    DEK_S1sorted{1,p} = DEK_S1(PhiIndexTable(p,1):PhiIndexTable(p,2),:);
                end
                
            % Find "shortest" azimuth, since the same number of azimuths
            % are needed to calculate stresses sigma(tau)
            minPhisorted = min(cellfun('length',Phisorted));
            
            % Calculation of f+, f-, f13 and f23
            % "f+"
            % Use repmat for "Psisorted" in order to facilitate addition of
            % the terms. "minPhisorted" used to have the same length of the
            % different vectors of epsilonsorted(azimuth).
            fplus = 1/4*(epsilonsorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) + epsilonsorted{:,2}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) + epsilonsorted{:,3}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) + epsilonsorted{:,4}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)))./...
                (DEK_S2sorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)).*repmat(sind(Psisorted{:,1}(1:minPhisorted)).^2,1,size(DEK_S2sorted{1,1},2)) + 2.*DEK_S1sorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)));
            % "f-"
            fminus = 1/4*((epsilonsorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) + epsilonsorted{:,3}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2))) - (epsilonsorted{:,2}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) + epsilonsorted{:,4}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2))))./...
                (DEK_S2sorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)).*repmat(sind(Psisorted{:,1}(1:minPhisorted)).^2,1,size(DEK_S2sorted{1,1},2)));
            % "f13"
            f13 = 1/2*(epsilonsorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) - epsilonsorted{:,3}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)))./...
                (DEK_S2sorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)).*repmat(sind(2.*Psisorted{:,1}(1:minPhisorted)),1,size(DEK_S2sorted{1,1},2)));
            % "f23" 
            f23 = 1/2*(epsilonsorted{:,2}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)) - epsilonsorted{:,4}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)))./...
                (DEK_S2sorted{:,1}(1:minPhisorted,1:size(DEK_S2sorted{1,1},2)).*repmat(sind(2.*Psisorted{:,1}(1:minPhisorted)),1,size(DEK_S2sorted{1,1},2)));
            
            % Calculation of sigma_ii(tau)
            sigma11tau = fplus + fminus;
            
            sigma22tau = fplus - fminus;
            
            sigma13tau = f13;
            
            sigma23tau = f23;
            
            sigmatau = {sigma11tau, sigma22tau, sigma13tau, sigma23tau};
            
            
            % Rearrange the tau cell array    
%             tauneu = cell(1,4);
% 
%                 for p = 1:4
%                     for i = 1:cellfun('length',Phisorted(p))
%                         tauneu{i,p} = tau{1,i};
%                     end
%                 end
        end
    
    %% Plot of sigma_ii(tau) vs. tau
    
        function plotsigmatau = plotSigmataufromeps(obj, psirange11, psirange22, psirange13, psirange23, show)
           
           phaseCnt = obj.getRVContainer().getPhaseCnt(); 
           specSize = obj.getRVContainer().getSpecSize();
           params = obj.getRVContainer().getParamStruct();
           ep = obj.computeEnergyPosReal();
           
           Phi = [params.spec.Phi];
           phiIndex = unique(Phi, 'stable');
                % Find index where a new azimuth begins, save as table.
                for i=1:length(phiIndex)
                    IndexMin(i) = arrayfun(@(x) find(Phi == x,1,'first'), phiIndex(i) );
                    IndexMax(i) = arrayfun(@(x) find(Phi == x,1,'last'), phiIndex(i) );
                    PhiIndexTable = [IndexMin; IndexMax]';
                end

            % Sort the different variables and save as cell array. The 
            % number of spectra can vary from azimuth to azimuth.
            Phisorted = cell(phaseCnt, length(phiIndex));
            
                for i = 1:length(phiIndex)
                    Phisorted{i} = Phi(PhiIndexTable(i,1):PhiIndexTable(i,2))';
                end
                
            sigmatau = obj.computeSigmataufromeps;
%            sigmatau1 = [sigmatau{1:specSize}];

            tau = obj.computeInformationDepth(ep);
            tausorted = [tau{1:specSize}]';
            
            sigma11 = sigmatau{:,1};
            sigma22 = sigmatau{:,2};
            sigma13 = sigmatau{:,3};
            sigma23 = sigmatau{:,4};
%             assignin('base', 'sigmatau', sigmatau)
            tauneu = cell(1,4);
           
            for p = 1:4
                tauneu{1,p} = tausorted(PhiIndexTable(p,1):PhiIndexTable(p,2),:);
            end

%             for p = 1:4
%                 for i = 1:cellfun('length',Phisorted(p))
%                     tauneu{i,p} = tau1(i,:);
%                 end
%             end
            
            range11 = psirange11;
            range22 = psirange22;
            range13 = psirange13;
            range23 = psirange23;
            
            % Create 
            tau11 = tauneu{1,1};
            tau22 = tauneu{1,2};
            tau13 = tauneu{1,3};
            tau23 = tauneu{1,4};
%             assignin('base', 'tauneu', tauneu)
            
            Reflex = [params.general(1,1).H, params.general(1,1).K, params.general(1,1).L];
            Head = num2str(Reflex);
            
            for i = 1:size(tau11,2)
				HeadersTmp(i) = {Head(i,:)};
            end
            
            for i = 1:size(HeadersTmp,2)
				HeadersChar(i,:) = strrep(HeadersTmp{1,i}, ' ', '');
            end
            
            hold on
            % Create figure for subplot
            figure
            % subplot sigma_11
            subplot(2,2,1);
            plot(tau11(range11,:), sigma11(range11,:),'o');
            % Numerate the data points
                % offset for data point labels
                offset_x = 0;
                offset_y = 0;
                % reduce tau and sigma values according to the chosen range
                tau11red = tau11(range11,:);
                sigma11red = sigma11(range11,:);
                % data point labels, use repmat to account for the number
                % of peaks
                number = repmat(range11,1,size(tau11,2));
                % write text to data points
                for k = 1:(length(tau11(range11,:))*size(tau11,2));
                    text(tau11red(k)+offset_x,sigma11red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show, 'FontSize', 7)
                end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{11} [MPa]');
            legend({HeadersChar},'FontSize', 8, 'Location', 'eastoutside')
            legend boxoff
			axis tight
			grid
            
            % Subplot sigma_13
            subplot(2,2,2);
            plot(tau13(range13,:), sigma13(range13,:),'o');
            % Numerate the data points
                % offset for data point labels
                offset_x = 0;
                offset_y = 0;
                % reduce tau and sigma values according to the chosen range
                tau13red = tau13(range13,:);
                sigma13red = sigma13(range13,:);
                % data point labels, use repmat to account for the number
                % of peaks
                number = repmat(range13,1,size(tau13,2));
                % write text to data points
                for k = 1:(length(tau13(range13,:))*size(tau13,2));
                    text(tau13red(k)+offset_x,sigma13red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show, 'FontSize', 7)
                end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{13} [MPa]');
            legend({HeadersChar},'FontSize', 8, 'Location', 'eastoutside')
            legend boxoff
			axis tight
			grid
            
            % Subplot sigma_22
            subplot(2,2,3);
            plot(tau22(range22,:), sigma22(range22,:),'o');
            % Numerate the data points
                % offset for data point labels
                offset_x = 0;
                offset_y = 0;
                % reduce tau and sigma values according to the chosen range
                tau22red = tau22(range22,:);
                sigma22red = sigma22(range22,:);
                % data point labels, use repmat to account for the number
                % of peaks
                number = repmat(range22,1,size(tau22,2));
                % write text to data points
                for k = 1:(length(tau22(range22,:))*size(tau22,2));
                    text(tau22red(k)+offset_x,sigma22red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show, 'FontSize', 7)
                end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{22} [MPa]');
            legend({HeadersChar},'FontSize', 8, 'Location', 'eastoutside')
            legend boxoff
			axis tight
			grid
            
            % Subplot sigma_23
            subplot(2,2,4);
            plot(tau23(range23,:), sigma23(range23,:),'o');
            % Numerate the data points
                % offset for data point labels
                offset_x = 0;
                offset_y = 0;
                % reduce tau and sigma values according to the chosen range
                tau23red = tau23(range23,:);
                sigma23red = sigma23(range23,:);
                % data point labels, use repmat to account for the number
                % of peaks
                number = repmat(range23,1,size(tau23,2));
                % write text to data points
                for k = 1:(length(tau23(range23,:))*size(tau23,2));
                    text(tau23red(k)+offset_x,sigma23red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show, 'FontSize', 7)
                end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{23} [MPa]');
            legend({HeadersChar},'FontSize', 8, 'Location', 'eastoutside')
            legend boxoff
			axis tight
			grid
        end
    %% Calculation of integrated intensity
    
        function IntegratedInt = computeIntegratedIntensity(obj)
        % Berechnet die Integralintensitaet der einzelnen Beugungslinien.
        
        % Anzahl der Spektren und Phasen 
        specSize = obj.getRVContainer().getSpecSize();
        phaseCnt = obj.getRVContainer().getPhaseCnt();
	    
        % Laden des Parametercontainers, damit auf die zur Berechnung
        % notwendigen Parameter zugegriffen werden kann.
        params = obj.getRVContainer().getParamStruct();
        
        % Fuer die Berechnung benoetigte Parameter
        ScaleFactor = {params.general.ScaleFactor};
        Multiplicity = {params.general.Multiplicity};
        P_Size = [params.general.P_Size];
        X_Size = [params.general.X_Size];
        U_Strain = [params.general.U_Strain];
        Y_Strain = [params.general.Y_Strain];
        RingCurrent = [params.spec.RingCurrent];
        DeadTime = [params.spec.DeadTime];
        Density = params.phase.Density;
        DensityAir = params.meas.DensityAir;
        DetectorDistance = params.meas.DetectorDistance;
        
        % Fuer die Berechnung benoetigte Sub-Funktionen
        modACM = obj.getSubFunction('AttenuationCoeffMat');
        modACAir = obj.getSubFunction('AttenuationCoeffAir');
        modEP = obj.getSubFunction('EnergyPos');
        modFHKL = obj.getSubFunction('FHKL');
        modWiggler = obj.getSubFunction('Wiggler');
        
        ep = cell([phaseCnt, specSize]);
        Wiggler = cell([phaseCnt, specSize]);
        FHKL = cell([phaseCnt, specSize]);
        acm = cell([phaseCnt, specSize]); 
        aca = cell([phaseCnt, specSize]);
        
            % Berechnung der zur Berechnung der Integralintensitaet
            % benoetigten Parameter
            for p = 1:phaseCnt
		
                for s = 1:specSize
			
                    ep{p,s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
                    Wiggler{p,s} = modWiggler.execute(ep{p,s});
                    FHKL{p,s} = modFHKL.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
                    acm{p,s} = modACM.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
                    aca{p,s} = modACAir.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
                end
            end
            
            % Zum Test der Funktion wurden die fuer die Berechnung
            % benoetigten Werte im Workspace gespeichert.
%             assignin('base', 'ep', ep);
%             assignin('base', 'Wiggler', Wiggler);
%             assignin('base', 'FHKL', FHKL);
%             assignin('base', 'acm', acm);
%             assignin('base', 'aca', aca);
%             assignin('base', 'ScaleFactor', ScaleFactor);
%             assignin('base', 'Multiplicity', Multiplicity);
%             assignin('base', 'Density', Density);
%             assignin('base', 'DensityAir', DensityAir);
%             assignin('base', 'DetectorDistance', DetectorDistance);
%             assignin('base', 'params', params);
        
            % Berechnung der Beugungslinienintensitaeten, die spaeter fuer
            % die Berechnung der Integralintensitaeten benoetigt werden
            Intensity = cell(size(ep));
            for i = 1:phaseCnt
                for j = 1:specSize
                    INorm = 300;
                    corr = (INorm / RingCurrent(j) * (100 / (100 - DeadTime(j))));
                    Intensity{i,j} = ScaleFactor{i,j} .* 1/corr .* (FHKL{i,j} .* Multiplicity{i,j} .* Wiggler{i,j} .* ...
                    1 ./ (2 * Density * acm{i,j}) .* exp(- DensityAir * DetectorDistance * aca{i,j}) .* (12.398 ./ ep{i,j}).^3);
                end
            end
            assignin('base', 'Intensity', Intensity);
            % Berechnung der Integralintensitaeten
            % Zur Berechnung der Integralintensitaeten der durch die
            % TCHPV-Profilfunktion beschriebenen Beugungslinien werden zu
            % Beginn, unter Verwendung der Groessenparameter (P_Size etc.), 
            % die Werte der Halbwertsbreite (H_kG etc.) berechnet. Es wird
            % ein Function-Handle (fun) erzeugt, welches benoetigt wird, um
            % die Integralfunktion von Matlab aufzurufen (f = integral(fun,
            % xmin, xmax). Da die Anzahl der Beugungslinien von Spektrum zu
            % Spektrum variieren kann, laeuft die for-Schleife über die
            % Phasen, die Spektren und die "Laenge", sprich die Anzahl der
            % Beugungslinien pro Spektrum (size(ep{k,l},1)).
            H_kG = cell(size(ep));
            H_kL = cell(size(ep));
            H_k = cell(size(ep));
            GL = cell(size(ep));
            IntegratedInt = cell(size(ep));
            
            for k = 1:phaseCnt
                for l = 1:specSize
                    for i = 1:size(ep{k,l},1)
                        H_kG{k,l} = sqrt(P_Size(l)+U_Strain(l).*(ep{k,l}.^2));
                        H_kL{k,l} = X_Size(l)+Y_Strain(l).*ep{k,l};
                        H_k{k,l} = (H_kG{k,l}.^5+2.69269.*H_kG{k,l}.^4.*H_kL{k,l}+2.42843.*H_kG{k,l}.^3.*H_kL{k,l}.^2+4.47163.*H_kG{k,l}.^2.*H_kL{k,l}.^3+0.07842.*H_kG{k,l}.*H_kL{k,l}.^4+H_kL{k,l}.^5).^(0.2);
                        GL{k,l} = 1.36603.*(H_kL{k,l}./H_k{k,l})-0.47719.*(H_kL{k,l}./H_k{k,l}).^2+0.11116.*(H_kL{k,l}./H_k{k,l}).^3;
                        fun = @(X_DataEnergy)Intensity{k,l}(i)*(GL{k,l}(i)*(2./(pi.*H_k{k,l}(i)))./(1+4.*((X_DataEnergy-ep{k,l}(i))./H_k{k,l}(i)).^2) + ...
                        (1-GL{k,l}(i)).*(2.*sqrt(log(2)./pi)./H_k{k,l}(i)).*exp(-4.*log(2).*((X_DataEnergy-ep{k,l}(i))./H_k{k,l}(i)).^2));
                        IntegratedInt{k,l}(i,1) = integral(fun, ep{k,l}(i)-3, ep{k,l}(i)+3);
                    end
                end
            end
        end

    %% Calculation of peak breadth
    
        function PeakBreath = computePeakBreath(obj)
        % Berechnet die Integralintensitaet der einzelnen Beugungslinien.
        
        % Anzahl der Spektren und Phasen 
        specSize = obj.getRVContainer().getSpecSize();
        phaseCnt = obj.getRVContainer().getPhaseCnt();
	    
        % Laden des Parametercontainers, damit auf die zur Berechnung
        % notwendigen Parameter zugegriffen werden kann.
        params = obj.getRVContainer().getParamStruct();
        
        % Fuer die Berechnung benoetigte Parameter
%         ScaleFactor = {params.general.ScaleFactor};
%         Multiplicity = {params.general.Multiplicity};
        P_Size = [params.general.P_Size];
        X_Size = [params.general.X_Size];
        U_Strain = [params.general.U_Strain];
        Y_Strain = [params.general.Y_Strain];
%         RingCurrent = [params.spec.RingCurrent];
%         DeadTime = [params.spec.DeadTime];
%         Density = params.phase.Density;
%         DensityAir = params.meas.DensityAir;
%         DetectorDistance = params.meas.DetectorDistance;
        
        % Fuer die Berechnung benoetigte Sub-Funktionen
%         modACM = obj.getSubFunction('AttenuationCoeffMat');
%         modACAir = obj.getSubFunction('AttenuationCoeffAir');
        modEP = obj.getSubFunction('EnergyPos');
%         modFHKL = obj.getSubFunction('FHKL');
%         modWiggler = obj.getSubFunction('Wiggler');
        
        ep = cell([phaseCnt, specSize]);
%         Wiggler = cell([phaseCnt, specSize]);
%         FHKL = cell([phaseCnt, specSize]);
%         acm = cell([phaseCnt, specSize]); 
%         aca = cell([phaseCnt, specSize]);
%         
            % Berechnung der zur Berechnung der Integralintensitaet
            % benoetigten Parameter
            for p = 1:phaseCnt
		
                for s = 1:specSize
			
                    ep{p,s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
%                     Wiggler{p,s} = modWiggler.execute(ep{p,s});
%                     FHKL{p,s} = modFHKL.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
%                     acm{p,s} = modACM.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
%                     aca{p,s} = modACAir.execute(ep{p,s}, params.general(p,s), params.meas, params.phase(p), params.spec(s));
                end
            end
            
            % Zum Test der Funktion wurden die fuer die Berechnung
            % benoetigten Werte im Workspace gespeichert.
%             assignin('base', 'ep', ep);
%             assignin('base', 'Wiggler', Wiggler);
%             assignin('base', 'FHKL', FHKL);
%             assignin('base', 'acm', acm);
%             assignin('base', 'aca', aca);
%             assignin('base', 'ScaleFactor', ScaleFactor);
%             assignin('base', 'Multiplicity', Multiplicity);
%             assignin('base', 'Density', Density);
%             assignin('base', 'DensityAir', DensityAir);
%             assignin('base', 'DetectorDistance', DetectorDistance);
%             assignin('base', 'params', params);
        
            % Berechnung der Beugungslinienintensitaeten, die spaeter fuer
            % die Berechnung der Integralintensitaeten benoetigt werden
%             Intensity = cell(size(ep));
%             for i = 1:phaseCnt
%                 for j = 1:specSize
%                     INorm = 300;
%                     corr = (INorm / RingCurrent(j) * (100 / (100 - DeadTime(j))));
%                     Intensity{i,j} = ScaleFactor{i,j} .* 1/corr .* (FHKL{i,j} .* Multiplicity{i,j} .* Wiggler{i,j} .* ...
%                     1 ./ (2 * Density * acm{i,j}) .* exp(- DensityAir * DetectorDistance * aca{i,j}) .* (12.398 ./ ep{i,j}).^3);
%                 end
%             end
            
            % Berechnung der Integralintensitaeten
            % Zur Berechnung der Integralintensitaeten der durch die
            % TCHPV-Profilfunktion beschriebenen Beugungslinien werden zu
            % Beginn, unter Verwendung der Groessenparameter (P_Size etc.), 
            % die Werte der Halbwertsbreite (H_kG etc.) berechnet. Es wird
            % ein Function-Handle (fun) erzeugt, welches benoetigt wird, um
            % die Integralfunktion von Matlab aufzurufen (f = integral(fun,
            % xmin, xmax). Da die Anzahl der Beugungslinien von Spektrum zu
            % Spektrum variieren kann, laeuft die for-Schleife über die
            % Phasen, die Spektren und die "Laenge", sprich die Anzahl der
            % Beugungslinien pro Spektrum (size(ep{k,l},1)).
            H_kG = cell(size(ep));
            H_kL = cell(size(ep));
            PeakBreath = cell(size(ep));
%             GL = cell(size(ep));
%             IntegratedInt = cell(size(ep));
            
            for k = 1:phaseCnt
                for l = 1:specSize
%                     for i = 1:size(ep{k,l},1)
                        H_kG{k,l} = sqrt(P_Size(l)+U_Strain(l).*(ep{k,l}.^2));
                        H_kL{k,l} = X_Size(l)+Y_Strain(l).*ep{k,l};
                        PeakBreath{k,l} = (H_kG{k,l}.^5+2.69269.*H_kG{k,l}.^4.*H_kL{k,l}+2.42843.*H_kG{k,l}.^3.*H_kL{k,l}.^2+4.47163.*H_kG{k,l}.^2.*H_kL{k,l}.^3+0.07842.*H_kG{k,l}.*H_kL{k,l}.^4+H_kL{k,l}.^5).^(0.2);
%                         GL{k,l} = 1.36603.*(H_kL{k,l}./H_k{k,l})-0.47719.*(H_kL{k,l}./H_k{k,l}).^2+0.11116.*(H_kL{k,l}./H_k{k,l}).^3;
%                         fun = @(X_DataEnergy)Intensity{k,l}(i)*(GL{k,l}(i)*(2./(pi.*H_k{k,l}(i)))./(1+4.*((X_DataEnergy-ep{k,l}(i))./H_k{k,l}(i)).^2) + ...
%                         (1-GL{k,l}(i)).*(2.*sqrt(log(2)./pi)./H_k{k,l}(i)).*exp(-4.*log(2).*((X_DataEnergy-ep{k,l}(i))./H_k{k,l}(i)).^2));
%                         IntegratedInt{k,l}(i,1) = integral(fun, ep{k,l}(i)-3, ep{k,l}(i)+3);
%                     end
                end
            end
            
            % Plot
%             figure
%             for i = 1:size(ep,1)
%             subplot(3, 3, i)
%             hold on
%             plot(sind(Psi(1:9)).^2,breath1(1:9,i),'or')
%             hold on
%             plot(sind(Psi(11:32)).^2,breath1(11:32,i),'or')
%             hold on
%             plot(sind(Psi(32:56)).^2,breath1(32:56,i),'+k')
%             end
        end

    %% Calculation of peak breadths corrected for instrumental broadening
    
        function PeakBreath = computePeakBreathcorr(obj)
        % Berechnet die gegen die instrumentelle Verbreiterung korrigierte
        % Peakbreite
        
        % Anzahl der Spektren und Phasen 
        specSize = obj.getRVContainer().getSpecSize();
        phaseCnt = obj.getRVContainer().getPhaseCnt();
	    
        % Laden des Parametercontainers, damit auf die zur Berechnung
        % notwendigen Parameter zugegriffen werden kann.
        params = obj.getRVContainer().getParamStruct();
        
        % Fuer die Berechnung benoetigte Parameter
        
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
            
%         P_Size = [params.general.P_Size];
%         X_Size = [params.general.X_Size];
%         U_Strain = [params.general.U_Strain];
%         Y_Strain = [params.general.Y_Strain];
        
        % Fuer die Berechnung benoetigte Sub-Funktionen
        modEP = obj.getSubFunction('EnergyPos');
        
        ep = cell([phaseCnt, specSize]);
     
            % Berechnung der zur Berechnung der Integralintensitaet
            % benoetigten Parameter
            for p = 1:phaseCnt
		
                for s = 1:specSize
			
                    ep{p,s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
                end
            end

            H_kG = cell(size(ep));
            H_kL = cell(size(ep));
            PeakBreath = cell(size(ep));
%             GL = cell(size(ep));
%             IntegratedInt = cell(size(ep));
            
            for k = 1:phaseCnt
                for l = 1:specSize
%                     for i = 1:size(ep{k,l},1)
                        H_kG{k,l} = sqrt(Phys_P(l)+Phys_U(l).*(ep{k,l}.^2));
                        H_kL{k,l} = Phys_X(l)+Phys_Y(l).*ep{k,l};
                        PeakBreath{k,l} = (H_kG{k,l}.^5+2.69269.*H_kG{k,l}.^4.*H_kL{k,l}+2.42843.*H_kG{k,l}.^3.*H_kL{k,l}.^2+4.47163.*H_kG{k,l}.^2.*H_kL{k,l}.^3+0.07842.*H_kG{k,l}.*H_kL{k,l}.^4+H_kL{k,l}.^5).^(0.2);
                end
            end
        end
        
%         function ms = saveFitResults(obj)
% 		
%             % Anzahl der Spektren und Phasen 
%             specSize = obj.getRVContainer().getSpecSize();
%             phaseCnt = obj.getRVContainer().getPhaseCnt();
% 
%             % Laden des Parametercontainers, damit auf die zur Berechnung
%             % notwendigen Parameter zugegriffen werden kann.
%             params = obj.getRVContainer().getParamStruct();
% 
%             modEP = obj.getSubFunction('EnergyPos');
% 
%             ep = cell([phaseCnt, specSize]);
%         
%             % Berechnung der zur Berechnung der Integralintensitaet
%             % benoetigten Parameter
%             for p = 1:phaseCnt
% 		
%                 for s = 1:specSize
% 			
%                     ep{p,s} = modEP.execute([], params.general(p,s), params.meas, params.phase(p), params.spec(s));
%                 end
%             end
%             
%             % Berechnet aus den Energielagen die entsprechenden d-Werte.
%             
%             peakCnt = size([obj.getRVContainer().getParam('general','H').value],1);
%             % Muss noch angepasst werden, je nachdem ob TwoTheta gefittet
%             % oder konstant gehalten wird.
%             TwoTheta = [obj.getRVContainer().getParam('spec','TwoTheta').value]';
%             EPos = [ep{1:specSize}]';
%             
%             for p = 1:peakCnt
%                     dhkl(:,p) = 12.398./(2.*sind(TwoTheta./2)).*1./EPos(:,p);
%             end
%             
%             d_hkl = dhkl;
%             
%             
% 			Instr_P = [obj.getRVContainer.getParam('general','P_Size').lowerConstraint];
% 			Meas_P = [obj.getRVContainer.getParam('general','P_Size').value];
% 			Phys_P = (Meas_P - Instr_P)';
% 
% 			Instr_X = [obj.getRVContainer.getParam('general','X_Size').lowerConstraint];
% 			Meas_X = [obj.getRVContainer.getParam('general','X_Size').value];
% 			Phys_X = (Meas_X - Instr_X)';
% 
% 			Instr_U = [obj.getRVContainer.getParam('general','U_Strain').lowerConstraint];
% 			Meas_U = [obj.getRVContainer.getParam('general','U_Strain').value];
% 			Phys_U = (Meas_U - Instr_U)';
% 
% 			Instr_Y = [obj.getRVContainer.getParam('general','Y_Strain').lowerConstraint];
% 			Meas_Y = [obj.getRVContainer.getParam('general','Y_Strain').value];
% 			Phys_Y = (Meas_Y - Instr_Y)';
% 			
% % 			TwoTheta = obj.getRVContainer.getParam('spec','TwoTheta').value;
% 			TwoTheta = obj.getRVContainer.getParam('meas','TwoTheta').value;
% 	
% 			beta_L_size = pi./2.*Phys_X;
% 
% 			beta_G_size = sqrt(pi./4./log(2).*Phys_P);
% 
% 			beta_L_strain = pi./2.*Phys_Y;
% 
% 			beta_G_strain = sqrt(pi./4./log(2).*Phys_U);
% 
% 			beta_Size = beta_G_size./(-0.5.*beta_L_size./beta_G_size+0.5.*sqrt(pi.*(beta_L_size./(sqrt(pi).*beta_G_size)).^2+4)-0.234.*beta_L_size./(sqrt(pi).*beta_G_size).*exp(-2.176.*beta_L_size./(sqrt(pi).*beta_G_size)));
% 
% 			beta_Strain = beta_G_strain./(-0.5.*beta_L_strain./beta_G_strain+0.5.*sqrt(pi.*(beta_L_strain./(sqrt(pi).*beta_G_strain)).^2+4)-0.234.*beta_L_strain./(sqrt(pi).*beta_G_strain).*exp(-2.176.*beta_L_strain./(sqrt(pi).*beta_G_strain)));
% 
% 			Size = (6.199)./(beta_Size.*sind(TwoTheta./2));
% % 			Size = (6.199)./(beta_Size.*sin(TwoTheta./2.*pi./180));
% 			
% 			Strain = beta_Strain./2;
% 			
% 			% Header fuer die gespeicherte Textdatei.
%             % Den Eintrag 'Phi' hab ich rausgelöscht, da der Parameter
%             % nicht definiert war. Unten muss es auch wieder auskommentiert
%             % werden.
% 			Headers = {'Psi', 'P_measured', 'P_sample', 'X_measured', 'X_sample', ...
% 		   'U_measured', 'U_sample', 'Y_measured', 'Y_sample', ...
% 		   'beta_L_size', 'beta_G_size', 'beta_L_strain', 'beta_G_strain', ...
% 		   'beta_Size', 'beta_Strain', 'Size_[A]', 'Strain_[%]'};
% 			% Matrix erstellt aus den verwendeten Daten.
% 			ms = [Meas_P', Phys_P, Meas_X', Phys_X, Meas_U', Phys_U, Meas_Y', Phys_Y, beta_L_size, beta_G_size, beta_L_strain, beta_G_strain, beta_Size, beta_Strain, Size, Strain];		   
% 			
% 			% Parametercontainer auslesen.
% 			params = struct2cell(obj.getRVContainer().getParamStruct());
% 			SpecSize = obj.getRVContainer.getSpecSize;
% 			% Psi auslesen.
% 			PsiTmp = zeros(SpecSize);
% 			for i = 1:SpecSize
% 				PsiTmp(i,:) = params{4,1}(i,1).Psi;
% 			end
% 			PsiTmp = reshape(PsiTmp,SpecSize);
% 
% 			% Phi auslesen.
% % 			PhiTmp = zeros(SpecSize);
% % 			for i = 1:SpecSize
% % 				PhiTmp(i,:) = params{4,1}(i,1).Phi;
% % 			end
% 			
% % 			Dat = [PsiTmp, PhiTmp, ms];
%             Dat = [PsiTmp, ms];
% 			% Numbers are converted to strings using num2str, because 
% 			% fprintf expects just strings. By using cellfun every element
% 			% of num2cell(...) is converted iteratively in strings,
% 			% obtaining a cell.
% 			Data = cellfun(@num2str, num2cell(Dat), 'UniformOutput', false);
% 			Final = [Headers;Data];
% 			% Speichern der Daten in einer Textdatei.
% 			fid = fopen('MicrostructureAnalysis.txt','wt');
% % 			[filenamePattern, num2str(i), '.dat']
% 			
% 			for i = 1:size(Final,1)
% 				fprintf(fid,'%s ', Final{i,:});
% 				fprintf(fid,'\n');
% 			end
% 			
% 			fclose(fid);
% 						
% 		end
	end
end

