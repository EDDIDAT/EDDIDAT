% +------------------------------------------------------+
% |            Interactive 2D Plot Magnifier             |
% |              with MATLAB Implementation              | 
% |                                                      |
% | Author: Ph.D. Eng. Hristo Zhivomirov        08/24/17 | 
% +------------------------------------------------------+
% 
% function: magnifier(hFig)
%
% Input:
% hFig - handle of the figure where the magnification must be applied
%
% Output:
% N/A
%
% Instructions for use:
% - Click and hold the left mouse button to turn the magnifier on;
% - Simultaneously, turn the mouse scroll wheel to increase or decrease 
%   the magnification factor;
% - Release the left mouse button to remove the magnifier;
% - Press and hold the "Ctrl" key while operate with the magnifier in 
%   order to preserve the zoomed area when the left mouse button is 
%   released.
function magnifier(hFig)
% set the mouse callback functions
set(hFig, 'WindowButtonDownFcn',    @ButtonDownCallback, ...
          'WindowButtonMotionFcn',  @ButtonMotionCallback, ...
          'WindowScrollWheelFcn',   @WindowScrollWheel, ...
          'WindowButtonUpFcn',      @ButtonUpCallback)
      
end
function ButtonDownCallback(src, eventdata)
% prepare the magnifier axes
ax1 = gca;
ax2 = copyobj(ax1, src);
% set some figure properties
set(src, 'UserData', [ax1, ax2])
set(src, 'Pointer', 'crosshair')
set(src, 'Units', 'normalized')
% set some magnifier properties
mag_factor = 2;
set(ax2, 'UserData', mag_factor) 
xlabel(ax2, ''), ylabel(ax2, ''), zlabel(ax2, ''), title(ax2, '')
% call ButtonMotionCallback function
ButtonMotionCallback(src)
end
function ButtonMotionCallback(src, eventdata)
% get the user data
UD = get(src, 'UserData');
% check if the user data exist
if isempty(UD)
    return
end
% get the user data (cont.)
ax1 = UD(1); ax2 = UD(2);
% determine the pointer position in the figure (normalized units)
fig_ppos = get(src, 'CurrentPoint');
% set the magnifier size and position
ax1_pos = get(ax1, 'Position');
set(ax2, 'Position', [fig_ppos(1) - 0.125*ax1_pos(3)
                      fig_ppos(2) - 0.125*ax1_pos(4)
                      0.25*ax1_pos(3)
                      0.25*ax1_pos(4)])
% determine the pointer position in the axes (data units)
ax1_ppos = get(ax1, 'CurrentPoint');
ax1_ppos = ax1_ppos([1, 3]);
% set the magnifier axes limits
ax2_pos = get(ax2, 'Position');
mag_factor = get(ax2, 'UserData');
xlim(ax2, ax1_ppos(1) + (1/mag_factor)*(ax2_pos(3)/ax1_pos(3))*diff(get(ax1,'XLim'))*[-0.5 0.5])
ylim(ax2, ax1_ppos(2) + (1/mag_factor)*(ax2_pos(4)/ax1_pos(4))*diff(get(ax1,'YLim'))*[-0.5 0.5])
% show the magnification factor
set(src, 'CurrentAxes', ax2)
delete(findobj(ax2, 'Type', 'Text'))
text(0.75, 0.85, ['x' num2str(mag_factor)], 'Units', 'normalized', 'FontSize', 12)
end
function WindowScrollWheel(src, eventdata)
% get the user data
UD = get(src, 'UserData');
% check if the user data exist
if isempty(UD)
    return
end
% get the user data (cont.)
ax2 = UD(2);
mag_factor = get(ax2, 'UserData');
% set the new magnification value
if eventdata.VerticalScrollCount < 0
    % increase the magnification
    mag_factor = mag_factor + 1;
elseif eventdata.VerticalScrollCount > 0
    % decrease the magnification
    mag_factor = mag_factor - 1;
else
    % keep the current magnification
end
if mag_factor < 1
    mag_factor = 1;
end
set(ax2, 'UserData', mag_factor)
% call the ButtonMotionCallback function
ButtonMotionCallback(src)
end
function ButtonUpCallback(src, eventdata)
% get the user data
UD = get(src, 'UserData');
% check if the user data exist
if isempty(UD)
    return
end
% get the user data (cont.)
ax1 = UD(1); ax2 = UD(2);
% restore the figure properties
set(src, 'CurrentAxes', ax1)
set(src, 'UserData', [])
set(src, 'Pointer', 'arrow')
% check if the user operates with the right 
% mouse button, if not - delete the magnifier
if ~strcmp(get(src, 'SelectionType'), 'alt')
    % delete the 2D magnifier
    delete(ax2)
end
end