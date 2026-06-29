function [FitParameter] = Fit_MW_Plot_Laplace(sigmataudata,polydeg,Range1,Range2,Range3,Confidence,PlotRangeFit,Xlim,YlimLow,Ylimhigh)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% sigmataudata = sortrows(sigmataudata,2);
% fitdata = sigmataudata(:,2:end);
sigmataudata = sortrows(sigmataudata,3);
fitdata = sigmataudata(:,3:end);

if polydeg == 0
    polydeg = @(a,x) a(1)./((1./x+a(2)).*x);
    polydegz = @(a,x) a(1).*exp(-a(2).*x);
elseif polydeg == 1
    polydeg = @(a,x) (a(1)./(1./x+a(3)) + a(2)./(1./x+a(3)).^2)./x;
    polydegz = @(a,x) (a(1) + a(2).*x).*exp(-a(3).*x);
end


func = polydeg;
funcz = polydegz;
FitParameter.func = func;
FitParameter.funcz = funcz;

% opts = statset('MaxIter',400,'TolFun',1e-10,'TolX',1e-8);
options = optimoptions('lsqcurvefit');
options.OptimalityTolerance = 1e-10;
options.FunctionTolerance = 1e-10;
options.MaxIterations = 400;

% 
Startparams = fitdata(1,2);

FitParams = [Startparams, Startparams/10, 0.1];
% FitParams = [-900, -300, -0.07];

x0 = FitParams;

x = fitdata(:,1);
y = fitdata(:,2);
% 
lb = [Startparams(1) + Startparams(1)*Range1 -500 -1];
ub = [Startparams(1) - Startparams(1)*Range1 500 1];
[FitParamRange1,residualnormRange1,residualRange1,exitflagRange1,outputRange1,lambdaRange1,jacobianRange1] = lsqcurvefit(func,(x0)',x,y,...
lb,... % lb
ub,... % ub
options);

lb = [Startparams(1) + Startparams(1)*Range2 -500 -1];
ub = [Startparams(1) - Startparams(1)*Range2 500 1];
[FitParamRange2,residualnormRange2,residualRange2,exitflagRange2,outputRange2,lambdaRange2,jacobianRange2] = lsqcurvefit(func,(x0)',x,y,...
lb,... % lb
ub,... % ub
options);

lb = [Startparams(1) + Startparams(1)*Range3 -500 -1];
ub = [Startparams(1) - Startparams(1)*Range3 500 1];
[FitParamRange3,residualnormRange3,residualRange3,exitflagRange3,outputRange3,lambdaRange3,jacobianRange3] = lsqcurvefit(func,(x0)',x,y,...
lb,... % lb
ub,... % ub
options);
% 
% lb = [Startparams(1) - Startparams(1)*Range1 -200 -1];
% ub = [Startparams(1) + Startparams(1)*Range1 100 1];
% [FitParamRange1,residualnormRange1,residualRange1,exitflagRange1,outputRange1,lambdaRange1,jacobianRange1] = lsqcurvefit(func,(x0)',x,y,...
% lb,... % lb
% ub,... % ub
% options);
% 
% lb = [Startparams(1) - Startparams(1)*Range2 -200 -1];
% ub = [Startparams(1) + Startparams(1)*Range2 100 1];
% [FitParamRange2,residualnormRange2,residualRange2,exitflagRange2,outputRange2,lambdaRange2,jacobianRange2] = lsqcurvefit(func,(x0)',x,y,...
% lb,... % lb
% ub,... % ub
% options);
% 
% lb = [Startparams(1) - Startparams(1)*Range3 -200 -1];
% ub = [Startparams(1) + Startparams(1)*Range3 100 1];
% [FitParamRange3,residualnormRange3,residualRange3,exitflagRange3,outputRange3,lambdaRange3,jacobianRange3] = lsqcurvefit(func,(x0)',x,y,...
% lb,... % lb
% ub,... % ub
% options);

FitParameter.FitParamRange1 = FitParamRange1;
FitParameter.FitParamRange2 = FitParamRange2;
FitParameter.FitParamRange3 = FitParamRange3;

FitParameter.residualRange1 = residualRange1;
FitParameter.residualRange2 = residualRange2;
FitParameter.residualRange3 = residualRange3;

