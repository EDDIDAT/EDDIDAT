function [sin2psiinterpol,daverage,derraverage,regressline,sigmaaverage,sigmaerraverage] = sin2psiAveraging(h)
% assignin('base','hParamsToFit',h.ParamsToFit)
% Check whether crystal symmetry is cubic (fcc/bcc)
if strcmp(h.Measurement(1).Sample.Materials.CrystalStructure,'fcc') || strcmp(h.Measurement(1).Sample.Materials.CrystalStructure,'bcc') && size(h.ParamsToFit(1).LatticeSpacing,2) ~= 1
    % Check if hkl were excluded from analysis
    if isfield(h,'idxhklPeaktable')
        sin2psi_tmp = h.sin2psi;
        Params_tmp = h.Params;
        ParamsToFit_tmp = h.ParamsToFit;
        fieldnames1 = fieldnames(sin2psi_tmp);
        fieldnames2 = fieldnames(ParamsToFit_tmp);
        fieldnames3 = fieldnames(Params_tmp);
        
        for i = 1:size(fieldnames1,1)
            if isa(sin2psi_tmp.(fieldnames1{i}),'cell')
                sin2psi_tmp.(fieldnames1{i})(~h.idxhklPeaktable) = [];
            elseif isa(sin2psi_tmp.(fieldnames1{i}),'double')
                if strcmp(fieldnames1{i},'StressPlotDatatmpsorted') || strcmp(fieldnames1{i},'sigmataulist') || strcmp(fieldnames1{i},'tautmp') || strcmp(fieldnames1{i},'taupsizero') 
                    sin2psi_tmp.(fieldnames1{i})(~h.idxhklPeaktable,:) = [];
                elseif strcmp(fieldnames1{i},'taumean') || strcmp(fieldnames1{i},'taupsizeromean') || strcmp(fieldnames1{i},'dzero') || strcmp(fieldnames1{i},'reglinephi0') || strcmp(fieldnames1{i},'reglinephi90') || strcmp(fieldnames1{i},'reglinephi180') || strcmp(fieldnames1{i},'reglinephi270')
                    sin2psi_tmp.(fieldnames1{i})(:,~h.idxhklPeaktable) = [];
                end
            end
        end
        
        for j = 1:size(ParamsToFit_tmp,2)
            for i = 1:size(fieldnames2,1)
                ParamsToFit_tmp(j).(fieldnames2{i})(~h.idxhklPeaktable) = [];
            end
        end
        
        for i = 1:size(fieldnames3,1)
            if isa(Params_tmp.(fieldnames3{i}),'cell')
                Params_tmp.(fieldnames3{i})(~h.idxhklPeaktable) = [];
            elseif isa(Params_tmp.(fieldnames3{i}),'double')
                Params_tmp.(fieldnames3{i})(~h.idxhklPeaktable,:) = [];
            end
        end
    else
        sin2psi_tmp = h.sin2psi;
        Params_tmp = h.Params;
        ParamsToFit_tmp = h.ParamsToFit;
    end
    
    % Get unique phi angles
    for k = 1:size(Params_tmp.Phi_Winkel,2)
        [PhiWinkel{k},ia{k},~] = unique(Params_tmp.Phi_Winkel{k});
    end

    % Find indices of phi angles.
    h.idxphi0 = find(PhiWinkel{1}==0);
    h.idxphi90 = find(PhiWinkel{1}==90);
    h.idxphi180 = find(PhiWinkel{1}==180);
    h.idxphi270 = find(PhiWinkel{1}==270);
    
    % Get multiplicity of reflection hkl
    DEKdatatmp = get(h.loadDEKtable,'data');
    hkl = DEKdatatmp(:,1:3);
    % Change DEk and hkl if user excluded peaks from analysis
    if isfield(h,'idxhklPeaktable')
        hkl(~h.idxhklPeaktable,:) = [];
        DEKdatatmp(~h.idxhklPeaktable,:) = [];
    end

    for k = 1:size(hkl,1)
        if length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 3 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 0
            multihkl(k) = 48;
        elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 3 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 1
            multihkl(k) = 24;
        elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 0
            multihkl(k) = 24;
        elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 1
            multihkl(k) = 12;
        elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 2
            multihkl(k) = 6;
        elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 1
            multihkl(k) = 8;    
        end
    end

    % Sum of multiplicity of alle reflections
    sumhkl = sum(multihkl);
    % Weight function according to multiplicity
    weighthkl = multihkl./sumhkl;
    % Calculate average DEK's s1 and s2h
    s1average = weighthkl*DEKdatatmp(:,4);
    s2haverage = weighthkl*DEKdatatmp(:,5);
