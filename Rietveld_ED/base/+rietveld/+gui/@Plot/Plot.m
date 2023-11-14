classdef Plot < hgsetget
%% (* Plot *)
% Ein einfaches Fenster, welches auf Eingabe eines "RVAnalysis"-Objekts
% einen Plot mit Slider erzeugt.
% -------------------------------------------------------------------------

%% Steuerelemente

	properties (Access = private)
		
		% Figure handle
		fig;
		
		% Axes
		plotAxes;
		
		% Slider
		slider;
		
% 		% Label
% 		label;
	end
	
%% Weitere Eigenschaften

	properties (Access = private)
		
		% PlotHandles (siehe createPlots)
		plotHandles;
		
% 		% TextHandles (siehe createPlots)
% 		textHandles;
	end
	
%% Konstanten
	
	properties (Access = private)
		
		% Hoehe der Matlab-Bar
		SLIDER_HEIGHT = 25;
		% Randdicke der Steuerelemente (siehe addBorder)
		DEFAULT_BORDER = 3;
	end
	
	methods (Access = private)
		
		function resize(obj, h, data) %#ok
		% Resize callback des Fensters.
			
			function corrPos = addBorder(pos)
			% Hilfsfunktion, die einen Rand auf einen Bound addiert.

				corrPos(1) = pos(1) + obj.DEFAULT_BORDER;
				corrPos(2) = pos(2) + obj.DEFAULT_BORDER;
				corrPos(3) = pos(3) - 2 * obj.DEFAULT_BORDER;
				corrPos(4) = pos(4) - 2 * obj.DEFAULT_BORDER;
			end
			
			% Layout des Fensters
			try
				figPos = get(obj.fig, 'Position');

				set(obj.slider, 'Position', addBorder([0, 0, figPos(3), obj.SLIDER_HEIGHT]));	
			catch ex
				
				disp(ex.message);
			end
		end
		
		function sliderCallback(obj, h, data) %#ok
		% Slider Callback. Hier wird die Sichtbarkeit des jeweiligen Plot
		% eingestellt.
			
			% aktueller Plot
            index = round(get(h, 'Value'));
			
			% zunaechst alle Plot verstecken
			for i = 1:size(obj.plotHandles, 1)
				
				for j = 1:size(obj.plotHandles, 2)
					
					set(obj.plotHandles(i, j), 'Visible', 'off');
				end
			end
			
			% richtigen Plot sichtbar machen
			for j = 1:size(obj.plotHandles, 2)
					
				set(obj.plotHandles(index, j), 'Visible', 'on');
			end
			
% 			% zunaechst alle Text verstecken
% 			for i = 1:size(obj.textHandles, 1)
% 				
% 				for j = 1:size(obj.textHandles, 2)
% 					
% 					set(obj.textHandles(i, j), 'Visible', 'off');
% 				end
% 			end
% 			
% 			% richtigen Text sichtbar machen
% 			for j = 1:size(obj.textHandles, 2)
% 					
% 				set(obj.textHandles(index, j), 'Visible', 'on');
% 			end
						
			% Beschriftung
			title(obj.plotAxes, ['Spectrum ', num2str(index)]);
			xlabel(obj.plotAxes, 'Energy [keV]');
			ylabel(obj.plotAxes, 'Intensity [cts]');
		end
	end
	
	methods (Access = public)
		
		function obj = Plot(rvAnalysis, resPlotPosition)
		% Standard-Konstruktor der die Steuerelemente erzeugt. Die Daten
		% werden der "RVAnalysis"-Instanz "rvAnalysis" geholt. Mit
		% "resPlotPosition" gibt man den Abstand des Residuumsplots an.
		
			if (nargin < 2)
				
				resPlotPosition = NaN;
			end
		
			validateattributes(rvAnalysis, {'rietveld.analysis.RVAnalysis'}, {'scalar'})
			validateattributes(resPlotPosition, {'double'}, {'scalar'});
			
			%% Figure			
			obj.fig = figure('Tag', 'PlotWindow',...
				'Name', 'Rietveld-plot-window',...
				'Resize', 'on',...
				'Toolbar', 'figure',...
				'Position', [100 100 880 514],...
				'NumberTitle', 'off',...
				'ResizeFcn', @(h, evtdata, data)resize(obj, h, guidata(h)));
			
			%% Axes
			obj.plotAxes = axes('Tag', 'PlotAxes',...
				'Parent', obj.fig,...
				'Units', 'normalized',...
				'OuterPosition',[0 0 1 1],...
				'XGrid', 'on', 'YGrid', 'on');
			
			%% Slider
			obj.slider = uicontrol('Tag', 'Slider',...
				'Parent', obj.fig,...
				'Style', 'slider',...
				'Value', 1,...
				'Callback', @(h, evtdata, data)sliderCallback(obj, h, guidata(h)));
			
