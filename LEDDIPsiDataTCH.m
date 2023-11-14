function [Psidata] = LEDDIPsiDataTCH(DiffractionLines)
    for k = 1:size(DiffractionLines,1)
        for l = 1:size(DiffractionLines{k},2)
            Psidata.LineNumber(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).LineNumber(1),'%.0f')); 
            Psidata.Energy_Max(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Energy_Max,'%.4f'));
            Psidata.Energy_Max_Delta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Energy_Max_Delta,'%.4f'));
            Psidata.Intensity_Int_calc(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Intensity_Int_calc,'%.0f'));
            Psidata.IntegralWidth(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).IntegralWidth,'%.4f'));
            Psidata.FWHM(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).FWHM,'%.4f'));
            Psidata.FWHM_Gauss(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).FWHM_Gauss,'%.4f'));
            Psidata.FWHM_Lorentz(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).FWHM_Lorentz,'%.2e'));
            Psidata.twotheta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).twotheta,'%.2f'));
            Psidata.phi(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.phi,'%.0f'));
            Psidata.psi(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.psi,'%.2f'));
            Psidata.eta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.eta,'%.0f'));
            Psidata.RingCurrent(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RingCurrent,'%.2f'));
            Psidata.RealTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
            Psidata.DeadTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).DeadTime,'%.2f'));
            Psidata.alpha(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.alpha,'%.2f'));
            Psidata.beta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.beta,'%.2f'));
            Psidata.x_achse(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Motors.sam_x,'%.4f'));
            Psidata.y_achse(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Motors.sam_y,'%.4f'));
            Psidata.z_achse(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Motors.sam_z,'%.4f'));
            Psidata.SampleStagePos1(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(1),'%.0f'));
            Psidata.SampleStagePos2(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(2),'%.0f'));
            Psidata.SampleStagePos3(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(3),'%.0f'));
            Psidata.Temperatures1(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.Temperatures(1),'%.1f'));
            Psidata.Temperatures2(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.Temperatures(2),'%.1f'));
            Psidata.HeatRate(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.HeatRate,'%.0f'));
            Psidata.Time(k,l) = cellstr(datestr(DiffractionLines{k,1}(l).Measurement.Time,'dd-mm-yyyy-HH-MM-SS'));
            Psidata.PeakCount(k,l) = cellstr(num2str(k,'%.0f'));
        end
    end
end

