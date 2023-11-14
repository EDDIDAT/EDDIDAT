function [x,y] = getptszoom(varargin)
%GETPTS Select points with mouse.
%   [X,Y] = GETPTS(FIG) lets you choose a set of points in the
%   current axes of figure FIG using the mouse. Coordinates of
%   the selected points are returned in the vectors X and Y. Use
%   normal button clicks to add points.  A shift-, right-, or 
%   double-click adds a final point and ends the selection.  
%   Pressing RETURN or ENTER ends the selection without adding 
%   a final point.  Pressing BACKSPACE or DELETE removes the 
%   previously selected point.
%
%   [X,Y] = GETPTS(AX) lets you choose points in the axes
%   specified by the handle AX.
%
%   [X,Y] = GETPTS is the same as [X,Y] = GETPTS(GCF).
%
%   Example
%   --------
%       imshow('moon.tif')
%       [x,y] = getpts 
%
%   See also GETRECT, GETLINE.

%   Callback syntaxes:
%       getpts('KeyPress')
%       getpts('FirstButtonDown')
%       getpts('NextButtonDown')

%   Copyright 1993-2011 The MathWorks, Inc.

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2 GETPTSZOOM_AX GETPlotDataZOOM GETintMaxZOOM GETintMeanZOOM GETPlotData XLimRange ZoomLevel p

if ((nargin >= 1) && (ischar(varargin{1})))
    % Callback invocation: 'KeyPress', 'FirstButtonDown', or 
    % 'NextButtonDown'.
    feval(varargin{:});
    return;
end

if (nargin < 1)
    GETPTS_AX = gca;
    GETPTS_FIG = ancestor(GETPTS_AX, 'figure');
else
    if (~ishghandle(varargin{1}))
        error(message('images:getpts:expectedHandle'));
    end
    
    switch get(varargin{1}, 'Type')
    case 'figure'
        GETPTS_FIG = varargin{1};
        GETPTS_AX = get(GETPTS_FIG, 'CurrentAxes');
        if (isempty(GETPTS_AX))
            GETPTS_AX = axes('Parent', GETPTS_FIG);
        end

    case 'axes'
        GETPTS_AX = varargin{1};
        GETPTSZOOM_AX = varargin{2};
        GETPlotDataZOOM = varargin{3};
        GETintMaxZOOM = varargin{4};
        GETintMeanZOOM = varargin{5};
        GETPlotData = varargin{6};
        XLimRange = 2;
        ZoomLevel = 1;
        GETPTS_FIG = ancestor(GETPTS_AX, 'figure');
        % Calculate function to account for intensity drop at higher
        % energies. Asymptotic function of type "a-b*c^x" is used.
        f = @(para,x) para(1)-para(2).*para(3).^x;
        if ((GETintMeanZOOM*100)/GETintMaxZOOM) < 2
            % If GetintMeanZoom is smaller than 2% of GetintMaxZoom
            xdatafit = [GETPTS_AX.XLim(1),GETPTS_AX.XLim(2)/2,GETPTS_AX.XLim(2)-10,GETPTS_AX.XLim(2)];
            ydatafit = [GETintMaxZOOM,2*GETintMeanZOOM,1.5*GETintMeanZOOM,GETintMeanZOOM];
        else
            xdatafit = [GETPTS_AX.XLim(1),GETPTS_AX.XLim(2)/2,GETPTS_AX.XLim(2)-10,GETPTS_AX.XLim(2)];
            ydatafit = [GETintMaxZOOM,4*GETintMeanZOOM,2*GETintMeanZOOM,GETintMeanZOOM];
        end
        % Parameters p obtained using lsqcurvefit
        opts = optimset('Display','off');
        [p, ~] = lsqcurvefit(f,[GETintMeanZOOM,-2000000,0.8],xdatafit,ydatafit,[],[],opts);

    otherwise
        error(message('images:getpts:expectedFigureOrAxesHandle'));

    end
end

% Bring target figure forward
GETPTS_FIG.Visible = 'on'; % make sure Live Editor figures are shown
figure(GETPTS_FIG);

% Remember initial figure state
state = uisuspend(GETPTS_FIG);

