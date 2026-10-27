function [Psidata] = PsiDataSplitPVGeneral(DiffractionLines,SPECFileCheck)
% Wie PsiDataPVGeneral, aber mit zusaetzlichen Spalten fuer die beiden
% Halbwertsbreiten (wL, wR) und den Gauss/Lorentz-Mischungsanteil
% (GLmix) der Split- (bifurkierten) Pseudo-Voigt-Funktion, direkt nach
% der integralen Breite (Ib) einsortiert.
    for k = 1:size(DiffractionLines,1)
        for l = 1:size(DiffractionLines{k},2)
            Psidata.LineNumber(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).LineNumber(1),'%.0f'));
            Psidata.Energy_Max(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Energy_Max,'%.4f'));
            Psidata.Energy_Max_Delta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Energy_Max_Delta,'%.4f'));
            Psidata.Intensity_Int_calc(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Intensity_Int_calc,'%.2f'));
            Psidata.IntegralWidth(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).IntegralWidth,'%.4f'));
            Psidata.WidthLeft(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).WidthLeft,'%.4f'));
            Psidata.WidthRight(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).WidthRight,'%.4f'));
            Psidata.GLmix(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).WeightingFactor,'%.4f'));
            Psidata.twotheta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).twotheta,'%.2f'));
            Psidata.phi(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.phi,'%.2f'));
            Psidata.psi(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.psi,'%.2f'));
            Psidata.eta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SCSAngles.eta,'%.0f'));
            Psidata.h(k,l) = cellstr(num2str(0,'%.0f'));
            Psidata.k(k,l) = cellstr(num2str(0,'%.0f'));
            Psidata.l(k,l) = cellstr(num2str(0,'%.0f'));
            Psidata.SampleStagePos1(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(1),'%.2f'));
            Psidata.SampleStagePos2(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(2),'%.2f'));
            Psidata.SampleStagePos3(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).SampleStagePos(3),'%.2f'));
            if SPECFileCheck == 1
                if strcmp(DiffractionLines{k}(l).Measurement.Diffractometer.Name,'ETA3000')
                    Psidata.twotheta(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).twotheta(1),'%.2f'));
                    Psidata.RealTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
                    Psidata.DeadTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).DeadTime,'%.2f'));
                    Psidata.Temperatures1(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
                    Psidata.Temperatures2(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
                    Psidata.HeatRate(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
                    Psidata.Time(k,l) = cellstr(datestr(DiffractionLines{k,1}(l).Measurement.Time,'dd-mm-yyyy-HH-MM-SS'));
                else
                    Psidata.RealTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).RealTime,'%.2f'));
                    Psidata.DeadTime(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).DeadTime,'%.2f'));
                    Psidata.Temperatures1(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.Temperatures(1),'%.0f'));
                    Psidata.Temperatures2(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.Temperatures(2),'%.0f'));
                    Psidata.HeatRate(k,l) = cellstr(num2str(DiffractionLines{k,1}(l).Measurement.HeatRate,'%.0f'));
                    Psidata.Time(k,l) = cellstr(datestr(DiffractionLines{k,1}(l).Measurement.Time,'dd-mm-yyyy-HH-MM-SS'));
                end
            end
            Psidata.PeakCount(k,l) = cellstr(num2str(k,'%.0f'));
        end
    end
end
