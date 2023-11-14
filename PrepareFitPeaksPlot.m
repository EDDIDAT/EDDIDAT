function [FittedPeaksCalc,FittedPeaksCalctmp,xDataTmpCalc,XFit,YFit,XPlot,YPlot] = PrepareFitPeaksPlot(DataTmpCalc,FittedPeaksCalc,PeaksCalc,PeakRegionsXCalc,SE,PopupValueFitFunc,valueSlider,Diffractometer,lambdaka1,lambdaka2)

XFit = DataTmpCalc{valueSlider}(:, 1);
YFit = DataTmpCalc{valueSlider}(:, 2);  
% Fit-Data
XPlot = XFit(1):0.001:XFit(end);
YPlot = zeros(size(XPlot));
% Calculate fitted profile using Fitted PeakData
for d = 1:size(FittedPeaksCalc{valueSlider}, 1)
    if PopupValueFitFunc == 2 %PV-Func
        if strcmp(Diffractometer,'ETA3000')
            funka1ka2 = @(p,x)(Tools.Science.Math.FF_PseudoVoigt(...
            x,p(1),p(2),p(3),p(4)) + Tools.Science.Math.FF_PseudoVoigt(...
            x,p(1)/2,(2.*asind(lambdaka2./(2.*lambdaka1./sind(p(2)/2)./2))),p(3),p(4)));

            SinglePlot = funka1ka2([FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3),FittedPeaksCalc{valueSlider}(d, 4)],XPlot); %,FittedPeaksCalc{valueSlider}(d, 5));

            funka1 = @(p,x)(Tools.Science.Math.FF_PseudoVoigt(x,p(1),p(2),p(3),p(4)));
            Plotka1 = funka1([FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3),FittedPeaksCalc{valueSlider}(d, 4)],XPlot);

            funka2 = @(p,c,x)(Tools.Science.Math.FF_PseudoVoigt(x,p(1)/2,2.*asind(lambdaka2./(2.*lambdaka1./sind(p(2)/2)./2)),p(3),p(4)));
            Plotka2 = funka2([FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3),FittedPeaksCalc{valueSlider}(d, 4)],[lambdaka1,lambdaka2],XPlot);
        else
            SinglePlot = Tools.Science.Math.FF_PseudoVoigt(XPlot, ...
                FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3),FittedPeaksCalc{valueSlider}(d, 4));
        end
    elseif PopupValueFitFunc == 3 %TCH
        SinglePlot = Tools.Science.Math.FF_TCH(XPlot, ...
            FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3),FittedPeaksCalc{valueSlider}(d, 4));
    elseif PopupValueFitFunc == 4 %Gauss
        SinglePlot = Tools.Science.Math.FF_Gauss(XPlot, ...
            FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3));    
    elseif PopupValueFitFunc == 5 %Lorentz
        SinglePlot = Tools.Science.Math.FF_Lorentz(XPlot, ...
            FittedPeaksCalc{valueSlider}(d, 1), FittedPeaksCalc{valueSlider}(d, 2), FittedPeaksCalc{valueSlider}(d, 3));  
    end

    if strcmp(Diffractometer,'ETA3000')
        YPlot_tmp = YPlot + SinglePlot;
        YPlot = [YPlot_tmp' Plotka1' Plotka2'];
        assignin('base','YPlot',YPlot)
    else
        YPlot = YPlot + SinglePlot;
    end
end

% Set fit results as data in table
if PopupValueFitFunc == 2 %PV-Func
    for c = 1:size(FittedPeaksCalc,2)
        IntegralBreadthtmp{1,c} = sqrt(2.*pi) .* FittedPeaksCalc{1,c}(:,4) .* ...
            FittedPeaksCalc{1,c}(:,3) + pi .* (1 - FittedPeaksCalc{1,c}(:,4)) .* ...
            FittedPeaksCalc{1,c}(:,3) ./ 2;
    end

    for c = 1:size(FittedPeaksCalc,2)
        FWHMtmp{1,c} = 2 .* sqrt(2 .* log(2)) .* FittedPeaksCalc{1,c}(:,4) .* ...
        FittedPeaksCalc{1,c}(:,3) + (1 - FittedPeaksCalc{1,c}(:,4)) .* FittedPeaksCalc{1,c}(:,3);
    end
elseif PopupValueFitFunc == 3 %TCH-Func
    for c = 1:size(FittedPeaksCalc,2)
        FWHMtmp{1,c} = (FittedPeaksCalc{1,c}(:,3).^5 + 2.69269.*FittedPeaksCalc{1,c}(:,3).^4.*FittedPeaksCalc{1,c}(:,4) + 2.42843.*FittedPeaksCalc{1,c}(:,3).^3.*FittedPeaksCalc{1,c}(:,4).^2 + ...
        4.47163.*FittedPeaksCalc{1,c}(:,3).^2.*FittedPeaksCalc{1,c}(:,4).^3 + 0.07842.*FittedPeaksCalc{1,c}(:,3).*FittedPeaksCalc{1,c}(:,4).^4 + FittedPeaksCalc{1,c}(:,4).^5).^0.2;
    end   
    
    for c = 1:size(FittedPeaksCalc,2)
        ETAtmp{1,c} = 1.36603.*(FittedPeaksCalc{1,c}(:,4)./FWHMtmp{1,c}) - 0.47719.*(FittedPeaksCalc{1,c}(:,4)./FWHMtmp{1,c}).^2 + 0.1116.*(FittedPeaksCalc{1,c}(:,4)./FWHMtmp{1,c}).^3;
    end
    
    for c = 1:size(FittedPeaksCalc,2)
        IntegralBreadthtmp{1,c} = (FWHMtmp{1,c}./2) .* ((ETAtmp{1,c}./pi) + (1 - ETAtmp{1,c}) .* (log(2)./pi).^(1/2)).^(-1);
    end
elseif PopupValueFitFunc == 4 %Gauss
    for c = 1:size(FittedPeaksCalc,2)
        IntegralBreadthtmp{1,c} = sqrt(2.*pi) .* FittedPeaksCalc{1,c}(:,3);
    end

    for c = 1:size(FittedPeaksCalc,2)
        FWHMtmp{1,c} = 2 .* sqrt(2 .* log(2)) .* FittedPeaksCalc{1,c}(:,3);
    end
elseif PopupValueFitFunc == 5 %Lorentz
    for c = 1:size(FittedPeaksCalc,2)
        IntegralBreadthtmp{1,c} = pi .* FittedPeaksCalc{1,c}(:,3) ./ 2;
    end

    for c = 1:size(FittedPeaksCalc,2)
        FWHMtmp{1,c} = FittedPeaksCalc{1,c}(:,3);
    end    
end


% Add IB and FWHM to FittedPeaksCalc
if PopupValueFitFunc == 2 %PV-Func
    for c = 1:size(FittedPeaksCalc,2)
%         if strcmp(Diffractometer,'ETA3000')
%             FittedPeaksCalc{1,c}(:,6) = IntegralBreadthtmp{1,c}(:,1);
%             FittedPeaksCalc{1,c}(:,7) = FWHMtmp{1,c}(:,1);
%         else
            FittedPeaksCalc{1,c}(:,5) = IntegralBreadthtmp{1,c}(:,1);
            FittedPeaksCalc{1,c}(:,6) = FWHMtmp{1,c}(:,1);
%         end
    end
elseif PopupValueFitFunc == 3 %TCH-Func
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,5) = IntegralBreadthtmp{1,c}(:,1);
        FittedPeaksCalc{1,c}(:,6) = FWHMtmp{1,c}(:,1);
        FittedPeaksCalc{1,c}(:,7) = ETAtmp{1,c}(:,1);
    end