% Set up initial callbacks for initial stage
[pointerShape, pointerHotSpot] = CreatePointer;
set(GETPTS_FIG, 'WindowButtonDownFcn', 'getptszoom(''FirstButtonDown'');', ...
        'WindowButtonMotionFcn', 'getptszoom(''MouseMove'');' , ...
        'windowscrollWheelFcn', @MouseScroll , ...
        'KeyPressFcn', 'getptszoom(''KeyPress'');', ...
        'Pointer', 'custom', ...
        'PointerShapeCData', pointerShape, ...
        'PointerShapeHotSpot', pointerHotSpot);

% Initialize the lines to be used for the drag
markerSize = 9;
GETPTS_H1 = line('Parent', GETPTS_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'c', ...
                  'LineStyle', 'none', ...
                  'Marker', '+', ...
                  'MarkerSize', markerSize);

GETPTS_H2 = line('Parent', GETPTS_AX, ...
                  'XData', [], ...
                  'YData', [], ...
                  'Visible', 'off', ...
                  'Clipping', 'off', ...
                  'Color', 'm', ...
                  'LineStyle', 'none', ...
                  'Marker', 'x', ...
                  'MarkerSize', markerSize);

                           
% We're ready; wait for the user to do the drag
% Wrap the call to waitfor in try-catch so we'll
% have a chance to clean up after ourselves.
errCatch = 0;
try  
   waitfor(GETPTS_H1, 'UserData', 'Completed');
catch
   errCatch=1;
end

% After the waitfor, if GETPTS_H1 is still valid
% and its UserData is 'Completed', then the user
% completed the drag.  If not, the user interrupted
% the action somehow, perhaps by a Ctrl-C in the
% command window or by closing the figure.

if (errCatch == 1)
    errStatus = 'trap';
    
elseif (~ishghandle(GETPTS_H1) || ...
            ~strcmp(get(GETPTS_H1, 'UserData'), 'Completed'))
    errStatus = 'unknown';
    
else
    errStatus = 'ok';
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H1, 'YData');
    x = x(:);
    y = y(:);
    % If no points were selected, return rectangular empties.
    % This makes it easier to handle degenerate cases in
    % functions that call getpts.
    if (isempty(x))
        x = zeros(0,1);
    end
    if (isempty(y))
        y = zeros(0,1);
    end
end

% Delete the animation objects
if (ishghandle(GETPTS_H1))
    delete(GETPTS_H1);
end
if (ishghandle(GETPTS_H2))
    delete(GETPTS_H2);
end

% Restore the figure state
if (ishghandle(GETPTS_FIG))
    uirestore(state);
end

% Clean up the global workspace
clear global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2
clear global GETPTS_PT1 

% Depending on the error status, return the answer or generate
% an error message.
switch errStatus
case 'ok'
    % No action needed.
    
case 'trap'
    % An error was trapped during the waitfor
    error(message('images:getpts:interruptedMouseSelection'));
    
case 'unknown'
    % User did something to cause the point selection to
    % terminate abnormally.  For example, we would get here
    % if the user closed the figure in the middle of the selection.
    error(message('images:getpts:interruptedMouseSelection'));
end


%--------------------------------------------------
% Subfunction KeyPress
%--------------------------------------------------
function KeyPress %#ok

global GETPTS_FIG GETPTS_H1 GETPTS_H2

key = get(GETPTS_FIG, 'CurrentCharacter');

switch key
case {char(8), char(127)}  % delete and backspace keys
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H1, 'YData');
    switch length(x)
    case 0
        % nothing to do
    case 1
        % remove point and start over
        set([GETPTS_H1 GETPTS_H2], ...
                'XData', [], ...
                'YData', []);
        set(GETPTS_FIG, 'WindowButtonDownFcn', ...
                'getptszoom(''FirstButtonDown'');');
    otherwise
        % remove last point
        set([GETPTS_H1 GETPTS_H2], ...
                'XData', x(1:end-1), ...
                'YData', y(1:end-1));
    end

case {char(13), char(3)}   % enter and return keys
    % return control to line after waitfor
    set(GETPTS_H1, 'UserData', 'Completed');

