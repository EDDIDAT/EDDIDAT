function [h] = CallbackPlotwindowCheckboxPhi(h, PlotWindow, Phi, value, YDataStr)

PlotPhi = join(['fitdata',PlotWindow,'plotphi',Phi]);
PlotErrPhi = join(['fitdata',PlotWindow,'ploterrphi',Phi]);

if value == 1
    if strcmp(YDataStr,'d-spacing')
        set(h.(PlotErrPhi),'visible','on')
    else
        set(h.(PlotPhi),'visible','on')
    end    
else
    set(h.(PlotPhi),'visible','off')
    set(h.(PlotErrPhi),'visible','off')
end

end

