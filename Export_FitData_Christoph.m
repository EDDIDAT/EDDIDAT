% for k = 1:1
% 	PeakData{k} = [h.ParamsToFit(1).Psi_Winkel{k} h.ParamsToFit(1).LatticeSpacing{k} h.ParamsToFit(1).LatticeSpacing_Delta{k} repmat(h.PeaksforLabel(k,1:3),length(h.ParamsToFit(1).Psi_Winkel{k}),1); -1*h.ParamsToFit(2).Psi_Winkel{k} h.ParamsToFit(2).LatticeSpacing{k} h.ParamsToFit(2).LatticeSpacing_Delta{k} repmat(h.PeaksforLabel(k,1:3),length(h.ParamsToFit(2).Psi_Winkel{k}),1)];
% end
% 
% for k = 1:1
% fid = fopen(['Herold-Zerodur-weiss-SeiteohneNoppen-sin2psi-phi0_',strrep(num2str((h.PeaksforLabel(k,1:3))),' ',''),'.txt'],'w');
% fprintf(fid, '{{%.15g, %.15g, %.6f},\n', PeakData{k}(1,1:3).');
% fprintf(fid, '{%.15g, %.15g, %.6f},\n', PeakData{k}(2:end-1,1:3).');
% fprintf(fid, '{%.15g, %.15g, %.6f}}\n', PeakData{k}(end,1:3).');
% fclose(fid);
% end


for k = 1:1
	PeakData{k} = [h.ParamsToFit(1).Psi_Winkel{k} h.ParamsToFit(1).LatticeSpacing{k} h.ParamsToFit(1).LatticeSpacing_Delta{k} repmat(h.PeaksforLabel(k,1:3),length(h.ParamsToFit(1).Psi_Winkel{k}),1); -1*h.ParamsToFit(2).Psi_Winkel{k} h.ParamsToFit(2).LatticeSpacing{k} h.ParamsToFit(2).LatticeSpacing_Delta{k} repmat(h.PeaksforLabel(k,1:3),length(h.ParamsToFit(2).Psi_Winkel{k}),1)];
end

for k = 1:1
fid = fopen(['Herold-Zerodur-transparent-sin2psi-phi0-180_',strrep(num2str((h.PeaksforLabel(k,1:3))),' ',''),'.txt'],'w');
fprintf(fid, '{{%.15g, %.15g, %.6f},\n', PeakData{k}(1,1:3).');
fprintf(fid, '{%.15g, %.15g, %.6f},\n', PeakData{k}(2:end-1,1:3).');
fprintf(fid, '{%.15g, %.15g, %.6f}}\n', PeakData{k}(end,1:3).');
fclose(fid);
end