end

%--------------------------------------------------
% Subfunction FirstButtonDown
%--------------------------------------------------
function FirstButtonDown %#ok

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2

[x,y] = getcurpt(GETPTS_AX);

set([GETPTS_H1 GETPTS_H2], ...
        'XData', x, ...
        'YData', y, ...
        'Visible', 'on');

if (~strcmp(get(GETPTS_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETPTS_H1, 'UserData', 'Completed');
else
    set(GETPTS_FIG, 'WindowButtonDownFcn', 'getptszoom(''NextButtonDown'');');
end

%--------------------------------------------------
% Subfunction NextButtonDown
%--------------------------------------------------
function NextButtonDown %#ok

global GETPTS_FIG GETPTS_AX GETPTS_H1 GETPTS_H2

selectionType = get(GETPTS_FIG, 'SelectionType');
if (~strcmp(selectionType, 'open'))
    % We don't want to add a point on the second click
    % of a double-click

    [newx, newy] = getcurpt(GETPTS_AX);
    x = get(GETPTS_H1, 'XData');
    y = get(GETPTS_H2, 'YData');

    set([GETPTS_H1 GETPTS_H2], 'XData', [x newx], ...
            'YData', [y newy]);
    
end

if (~strcmp(get(GETPTS_FIG, 'SelectionType'), 'normal'))
    % We're done!
    set(GETPTS_H1, 'UserData', 'Completed');
end

%--------------------------------------------------
% Subfunction MouseMove
%--------------------------------------------------
function MouseMove %#ok
% Function used to create axis limits using the cursor position of the
% mouse. This way, a zoom of the plotted data is achieved.
global GETPTS_AX GETPTSZOOM_AX GETPlotDataZOOM XLimRange GETPlotData GETintMeanZOOM ZoomLevel p

% Get current point from mouse position
[x,y] = getcurpt(GETPTS_AX);
% Find Y-data value of plot data for current x, if x is part of GETPlotData
if x > ceil(min(GETPlotData(:,1))) && x < floor(max(GETPlotData(:,1)))
    indexYData = Tools.Data.DataSetOperations.FindNearestIndex(GETPlotData(:,1),x);
    % Set data for cross hair
    set(GETPlotDataZOOM,{'xdata', 'ydata'}, {x, GETPlotData(indexYData,2)})
else
    % Set data for cross hair
    set(GETPlotDataZOOM,{'xdata', 'ydata'}, {x, y})
end

% Change X-axes limits
if x <= GETPTS_AX.XLim(1) + XLimRange
	GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(1), GETPTS_AX.XLim(1) + 2*XLimRange];
elseif x > GETPTS_AX.XLim(1) + XLimRange
    if x >= GETPTS_AX.XLim(2) - XLimRange
        GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(2) - 2*XLimRange, GETPTS_AX.XLim(2)];
    else
        GETPTSZOOM_AX.XLim = [x - XLimRange, x + XLimRange];
    end
end

% Change Y-axes limits
% Calculate intensity drop correction function
IntDrop = p(1) - p(2).*p(3).^x;
% Calculate zoom drop level
xdata = linspace(GETPTS_AX.XLim(1),GETPTS_AX.XLim(2),6);

switch ZoomLevel
    case 1
        ydata = [1,0.975, 0.95, 0.925, 0.9, 0.875];
    case 2
        ydata = [1,0.95, 0.9, 0.85, 0.8, 0.75];
    case 3
        ydata = [1,0.9, 0.8, 0.7, 0.6, 0.5];
    case 4
        ydata = [1, 0.8, 0.6, 0.4, 0.2, 0.1];
    case 5
        ydata = [1, 0.6, 0.3, 0.2, 0.1, 0.05];
    case 6
        ydata = [1, 0.4, 0.3, 0.2, 0.1, 0.05];
    case 7
        ydata = [1, 0.3, 0.2, 0.15, 0.1, 0.05];
    case 8
        ydata = [1, 0.1, 0.1, 0.1, 0.1, 0.1];
    case 9
        ydata = [1, 0.05, 0.05, 0.05, 0.05, 0.05];