FitParameter.jacobianRange1 = jacobianRange1;
FitParameter.jacobianRange2 = jacobianRange2;
FitParameter.jacobianRange3 = jacobianRange3;

alpha = Confidence;
FitParameter.ciRange1 = nlparci(FitParamRange1, residualRange1, 'Jacobian', jacobianRange1, 'Alpha', alpha);
FitParameter.ciRange2 = nlparci(FitParamRange2, residualRange2, 'Jacobian', jacobianRange2, 'Alpha', alpha);
FitParameter.ciRange3 = nlparci(FitParamRange3, residualRange3, 'Jacobian', jacobianRange3, 'Alpha', alpha);

xplot = linspace(0,PlotRangeFit,3000);

yfitRange1z = funcz(FitParamRange1,xplot);
yfitRange2z = funcz(FitParamRange2,xplot);
yfitRange3z = funcz(FitParamRange3,xplot);
yfitRange1 = func(FitParamRange1,xplot);
yfitRange2 = func(FitParamRange2,xplot);
yfitRange3 = func(FitParamRange3,xplot);
yfitRange1ciub = func(FitParameter.ciRange1(:,1),xplot);
yfitRange2ciub = func(FitParameter.ciRange2(:,1),xplot);
yfitRange3ciub = func(FitParameter.ciRange3(:,1),xplot);
yfitRange1cilb = func(FitParameter.ciRange1(:,2),xplot);
yfitRange2cilb = func(FitParameter.ciRange2(:,2),xplot);
yfitRange3cilb = func(FitParameter.ciRange3(:,2),xplot);

% Fill area between CI curves
% (2:end) da NaN als erster Eintrag bei yfit**ci
yplotRange1ci = [yfitRange1cilb(2:end); yfitRange1ciub(2:end)]';
yplotRange2ci = [yfitRange2cilb(2:end); yfitRange2ciub(2:end)]';
yplotRange3ci = [yfitRange3cilb(2:end); yfitRange3ciub(2:end)]';

FitParameter.ciRange1 = reshape(FitParameter.ciRange1,6,1);
FitParameter.ciRange2 = reshape(FitParameter.ciRange2,6,1);
FitParameter.ciRange3 = reshape(FitParameter.ciRange3,6,1);

% figure
% fig = gcf;
% fig.PaperUnits = 'centimeters';
% fig.PaperPositionMode = 'auto';
% fig.PaperPosition = [0 0 180 120];
% axesplotdata = axes('Parent', fig, 'Position', [0.07 0.1125 0.9 0.85]);
% 
% % stressdata.
% axesplotdata.XLim = [0 Xlim];
% xticks(axesplotdata,0:10:Xlim)
% axesplotdata.YLim = [YlimLow Ylimhigh];
% yticks(axesplotdata,YlimLow:200:Ylimhigh)
% grid(axesplotdata,'on')
% 
% xlabel(['z, \tau_{0} [',char(181),'m]'],'FontSize', 20)
% ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)

figure
fig = gcf;
fig.PaperUnits = 'centimeters';
fig.PaperPositionMode = 'auto';
fig.PaperPosition = [0 0 18 12];
ax = gca;
ax.OuterPosition = [0 0 1.0625 1.025];
ax.TickDir = 'out';
ax.Box = 'on';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.GridLineStyle = '-';
ax.GridColor = 'k';
ax.GridAlpha = 0.3;

ax.XLim = ([0 Xlim]); 
ax.XTick = 0:10:Xlim;

ax.YLim = [YlimLow Ylimhigh];
ax.YTick = YlimLow:200:Ylimhigh;

xlabel(['z, \tau_{0} [',char(181),'m]'],'FontSize', 20)
ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)

% ylabel('<\sigma_{11} - \sigma_{33}> [MPa]','FontSize', 20)
%     ylabel('<\sigma_{22} - \sigma_{33}> [MPa]','FontSize', 20)

% ax.XLabel.FontSize = 16;
% ax.LabelFontSizeMultiplier = 1.3;
ax.LineWidth = 1.3;
set(gca,'FontSize',16)
hold on

