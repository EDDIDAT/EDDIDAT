function [h] = buttonClearFitData(h, PlotWindow, valueSlider)

Axes = join(['axesplotfitdata',PlotWindow]);
Slider = join(['Sliderplotwindowfitdata',PlotWindow]);
PlotPhi0 = join(['fitdata',PlotWindow,'plotphi0']);
PlotErrPhi0 = join(['fitdata',PlotWindow,'ploterrphi0']);
PlotPhi90 = join(['fitdata',PlotWindow,'plotphi90']);
PlotErrPhi90 = join(['fitdata',PlotWindow,'ploterrphi90']);
PlotPhi180 = join(['fitdata',PlotWindow,'plotphi180']);
PlotErrPhi180 = join(['fitdata',PlotWindow,'ploterrphi180']);
PlotPhi270 = join(['fitdata',PlotWindow,'plotphi270']);
PlotErrPhi270 = join(['fitdata',PlotWindow,'ploterrphi270']);
PlotCheckBoxPhi0 = join(['plotwindowfitdata',PlotWindow,'checkboxphi0']);
PlotCheckBoxPhi90 = join(['plotwindowfitdata',PlotWindow,'checkboxphi90']);
PlotCheckBoxPhi180 = join(['plotwindowfitdata',PlotWindow,'checkboxphi180']);
PlotCheckBoxPhi270 = join(['plotwindowfitdata',PlotWindow,'checkboxphi270']);
LegendPlot = join(['legendplotfitdata',PlotWindow]);
PopupmenuXData = join(['popupmenuXData',PlotWindow]);
PopupmenuYData = join(['popupmenuYData',PlotWindow]);
eta = join(['eta',PlotWindow]);
phi = join(['phi',PlotWindow]);

% Set plot data
if ~isempty(h.idxphi0)
    set(h.(PlotErrPhi0), {'XData','YData','YNegativeDelta','YPositiveDelta','Visible'}, {0,0,0,0,'off'})
    set(h.(PlotPhi0), {'XData','YData','Visible'}, {0,0,'off'})
end

if ~isempty(h.idxphi90)
    set(h.(PlotErrPhi90), {'XData','YData','YNegativeDelta','YPositiveDelta','Visible'}, {0,0,0,0,'off'})
    set(h.(PlotPhi90), {'XData','YData','Visible'}, {0,0,'off'})
end

if ~isempty(h.idxphi180)
    set(h.(PlotErrPhi180), {'XData','YData','YNegativeDelta','YPositiveDelta','Visible'}, {0,0,0,0,'off'})
    set(h.(PlotPhi180), {'XData','YData','Visible'}, {0,0,'off'})
end

if ~isempty(h.idxphi270)
    set(h.(PlotErrPhi270), {'XData','YData','YNegativeDelta','YPositiveDelta','Visible'}, {0,0,0,0,'off'})
    set(h.(PlotPhi270), {'XData','YData','Visible'}, {0,0,'off'})
end

% Reset phi checkboxes
set(h.(PlotCheckBoxPhi0),{'Value','Enable'},{0,'on'})
set(h.(PlotCheckBoxPhi90),{'Value','Enable'},{0,'on'})
set(h.(PlotCheckBoxPhi180),{'Value','Enable'},{0,'on'})
set(h.(PlotCheckBoxPhi270),{'Value','Enable'},{0,'on'})

% Set legend visible off
h.(LegendPlot).Visible = 'off';

% If eta measurements were analyzed
if isfield(h,['eta',PlotWindow])
    if isfield(h.(eta),'etaplot')
        for i = 1:length(h.(eta).psiIndex{valueSlider})
            set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta','Visible'},{h.(eta).Tabledspacing{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,'off'});
        end
    end
    h.(eta).legend.Visible = 'off';
    h = rmfield(h,['eta',PlotWindow]);
end

if isfield(h,['phi',PlotWindow])
    if isfield(h.(phi),'phiplot')
        assignin('base','hphi',h.(phi))
        for i = 1:length(h.(phi).psiIndex{valueSlider})
            set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta','Visible'},{h.(phi).Tabledspacing{valueSlider,i}.*0,h.(phi).Tabledspacingdelta{valueSlider,i}.*0,h.(phi).Tabledspacingdelta{valueSlider,i}.*0,'off'});
        end
    end
    delete(h.(phi).phiplot{1})
    h.(phi).legend.Visible = 'off';
    h = rmfield(h,['phi',PlotWindow]);
end
% h.(eta).legend.Visible = 'off';
% Set pop up menu to defautl values
set(h.(PopupmenuXData),'Value',1)
set(h.(PopupmenuYData),'Value',1)

% Set plot properties
xlabel(h.(Axes),'Choose Data')
ylabel(h.(Axes),'Choose Data')
title(h.(Axes),{'No measurement data loaded';'  '})
h.(Axes).XLim = [0 1];
h.(Axes).YLim = [0 1];
h.(Axes).YLimMode = 'auto';
ytickformat(h.(Axes),'auto')
xtickformat(h.(Axes),'auto')
yticks(h.(Axes),'auto')
xticks(h.(Axes),'auto')

% Set slider value
set(h.(Slider), 'Value', 1);

end