% 			%% Label
% 			obj.label = uicontrol('Tag', 'Label',...
% 				'Parent', obj.fig,...
% 				'Style', 'text',...
% 				'FontSize', 14,...
% 				'FontName', 'Arial',...
% 				'Callback', @(h, evtdata, data)sliderCallback(obj, h, guidata(h)));				
			
			obj.createPlots(rvAnalysis, resPlotPosition);
			
		end
		
		function createPlots(obj, rvAnalysis, resPlotPosition)
		% Diese Funktion erzeugt die Plots. Hier koennen auch weitere Plots
		% hinzugefuegt werden. Zur Dartstellung werden die Plots in
		% plotHandles gespeichert und zwar pro Spalte ein Plot. Mit
		% "resPlotPosition" gibt man den Abstand des Residuumsplots an.
			
			rc = rvAnalysis.getRVContainer();
			params = rvAnalysis.getRVContainer().getParamStruct();
            phaseCnt = rc.getPhaseCnt;
% 			assignin('base', 'params', params);
			
			specSize = prod(rc.getSpecSize);
			
			dataYCalc = rvAnalysis.computeSpectrum();
			res = rvAnalysis.computeResiduals();
			
			EPos = rvAnalysis.computeEnergyPosReal(); % Berechnung der Energielagen
			
% 			assignin('base', 'EPos', EPos);
			
			% Energielagen in Matrix schreiben
% 			lmax = max(cellfun(@length,EPos));
            
            for i = 1:phaseCnt
               lmax(:,i) = max(cellfun(@length,EPos(i)));
            end
            
%             disp(lmax)
%             assignin('base', 'lmax', lmax);

            ncol = cellfun(@length,EPos);
            
            for i = 1:phaseCnt
                ncol1{:,i} = ncol(i,:);
            end
            
            % Aenderung 25.09.2015: max(lmax) statt lmax, sonst laeuft es
            % nicht bei mehr als einer Phase.
%             EPositionsExp=zeros(max(lmax),numel(EPos));
%             for k=1:numel(ncol)
%                 EPositionsExp(1:ncol(k),k)=EPos{k}; % vorn einfügen 
%             end

            for i = 1:phaseCnt
                EPositionsExp1{:,i}=zeros(lmax(i),numel(EPos)/phaseCnt);
                for k=1:numel(ncol1{i})
                    EPositionsExp1{i}(1:ncol1{i},k)=EPos{i,k}; % vorn einfügen 
                end
            end
      
            EPositionsExp1 = vertcat(EPositionsExp1{:});
            EPositionsExp = EPositionsExp1;
%             EPositionsExp = reshape(EPositionsExp,max(lmax)*phaseCnt,specSize);
            
% 			assignin('base', 'EPos', EPositionsExp);
			
% 			% Sortieren der Matrixelemente gemäß ihres Auftretens in den
% 			% Spektren. (Hier: hkl Reihenfolge)
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
            
			% Erzeugen des korrekten A_logical. A_logical wird dann zur
			% korrekten Indizierung der Reflexe hkl verwendet.
			A_logical_sorted = cell(size(EPositionsExp,1),1);
			for i = 1:size(EPositionsExpsorted,1)
				for j = 1:size(EPositionsExpsorted,1)
					C = ismemberf(EPositionsExpsorted,EPositionsExpsorted(i,1),'tol',0.5);
					A_logical_sorted{i,1} = C;
				end
			end
			
			assignin('base', 'A_logical_sorted', A_logical_sorted);
					
% 			assignin('base', 'EPosSorted', EPositionsExpsorted);
			
			% Bestimmung der Intensitaeten für die entsprechenden
			% Reflexpositionen EPositionsExp.
% 			int = zeros(size(EPositionsExp,1),size(EPositionsExp,2)/2);
            int = zeros(size(EPositionsExp));
            
            assignin('base', 'EPositionsExp', EPositionsExp);
            assignin('base', 'dataYCalc', dataYCalc);
			dataX = rc.getDataX;
            assignin('base', 'dataXCalc', dataX);
            
            for i = 1:specSize
				int(:,i) = interp1(rc.getDataX(':',i),dataYCalc(:,i),EPositionsExp(:,i));
            end
			
			assignin('base', 'int', int);
			
			% Einlesen der hkl Reflexbezeichnungen. Dabei wird erneut davon
			% ausgegangen, dass im ersten Spektrum die maximale Anzahl an
			% Reflexen vorliegt. Es wird eine Matrix erstellt, die die H-
			% K- und L-Werte des entsprechenden Reflexes beinhaltet.
			