stressdata = errorbar(ax,x,y,fitdata(:,3),'s','color','k');
% stressdata = errorbar(axesplotdata,x,y,fitdata(:,3),'s','color','k');
stressdata.MarkerSize = 6;
stressdata.MarkerFaceColor = 'k';
stressdata.MarkerEdgeColor = 'k';

% Add hkl label
label = string(sigmataudata(:,1));
dx = 1.25;
h = labelpoints(x + dx,y,label,'NE', 'FontSize', 7);
% check if ydata point overlap or lie too close to each other
ydiff = diff(sigmataudata(:,4));
idxydiff = find(abs(ydiff)<=50);

for k = 1:length(idxydiff)
    set(h(idxydiff(k)),'VerticalAlignment','top')
    set(h(idxydiff(k)),'HorizontalAlignment','left')
end

% hold on

plot(xplot,yfitRange1,':',xplot,yfitRange2,':',xplot,yfitRange3,':')
plot(xplot,yfitRange1z,'b',xplot,yfitRange2z,'r',xplot,yfitRange3z,'g')
% plot(xplot,yfitRange1cilb,'b',xplot,yfitRange3ciub,'b')
plot(xplot,yfitRange1cilb,'b:',xplot,yfitRange1ciub,'b:')
plot(xplot,yfitRange2cilb,'r:',xplot,yfitRange2ciub,'r:')
plot(xplot,yfitRange3cilb,'g:',xplot,yfitRange3ciub,'g:')
% Dummy plot
plot(0,0,'Color','black')

patch([xplot(2:end)'; flip(xplot(2:end)',1)], [yplotRange1ci(:,1); flip(yplotRange1ci(:,2),1)],'blue','EdgeColor','none','FaceAlpha',0.05)
patch([xplot(2:end)'; flip(xplot(2:end)',1)], [yplotRange2ci(:,1); flip(yplotRange2ci(:,2),1)],'red','EdgeColor','none','FaceAlpha',0.05)
patch([xplot(2:end)'; flip(xplot(2:end)',1)], [yplotRange3ci(:,1); flip(yplotRange3ci(:,2),1)],'green','EdgeColor','none','FaceAlpha',0.05)

% Add labels and legend
xtau = 0.75;
ytau = 0.545;
xz = 0.29;
yz = 0.77;
labelsigmatau = annotation('textarrow',[xtau xtau-0.1],[ytau ytau+0.1],'String',([char(963),'(',char(964),')']),'FontSize',14,'headStyle','plain','HeadLength',5,'HeadWidth',5,'LineWidth',0.25,'TextBackgroundColor','w','TextEdgeColor','k');
labelsigmaz = annotation('textarrow',[xz xz+0.05],[yz yz-0.05],'String',([char(963),'(z)']),'FontSize',14,'headStyle','plain','HeadLength',5,'HeadWidth',5,'LineWidth',0.25,'TextBackgroundColor','w','TextEdgeColor','k');

lgd = legend(ax,{'','','','',['\color{blue}',char(963),'^{(1)} ',char(177),' ',num2str(Range1*100),'%'],['\color{red}',char(963),'^{(1)} ',char(177),' ',num2str(Range2*100),'%'],['\color{green}',char(963),'^{(1)} ',char(177),' ',num2str(Range3*100),'%'],'','','','','','',['\color{black}','Confidence = ',num2str(Confidence)]});
% lgd = legend(axesplotdata,{'','','','',['\color{blue}',char(963),'^{(1)} ',char(177),' ',num2str(Range1*100),'%'],['\color{red}',char(963),'^{(1)} ',char(177),' ',num2str(Range2*100),'%'],['\color{green}',char(963),'^{(1)} ',char(177),' ',num2str(Range3*100),'%'],'','','','','','',['\color{black}','Confidence = ',num2str(Confidence)]});
lgd.FontSize = 8;
lgd.Location = 'SouthEast';

FileName = sprintf('Laplace_Real_Space_Fit_Sample1');
Path = [General.ProgramInfo.Path,'\Data\Results\Test\'];
if exist(Path,'dir') ~= 7
    mkdir(Path);
end
print(fig,[Path,FileName],'-painters','-dtiff','-r300')
print(fig,[Path,FileName],'-painters','-djpeg','-r600')

end