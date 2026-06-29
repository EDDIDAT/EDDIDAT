tic
Folder = 'D:\EDDIDAT_github\Data\Results\Pilatus-2DXRD\Test_neue_Analyse\02_SiSiC_vor_WB\Mirko_20251212_02_SiSiC_iWT_Kanalstruktur_Top_P0_radial';
FolderPoni = 'D:\EDDIDAT_github\Data\Results\Pilatus-2DXRD\Test_neue_Analyse\02_SiSiC_vor_WB\LaB6_2025';
images = {"image_0000007.tif","image_0000008.tif","image_0000009.tif"};
ponis = {"image_0000007_LaB6_Pos1_alpha6.poni","image_0000008_LaB6_Pos2_alpha6.poni","image_0000009_LaB6_Pos3_alpha6.poni"};

imgPaths = cell(length(images),1);

for k = 1:length(images)
    imgPaths{k} = fullfile(Folder, images{k});    
end

poniPaths = cell(length(ponis),1);

for k = 1:length(ponis)
    poniPaths{k} = fullfile(FolderPoni, ponis{k});  
end

% imgPaths  = {"image_0000013.tif","image_0000014.tif","image_0000015.tif","image_0000016.tif","image_0000017.tif","image_0000018.tif"};
% poniPaths = {"LaB6_alpha06_Pos1_image_0000013.poni","LaB6_alpha06_Pos1_image_0000014.poni","LaB6_alpha06_Pos1_image_0000015.poni","LaB6_alpha06_Pos2_image_0000016.poni","LaB6_alpha06_Pos2_image_0000017.poni","LaB6_alpha06_Pos2_image_0000018.poni"};

% imgPaths  = {"image_0000013.tif","image_0000014.tif","image_0000015.tif"};
% poniPaths = {"LaB6_alpha06_Pos1_image_0000013.poni","LaB6_alpha06_Pos1_image_0000014.poni","LaB6_alpha06_Pos1_image_0000015.poni"};
lambda_m  = 1.34143847484e-10; %1.34115133333e-10;

cfg = struct;
cfg.pythonExe = "python";                  % oder voller Pfad
cfg.outBase   = fullfile(Folder,"pyfai_SiSiC_Test_vor_WB2");
cfg.mode      = "2d";
cfg.unit      = "2th_deg";
cfg.npt_rad   = 3000;
cfg.npt_azim  = 360;
cfg.method    = "csr";
cfg.pythonExe = "C:\Users\hrp\AppData\Local\Programs\Python\Python311\venv\Scripts\python.exe";
cfg.scriptPath = fullfile(pwd,"pyfai_multigeom_run.py");

out = run_pyfai_multigeometry_from_matlab(imgPaths, poniPaths, lambda_m, cfg);

% save([fullfile(Folder,'SiSIC_vor_WB_alpha6_pyfai_multigeom.mat')], '-struct', 's1');

plot_pyfai_multigeom_2d(out, lambda_m, struct("showAxis","tth","useLog",true,"logStrength",1,"saveTif", true, "tifPath", fullfile(Folder, "SiSIC_vor_WB_alpha6_pyfai_multigeom_plot.tif")));
toc
% out.I: [npt_rad x npt_azim]
% out.radial: 2theta grid
% out.azimuthal: chi grid
% figure; imagesc(out.azimuthal, out.radial, log10(out1.I + 1)); set(gca,'YDir','normal'); colorbar;
% xlabel('\chi (deg)'); ylabel('2\theta (deg)'); title('pyFAI MultiGeometry I(2\theta,\chi)');
% 
% figure; imagesc(out.radial, out.azimuthal, log10(out1.I + 1)); set(gca,'YDir','normal'); colorbar;
% xlabel('2\theta (deg)'); ylabel('\chi (deg)'); title('pyFAI MultiGeometry I(2\theta,\chi)');