elseif PopupValueFitFunc == 4 %Gauss
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,4) = IntegralBreadthtmp{1,c}(:,1);
        FittedPeaksCalc{1,c}(:,5) = FWHMtmp{1,c}(:,1);
    end   
elseif PopupValueFitFunc == 5 %Lorentz
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,4) = IntegralBreadthtmp{1,c}(:,1);
        FittedPeaksCalc{1,c}(:,5) = FWHMtmp{1,c}(:,1);
    end    
end

% Function to calucate fitted peaks
if PopupValueFitFunc == 2 %PV-Func
    if strcmp(Diffractometer,'ETA3000')
        fun = funka1ka2;
    else
        fun = @(p,x)Tools.Science.Math.FF_PseudoVoigt(x,p(1),p(2),p(3),p(4));
    end
elseif PopupValueFitFunc == 3 %TCH-Func
    fun = @(p,x)Tools.Science.Math.FF_TCH(x,p(1),p(2),p(3),p(4));
elseif PopupValueFitFunc == 4 %Gauss
    fun = @(p,x)Tools.Science.Math.FF_Gauss(x,p(1),p(2),p(3));
elseif PopupValueFitFunc == 5 %Lorentz
    fun = @(p,x)Tools.Science.Math.FF_Lorentz(x,p(1),p(2),p(3));    
