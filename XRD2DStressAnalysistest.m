function XRD2DStressAnalysistest()
h.myfig = figure('Name','2DXRD Stress Analysis','MenuBar','none','ToolBar','auto','Position', [50 100 1800 900]);


h.plotpanel = uipanel(h.myfig,...
    "BackgroundColor","white",...
    "Units","pixels",...
    "Position",[350 250 800 600]);

assignin('base','plotpanel',h.plotpanel)

guidata(h.myfig, h)