end
% Calculate zoom drop level function
ZoomDrop = interp1(xdata,ydata,x,'linear');
% Calculate min and max zoom for the case when the cross hair is out of the
% figure bounds
ZoomDropmin = interp1(xdata,ydata,min(xdata),'linear');
ZoomDropmax = interp1(xdata,ydata,max(xdata),'linear');

% Calculate decay coefficient in order to adjust Ylim(1) for low
% intensities.
coefficients = polyfit([GETPTS_AX.XLim(1),GETPTS_AX.XLim(2)], [1, 50], 1);
decay = coefficients(1)*x + coefficients(2); 

if y < GETPTS_AX.YLim(2)
    if ~isnan(ZoomDrop)
        if (y - ZoomDrop*GETintMeanZOOM) <= 0
            if y > 0
                GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, y + ZoomDrop*IntDrop];
            elseif y <= 0
                GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, ZoomDrop*IntDrop];
            end
        elseif (y - ZoomDrop*GETintMeanZOOM) > 0
            GETPTSZOOM_AX.YLim = [y - ZoomDrop*GETintMeanZOOM, y + ZoomDrop*IntDrop];
        end
    elseif isnan(ZoomDrop) && x <= GETPTS_AX.XLim(1)
        if (y - ZoomDropmin*GETintMeanZOOM) <= 0
            if y > 0
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
            elseif y <= 0
                GETPTSZOOM_AX.YLim = [0, ZoomDropmin*IntDrop];
            end
        else
            GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
        end
    elseif isnan(ZoomDrop) && x >= GETPTS_AX.XLim(2)
        if (y - ZoomDropmax*GETintMeanZOOM) <= 0
            if y > 0
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax*IntDrop];
            elseif y <= 0
                GETPTSZOOM_AX.YLim = [0, ZoomDropmax*IntDrop];
            end
        else
            GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax];
        end    
    end
elseif y >= GETPTS_AX.YLim(2)   
    GETPTSZOOM_AX.XLim = [GETPTS_AX.YLim(2)-ZoomDrop*GETintMeanZOOM, GETPTS_AX.YLim(2)];
end

%--------------------------------------------------
% Subfunction MouseScroll
%--------------------------------------------------
function MouseScroll(~,callbackdata)
% Function used to change axis limits using the cursor position of the
% mouse. This way, a zoom of the plotted data is achieved when using the
% scroll wheel.
global GETPTS_AX GETPTSZOOM_AX GETintMeanZOOM ZoomLevel p

% Get current point from mouse position
[x,y] = getcurpt(GETPTS_AX);

if callbackdata.VerticalScrollCount > 0
%     if XLimRange <= 3
%         XLimRange = XLimRange + 1;
%     elseif XLimRange < 1
%         XLimRange = 1;
%     end
    