% 			for i = 1:specSize
%				Reflex{:,i} = [params.general(1,i).H, params.general(1,i).K, params.general(1,i).L];
% 			end

% 			Reflex = [params.general(1,1).H, params.general(1,1).K, params.general(1,1).L];

% 			assignin('base', 'Reflex', Reflex)

			% Es wird ein Char Array erzeugt, welches die
			% Reflexbezeichnungen als 'String' enthaelt. Diese Strings
			% werden dann zur Erstellung einer Header-Zeile benutzt.
% 			Head = num2str(Reflex);
% 			assignin('base', 'Head', Head)

			% Aus dem Char Array wird ein Cell-Array erzeugt.
% 			for i = 1:length(Head)
% 				HeadersTmp(i) = {Head(i,:)};
% 			end
			
			% Die Leerzeichen in den Strings werden gelöscht.
% 			for i = 1:size(HeadersTmp,2)
% 				HeadersChar(i,:) = strrep(HeadersTmp{1,i}, ' ', '');
% 			end
% 			
% 			Head = cellstr(HeadersChar);
			
% 			assignin('base', 'Head', Head);
			
			% Umwandeln des Logicals 'A_logical' in eine Matrix, die zur
			% Indizierung der Reflexe genutzt werden kann.
% 			Indices = evalin('base', 'A_logical_sorted');
% 			
% 			Logicalmat = zeros(size(Indices));
% 			for i=1:numel(Indices)
% 				for j = 1:specSize
% 					Logicalmat(i,j) = Indices{i}(i,j);
% 				end
% 			end
			
% 			assignin('base', 'Logicalmat', Logicalmat);
			
			% Erzeugen einer Matrix mit den sich aus Logicalmat ergebenden
			% Reflexindizes.
% 			nrows = size(Logicalmat,1);
% 			ncols = size(Logicalmat,2);
% 
% 			Reflexindizes = zeros(nrows,ncols);
% 
% 			for r = 1:nrows
% 				for c = 1:ncols
% 
% 					if Logicalmat(r,c) == 1
% 						Reflexindizes(r,c) = str2double(Head(r,1));
% 					else
% 						Reflexindizes(r,c) = 0;
% 					end
% 				end
% 			end
			
% 			assignin('base', 'Reflexindizes', Reflexindizes);
			
			% Sortieren der Reflexindizes in die richtige Reihenfolge fuer
			% den spaeteren Plot.
% 			Reflexindizessorted = zeros(size(Reflexindizes));
% 			for J = 1:size(Reflexindizes,2)
% 				nonzeros = Reflexindizes(:,J)~=0;
% 				Reflexindizessorted(1:nnz(nonzeros), J) = Reflexindizes(nonzeros,J);
% 			end
			
% 			assignin('base', 'Reflexindizessorted', Reflexindizessorted);
						
			% Vorbereiten des Plots
			hold(obj.plotAxes);
			obj.plotHandles = zeros(specSize, 4);
% 			obj.textHandles = zeros(specSize, 1);
% 			disp(EPositionsExp)
%             assignin('base', 'EPositionsExp', EPositionsExp);
			% Durchlauf aller Spektren
            if phaseCnt == 1
                for i = 1:specSize

                    if (isnan(resPlotPosition))

                        resPlotPositionTmp = max(res(:,i)) * 1.5;
                    else

                        resPlotPositionTmp = resPlotPosition;
                    end

                    % Eigentlicher Plot
                    obj.plotHandles(i,1) = plot(obj.plotAxes, rc.getDataX(':',i), rc.getDataY(':',i), 'b+');
                    obj.plotHandles(i,2) = plot(obj.plotAxes, rc.getDataX(':',i), dataYCalc(:,i),'r-','LineWidth',2);
                    obj.plotHandles(i,3) = plot(obj.plotAxes, rc.getDataX(':',i), res(:,i) - resPlotPositionTmp ,'k-','LineWidth',1);
                    obj.plotHandles(i,4) = plot(obj.plotAxes, EPositionsExp(:,i), int(:,i),'k^','markerfacecolor',[0 1 0]);
                    xlim([min(rc.getDataX(':',i)) max(rc.getDataX(':',i))]);
    % 				obj.textHandles(i,1) = text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,1)), 'Rotation', 90, 'Parent', obj.plotAxes);
    % 				text(EPositionsExp(:,i), int(:,i)+((5.*int(:,i))./100), labels, 'Rotation', 90, 'Parent', obj.plotAxes);
    % 				text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,11)), 'Rotation', 90, 'Parent', obj.plotAxes);
                xlabel('Energy [keV]','FontSize', 15);
                ylabel('Intensity [cts]','FontSize', 15);
                end
            elseif phaseCnt == 2
                for i = 1:specSize
				
				if (isnan(resPlotPosition))
					
					resPlotPositionTmp = max(res(:,i)) * 1.5;
				else
					
					resPlotPositionTmp = resPlotPosition;
				end
				
				% Eigentlicher Plot
				obj.plotHandles(i,1) = plot(obj.plotAxes, rc.getDataX(':',i), rc.getDataY(:,i), 'b+');
				obj.plotHandles(i,2) = plot(obj.plotAxes, rc.getDataX(':',i), dataYCalc(:,i),'r-','LineWidth',2);
				obj.plotHandles(i,3) = plot(obj.plotAxes, rc.getDataX(':',i), res(:,i) - resPlotPositionTmp ,'k-','LineWidth',1);
				obj.plotHandles(i,4) = plot(obj.plotAxes, EPositionsExp(1:lmax(1),i), int(1:lmax(1),i),'k^','markerfacecolor',[0 1 0]);
                obj.plotHandles(i,5) = plot(obj.plotAxes, EPositionsExp(lmax(1)+1:lmax(1)+lmax(2),i), int(lmax(1)+1:lmax(1)+lmax(2),i),'k^','markerfacecolor',[1 1 0]);
                xlim([min(rc.getDataX(':',i)) max(rc.getDataX(':',i))]);
