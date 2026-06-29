for k = 1:size(h.plotData.dataLatticeSpacing{1,1},2)
    figure
    fig = gcf;
    fig.PaperUnits = 'centimeters';
    fig.PaperPosition = [0 0 18 12];
    ax = gca;
    ax.OuterPosition = [0 0 1.085 1.025];
    ax.TickDir = 'out';
    ax.YAxis.TickLabelFormat = '%.4f';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;
    ax.XLim = [0 1];
    % Set axes limits for lattice spacings
    % Find min/max value
	dmin = zeros(1,length(ia{1}));
    dmax = zeros(1,length(ia{1}));					   
    for m = 1:length(ia{1})
        dmin(:,m) = min(h.ParamsToFit(m).LatticeSpacing{k} - h.ParamsToFit(m).LatticeSpacing_Delta{k});
        dmax(:,m) = max(h.ParamsToFit(m).LatticeSpacing{k} + h.ParamsToFit(m).LatticeSpacing_Delta{k});
    end
    % Calculate limits
    % Round dmin and dmax values
    dmintmp = round(min(dmin),4);
    dmaxtmp = round(max(dmax),4);
    % Create Y limits
    YLimLow = dmintmp - 0.0001;
    YLimHigh = dmaxtmp + 0.0001;
    % Calculate difference
    Ylimdiff = YLimHigh - YLimLow;
    % Calculate Ytick marks
    if Ylimdiff >= 8e-4
        if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
            if abs(YLimLow-min(dmin)) > abs(YLimHigh-max(dmax))
                YLimHigh = YLimHigh + 0.0001;
                if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
                    YLimHigh = YLimHigh + 0.0001;
                end
                ax.YTick = 10*YLimLow:0.002:10*YLimHigh;
            elseif abs(YLimLow-min(dmin)) < abs(YLimHigh-max(dmax))
                YLimLow = YLimLow - 0.0001;
                if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
                    YLimLow = YLimLow - 0.0001;
                end
                ax.YTick = 10*YLimLow:0.002:10*YLimHigh;
            end
        else
            ax.YTick = 10*YLimLow:0.002:10*YLimHigh;
        end
    elseif Ylimdiff < 8e-4 && Ylimdiff > 4e-4
        if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
            if abs(YLimLow-min(dmin)) > abs(YLimHigh-max(dmax))
                YLimHigh = YLimHigh + 0.0001;
                ax.YTick = 10*YLimLow:0.001:10*YLimHigh;
            elseif abs(YLimLow-min(dmin)) < abs(YLimHigh-max(dmax))
                YLimLow = YLimLow - 0.0001;
                ax.YTick = 10*YLimLow:0.001:10*YLimHigh;
            end
        else
            ax.YTick = 10*YLimLow:0.001:10*YLimHigh;
        end
    elseif Ylimdiff <= 4e-4
        ax.YTick = 10*YLimLow:0.001:10*YLimHigh;  
    end

    ax.YLim = [10*YLimLow, 10*YLimHigh]; 
    ax.YLabel.String = ['d [',char(197),']'];
    ax.YLabel.FontSize = 24;
    ax.XLabel.String = ['sin',char(178),'\psi'];
    ax.XLabel.FontSize = 24;
    ax.LabelFontSizeMultiplier = 1.3;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',18)
    hold on
    set(fig, 'Visible', 'off');