%     if XLimRange >= 7
%         XLimRange = XLimRange - 3;
% %     elseif XLimRange <= 4
% %         XLimRange = 4;
%     end
% 
%     % Change X-axes limits
%     if x - XLimRange <= GETPTS_AX.XLim(1)
%         if x + XLimRange <= GETPTS_AX.XLim(1)
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(1), GETPTS_AX.XLim(1) + 1];
%         else
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(1), x + XLimRange];
%         end 
%     elseif x + XLimRange >= GETPTS_AX.XLim(2)
%         if x - XLimRange >= GETPTS_AX.XLim(2)
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(2) - XLimRange, GETPTS_AX.XLim(2)];
%         else
%             GETPTSZOOM_AX.XLim = [x - XLimRange, GETPTS_AX.XLim(2)];
%         end
%     else
%         GETPTSZOOM_AX.XLim = [x - XLimRange, x + XLimRange];
%     end
    
    % Change Y-axes limits
    % Calculate intensity drop correction function
    IntDrop = p(1) - p(2).*p(3).^x;
    % Calculate zoom drop level
    xdata = linspace(GETPTS_AX.XLim(1),GETPTS_AX.XLim(2),6);
    
    if ZoomLevel > 1
        ZoomLevel = ZoomLevel - 1;
    elseif ZoomLevel <= 1
        ZoomLevel = 1;
    end
    
    switch ZoomLevel
        case 1
            ydata = [1,0.975, 0.95, 0.925, 0.9, 0.875];
        case 2
            ydata = [1,0.95, 0.9, 0.85, 0.8, 0.75];
        case 3
            ydata = [1,0.9, 0.8, 0.7, 0.6, 0.5];
        case 4
            ydata = [1, 0.8, 0.6, 0.4, 0.2, 0.1];
        case 5
            ydata = [1, 0.6, 0.3, 0.2, 0.1, 0.05];
        case 6
            ydata = [1, 0.4, 0.3, 0.2, 0.1, 0.05];
        case 7
            ydata = [1, 0.3, 0.2, 0.15, 0.1, 0.05];
        case 8
            ydata = [1, 0.1, 0.1, 0.1, 0.1, 0.1];
        case 9
            ydata = [1, 0.05, 0.05, 0.05, 0.05, 0.05];    
    end
    % Calculate zoom drop level function
    ZoomDrop = interp1(xdata,ydata,x,'linear');
    % Calculate min and max zoom for the case when the cross hair is out of the
    % figure bounds
    ZoomDropmin = interp1(xdata,ydata,min(xdata),'linear');
    ZoomDropmax = interp1(xdata,ydata,max(xdata),'linear');

    % Calculate decay coefficient in order to adjust Ylim(1) for low
    % intensities.
    coefficients = polyfit([GETPTS_AX.XLim(1),GETPTS_AX.XLim(2)], [1, 50], 1);
    decay = coefficients(1)*x + coefficients(2);

    if y < GETPTS_AX.YLim(2)
        if ~isnan(ZoomDrop)
            if (y - ZoomDrop*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, y + ZoomDrop*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, ZoomDrop*IntDrop];
                end
            elseif (y - ZoomDrop*GETintMeanZOOM) > 0
                GETPTSZOOM_AX.YLim = [y - ZoomDrop*GETintMeanZOOM, y + ZoomDrop*IntDrop];
            end
        elseif isnan(ZoomDrop) && x <= GETPTS_AX.XLim(1)
            if (y - ZoomDropmin*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [0, ZoomDropmin*IntDrop];
                end
            else
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
            end
        elseif isnan(ZoomDrop) && x >= GETPTS_AX.XLim(2)
            if (y - ZoomDropmax*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [0, ZoomDropmax*IntDrop];
                end
            else
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax];
            end    
        end
    elseif y >= GETPTS_AX.YLim(2)   
        GETPTSZOOM_AX.XLim = [GETPTS_AX.YLim(2)-ZoomDrop*GETintMeanZOOM, GETPTS_AX.YLim(2)];
    end
    
%     if y <= 0
%         if ~isnan(ZoomDrop) && (y - ZoomDrop*GETintMeanZOOM) <= 0
%             GETPTSZOOM_AX.YLim = [-ZoomDrop*GETintMeanZOOM, ZoomDrop*IntDrop];
%         elseif isnan(ZoomDrop) && x < GETPTS_AX.XLim(1)
%             GETPTSZOOM_AX.YLim = [-ZoomDropmin*GETintMeanZOOM, ZoomDropmin*IntDrop];
%         elseif isnan(ZoomDrop) && x > GETPTS_AX.XLim(2)
%             GETPTSZOOM_AX.YLim = [-ZoomDropmax*GETintMeanZOOM, ZoomDropmax];  
%         end
%     elseif y > 0
%         if ~isnan(ZoomDrop)
%             if (y - ZoomDrop*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDrop*GETintMeanZOOM, ZoomDrop*IntDrop];
%             elseif (y - ZoomDrop*GETintMeanZOOM) > 0
%                 GETPTSZOOM_AX.YLim = [y - ZoomDrop*GETintMeanZOOM, y + ZoomDrop*IntDrop];
%             end
%         elseif isnan(ZoomDrop) && x <= GETPTS_AX.XLim(1)
%             if (y - ZoomDropmin*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDropmin*GETintMeanZOOM, ZoomDropmin*IntDrop];
%             else
%                 GETPTSZOOM_AX.YLim = [y - ZoomDropmin*GETintMeanZOOM, y + ZoomDropmin*IntDrop];
%             end
%         elseif isnan(ZoomDrop) && x >= GETPTS_AX.XLim(2)
%             if (y - ZoomDropmax*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDropmax*GETintMeanZOOM, ZoomDropmax*IntDrop];
%             else
%                 GETPTSZOOM_AX.YLim = [y - ZoomDropmax*GETintMeanZOOM, y + ZoomDropmax];
%             end    
%         end
%     elseif y >= GETPTS_AX.YLim(2)   
%         GETPTSZOOM_AX.YLim = [GETPTS_AX.YLim(2)-ZoomDrop*GETintMeanZOOM, GETPTS_AX.YLim(2)];
%     end
     
elseif callbackdata.VerticalScrollCount < 0
%     if XLimRange <= 16
%         XLimRange = XLimRange + 3;
% %     elseif XLimRange < 1
% %         XLimRange = 1;
%     end

%     if XLimRange > 1
%         XLimRange = XLimRange - 1;
%     elseif XLimRange <= 1
%         XLimRange = 1;
%     end
    
%     if XLimRange >=1 && XLimRange < 10
%         XLimRange = XLimRange + 1;
%     elseif XLimRange < 1
%         XLimRange = 1;
%     end
%     Change X-axes limits
%     if x - XLimRange <= GETPTS_AX.XLim(1)
%         if x + XLimRange <= GETPTS_AX.XLim(1)
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(1), GETPTS_AX.XLim(1) + 1];
%         else
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(1), x + XLimRange];
%         end 
%     elseif x + XLimRange >= GETPTS_AX.XLim(2)
%         if x - XLimRange >= GETPTS_AX.XLim(2)
%             GETPTSZOOM_AX.XLim = [GETPTS_AX.XLim(2) - XLimRange, GETPTS_AX.XLim(2)];
%         else
%             GETPTSZOOM_AX.XLim = [x - XLimRange, GETPTS_AX.XLim(2)];
%         end
%     else
%         GETPTSZOOM_AX.XLim = [x - XLimRange, x + XLimRange];
%     end

    % Change Y-axes limits
    % Calculate intensity drop correction function
    IntDrop = p(1) - p(2).*p(3).^x;
    % Calculate zoom drop level
    xdata = linspace(GETPTS_AX.XLim(1),GETPTS_AX.XLim(2),6);
    
    if ZoomLevel <= 6
        ZoomLevel = ZoomLevel + 1;
    elseif ZoomLevel < 1
        ZoomLevel = 1;
    end

    switch ZoomLevel
        case 1
            ydata = [1,0.975, 0.95, 0.925, 0.9, 0.875];
        case 2
            ydata = [1,0.95, 0.9, 0.85, 0.8, 0.75];
        case 3
            ydata = [1,0.9, 0.8, 0.7, 0.6, 0.5];
        case 4
            ydata = [1, 0.8, 0.6, 0.4, 0.2, 0.1];
        case 5
            ydata = [1, 0.6, 0.3, 0.2, 0.1, 0.05];
        case 6
            ydata = [1, 0.4, 0.3, 0.2, 0.1, 0.05];
        case 7
            ydata = [1, 0.3, 0.2, 0.15, 0.1, 0.05];
        case 8
            ydata = [1, 0.1, 0.1, 0.1, 0.1, 0.1];
        case 9
            ydata = [1, 0.05, 0.05, 0.05, 0.05, 0.05];    
    end
    % Calculate zoom drop level function
    ZoomDrop = interp1(xdata,ydata,x,'linear');
    % Calculate min and max zoom for the case when the cross hair is out of the
    % figure bounds
    ZoomDropmin = interp1(xdata,ydata,min(xdata),'linear');
    ZoomDropmax = interp1(xdata,ydata,max(xdata),'linear');

    % Calculate decay coefficient in order to adjust Ylim(1) for low
    % intensities.
    coefficients = polyfit([GETPTS_AX.XLim(1),GETPTS_AX.XLim(2)], [1, 50], 1);
    decay = coefficients(1)*x + coefficients(2);

    if y < GETPTS_AX.YLim(2)
        if ~isnan(ZoomDrop)
            if (y - ZoomDrop*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, y + ZoomDrop*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [-GETintMeanZOOM/decay, ZoomDrop*IntDrop];
                end
            elseif (y - ZoomDrop*GETintMeanZOOM) > 0
                GETPTSZOOM_AX.YLim = [y - ZoomDrop*GETintMeanZOOM, y + ZoomDrop*IntDrop];
            end
        elseif isnan(ZoomDrop) && x <= GETPTS_AX.XLim(1)
            if (y - ZoomDropmin*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [0, ZoomDropmin*IntDrop];
                end
            else
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmin*IntDrop];
            end
        elseif isnan(ZoomDrop) && x >= GETPTS_AX.XLim(2)
            if (y - ZoomDropmax*GETintMeanZOOM) <= 0
                if y > 0
                    GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax*IntDrop];
                elseif y <= 0
                    GETPTSZOOM_AX.YLim = [0, ZoomDropmax*IntDrop];
                end
            else
                GETPTSZOOM_AX.YLim = [0, y + ZoomDropmax];
            end    
        end
    elseif y >= GETPTS_AX.YLim(2)   
        GETPTSZOOM_AX.XLim = [GETPTS_AX.YLim(2)-ZoomDrop*GETintMeanZOOM, GETPTS_AX.YLim(2)];
    end
    
