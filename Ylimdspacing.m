function [YLim,YTick] = Ylimdspacing(h,l)
%Function used to calculate Ylim and YTick for plot of d-spacing

% Get phi angles
for k = 1:size(h.Params.Phi_Winkel,2)
	[PhiWinkel{k},ia{k},~] = unique(h.Params.Phi_Winkel{k});
end

for m = 1:length(ia{1})
    dmin(:,m) = min(h.ParamsToFit(m).LatticeSpacing{l} - h.ParamsToFit(m).LatticeSpacing_Delta{l});
    dmax(:,m) = max(h.ParamsToFit(m).LatticeSpacing{l} + h.ParamsToFit(m).LatticeSpacing_Delta{l});
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
            YTick = 10*YLimLow:0.002:10*YLimHigh;
        elseif abs(YLimLow-min(dmin)) < abs(YLimHigh-max(dmax))
            YLimLow = YLimLow - 0.0001;
            if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
                YLimLow = YLimLow - 0.0001;
            end
            YTick = 10*YLimLow:0.002:10*YLimHigh;
        end
    else
        YTick = 10*YLimLow:0.002:10*YLimHigh;
    end
elseif Ylimdiff < 8e-4 && Ylimdiff > 4e-4
    if mod(round((YLimHigh - YLimLow)*10000),2e-4*10000) >= 1
        if abs(YLimLow-min(dmin)) > abs(YLimHigh-max(dmax))
            YLimHigh = YLimHigh + 0.0001;
            YTick = 10*YLimLow:0.001:10*YLimHigh;
        elseif abs(YLimLow-min(dmin)) < abs(YLimHigh-max(dmax))
            YLimLow = YLimLow - 0.0001;
            YTick = 10*YLimLow:0.001:10*YLimHigh;
        end
    else
        YTick = 10*YLimLow:0.001:10*YLimHigh;
    end
elseif Ylimdiff <= 4e-4
    YTick = 10*YLimLow:0.001:10*YLimHigh;  
end
YLim = [10*YLimLow, 10*YLimHigh]; 
end