end

% Find how many peaks are in the designated PeakRegion
PeakRegionstmp = [Tools.Data.DataSetOperations.FindNearestIndex(DataTmpCalc{1}(:,1),PeakRegionsXCalc{valueSlider}(1,:)); ...
Tools.Data.DataSetOperations.FindNearestIndex(DataTmpCalc{1}(:,1),PeakRegionsXCalc{valueSlider}(2,:))];
PeakRegionstmp = Tools.LogicalRegions(PeakRegionstmp,length(DataTmpCalc{1}(:,1)));
Index_Peaks = Tools.Data.DataSetOperations.FindNearestIndex(DataTmpCalc{1}(:,1),PeaksCalc{valueSlider});
% Get indices of peaks in PeakRegion
for i_c = 1:size(PeakRegionstmp.Limits,2)
    a = PeakRegionstmp.Limits(1,i_c);
    b = PeakRegionstmp.Limits(2,i_c);
    Index_PeaksInRegion{:,i_c} = (intersect(a:b, Index_Peaks) - a + 1)';
end
% If there is more than one peak in the PeakRegion, xdata has to be doubled
idxDoublePeaktmp = find(cellfun('prodofsize',Index_PeaksInRegion)>1);

if ~isempty(idxDoublePeaktmp)

    % Calculate xdata used to simulate/calculate the fitted peaks
    for ii = 1:size(PeakRegionsXCalc{valueSlider},2)
        for ll = 1:length(Index_PeaksInRegion{ii})
            xDataTmpCalctmp{ii,1}(ll,:) = linspace(PeakRegionsXCalc{valueSlider}(1,ii),PeakRegionsXCalc{valueSlider}(2,ii));
        end
    end

    xDataTmpCalc = cell2mat(xDataTmpCalctmp);
else
    % Calculate xdata used to simulate/calculate the fitted peaks
    for ii = 1:size(PeakRegionsXCalc{valueSlider},2)
            xDataTmpCalc(ii,:) = linspace(PeakRegionsXCalc{valueSlider}(1,ii),PeakRegionsXCalc{valueSlider}(2,ii));
    end
end
% Calculate integrated intensities
if PopupValueFitFunc == 2 %PV-Func
    % Calculate integrated intensities
    for c = 1:size(FittedPeaksCalc,2)
        for ii = 1:length(PeaksCalc{c})
            IntegratedInt{1,c}(:,ii) = trapz(xDataTmpCalc(ii,:),fun(FittedPeaksCalc{1,c}(ii,:),xDataTmpCalc(ii,:)));
        end
    end
    % Add integrated intensities to FittedPeaksCalc
    for c = 1:size(FittedPeaksCalc,2)
%         if strcmp(Diffractometer,'ETA3000')
%             FittedPeaksCalc{1,c}(:,8) = IntegratedInt{1,c}(1,:);
%         else
            FittedPeaksCalc{1,c}(:,7) = IntegratedInt{1,c}(1,:);
%         end
    end