% 				obj.textHandles(i,1) = text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,1)), 'Rotation', 90, 'Parent', obj.plotAxes);
% 				text(EPositionsExp(:,i), int(:,i)+((5.*int(:,i))./100), labels, 'Rotation', 90, 'Parent', obj.plotAxes);
% 				text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,11)), 'Rotation', 90, 'Parent', obj.plotAxes);
                xlabel('Energy [keV]','FontSize', 15);
                ylabel('Intensity [cts]','FontSize', 15);
                end
            elseif phaseCnt == 3
                for i = 1:specSize
				
				if (isnan(resPlotPosition))
					
					resPlotPositionTmp = max(res(:,i)) * 1.5;
				else
					
					resPlotPositionTmp = resPlotPosition;
				end
				
				% Eigentlicher Plot
				obj.plotHandles(i,1) = plot(obj.plotAxes, rc.getDataX(':',i), rc.getDataY(':',i), 'b+');
				obj.plotHandles(i,2) = plot(obj.plotAxes, rc.getDataX(':',i), dataYCalc(:,i),'r-','LineWidth',2);
				obj.plotHandles(i,3) = plot(obj.plotAxes, rc.getDataX(':',i), res(:,i) - resPlotPositionTmp ,'k-','LineWidth',1);
				obj.plotHandles(i,4) = plot(obj.plotAxes, EPositionsExp(1:lmax(1),i), int(1:lmax(1),i),'k^','markerfacecolor',[0 1 0]);
                obj.plotHandles(i,5) = plot(obj.plotAxes, EPositionsExp(lmax(1)+1:lmax(1)+lmax(2),i), int(lmax(1)+1:lmax(1)+lmax(2),i),'k^','markerfacecolor',[1 1 0]);
                obj.plotHandles(i,6) = plot(obj.plotAxes, EPositionsExp(lmax(1)+lmax(2)+1:end,i), int(lmax(1)+lmax(2)+1:end,i),'k^','markerfacecolor',[0 1 1]);
                xlim([min(rc.getDataX(':',i)) max(rc.getDataX(':',i))]);
% 				obj.textHandles(i,1) = text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,1)), 'Rotation', 90, 'Parent', obj.plotAxes);
% 				text(EPositionsExp(:,i), int(:,i)+((5.*int(:,i))./100), labels, 'Rotation', 90, 'Parent', obj.plotAxes);
% 				text(EPositionsExp(:,1), int(:,1)+((5.*int(:,1))./100), num2str(Reflexindizessorted(:,11)), 'Rotation', 90, 'Parent', obj.plotAxes);
                xlabel('Energy [keV]','FontSize', 15);
                ylabel('Intensity [cts]','FontSize', 15);
                end
            end
		
			% Legende
			legend('measured profile', 'calculated profile', 'residual');
			
            if specSize ~= 1
                % Slider inititalisieren
                set(obj.slider,...
                    'Min', 1,...
                    'Max', specSize,...
                    'SliderStep', [1/(specSize-1) 1/(specSize-1)]);
                obj.sliderCallback(obj.slider, []);
            end
		end
		
	end
end

