
for k = 1:size(DEKdatatmp,1)
dphi0(:,k) = (DEKdatatmp(k,5).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}').*UPlot.sin2psi{1,k}+funcsij(Paramssigma13,UPlot.TauCalc.tau{1,k}').*2.*sqrt(UPlot.sin2psi{1,k}.*(1-UPlot.sin2psi{1,k}))) + DEKdatatmp(k,4).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}')+funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}'))).*dzerofit(k)+dzerofit(k);
dphi90(:,k) = (DEKdatatmp(k,5).*(funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}').*UPlot.sin2psi{1,k}+funcsij(Paramssigma23,UPlot.TauCalc.tau{1,k}').*2.*sqrt(UPlot.sin2psi{1,k}.*(1-UPlot.sin2psi{1,k}))) + DEKdatatmp(k,4).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}')+funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}'))).*dzerofit(k)+dzerofit(k);
dphi180(:,k) = (DEKdatatmp(k,5).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}').*UPlot.sin2psi{1,k}-funcsij(Paramssigma13,UPlot.TauCalc.tau{1,k}').*2.*sqrt(UPlot.sin2psi{1,k}.*(1-UPlot.sin2psi{1,k}))) + DEKdatatmp(k,4).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}')+funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}'))).*dzerofit(k)+dzerofit(k);
dphi270(:,k) = (DEKdatatmp(k,5).*(funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}').*UPlot.sin2psi{1,k}-funcsij(Paramssigma23,UPlot.TauCalc.tau{1,k}').*2.*sqrt(UPlot.sin2psi{1,k}.*(1-UPlot.sin2psi{1,k}))) + DEKdatatmp(k,4).*(funcsii(Paramssigma11,UPlot.TauCalc.tau{1,k}')+funcsii(Paramssigma22,UPlot.TauCalc.tau{1,k}'))).*dzerofit(k)+dzerofit(k);
end


for k = 1:size(DEKdatatmp,1)
    figure
    plot(UPlot.sin2psi{1,k},dphi0(:,k),'-',UPlot.sin2psi{1,k},dphi90(:,k),'-',UPlot.sin2psi{1},dphi180(:,k),'-',UPlot.sin2psi{1},dphi270(:,k),'-',UPlot.sin2psi{1,k}(sin2psirange{1,k}),ParamsToFit(1).LatticeSpacing{1,k}(sin2psirange{1,k}),'s',UPlot.sin2psi{1,k}(sin2psirange{1,k}),ParamsToFit(2).LatticeSpacing{1,k}(sin2psirange{1,k}),'s',UPlot.sin2psi{1,k}(sin2psirange{1,k}),ParamsToFit(3).LatticeSpacing{1,k}(sin2psirange{1,k}),'s',UPlot.sin2psi{1,k}(sin2psirange{1,k}),ParamsToFit(4).LatticeSpacing{1,k}(sin2psirange{1,k}),'s')
    xlim('auto')
    ylim('auto')
end


figure
for k = 1:size(DEKdatatmp,1)
    subplot(3,3,k);
    plot(UPlot.sin2psi{1,k},dphi0(:,k),'-',UPlot.sin2psi{1,k},dphi90(:,k),'-',UPlot.sin2psi{1},dphi180(:,k),'-',UPlot.sin2psi{1},dphi270(:,k),'-',UPlot.sin2psi{1,k},ParamsToFit(1).LatticeSpacing{1,k},'s',UPlot.sin2psi{1,k},ParamsToFit(2).LatticeSpacing{1,k},'s',UPlot.sin2psi{1,k},ParamsToFit(3).LatticeSpacing{1,k},'s',UPlot.sin2psi{1,k},ParamsToFit(4).LatticeSpacing{1,k},'s')
    xlim('auto')
    ylim('auto')
end



figure
plot(sin2psi.dphi0m180sinquadratpsi{1}(:,1),sin2psi.dphi0{1}(:,1),'*','MarkerSize',14)
hold on
plot(sin2psi.dphi0m180sinquadratpsi{1}(1:30,1),ParamsToFit(1).LatticeSpacing{1}(:,1),'s','MarkerSize',14)
hold on
plot(sin2psi.dphi0m180sinquadratpsi{1}(:,1),ParamsToFit(1).LatticeSpacingInterpol{1}(:,1),'o','MarkerSize',14)


% In order to plot only the d-sin²psi values that are "left" by the user,
% create a logical with the respective psi angles

idxPsi = ismember(NumberPsiAngles, ParamsToFit(4).Psi_Winkel{k}, 'rows');