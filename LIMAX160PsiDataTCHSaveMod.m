function [Psidata] = LIMAX160PsiDataTCHSaveMod(DiffractionLines)
    for k = 1:size(DiffractionLines,1)
        for l = 1:size(DiffractionLines{k},2)
            Psidata.LineNumber(k,l) = DiffractionLines{k,1}(l).LineNumber(1); 
            Psidata.Energy_Max(k,l) = DiffractionLines{k,1}(l).Energy_Max;
            Psidata.Energy_Max_Delta(k,l) = DiffractionLines{k,1}(l).Energy_Max_Delta;
            Psidata.Intensity_Int_calc(k,l) = DiffractionLines{k,1}(l).Intensity_Int_calc;
            Psidata.IntegralWidth(k,l) = DiffractionLines{k,1}(l).IntegralWidth;
            Psidata.FWHM(k,l) = DiffractionLines{k,1}(l).FWHM;
            Psidata.FWHM_Gauss(k,l) = DiffractionLines{k,1}(l).FWHM_Gauss;
            Psidata.FWHM_Lorentz(k,l) = DiffractionLines{k,1}(l).FWHM_Lorentz;
            Psidata.twotheta(k,l) = DiffractionLines{k,1}(l).twotheta;
            Psidata.phi(k,l) = DiffractionLines{k,1}(l).SCSAngles.phi;
            Psidata.psi(k,l) = DiffractionLines{k,1}(l).SCSAngles.psi;
            Psidata.eta(k,l) = DiffractionLines{k,1}(l).SCSAngles.eta;
            Psidata.RingCurrent(k,l) = DiffractionLines{k,1}(l).RingCurrent;
            Psidata.RealTime(k,l) = DiffractionLines{k,1}(l).RealTime;
            Psidata.DeadTime(k,l) = DiffractionLines{k,1}(l).DeadTime;
            Psidata.x_achse(k,l) = DiffractionLines{k,1}(l).Motors.sam_x;
            Psidata.y_achse(k,l) = DiffractionLines{k,1}(l).Motors.sam_y;
            Psidata.z_achse(k,l) = DiffractionLines{k,1}(l).Motors.sam_z;
            Psidata.SampleStagePos1(k,l) = DiffractionLines{k,1}(l).SampleStagePos(1);
            Psidata.SampleStagePos2(k,l) = DiffractionLines{k,1}(l).SampleStagePos(2);
            Psidata.SampleStagePos3(k,l) = DiffractionLines{k,1}(l).SampleStagePos(3);
            Psidata.Temperatures1(k,l) = DiffractionLines{k,1}(l).Measurement.Temperatures(1);
            Psidata.Temperatures2(k,l) = DiffractionLines{k,1}(l).Measurement.Temperatures(2);
            Psidata.HeatRate(k,l) = DiffractionLines{k,1}(l).Measurement.HeatRate;
            Psidata.Time(k,l) = cellstr(datestr(DiffractionLines{k,1}(l).Measurement.Time,'dd-mm-yyyy-HH-MM-SS'));
            Psidata.PeakCount(k,l) = k;
        end
    end
end

