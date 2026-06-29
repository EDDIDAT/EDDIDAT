SiC = CalcPeakPositions('Si1C1','SiC_hex',tth,80);
Si = CalcPeakPositions('Si1','Si',tth,80);

figure
xline(SiC.Etheo(1:6),'DisplayName','SiC')
hold on
xline(Si.Etheo(1:6),'--r','DisplayName','Si')
legend('show')
title(['2\theta = ',num2str(tth),'°'])