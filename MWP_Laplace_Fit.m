% sigmaii
polydeg1 = @(a,x) a(1)./(1+a(3).*x) + (a(2).*x)./(1+a(3).*x).^2;
polydeg1z = @(a,x) (a(1) + a(2).*x).*exp(-a(3).*x);

% sigmaij
polydeg1 = @(a,x) (a(1).*x)./(1./x+a(2)).^2;
polydeg1z = @(a,x) (a(1).*x).*exp(-a(2).*x);


[h.Paramssigma11,Rsigma11,Jsigma11,CovBsigma11] = nlinfit(h.FitDatasigma11(:,1),h.FitDatasigma11(:,2),h.funcsigma11,FitParams,opts,'Weights',1./h.FitDatasigma11(:,3));


% Fitdata
x = t.sin2psi.StressPlotDatatmpsorted(:,1);
y = t.sin2psi.StressPlotDatatmpsorted(:,2);
y_err = t.sin2psi.StressPlotDatatmpsorted(:,3);
xdata = x;
ydata = y;
ydataerr = y_err;
dataYWeight = 1./ydataerr;

opts = statset('MaxIter',400,'TolFun',1e-10,'TolX',1e-8);

% Funktion zum fitten von sigmaii
polydeg1 = @(a,xdata) a(1)./(1+a(3).*xdata) + (a(2).*xdata)./(1+a(3).*xdata).^2;
polydeg11 = @(a,xdata) dataYWeight.* (a(1)./(1+a(3).*xdata) + (a(2).*xdata)./(1+a(3).*xdata).^2);
polydeg1neu = @(x) x(1)./(1+x(3).*xdata) + (x(2).*xdata)./(1+x(3).*xdata).^2-ydata;

polydeg1z = @(a,xdata) (a(1) + a(2).*xdata).*exp(-a(3).*xdata);
% Untere und obere Grenze der Fitparameter
lb1 = [ydata(1) - 0.1*abs(ydata(1)),-Inf,0];
lb2 = [ydata(1) - 0.3*abs(ydata(1)),-Inf,0];
lb3 = [ydata(1) - 0.9*abs(ydata(1)),-Inf,0];

ub1 = [ydata(1) + 0.1*abs(ydata(1)),Inf,1];
ub2 = [ydata(1) + 0.3*abs(ydata(1)),Inf,1];
ub3 = [ydata(1) + 0.9*abs(ydata(1)),Inf,1];

% Startwerte
x0 = [ydata(1),100,0.1];

% Fit
x = lsqcurvefit(polydeg1,x0,xdata,ydata,lb1,ub1,opts);
xneu1 = lsqcurvefit(polydeg11,x0,xdata,ydata.*dataYWeight,lb1,ub1,opts);
xneu = lsqnonlin(polydeg1neu,x0,lb1,ub1,opts);
x1 = lsqcurvefit(polydeg1,x,xdata,ydata,lb2,ub2,opts);
x2 = lsqcurvefit(polydeg1,x1,xdata,ydata,lb3,ub3,opts);

% Plot der gefitteten Verläufe
% x-Daten für gefittete Verläufe
xfit = linspace(0,100,101);
% y-Daten für gefittete Verläufe im Laplace-Raum und Ortsraum
yfit = polydeg1(x,xfit);
yfit1 = polydeg1(x1,xfit);
yfit2 = polydeg1(x2,xfit);

yfitz = polydeg1z(x,xfit);
yfitz1 = polydeg1z(x1,xfit);
yfitz2 = polydeg1z(x2,xfit);

plot(xdata,ydata,'square')
hold on
plot(xfit,yfit,xfit,yfit1,xfit,yfit2)
plot(xfit,yfitz,xfit,yfitz1,xfit,yfitz2)