elseif PopupValueFitFunc == 3 %TCH-Func
    % Calculate max intensity
    for c = 1:size(FittedPeaksCalc,2)
        for ii = 1:length(PeaksCalc{c})
            IntMax{1,c}(:,ii) = fun(FittedPeaksCalc{1,c}(ii,:),FittedPeaksCalc{1,c}(ii,2));
        end
    end
    % Add integrated intensities to FittedPeaksCalc
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,8) = IntMax{1,c}(1,:);
    end
elseif PopupValueFitFunc == 4 %Gauss
    % Calculate integrated intensities
    for c = 1:size(FittedPeaksCalc,2)
        for ii = 1:length(PeaksCalc{c})
            IntegratedInt{1,c}(:,ii) = trapz(xDataTmpCalc(ii,:),fun(FittedPeaksCalc{1,c}(ii,:),xDataTmpCalc(ii,:)));
        end
    end
    % Add integrated intensities to FittedPeaksCalc
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,6) = IntegratedInt{1,c}(1,:);
    end
elseif PopupValueFitFunc == 5 %Lorentz
    % Calculate integrated intensities
    for c = 1:size(FittedPeaksCalc,2)
        for ii = 1:length(PeaksCalc{c})
            if strcmp(Diffractometer,'ETA3000')
                IntegratedInt{1,c}(:,ii) = trapz(xDataTmpCalc(ii,:),funka1ka2(FittedPeaksCalc{1,c}(ii,:),xDataTmpCalc(ii,:)));
            else
                IntegratedInt{1,c}(:,ii) = trapz(xDataTmpCalc(ii,:),fun(FittedPeaksCalc{1,c}(ii,:),xDataTmpCalc(ii,:)));
            end
        end
    end
    % Add integrated intensities to FittedPeaksCalc
    for c = 1:size(FittedPeaksCalc,2)
        FittedPeaksCalc{1,c}(:,6) = IntegratedInt{1,c}(1,:);
    end     
end