%     if y <= 0
%         if ~isnan(ZoomDrop) && (y - ZoomDrop*GETintMeanZOOM) <= 0
%             GETPTSZOOM_AX.YLim = [-ZoomDrop*GETintMeanZOOM, ZoomDrop*IntDrop];
%         elseif isnan(ZoomDrop) && x < GETPTS_AX.XLim(1)
%             GETPTSZOOM_AX.YLim = [-ZoomDropmin*GETintMeanZOOM, ZoomDropmin*IntDrop];
%         elseif isnan(ZoomDrop) && x > GETPTS_AX.XLim(2)
%             GETPTSZOOM_AX.YLim = [-ZoomDropmax*GETintMeanZOOM, ZoomDropmax];  
%         end
%     elseif y > 0
%         if ~isnan(ZoomDrop)
%             if (y - ZoomDrop*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDrop*GETintMeanZOOM, ZoomDrop*IntDrop];
%             elseif (y - ZoomDrop*GETintMeanZOOM) > 0
%                 GETPTSZOOM_AX.YLim = [y - ZoomDrop*GETintMeanZOOM, y + ZoomDrop*IntDrop];
%             end
%         elseif isnan(ZoomDrop) && x <= GETPTS_AX.XLim(1)
%             if (y - ZoomDropmin*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDropmin*GETintMeanZOOM, ZoomDropmin*IntDrop];
%             else
%                 GETPTSZOOM_AX.YLim = [y - ZoomDropmin*GETintMeanZOOM, y + ZoomDropmin*IntDrop];
%             end
%         elseif isnan(ZoomDrop) && x >= GETPTS_AX.XLim(2)
%             if (y - ZoomDropmax*GETintMeanZOOM) <= 0
%                 GETPTSZOOM_AX.YLim = [-ZoomDropmax*GETintMeanZOOM, ZoomDropmax*IntDrop];
%             else
%                 GETPTSZOOM_AX.YLim = [y - ZoomDropmax*GETintMeanZOOM, y + ZoomDropmax];
%             end    
%         end
%     elseif y >= GETPTS_AX.YLim(2)   
%         GETPTSZOOM_AX.YLim = [GETPTS_AX.YLim(2)-ZoomDrop*GETintMeanZOOM, GETPTS_AX.YLim(2)];
%     end
end

%----------------------------------------------------
% Subfunction CreatePointer
%----------------------------------------------------
function [pointerShape, pointerHotSpot] = CreatePointer

pointerHotSpot = [8 8];
pointerShape = [ ...
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
              1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
              2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN
              2   2   2   2   2   2   2 NaN   2   2   2   2   2   2   2   2
              1   1   1   1   1   1   2 NaN   2   1   1   1   1   1   1   1
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN   1   2 NaN   2   1 NaN NaN NaN NaN NaN NaN
            NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN NaN];

        