%     FaceColor = {h.Colors{k},h.Colors{k},'w','w'};
    
    % FaceColor of markers, order changes when measured under four azimuths
    if length(ia{1}) == 4
        FaceColor = {h.Colors{k},h.Colors2{k},h.Colors{k},h.Colors2{k}};
    else
        FaceColor = {h.Colors{k},h.Colors{k},h.Colors2{k},h.Colors2{k}};
    end

    if ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        % sigma11 + sigma13
        dphi0phi180 = (h.sin2psi.dphi0{k}+h.sin2psi.dphi180{k})./2;
        dreglinephi0phi180 = (h.sin2psi.reglinephi0(:,k) + h.sin2psi.reglinephi180(:,k))./2;
        xdataphi0phi180 = (h.sin2psi.dphi0p180sinquadratpsi{k}(:,1));
        Deltaphi0phi180 = (h.sin2psi.dphi0delta{k} + h.sin2psi.dphi180delta{k})./2;

        dplotphi0phi180 = errorbar(ax,xdataphi0phi180,10*dphi0phi180,10*Deltaphi0phi180,'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',FaceColor{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0phi180 = line(ax,linspace(0,1,51),10.*dreglinephi0phi180,'Color',h.Colors{k},'LineWidth',2);
        
        LegDatadspacing = dplotphi0phi180;
        LegLabelData = {['\phi = 0/180',char(176)]};


        % Export data to file
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_dspacing_phiavg_Line_','%d'],k);

        fid = fopen([[Path,'\'],FileName,'_',d,'.txt'],'w');

        fprintf(fid, [['sin²psi','   '],['d-spacing [A]','(phi=',num2str(PhiWinkel{1}(1)),char(176),')    '],['d-spacing error [A]','(phi=',num2str(PhiWinkel{1}(1)),char(176),')    '],'\n']);

            % In case measurements where performed under four different phi angles
            for m = 1:size(xdataphi0phi180,1)
                    str = sprintf('%.4f  %.6f  %.6f\n',...
                    xdataphi0phi180(m),...
                    dphi0phi180(m).*10,...
                    Deltaphi0phi180(m).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
            end

        fclose(fid);
        
        FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_dspacing_phiavg_LR_Line_','%d'],n);
        fid = fopen([[Path,'\'],FileName,'_',d,'.txt'],'w');

        fprintf(fid, [['sin²psi','   '],['d-spacing Fit [A]','(phi= 0/180',char(176),')    '],'\n']);
        
        PsiPlottmp = linspace(0,1,51);
            % In case measurements where performed under four different phi angles
            for m = 1:size(PsiPlottmp,1)
                    str = sprintf('%.4f  %.6f\n',...
                    PsiPlottmp(m),...
                    dreglinephi0phi180(m).*10);
                    str = regexprep(str, 'NaN', '  --  ');
                    fprintf(fid, '%s', str);
            end

        fclose(fid);


    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        % sigma22 + sigma23
        dphi90phi270 = (h.sin2psi.dphi90{k}+h.sin2psi.dphi270{k})./2;
        dreglinephi90phi270 = (h.sin2psi.reglinephi90(:,k) + h.sin2psi.reglinephi270(:,k))./2;
        xdataphi90phi270 = (h.sin2psi.dphi90p270sinquadratpsi{k}(:,1));
        Deltaphi90phi270 = (h.sin2psi.dphi90delta{k} + h.sin2psi.dphi270delta{k})./2;
        
        dplotphi90phi270 = errorbar(ax,xdataphi90phi270,10*dphi90phi270,10*Deltaphi90phi270,'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',FaceColor{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90phi270 = line(ax,linspace(0,1,51),10.*dreglinephi90phi270,'Color',h.Colors{k},'LineWidth',2);
        
        LegDatadspacing = dplotphi90phi270;
        LegLabelData = {['\phi = 90/270',char(176)]};
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        % sigma11 + sigma13
        dphi0phi180 = (h.sin2psi.dphi0{k}+h.sin2psi.dphi180{k})./2;
        dreglinephi0phi180 = (h.sin2psi.reglinephi0(:,k) + h.sin2psi.reglinephi180(:,k))./2;
        xdataphi0phi180 = (h.sin2psi.dphi0p180sinquadratpsi{k}(:,1));
        Deltaphi0phi180 = (h.sin2psi.dphi0delta{k} + h.sin2psi.dphi180delta{k})./2;
        
        % sigma22 + sigma23
        dphi90phi270 = (h.sin2psi.dphi90{k}+h.sin2psi.dphi270{k})./2;
        dreglinephi90phi270 = (h.sin2psi.reglinephi90(:,k) + h.sin2psi.reglinephi270(:,k))./2;
        xdataphi90phi270 = (h.sin2psi.dphi90p270sinquadratpsi{k}(:,1));
        Deltaphi90phi270 = (h.sin2psi.dphi90delta{k} + h.sin2psi.dphi270delta{k})./2;

        dplotphi0phi180 = errorbar(ax,xdataphi0phi180,10*dphi0phi180,10*Deltaphi0phi180,'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',FaceColor{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0phi180 = line(ax,linspace(0,1,51),10.*dreglinephi0phi180,'Color',h.Colors{k},'LineWidth',2);

        dplotphi90phi270 = errorbar(ax,xdataphi90phi270,10*dphi90phi270,10*Deltaphi90phi270,'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',FaceColor{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90phi270 = line(ax,linspace(0,1,51),10.*dreglinephi90phi270,'Color',h.Colors{k},'LineWidth',2);
        
        LegDatadspacing = [dplotphi0phi180 dplotphi90phi270];
        LegLabelData = {['\phi = 0/180',char(176)],['\phi = 90/270',char(176)]};
    end
    
    % Create legend
    l = legend(ax,LegDatadspacing,LegLabelData);
    % Find best legend position
    legposcell = {'NorthWest','NorthEast','SouthWest','SouthEast'};
    % Loop through legend positions in order to get coordinates of all
    % possible corner positions
    for m = 1:4
        l.Location = legposcell{m};
        LegendPos(:,m) = l.Position;
    end
	
	dataLatticeSpacing = cell(1,size(h.plotData.Psi_Winkel,2));
    for m = 1:size(h.plotData.Psi_Winkel,2)
        psiData{m} = h.plotData.Psi_Winkel{m}{k};
        dataLatticeSpacing{m} = h.plotData.dataLatticeSpacing{m}{k};
    end

    % Check if data intersects with legend box
    LegPosOpt = legendclash(ax,sind(cell2mat(psiData(:))).^2,10.*cell2mat(dataLatticeSpacing(:)),LegendPos);
    % Find index of zeros
    LegPosOptInd = find(LegPosOpt==0);
    % Set legend location and properties
    if isempty(LegPosOptInd)
        l.Location = legposcell{1};
    else
        l.Location = legposcell{LegPosOptInd(1)};
    end
    l.FontSize = 10;
    l.LineWidth = 0.5;
    
    title(l,[label(k,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
    set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
    FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_dspacing_phi_avg_Line_','%d'],k);
    print(fig,[Path,FileName],'-painters','-dtiff','-r300')
end