%     assignin('base','hkl',hkl)
%     assignin('base','weighthkl',weighthkl)
%     assignin('base','s1average',s1average)
%     assignin('base','s2haverage',s2haverage)
    
    % Find reflection with the most sin2psi positions. Those are used for the
    % interpolation.
    for k = 1:size(ParamsToFit_tmp,2)
        [Sin2PsiMax(:,k), Sin2PsiInd(:,k)] = max(cellfun(@length,cellfun(@unique,ParamsToFit_tmp(k).Psi_Winkel,'UniformOutput',false)));
    end
    % Get index of max. entry in Sin2PsiMax
    % M1 = Value
    % M2 = Index
    [M1,M2] = max(Sin2PsiMax);
    % Sin2psi values for interpolation
    sin2psiinterpol = sind(cell2mat(ParamsToFit_tmp(M2).Psi_Winkel(Sin2PsiInd(M2)))).^2;
    % Interpolate d-sin2psi distributions
    for j = 1:size(ParamsToFit_tmp,2)
        for k = 1:size(ParamsToFit_tmp(j).Psi_Winkel,2)
            dinterp{j}(:,k) = interp1(sind(cell2mat(ParamsToFit_tmp(j).Psi_Winkel(k))).^2,cell2mat(ParamsToFit_tmp(j).LatticeSpacing(k)),sin2psiinterpol,'linear','extrap');
            derrinterp{j}(:,k) = interp1(sind(cell2mat(ParamsToFit_tmp(j).Psi_Winkel(k))).^2,cell2mat(ParamsToFit_tmp(j).LatticeSpacing_Delta(k)),sin2psiinterpol,'linear','extrap');
        end
    end

    % Calculate average, normalized, weighted d-spacings
    for j = 1:size(ParamsToFit_tmp,2)
        for l = 1:size(dinterp{j},2)
            for k = 1:size(dinterp{j},1)
                daveragetmp{j}(l,k) = dinterp{j}(k,l).*sqrt(hkl(l,1).^2+hkl(l,2).^2+hkl(l,3).^2).*weighthkl(l);
                derraveragetmp{j}(l,k) = (derrinterp{j}(k,l).*weighthkl(l)).^2;
            end
        end
    end
    % Sum averaged values
    for j = 1:size(ParamsToFit_tmp,2)
        daverage{j} = sum(daveragetmp{j});
        derraverage{j} = sqrt(sum(derraveragetmp{j}));
    end
    % Perform linear regeression, depending on phi angles. If data was measured
    % under more than one phi angle, check pairs of angles
    for j = 1:size(ParamsToFit_tmp,2)
        daverageregress{j} = fitlm(sin2psiinterpol,daverage{j},'Weight',1./derraverage{j});
    end
    % Get regress coefficients
    % Intercept = regresscoeff(1,1)
    % Slope = regresscoeff(2,1)
    for j = 1:size(ParamsToFit_tmp,2)
        regresscoeff{j} = table2array(daverageregress{j}.Coefficients);
    end
    % Calculate averaged taumean
    taumeanavarege = sum(weighthkl.*sin2psi_tmp.taumean);
    
    % Calculate averaged sigma11 (d0 = d(psi=0°))
    if length(PhiWinkel{1}) == 1
        for j = 1:size(ParamsToFit_tmp,2)
                sigmaaverage{j} = regresscoeff{j}(2,1)/s2haverage/daverage{j}(1);
                sigmaerraverage{j} = regresscoeff{j}(2,2)/s2haverage/daverage{j}(1);
        end
    elseif length(PhiWinkel{1}) == 2
        % For the case phi = 90°/180° it has to be considered, that sigma11 and
        % sigma 22 are interchanged. This is important regarding saving the
        % stress values to a file
        if isequal([0;90],PhiWinkel{1}) || isequal([0;270],PhiWinkel{1}) || isequal([180;270],PhiWinkel{1})
            for j = 1:size(ParamsToFit_tmp,2)
                sigmaaverage{j} = regresscoeff{j}(2,1)/s2haverage/daverage{j}(1);
                sigmaerraverage{j} = regresscoeff{j}(2,2)/s2haverage/daverage{j}(1);
            end
        elseif isequal([90,180],PhiWinkel{1})
            sigmaaverage{1} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
            sigmaerraverage{1} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1);
            sigmaaverage{2} = regresscoeff{1}(2,1)/s2haverage/daverage{1}(1);
            sigmaerraverage{2} = regresscoeff{1}(2,2)/s2haverage/daverage{1}(1);
        elseif isequal([0;180],PhiWinkel{1}) || isequal([90;270],PhiWinkel{1})
            sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,1)/s2haverage/daverage{2}(1))./2;
            sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,2)/s2haverage/daverage{2}(1))./2;
        end
    elseif length(PhiWinkel{1}) == 3
        if isequal([0;90;180],PhiWinkel{1})
                sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
                sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
                sigmaaverage{2} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
                sigmaerraverage{2} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1);
        elseif isequal([0;180;270],PhiWinkel{1})
                sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,1)/s2haverage/daverage{2}(1))./2;
                sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,2)/s2haverage/daverage{2}(1))./2;
                sigmaaverage{2} = regresscoeff{3}(2,1)/s2haverage/daverage{3}(1);
                sigmaerraverage{2} = regresscoeff{3}(2,2)/s2haverage/daverage{3}(1);
        elseif isequal([0;90;270],PhiWinkel{1})
                sigmaaverage{1} = regresscoeff{1}(2,1)/s2haverage/daverage{1}(1);
                sigmaerraverage{1} = regresscoeff{1}(2,2)/s2haverage/daverage{1}(1); 
                sigmaaverage{2} = (regresscoeff{2}(2,1)/s2haverage/daverage{2}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
                sigmaerraverage{2} = (regresscoeff{2}(2,2)/s2haverage/daverage{2}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
        elseif isequal([90;180;270],PhiWinkel{1})
                sigmaaverage{1} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
                sigmaerraverage{1} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1); 
                sigmaaverage{2} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
                sigmaerraverage{2} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;           
        end
    elseif length(PhiWinkel{1}) == 4
        sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
        sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
        sigmaaverage{2} = (regresscoeff{2}(2,1)/s2haverage/daverage{2}(1) + regresscoeff{4}(2,1)/s2haverage/daverage{4}(1))./2;
        sigmaerraverage{2} = (regresscoeff{2}(2,2)/s2haverage/daverage{2}(1) + regresscoeff{4}(2,2)/s2haverage/daverage{4}(1))./2;
    end
    % Calculate regression line
    sin2psiregline = (0:0.1:1);
    if length(PhiWinkel{1}) == 1
        for j = 1:size(ParamsToFit_tmp,2)
            regressline{j} = regresscoeff{j}(1,1) + regresscoeff{j}(2,1).*sin2psiregline;
        end
    elseif length(PhiWinkel{1}) == 2
        if isequal([0;90],PhiWinkel{1}) || isequal([0;270],PhiWinkel{1}) || isequal([180;270],PhiWinkel{1})
            for j = 1:size(ParamsToFit_tmp,2)
                regressline{j} = regresscoeff{j}(1,1) + regresscoeff{j}(2,1).*sin2psiregline;
            end
        elseif isequal([90,180],PhiWinkel{1})
            regressline{1} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
            regressline{2} = regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline;
        elseif isequal([0;180],PhiWinkel{1}) || isequal([90;270],PhiWinkel{1})
            regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
        end
    elseif length(PhiWinkel{1}) == 3
        if isequal([0;90;180],PhiWinkel{1})
            regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
            regressline{2} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
        elseif isequal([0;180;270],PhiWinkel{1})
            regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
            regressline{2} = regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline;
        elseif isequal([0;90;270],PhiWinkel{1})
            regressline{1} = regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline;
            regressline{2} = (regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
        elseif isequal([90;180;270],PhiWinkel{1})
            regressline{1} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
            regressline{2} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
        end
    elseif length(PhiWinkel{1}) == 4
        regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
        regressline{2} = (regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline + regresscoeff{4}(1,1) + regresscoeff{4}(2,1).*sin2psiregline)./2;
    end

    % Plot Results
    Marker = {'s','o','d','p'};
    figure('Name','Averaged stress analysis','NumberTitle','off','Units','normalized','Position', [0.453 0.353 0.313 0.332]);
    fig = gcf;
    ax = gca;
   
    if ~isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        LegDatadspacing = dplotphi0;
        LegLabelData = {'\phi = 0°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        LegDatadspacing = dplotphi90;
        LegLabelData = {'\phi = 90°'};
    elseif isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi180 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        LegDatadspacing = dplotphi180;
        LegLabelData = {'\phi = 180°'};
    elseif isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi270 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        LegDatadspacing = dplotphi270;
        LegLabelData = {'\phi = 270°'};    
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
        hold on
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        LegDatadspacing = [dplotphi0 dplotphi90];
        LegLabelData = {'\phi = 0°','\phi = 90°'};
    elseif ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        hold on
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        LegDatadspacing = [dplotphi0 dplotphi180];
        LegLabelData = {'\phi = 0°','\phi = 180°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
        hold on
        dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi180 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        LegDatadspacing = [dplotphi90 dplotphi180];
        LegLabelData = {'\phi = 90°','\phi = 180°'};    
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        LegDatadspacing = [dplotphi90 dplotphi270];
        LegLabelData = {'\phi = 90°','\phi = 270°'};	
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)	|| ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        hold on
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        dplotphi180 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
        LegDatadspacing = [dplotphi0 dplotphi90 dplotphi180];
        LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 180°'};	
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)%	|| ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        hold on
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        dplotphi270 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
        LegDatadspacing = [dplotphi0 dplotphi90 dplotphi270];
        LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 270°'};
    elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        hold on
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi180 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        dplotphi270 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
        LegDatadspacing = [dplotphi90 dplotphi180 dplotphi270];
        LegLabelData = {'\phi = 90°','\phi = 180°','\phi = 270°'};	
    elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
        hold on
        dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
        dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
        dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
        dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{4},derraverage{4},'Linestyle','none','Color','k','Marker',Marker{4},'MarkerFaceColor',h.Colors{4},'MarkerEdgeColor','k','MarkerSize',12);
        reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
        reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
        hold off
        LegDatadspacing = [dplotphi0 dplotphi90 dplotphi180 dplotphi270];
        LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 180°','\phi = 270°'};
    end

    l = legend(ax,LegDatadspacing,LegLabelData);

%     l.Location = 'northeast';
    l.FontSize = 10;
    l.LineWidth = 0.5;

    % Add calculated stress data to the plot
    if length(PhiWinkel{1}) == 1 && isequal(0,PhiWinkel{1}) || length(PhiWinkel{1}) == 1 && isequal(180,PhiWinkel{1}) || length(PhiWinkel{1}) == 2 && isequal([0;180],PhiWinkel{1})
        dim = [.175 .13 .2 .2];
        annotation('textbox',dim,'String',['<\sigma_{11}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');
    elseif length(PhiWinkel{1}) == 1 && isequal(90,PhiWinkel{1}) || length(PhiWinkel{1}) == 1 && isequal(270,PhiWinkel{1}) || length(PhiWinkel{1}) == 2 && isequal([90;270],PhiWinkel{1})
        dim = [.175 .13 .2 .2];
        annotation('textbox',dim,'String',['<\sigma_{22}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');    
    elseif length(PhiWinkel{1}) == 4
        dim = [.175 .16 .2 .2];
        annotation('textbox',dim,'String',{['<\sigma_{11}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],['<\sigma_{22}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{2})),' ',char(177),' ',num2str(round(sigmaerraverage{2})),' MPa']},'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');
    end

    fig.PaperUnits = 'centimeters';
    fig.PaperPositionMode = 'manual';
    fig.PaperPosition = [0 0 18 12];
    
    ax.OuterPosition = [0 0 1.085 1.025];
    ax.TickDir = 'out';
    ax.YAxis.TickLabelFormat = '%,.4f';
    ax.Box = 'on';
    ax.XGrid = 'on';
    ax.YGrid = 'on';
    ax.GridLineStyle = '-';
    ax.GridColor = 'k';
    ax.GridAlpha = 0.3;
    ax.YLabel.String = 'a(100) [nm]';
    ax.YLabel.FontSize = 24;
    ax.XLabel.String = 'sin²\psi';
    ax.XLabel.FontSize = 24;
    ax.LabelFontSizeMultiplier = 1.3;
    ax.LineWidth = 1.3;
    set(gca,'FontSize',14)
    ax.XLim = [0 1];
    ax.YLim = [floor(min(cellfun(@min,daverage))*15000)/15000,ceil(max(cellfun(@max,daverage))*15000)/15000];
%     ax.YLim = [floor((min(cellfun(@min,daverage))-0.0002)./0.0001).*0.0001 ceil((max(cellfun(@max,daverage))+0.0002)/0.0001).*0.0001];
    ax.YTick = linspace(ax.YLim(1),ax.YLim(2),11);
    ax.XTick = 0:0.1:1;
    
    % Save figure
%     Folder = '\Plots\';
%     h.diffmode = 'LIMAX-160';
%     if ~isfield(h,'PathName')
%         formatOut = 'ddmmyyyy';
%         d = datestr(now, formatOut);
%         name = strtrim(h.Measurement(1).MeasurementSeries);
%         material = h.P.PopupValueMpd1;
%         
%         if strcmp(h.diffmode,'LIMAX-160')
%             h.PathName = [General.ProgramInfo.Path,'\Data\Results\MetalJet\',[name,'_',material,'_','added_plots','_',d]];
%         elseif strcmp(h.diffmode,'LEDDI')
%             h.PathName = [General.ProgramInfo.Path,'\Data\Results\LEDDI\',[name,'_',material,'_','added_plots','_',d]];
%         end
%     end
    
    if ~isfield(h,'PathName')
        formatOut = 'ddmmyyyy';
        d = datestr(now, formatOut);
        name = strtrim(h.Measurement(1).MeasurementSeries);
    %     material = h.P.PopupValueMpd1;
        h.PathName = [General.ProgramInfo.Path,'\Data\Results\' h.Diffsel, '\',[name,'_','added_plots','_',d]];
    end
    Folder = '\StressPlots_averaged\';
    Path = fullfile(h.PathName,Folder);

    if exist(Path,'dir') ~= 7
        mkdir(Path);
    end
    
    set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
    FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_dspacing_averaged']);
    print(fig,[Path,FileName],'-painters','-dtiff','-r300')


    % Get unique phi angles
%     for k = 1:size(h.Params.Phi_Winkel,2)
%         [PhiWinkel{k},ia{k},~] = unique(h.Params.Phi_Winkel{k});
%     end
% 
%     % Find indices of phi angles.
%     h.idxphi0 = find(PhiWinkel{1}==0);
%     h.idxphi90 = find(PhiWinkel{1}==90);
%     h.idxphi180 = find(PhiWinkel{1}==180);
%     h.idxphi270 = find(PhiWinkel{1}==270);
%     
%     % Get multiplicity of reflection hkl
%     DEKdatatmp = get(h.loadDEKtable,'data');
%     hkl = DEKdatatmp(:,1:3);
%     for k = 1:size(hkl,1)
%         if length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 3 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 0
%             multihkl(k) = 48;
%         elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 3 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 1
%             multihkl(k) = 24;
%         elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 0
%             multihkl(k) = 24;
%         elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 1
%             multihkl(k) = 12;
%         elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 2 && length(find([hkl(k,1),hkl(k,2),hkl(k,3)]==0)) == 2
%             multihkl(k) = 6;
%         elseif length(unique([hkl(k,1),hkl(k,2),hkl(k,3)])) == 1
%             multihkl(k) = 8;    
%         end
%     end
% 
%     % Sum of multiplicity of alle reflections
%     sumhkl = sum(multihkl);
%     % Weight function according to multiplicity
%     weighthkl = multihkl./sumhkl;
%     % Calculate average DEK's s1 and s2h
%     s1average = weighthkl*DEKdatatmp(:,4);
%     s2haverage = weighthkl*DEKdatatmp(:,5);
% %     assignin('base','hkl',hkl)
% %     assignin('base','weighthkl',weighthkl)
% %     assignin('base','s1average',s1average)
% %     assignin('base','s2haverage',s2haverage)
%     
%     % Find reflection with the most sin2psi positions. Those are used for the
%     % interpolation.
%     for k = 1:size(h.ParamsToFit,2)
%         [Sin2PsiMax(:,k), Sin2PsiInd(:,k)] = max(cellfun(@length,cellfun(@unique,h.ParamsToFit(k).Psi_Winkel,'UniformOutput',false)));
%     end
%     % Get index of max. entry in Sin2PsiMax
%     % M1 = Value
%     % M2 = Index
%     [M1,M2] = max(Sin2PsiMax);
%     % Sin2psi values for interpolation
%     sin2psiinterpol = sind(cell2mat(h.ParamsToFit(M2).Psi_Winkel(Sin2PsiInd(M2)))).^2;
%     % Interpolate d-sin2psi distributions
%     for j = 1:size(h.ParamsToFit,2)
%         for k = 1:size(h.ParamsToFit(j).Psi_Winkel,2)
%             dinterp{j}(:,k) = interp1(sind(cell2mat(h.ParamsToFit(j).Psi_Winkel(k))).^2,cell2mat(h.ParamsToFit(j).LatticeSpacing(k)),sin2psiinterpol,'linear','extrap');
%             derrinterp{j}(:,k) = interp1(sind(cell2mat(h.ParamsToFit(j).Psi_Winkel(k))).^2,cell2mat(h.ParamsToFit(j).LatticeSpacing_Delta(k)),sin2psiinterpol,'linear','extrap');
%         end
%     end
% 
%     % Calculate average, normalized, weighted d-spacings
%     for j = 1:size(h.ParamsToFit,2)
%         for l = 1:size(dinterp{j},2)
%             for k = 1:size(dinterp{j},1)
%                 daveragetmp{j}(l,k) = dinterp{j}(k,l).*sqrt(hkl(l,1).^2+hkl(l,2).^2+hkl(l,3).^2).*weighthkl(l);
%                 derraveragetmp{j}(l,k) = (derrinterp{j}(k,l).*weighthkl(l)).^2;
%             end
%         end
%     end
%     % Sum averaged values
%     for j = 1:size(h.ParamsToFit,2)
%         daverage{j} = sum(daveragetmp{j});
%         derraverage{j} = sqrt(sum(derraveragetmp{j}));
%     end
%     % Perform linear regeression, depending on phi angles. If data was measured
%     % under more than one phi angle, check pairs of angles
%     for j = 1:size(h.ParamsToFit,2)
%         daverageregress{j} = fitlm(sin2psiinterpol,daverage{j},'Weight',1./derraverage{j});
%     end
%     % Get regress coefficients
%     % Intercept = regresscoeff(1,1)
%     % Slope = regresscoeff(2,1)
%     for j = 1:size(h.ParamsToFit,2)
%         regresscoeff{j} = table2array(daverageregress{j}.Coefficients);
%     end
%     % Calculate averaged taumean
%     taumeanavarege = sum(weighthkl.*sin2psi_tmp.taumean);
%     
%     % Calculate averaged sigma11 (d0 = d(psi=0°))
%     if length(PhiWinkel{1}) == 1
%         for j = 1:size(h.ParamsToFit,2)
%                 sigmaaverage{j} = regresscoeff{j}(2,1)/s2haverage/daverage{j}(1);
%                 sigmaerraverage{j} = regresscoeff{j}(2,2)/s2haverage/daverage{j}(1);
%         end
%     elseif length(PhiWinkel{1}) == 2
%         % For the case phi = 90°/180° it has to be considered, that sigma11 and
%         % sigma 22 are interchanged. This is important regarding saving the
%         % stress values to a file
%         if isequal([0;90],PhiWinkel{1}) || isequal([0;270],PhiWinkel{1}) || isequal([180;270],PhiWinkel{1})
%             for j = 1:size(h.ParamsToFit,2)
%                 sigmaaverage{j} = regresscoeff{j}(2,1)/s2haverage/daverage{j}(1);
%                 sigmaerraverage{j} = regresscoeff{j}(2,2)/s2haverage/daverage{j}(1);
%             end
%         elseif isequal([90,180],PhiWinkel{1})
%             sigmaaverage{1} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
%             sigmaerraverage{1} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1);
%             sigmaaverage{2} = regresscoeff{1}(2,1)/s2haverage/daverage{1}(1);
%             sigmaerraverage{2} = regresscoeff{1}(2,2)/s2haverage/daverage{1}(1);
%         elseif isequal([0;180],PhiWinkel{1}) || isequal([90;270],PhiWinkel{1})
%             sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,1)/s2haverage/daverage{2}(1))./2;
%             sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,2)/s2haverage/daverage{2}(1))./2;
%         end
%     elseif length(PhiWinkel{1}) == 3
%         if isequal([0;90;180],PhiWinkel{1})
%                 sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
%                 sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
%                 sigmaaverage{2} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
%                 sigmaerraverage{2} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1);
%         elseif isequal([0;180;270],PhiWinkel{1})
%                 sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,1)/s2haverage/daverage{2}(1))./2;
%                 sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{2}(2,2)/s2haverage/daverage{2}(1))./2;
%                 sigmaaverage{2} = regresscoeff{3}(2,1)/s2haverage/daverage{3}(1);
%                 sigmaerraverage{2} = regresscoeff{3}(2,2)/s2haverage/daverage{3}(1);
%         elseif isequal([0;90;270],PhiWinkel{1})
%                 sigmaaverage{1} = regresscoeff{1}(2,1)/s2haverage/daverage{1}(1);
%                 sigmaerraverage{1} = regresscoeff{1}(2,2)/s2haverage/daverage{1}(1); 
%                 sigmaaverage{2} = (regresscoeff{2}(2,1)/s2haverage/daverage{2}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
%                 sigmaerraverage{2} = (regresscoeff{2}(2,2)/s2haverage/daverage{2}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
%         elseif isequal([90;180;270],PhiWinkel{1})
%                 sigmaaverage{1} = regresscoeff{2}(2,1)/s2haverage/daverage{2}(1);
%                 sigmaerraverage{1} = regresscoeff{2}(2,2)/s2haverage/daverage{2}(1); 
%                 sigmaaverage{2} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
%                 sigmaerraverage{2} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;           
%         end
%     elseif length(PhiWinkel{1}) == 4
%         sigmaaverage{1} = (regresscoeff{1}(2,1)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,1)/s2haverage/daverage{3}(1))./2;
%         sigmaerraverage{1} = (regresscoeff{1}(2,2)/s2haverage/daverage{1}(1) + regresscoeff{3}(2,2)/s2haverage/daverage{3}(1))./2;
%         sigmaaverage{2} = (regresscoeff{2}(2,1)/s2haverage/daverage{2}(1) + regresscoeff{4}(2,1)/s2haverage/daverage{4}(1))./2;
%         sigmaerraverage{2} = (regresscoeff{2}(2,2)/s2haverage/daverage{2}(1) + regresscoeff{4}(2,2)/s2haverage/daverage{4}(1))./2;
%     end
%     % Calculate regression line
%     sin2psiregline = (0:0.1:1);
%     if length(PhiWinkel{1}) == 1
%         for j = 1:size(h.ParamsToFit,2)
%             regressline{j} = regresscoeff{j}(1,1) + regresscoeff{j}(2,1).*sin2psiregline;
%         end
%     elseif length(PhiWinkel{1}) == 2
%         if isequal([0;90],PhiWinkel{1}) || isequal([0;270],PhiWinkel{1}) || isequal([180;270],PhiWinkel{1})
%             for j = 1:size(h.ParamsToFit,2)
%                 regressline{j} = regresscoeff{j}(1,1) + regresscoeff{j}(2,1).*sin2psiregline;
%             end
%         elseif isequal([90,180],PhiWinkel{1})
%             regressline{1} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
%             regressline{2} = regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline;
%         elseif isequal([0;180],PhiWinkel{1}) || isequal([90;270],PhiWinkel{1})
%             regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
%         end
%     elseif length(PhiWinkel{1}) == 3
%         if isequal([0;90;180],PhiWinkel{1})
%             regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
%             regressline{2} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
%         elseif isequal([0;180;270],PhiWinkel{1})
%             regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
%             regressline{2} = regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline;
%         elseif isequal([0;90;270],PhiWinkel{1})
%             regressline{1} = regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline;
%             regressline{2} = (regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
%         elseif isequal([90;180;270],PhiWinkel{1})
%             regressline{1} = regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline;
%             regressline{2} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{3}(1,1) + regresscoeff{3}(2,1).*sin2psiregline)./2;
%         end
%     elseif length(PhiWinkel{1}) == 4
%         regressline{1} = (regresscoeff{1}(1,1) + regresscoeff{1}(2,1).*sin2psiregline + regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline)./2;
%         regressline{2} = (regresscoeff{2}(1,1) + regresscoeff{2}(2,1).*sin2psiregline + regresscoeff{4}(1,1) + regresscoeff{4}(2,1).*sin2psiregline)./2;
%     end
% 
%     % Plot Results
%     Marker = {'s','o','d','p'};
%     figure('Name','Averaged stress analysis','NumberTitle','off','Units','normalized','Position', [0.453 0.353 0.313 0.332]);
%     fig = gcf;
%     ax = gca;
%    
%     if ~isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         LegDatadspacing = dplotphi0;
%         LegLabelData = {'\phi = 0°'};
%     elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         LegDatadspacing = dplotphi90;
%         LegLabelData = {'\phi = 90°'};
%     elseif isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
%         dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi180 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         LegDatadspacing = dplotphi180;
%         LegLabelData = {'\phi = 180°'};
%     elseif isempty(h.idxphi0) && isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi270 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         LegDatadspacing = dplotphi270;
%         LegLabelData = {'\phi = 270°'};    
%     elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && isempty(h.idxphi270)
%         hold on
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         LegDatadspacing = [dplotphi0 dplotphi90];
%         LegLabelData = {'\phi = 0°','\phi = 90°'};
%     elseif ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
%         hold on
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         LegDatadspacing = [dplotphi0 dplotphi180];
%         LegLabelData = {'\phi = 0°','\phi = 180°'};
%     elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)
%         hold on
%         dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi180 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         LegDatadspacing = [dplotphi90 dplotphi180];
%         LegLabelData = {'\phi = 90°','\phi = 180°'};    
%     elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         LegDatadspacing = [dplotphi90 dplotphi270];
%         LegLabelData = {'\phi = 90°','\phi = 270°'};	
%     elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && isempty(h.idxphi270)	|| ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         hold on
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         dplotphi180 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
%         LegDatadspacing = [dplotphi0 dplotphi90 dplotphi180];
%         LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 180°'};	
%     elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && isempty(h.idxphi180) && ~isempty(h.idxphi270)%	|| ~isempty(h.idxphi0) && isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         hold on
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         dplotphi270 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
%         LegDatadspacing = [dplotphi0 dplotphi90 dplotphi270];
%         LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 270°'};
%     elseif isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         hold on
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi180 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         dplotphi270 = errorbar(ax,sin2psiregline,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
%         LegDatadspacing = [dplotphi90 dplotphi180 dplotphi270];
%         LegLabelData = {'\phi = 90°','\phi = 180°','\phi = 270°'};	
%     elseif ~isempty(h.idxphi0) && ~isempty(h.idxphi90) && ~isempty(h.idxphi180) && ~isempty(h.idxphi270)
%         hold on
%         dplotphi0 = errorbar(ax,sin2psiinterpol,daverage{1},derraverage{1},'Linestyle','none','Color','k','Marker',Marker{1},'MarkerFaceColor',h.Colors{1},'MarkerEdgeColor','k','MarkerSize',12);
%         dplotphi90 = errorbar(ax,sin2psiinterpol,daverage{2},derraverage{2},'Linestyle','none','Color','k','Marker',Marker{2},'MarkerFaceColor',h.Colors{2},'MarkerEdgeColor','k','MarkerSize',12);
%         dplotphi180 = errorbar(ax,sin2psiinterpol,daverage{3},derraverage{3},'Linestyle','none','Color','k','Marker',Marker{3},'MarkerFaceColor',h.Colors{3},'MarkerEdgeColor','k','MarkerSize',12);
%         dplotphi270 = errorbar(ax,sin2psiinterpol,daverage{4},derraverage{4},'Linestyle','none','Color','k','Marker',Marker{4},'MarkerFaceColor',h.Colors{4},'MarkerEdgeColor','k','MarkerSize',12);
%         reglineplotphi0 = line(ax,sin2psiregline,regressline{1},'Color',h.Colors{1},'LineWidth',2);
%         reglineplotphi90 = line(ax,sin2psiregline,regressline{2},'Color',h.Colors{2},'LineWidth',2);
%         hold off
%         LegDatadspacing = [dplotphi0 dplotphi90 dplotphi180 dplotphi270];
%         LegLabelData = {'\phi = 0°','\phi = 90°','\phi = 180°','\phi = 270°'};
%     end
% 
%     l = legend(ax,LegDatadspacing,LegLabelData);
% 
% %     l.Location = 'northeast';
%     l.FontSize = 10;
%     l.LineWidth = 0.5;
% 
%     % Add calculated stress data to the plot
%     if length(PhiWinkel{1}) == 1 && isequal(0,PhiWinkel{1}) || length(PhiWinkel{1}) == 1 && isequal(180,PhiWinkel{1}) || length(PhiWinkel{1}) == 2 && isequal([0;180],PhiWinkel{1})
%         dim = [.175 .13 .2 .2];
%         annotation('textbox',dim,'String',['<\sigma_{11}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');
%     elseif length(PhiWinkel{1}) == 1 && isequal(90,PhiWinkel{1}) || length(PhiWinkel{1}) == 1 && isequal(270,PhiWinkel{1}) || length(PhiWinkel{1}) == 2 && isequal([90;270],PhiWinkel{1})
%         dim = [.175 .13 .2 .2];
%         annotation('textbox',dim,'String',['<\sigma_{22}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');    
%     elseif length(PhiWinkel{1}) == 4
%         dim = [.175 .16 .2 .2];
%         annotation('textbox',dim,'String',{['<\sigma_{11}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{1})),' ',char(177),' ',num2str(round(sigmaerraverage{1})),' MPa'],['<\sigma_{22}-\sigma_{33}> ','= ',num2str(round(sigmaaverage{2})),' ',char(177),' ',num2str(round(sigmaerraverage{2})),' MPa']},'LineStyle','-','FontSize',16,'BackgroundColor','w','FitBoxToText','on');
%     end
% 
%     fig.PaperUnits = 'centimeters';
%     fig.PaperPositionMode = 'manual';
%     fig.PaperPosition = [0 0 18 12];
%     
%     ax.OuterPosition = [0 0 1.085 1.025];
%     ax.TickDir = 'out';
%     ax.YAxis.TickLabelFormat = '%,.4f';
%     ax.Box = 'on';
%     ax.XGrid = 'on';
%     ax.YGrid = 'on';
%     ax.GridLineStyle = '-';
%     ax.GridColor = 'k';
%     ax.GridAlpha = 0.3;
%     ax.YLabel.String = 'a(100) [nm]';
%     ax.YLabel.FontSize = 24;
%     ax.XLabel.String = 'sin²\psi';
%     ax.XLabel.FontSize = 24;
%     ax.LabelFontSizeMultiplier = 1.3;
%     ax.LineWidth = 1.3;
%     set(gca,'FontSize',14)
%     ax.XLim = [0 1];
%     ax.YLim = [floor(min(cellfun(@min,daverage))*15000)/15000,ceil(max(cellfun(@max,daverage))*15000)/15000];
% %     ax.YLim = [floor((min(cellfun(@min,daverage))-0.0002)./0.0001).*0.0001 ceil((max(cellfun(@max,daverage))+0.0002)/0.0001).*0.0001];
%     ax.YTick = linspace(ax.YLim(1),ax.YLim(2),11);
%     ax.XTick = 0:0.1:1;
%     
%     % Save figure
%     Folder = '\Plots\';
%     h.diffmode = 'LIMAX-160';
%     if ~isfield(h,'PathName')
%         formatOut = 'ddmmyyyy';
%         d = datestr(now, formatOut);
%         name = strtrim(h.Measurement(1).MeasurementSeries);
%         material = h.P.PopupValueMpd1;
%         
%         if strcmp(h.diffmode,'LIMAX-160')
%             h.PathName = [General.ProgramInfo.Path,'\Data\Results\MetalJet\',[name,'_',material,'_','added_plots','_',d]];
%         elseif strcmp(h.diffmode,'LEDDI')
%             h.PathName = [General.ProgramInfo.Path,'\Data\Results\LEDDI\',[name,'_',material,'_','added_plots','_',d]];
%         end
%     end
% 
%     Path = fullfile(h.PathName,Folder);
% 
%     if exist(Path,'dir') ~= 7
%         mkdir(Path);
%     end
%     
%     set(get(gca,'title'),'Units', 'Normalized', 'Position',[0.5 1.05]);
%     FileName = sprintf([strrep(h.Measurement(1).MeasurementSeries,' ',''),'_',h.Sample.Materials.Name,'_dspacing_averaged']);
%     print(fig,[Path,FileName],'-painters','-dtiff','-r300')
elseif strcmp(h.Measurement(1).Sample.Materials.CrystalStructure,'fcc') || strcmp(h.Measurement(1).Sample.Materials.CrystalStructure,'bcc') && size(h.ParamsToFit(1).LatticeSpacing,2) == 1
    sin2psiinterpol = [ ]; 
    daverage = [ ]; 
    derraverage = [ ]; 
    regressline = [ ]; 
    sigmaaverage = [ ]; 
    sigmaerraverage = [ ]; 
    warndlg('Only one peak analyzed! Averaging not possible.','Warning');
else
    sin2psiinterpol = [ ]; 
    daverage = [ ]; 
    derraverage = [ ]; 
    regressline = [ ]; 
    sigmaaverage = [ ]; 
    sigmaerraverage = [ ]; 
    warndlg('Crystal structure not cubic! Averaging not possible.','Warning');
end
