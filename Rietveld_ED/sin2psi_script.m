specSize = 116;
peakCnt = 7;

% Berechnung der d-Werte aus den Energielagen

for i = 1:peakCnt
    d(:,i) = 12.398./(2*sind(TwoTheta'./2)).*1./EPosReal(:,i);
end

% Fit der d-Werte als Funktion von sin2psi

for i = 1:peakCnt
    m_hkl = fitlm(sind(Psi').^2, d(:,i), 'linear');
    %tbl = anova(m_hkl, 'summary');
    tbl = table2array(m_hkl.Coefficients);
    fitvalues(i) = tbl(2,1);
    fiterrors(i) = tbl(2,2); 
end

% d0 Werte berechnen

for i = 1:peakCnt
    d0_hkl(:,i) = a0./sqrt(H(i).^2 + K(i).^2 + L(i).^2);
end

% Berechnung der Spannung sigma

for i = 1:peakCnt
    sigma_hkl(:,i) = fitvalues(i)*1/d0_hkl(i)*1/DEK_S2(i);
end

% Berechnung des Fehlers deltasigma_hkl von sigma_hkl

for i = 1:peakCnt
    deltasigma_hkl(:,i) = fiterrors(i)*1/d0_hkl(i)*1/DEK_S2(i);
end

% Berechnung der mittleren Eindringtiefe tauavg

for i = 1:peakCnt
    tauavg(:,i) = (tau(1,i) + tau(specSize,i))/2;
end

% Plot der Ergebnisse

figure;
errorbar(tauavg,sigma_hkl,deltasigma_hkl,'--sk')

xlabel('\tau [µm]');
ylabel('\sigma_{11} - \sigma_{33} [Mpa]','Interpreter','tex','FontSize',10);
title('\sigma_{11}-sin²\psi distribution');
% axis tight
grid on

% for i = 1:peakCnt
%     subplot(2, 2, i)
%     hold on
%     errorbar(tauavg(i),sigma_hkl(i),deltasigma_hkl(i))
% end