% % Save variables to handle and workspace
% h.FittedPeaksCalc = FittedPeaksCalc;
for k = 1:size(FittedPeaksCalc,2)
    if PopupValueFitFunc == 2 %PV-Func
        if strcmp(Diffractometer,'ETA3000')
            FittedPeaksCalctmp{1,k}(:,1) = cellstr(num2str(FittedPeaksCalc{1,k}(:,1),'%.0f')); % IntMax.
            FittedPeaksCalctmp{1,k}(:,2) = cellstr(num2str(FittedPeaksCalc{1,k}(:,2),'%.4f')); % 2Theta-ka1
            FittedPeaksCalctmp{1,k}(:,3) = cellstr(num2str(SE{1,k}(:,2),'%.4f')); % delta2Theta
            FittedPeaksCalctmp{1,k}(:,4) = cellstr(num2str(FittedPeaksCalc{1,k}(:,4),'%.4f')); % ETA-PV
            FittedPeaksCalctmp{1,k}(:,5) = cellstr(num2str(FittedPeaksCalc{1,k}(:,5),'%.4f')); % FWHM
            FittedPeaksCalctmp{1,k}(:,6) = cellstr(num2str(FittedPeaksCalc{1,k}(:,6),'%.4f')); % IB
            FittedPeaksCalctmp{1,k}(:,7) = cellstr(num2str(FittedPeaksCalc{1,k}(:,7),'%.0f')); % Int.Int
        else
            FittedPeaksCalctmp{1,k}(:,1) = cellstr(num2str(FittedPeaksCalc{1,k}(:,1),'%.0f')); % IntMax.
            FittedPeaksCalctmp{1,k}(:,2) = cellstr(num2str(FittedPeaksCalc{1,k}(:,2),'%.4f')); % EMax
            FittedPeaksCalctmp{1,k}(:,3) = cellstr(num2str(SE{1,k}(:,2),'%.4f')); % deltaEMax
            FittedPeaksCalctmp{1,k}(:,4) = cellstr(num2str(FittedPeaksCalc{1,k}(:,4),'%.4f')); % ETA
            FittedPeaksCalctmp{1,k}(:,5) = cellstr(num2str(FittedPeaksCalc{1,k}(:,5),'%.4f')); % IB
            FittedPeaksCalctmp{1,k}(:,6) = cellstr(num2str(FittedPeaksCalc{1,k}(:,6),'%.4f')); % FWHM
            FittedPeaksCalctmp{1,k}(:,7) = cellstr(num2str(FittedPeaksCalc{1,k}(:,7),'%.0f')); % Int.Int
        end
    elseif PopupValueFitFunc == 3 %TCH-Func
        FittedPeaksCalctmp{1,k}(:,1) = cellstr(num2str(FittedPeaksCalc{1,k}(:,1),'%.0f')); % Int.Int
        FittedPeaksCalctmp{1,k}(:,2) = cellstr(num2str(FittedPeaksCalc{1,k}(:,2),'%.4f')); % EMax
        FittedPeaksCalctmp{1,k}(:,3) = cellstr(num2str(SE{1,k}(:,2),'%.4f')); % deltaEMax
        FittedPeaksCalctmp{1,k}(:,4) = cellstr(num2str(FittedPeaksCalc{1,k}(:,3),'%.4f')); % FWHM_Gauss
        FittedPeaksCalctmp{1,k}(:,5) = cellstr(num2str(FittedPeaksCalc{1,k}(:,4),'%.2e')); % FWHM_Lorentz
        FittedPeaksCalctmp{1,k}(:,6) = cellstr(num2str(FittedPeaksCalc{1,k}(:,5),'%.4f')); % IB
        FittedPeaksCalctmp{1,k}(:,7) = cellstr(num2str(FittedPeaksCalc{1,k}(:,6),'%.4f')); % FWHM
        FittedPeaksCalctmp{1,k}(:,8) = cellstr(num2str(FittedPeaksCalc{1,k}(:,7),'%.2e')); % ETA
        FittedPeaksCalctmp{1,k}(:,9) = cellstr(num2str(FittedPeaksCalc{1,k}(:,8),'%.0f')); % IntMax.
    elseif PopupValueFitFunc == 4 %Gauss
        FittedPeaksCalctmp{1,k}(:,1) = cellstr(num2str(FittedPeaksCalc{1,k}(:,1),'%.0f')); % IntMax.
        FittedPeaksCalctmp{1,k}(:,2) = cellstr(num2str(FittedPeaksCalc{1,k}(:,2),'%.4f')); % EMax
        FittedPeaksCalctmp{1,k}(:,3) = cellstr(num2str(SE{1,k}(:,2),'%.4f')); % deltaEMax
        FittedPeaksCalctmp{1,k}(:,4) = cellstr(num2str(FittedPeaksCalc{1,k}(:,4),'%.4f')); % IB
        FittedPeaksCalctmp{1,k}(:,5) = cellstr(num2str(FittedPeaksCalc{1,k}(:,5),'%.4f')); % FWHM
        FittedPeaksCalctmp{1,k}(:,6) = cellstr(num2str(FittedPeaksCalc{1,k}(:,6),'%.0f')); % Int.Int
    elseif PopupValueFitFunc == 5 %Lorentz
        FittedPeaksCalctmp{1,k}(:,1) = cellstr(num2str(FittedPeaksCalc{1,k}(:,1),'%.0f')); % IntMax.
        FittedPeaksCalctmp{1,k}(:,2) = cellstr(num2str(FittedPeaksCalc{1,k}(:,2),'%.4f')); % EMax
        FittedPeaksCalctmp{1,k}(:,3) = cellstr(num2str(SE{1,k}(:,2),'%.4f')); % deltaEMax
        FittedPeaksCalctmp{1,k}(:,4) = cellstr(num2str(FittedPeaksCalc{1,k}(:,4),'%.4f')); % IB
        FittedPeaksCalctmp{1,k}(:,5) = cellstr(num2str(FittedPeaksCalc{1,k}(:,5),'%.4f')); % FWHM
        FittedPeaksCalctmp{1,k}(:,6) = cellstr(num2str(FittedPeaksCalc{1,k}(:,6),'%.0f')); % Int.Int
    end
end

end

