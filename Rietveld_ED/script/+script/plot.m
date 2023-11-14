dataYPlot = analysis.computeSpectrum();
res = analysis.computeResiduals();

for i = 1:numberOfSpecs
	figure();
	
	hold on;
	
	plot(rc.getDataX, rc.getDataY(:,i) .* rc.getDataYWeight(:,i), '+');
	plot(rc.getDataX, dataYPlot(:,i),'r-','LineWidth',2);
	plot(rc.getDataX, res(:,i) - 1000 ,'-','LineWidth',1);
% 	plot(rc.getDataX(), (rc.getDataY(:,i) .* rc.getDataYWeight(:,i) - dataYPlot(:,i)) - 300 ,'-','LineWidth',1);
	legend('measured profile', 'calculated profile', 'residual');
	
	hold off;
end