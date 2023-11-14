function flag = legendclash(ax,XData,YData,LegendPos)

for k = 1:size(LegendPos,2)
    % get axis position vector
    AxPosn = ax.Position;
    Axbot = AxPosn(2);
    % compute bounding box
    Axtop = Axbot+AxPosn(4);
    Axlft = AxPosn(1);
    Axrgt = Axlft+AxPosn(3);
    % and same for the legend
    LgPosn = LegendPos(k,:);        
    LGbot = LgPosn(2);
    LGtop = LGbot+LgPosn(4);
    LGlft = LgPosn(1);
    LGrgt = LGlft+LgPosn(3);
    % compute scaled plotted values in the axis bounding box
    yscaled = interp1(ax.YLim,[Axbot Axtop],YData);
    xscaled = interp1(ax.XLim,[Axlft Axrgt],XData);
    % Check if data intersects inside the legend bounding box
    % If flag = 1, data intersects with the legend bounding box
    flag(:,k) = any(iswithin(yscaled(:),LGbot,LGtop) & iswithin(xscaled(:),LGlft,LGrgt));
end

end

