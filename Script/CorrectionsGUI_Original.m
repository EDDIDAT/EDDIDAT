function [Measurement,DataTmp,S] = CorrectionsGUI(Measurement,P)
%% (* Correction of the measurements *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Specify which corrections you'd like to perform.
% For synchrotron measurements, all corrections need to be performed.
% For LEDDI measurements the RingCurrent correction must be turned off.
% For Data Preparation all corrections must be turned off ('false')!
% if P.CorrectAbsortption == 1
%     CorrectAbsorption = true;
% else
%     CorrectAbsorption = false;
% end
% 
% if P.CorrectWiggler == 1
%     CorrectWigglerSpectrum = true;
% else
%     CorrectWigglerSpectrum = false;
% end
% 
% if P.CorrectRC == 1
%     CorrectRingCurrent = true;
% else
%     CorrectRingCurrent = false;
% end
CorrectAbsorption = logical(P.CorrectAbsortption);
CorrectWigglerSpectrum = logical(P.CorrectWiggler);
CorrectRingCurrent = logical(P.CorrectRC);
% Chose the diffractometer that was used for the measurement. This options
% decides which absorption correction has to be applied (only for manual
% fitting, not for Rietveld)
Mode = P.MeasurementMode;
% 1 = EDDI Reflection Mode
% 2 = EDDI Transmission Mode
% 3 = LEDDI_Mode_1
% 4 = LEDDI_Mode_2
% 5 = LEDDI_Mode_Horizontal
% 6 = LEDDI_Mode_Vertical
SampleThickness = P.SampleThickness; % in [mm]
% P.DeltaTwoTheta = 0;
% P.Eoffset = 0;
% Note from programmer:
% Bei Messungen vor dem 01.02.2016 muessen die Parameter P.Detalpha und
% P.Omega angepasst werden. Am 01.02.2016 wurden die Referenzwerte des
% Diffraktometers geaendert.
% Specifiy the parameters that are needed to calculate the incidence and
% reflection angles, alpha and beta. For the "EDDI" diffractometer, the
% values have to be set to Zero.
% if Mode == 1
%     P.DetRadius = 0; % EDDI Reflection Mode
%     P.QuellRadius = 0; % EDDI Reflection Mode
% elseif Mode == 2
%     P.DetRadius = 0; % EDDI Transmission Mode
%     P.QuellRadius = 0; % EDDI Transmission Mode
% else
%     P.Det = 1; % 1 for Det1 (rausgefahren) and 2 für Det2 (Primaerstrahl)
%     P.DetRadius = Measurement(1).Motors.radd1; %Measurement(1).Motors.radd1; % LEDDI
%     P.QuellRadius = 360; % LEDDI
% end
% Clean up all temporary variables
P.CleanUpTemporaryVariables = false;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% If the corrected/uncorrected data should be exported to be used with a
% different program, define the path where the file should be saved and the
% filename. Choose P.SaveToFile true (export) or false (no export).
P.SaveToFile = false;                                                 % <--
if (P.SaveToFile)
    % Choose file path.
    P.Pathdir = 'C:\Users\hrp\Documents\MATLAB\rietveld\rietveld_neue_DT_Korrektur\data\CurrentProject';
    % Choose file name.
    P.MaterialParameterFileName = 'Schaefflerdata.mat';
end
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
if Mode == 1 || Mode == 2
    for j_c = 1:length(Measurement)
        if Mode == 1
            if (CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(260);  end
            if (CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(Mode);  end
            if (CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(Mode);  end
        elseif Mode == 2
            set(Measurement, 'SampleThickness', SampleThickness);
            if (CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(260);  end
            if (CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(Mode);  end
            if (CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(Mode);  end
        end
    end
else
 %---------------------------------------------------------------------------------------------
    % For the LEDDI diffractometer, measurements are done simultaneously
    % with both detectors. Therefore, there has to be a distinction between
    % the two detectors.
%     MeasurementDet1 = Measurement(2:2:end);
%     MeasurementDet2 = Measurement(1:2:end);      

    % Measurement from Det1 (rausgefahren)
    MeasurementDet1 = Measurement(2:2:end);

    for j_c = 1:length(MeasurementDet1)
        % Define radius, theta and alpha of Det1 and radius and theta of source
        Det1.Dettheta = abs(MeasurementDet1(1).Motors.Det1_rot);
        Det1.Detalpha = abs(MeasurementDet1(1).Motors.Det1);
        Det1.DetRadius = MeasurementDet1(1).Motors.radd1;
        Det1.QuellRadius = 360;
        Det1.Quelltheta = abs(MeasurementDet1(1).Motors.Source_rot);
        % Calculations regarding beam path
        Det1.Omega = abs(MeasurementDet1(1).Motors.Omega);
        Det1.h = 2 * Det1.DetRadius * sind(Det1.Dettheta/2);
        Det1.qD = Det1.h * sind(Det1.Dettheta/2);
        Det1.l = 2 * sind(Det1.Detalpha/2) * (Det1.DetRadius - Det1.qD);
        Det1.l1D = sind(Det1.Detalpha) * (Det1.DetRadius - Det1.qD);
        Det1.h1D = Det1.DetRadius * sind(Det1.Dettheta);
        Det1.s = sqrt(Det1.l^2 + Det1.h1D^2);
        Det1.pD = (Det1.DetRadius - Det1.qD) * cosd(Det1.Detalpha);
        Det1.xDet = Det1.pD;
        Det1.yDet = Det1.l1D;
        Det1.zDet = Det1.h1D;
        Det1.hQ = 2 * Det1.QuellRadius * sind(Det1.Quelltheta/2);
        Det1.h1Q = Det1.QuellRadius * sind(Det1.Quelltheta);
        Det1.qQ = Det1.h1Q * tand(Det1.Quelltheta/2);
        Det1.xQuel = -(Det1.QuellRadius-Det1.qQ);
        Det1.yQuel = 0;
        Det1.zQuel = Det1.h1Q;
        Det1.zH = Det1.DetRadius*sind(Det1.Quelltheta);
        Det1.yH = 0;
        Det1.xH = -(Det1.DetRadius-(Det1.zH*tand(Det1.Quelltheta/2)));
        Det1.det = [Det1.xDet Det1.yDet Det1.zDet];
        Det1.quel = [Det1.xQuel Det1.yQuel Det1.zQuel];
        Det1.Skalar1 = dot(Det1.det, Det1.quel);
        Det1.Norm1 = norm(norm(Det1.det)*norm(Det1.quel));
        Det1.zSV = (Det1.zDet + (Det1.DetRadius * sind(Det1.Quelltheta)))/2;

        if Det1.Quelltheta == Det1.Dettheta
            Det1.g = 0;
        else
            Det1.g = (Det1.zSV - Det1.zDet)/(Det1.zH - Det1.zDet); 
        end

        Det1.ySV = Det1.yDet + Det1.g * (Det1.yH - Det1.yDet);

        if Det1.g == 0
            Det1.xSV = 0;
        else
            Det1.xSV = Det1.xDet + Det1.g * (Det1.xH - Det1.xDet); 
        end

        if MeasurementDet1(j_c).Motors.Chi == 0
            Det1.xOFN = 0;
        else
            Det1.xOFN = -cosd(90 - abs(MeasurementDet1(j_c).Motors.Chi)) * sind(Det1.Omega);
        end

        Det1.yOFN = cosd(90 - abs(MeasurementDet1(j_c).Motors.Chi)) * cosd(Det1.Omega);
        Det1.zOFN = sind(90 - abs(MeasurementDet1(j_c).Motors.Chi));
        Det1.SV = [Det1.xSV Det1.ySV Det1.zSV];
        Det1.OFN = [Det1.xOFN Det1.yOFN Det1.zOFN];
        Det1.Skalar2 = dot(Det1.SV, Det1.OFN);
        Det1.Norm2 = norm(norm(Det1.SV)*norm(Det1.OFN));
        Det1.Skalar3 = dot(Det1.det, Det1.OFN);
        Det1.Norm3 = norm(norm(Det1.det)*norm(Det1.OFN));
        Det1.Skalar4 = dot(Det1.quel, Det1.OFN);
        Det1.Norm4 = norm(norm(Det1.quel)*norm(Det1.OFN));

        % Unterscheidung von Mode 3 (LEDDI-Mode-1) und 4 (LEDDI-Mode-2)
        % noetig, da bei Mode 3, Det1 (rausgefahren), der Winkel Det1_rot = 0
        % ist. Zur Berechnung wird der Winkel Det2_rot benoetigt.
        if Mode == 3
            if MeasurementDet1(j_c).Motors.Det1 == 0
                MeasurementDet1(j_c).twotheta = 2 * abs(MeasurementDet1(j_c).Motors.Det1_rot);
            else
                MeasurementDet1(j_c).twotheta = 2 * asind((1/sqrt(2))*sind(abs(MeasurementDet1(j_c).Motors.Det2_rot)));
            end
            
        elseif Mode == 4
                MeasurementDet1(j_c).twotheta = 180 - acosd(Det1.Skalar1/Det1.Norm1);
        end

        if Mode == 3
            MeasurementDet1(j_c).SCSAngles.psi = acosd(Det1.Skalar2/Det1.Norm2);
        elseif Mode == 4
            MeasurementDet1(j_c).SCSAngles.psi = 60 - MeasurementDet1(j_c).SCSAngles.chi;
        end

        % Berechnung der Strahleinfalls- und ausfallswinkel.    
        if Mode == 3
            MeasurementDet1(j_c).SCSAngles.alpha = asind(sind(abs(MeasurementDet1(j_c).Motors.Det2_rot))*(cosd(abs(MeasurementDet1(j_c).SCSAngles.chi))));

            if MeasurementDet1(j_c).Motors.Det1 == 0
                MeasurementDet1(j_c).SCSAngles.beta = asind(sind(abs(MeasurementDet1(j_c).Motors.Det1_rot))*(cosd(abs(MeasurementDet1(j_c).SCSAngles.chi))));
            else
                MeasurementDet1(j_c).SCSAngles.beta = asind(sind(abs(MeasurementDet1(j_c).Motors.Det2_rot))*(sind(abs(MeasurementDet1(j_c).SCSAngles.chi))));
            end
        end

        if Mode == 4
            MeasurementDet1(j_c).SCSAngles.alpha = asind(sind(MeasurementDet1(j_c).twotheta/2)*(cosd(abs(MeasurementDet1(j_c).SCSAngles.chi)) + ...
            (1/sqrt(3)*sind(abs(MeasurementDet1(j_c).SCSAngles.chi)))));

            MeasurementDet1(j_c).SCSAngles.beta = asind((2/sqrt(3)*sind(MeasurementDet1(j_c).twotheta/2)*sind(abs(MeasurementDet1(j_c).SCSAngles.chi))));
        end

        % Unterscheidung von Mode 3 (LEDDI-Mode-1) und 4 (LEDDI-Mode-2)
        % noetig, da die Grenzen fuer chi bei Mode 3 = 0° und 90° und 
        % fuer Mode 4 = 0° und 60° sind.
        if Mode == 3
            if MeasurementDet1(j_c).Motors.Det1 == 0
                if MeasurementDet1(j_c).SCSAngles.chi == 0
                    MeasurementDet1(j_c).SCSAngles.eta = 90 + Det1.Omega;
                elseif MeasurementDet1(j_c).SCSAngles.chi == 90
                    MeasurementDet1(j_c).SCSAngles.eta = 90 + Det1.Omega;
                else
                    MeasurementDet1(j_c).SCSAngles.eta = acosd((sind(MeasurementDet1(j_c).twotheta ./ 2).*cosd(MeasurementDet1(j_c).SCSAngles.psi) - ...
                        sind(MeasurementDet1(j_c).SCSAngles.alpha)) ./ ...
                        ((cosd(MeasurementDet1(j_c).twotheta ./ 2) .* sind(MeasurementDet1(j_c).SCSAngles.psi))));
                end

                if MeasurementDet1(j_c).SCSAngles.chi < 0 
                    MeasurementDet1(j_c).SCSAngles.phi = 180;
                elseif MeasurementDet1(j_c).SCSAngles.chi >= 0
                    MeasurementDet1(j_c).SCSAngles.phi = 0;
                end

            else
                if MeasurementDet1(j_c).SCSAngles.psi == 0
                    MeasurementDet1(j_c).SCSAngles.eta = 90 + Det1.Omega;
                else
                    MeasurementDet1(j_c).SCSAngles.eta = acosd((sind(MeasurementDet1(j_c).twotheta ./ 2).*cosd(MeasurementDet1(j_c).SCSAngles.psi) - ...
                        sind(MeasurementDet1(j_c).SCSAngles.alpha)) ./ ...
                        ((cosd(MeasurementDet1(j_c).twotheta ./ 2) .* sind(MeasurementDet1(j_c).SCSAngles.psi))));
                end

                % Unterscheidung, ob der Detektor in positiver oder negativer Richtung verfahren wurde 
                if MeasurementDet1(j_c).Motors.Det1 < 0
                    if MeasurementDet1(j_c).SCSAngles.chi <= 44 
                        MeasurementDet1(j_c).SCSAngles.phi = 180;
                    elseif MeasurementDet1(j_c).SCSAngles.chi >= 45
                        MeasurementDet1(j_c).SCSAngles.phi = 0;
                    end
                else    
                    if MeasurementDet1(j_c).SCSAngles.chi >= -44 
                        MeasurementDet1(j_c).SCSAngles.phi = 180;
                    elseif MeasurementDet1(j_c).SCSAngles.chi <= -45
                        MeasurementDet1(j_c).SCSAngles.phi = 0;
                    end
                end    
            end

        elseif Mode == 4
            if MeasurementDet1(j_c).SCSAngles.chi == 0
                MeasurementDet1(j_c).SCSAngles.eta = 90 + Det1.Omega;
            elseif MeasurementDet1(j_c).SCSAngles.chi == 60
                MeasurementDet1(j_c).SCSAngles.eta = 90 + Det1.Omega;
            else
                MeasurementDet1(j_c).SCSAngles.eta = acosd((sind(MeasurementDet1(j_c).twotheta ./ 2).*cosd(MeasurementDet1(j_c).SCSAngles.psi) - ...
                    sind(MeasurementDet1(j_c).SCSAngles.alpha)) ./ ...
                    ((cosd(MeasurementDet1(j_c).twotheta ./ 2) .* sind(MeasurementDet1(j_c).SCSAngles.psi))));
            end

            MeasurementDet1(j_c).SCSAngles.phi = MeasurementDet1(j_c).SCSAngles.phi + 180;
            
        elseif Mode == 5 % Horizontal
            
            MeasurementDet1(j_c).SCSAngles.alpha = sind(MeasurementDet1(j_c).twotheta/2);
            MeasurementDet1(j_c).SCSAngles.beta = sind(MeasurementDet1(j_c).twotheta/2);
%             MeasurementDet1(j_c).SCSAngles.eta = MeasurementDet1(j_c).SCSAngles.eta;        
%             MeasurementDet1(j_c).SCSAngles.phi = MeasurementDet1(j_c).Motors_all.Phi;
%             MeasurementDet1(j_c).SCSAngles.chi = MeasurementDet1(j_c).Motors_all.Chi;
        elseif Mode == 6 % Vertical
            
            MeasurementDet1(j_c).SCSAngles.alpha = sind(MeasurementDet1(j_c).twotheta/2);
            MeasurementDet1(j_c).SCSAngles.beta = sind(MeasurementDet1(j_c).twotheta/2);  
%             MeasurementDet1(j_c).SCSAngles.eta = MeasurementDet1(j_c).SCSAngles.eta;        
%             MeasurementDet1(j_c).SCSAngles.phi = MeasurementDet1(j_c).Motors_all.Phi;
%             MeasurementDet1(j_c).SCSAngles.chi = MeasurementDet1(j_c).Motors_all.Chi;
        end

        if (CorrectRingCurrent),        MeasurementDet1(j_c).CorrectRingCurrent(260);  end
        if (CorrectAbsorption),         MeasurementDet1(j_c).CorrectAbsorption(Mode);  end
        if (CorrectWigglerSpectrum),    MeasurementDet1(j_c).CorrectWigglerSpectrum(Mode);  end

    end
   
    % Measurement from Det2 (Primaerstrahl)
    MeasurementDet2 = Measurement(1:2:end);

    for j_c = 1:length(MeasurementDet2)
        % Define radius, theta and alpha of Det1 and radius and theta of source
        Det2.Dettheta = abs(MeasurementDet2(1).Motors.Det2_rot);
        Det2.Detalpha = 0;
        Det2.DetRadius = MeasurementDet2(1).Motors.radd2;
        Det2.QuellRadius = 360;
        Det2.Quelltheta = abs(MeasurementDet2(1).Motors.Source_rot);
        % Calculations regarding beam path
        Det2.Omega = abs(MeasurementDet2(1).Motors.Omega);
        Det2.h = 2 * Det2.DetRadius * sind(Det2.Dettheta/2);
        Det2.qD = Det2.h * sind(Det2.Dettheta/2);
        Det2.l = 2 * sind(Det2.Detalpha/2) * (Det2.DetRadius - Det2.qD);
        Det2.l1D = sind(Det2.Detalpha) * (Det2.DetRadius - Det2.qD);
        Det2.h1D = Det2.DetRadius * sind(Det2.Dettheta);
        Det2.s = sqrt(Det2.l^2 + Det2.h1D^2);
        Det2.pD = (Det2.DetRadius - Det2.qD) * cosd(Det2.Detalpha);
        Det2.xDet = Det2.pD;
        Det2.yDet = Det2.l1D;
        Det2.zDet = Det2.h1D;
        Det2.hQ = 2 * Det2.QuellRadius * sind(Det2.Quelltheta/2);
        Det2.h1Q = Det2.QuellRadius * sind(Det2.Quelltheta);
        Det2.qQ = Det2.h1Q * tand(Det2.Quelltheta/2);
        Det2.xQuel = -(Det2.QuellRadius-Det2.qQ);
        Det2.yQuel = 0;
        Det2.zQuel = Det2.h1Q;
        Det2.zH = Det2.DetRadius*sind(Det2.Quelltheta);
        Det2.yH = 0;
        Det2.xH = -(Det2.DetRadius-(Det2.zH*tand(Det2.Quelltheta/2)));
        Det2.det = [Det2.xDet Det2.yDet Det2.zDet];
        Det2.quel = [Det2.xQuel Det2.yQuel Det2.zQuel];
        Det2.Skalar1 = dot(Det2.det, Det2.quel);
        Det2.Norm1 = norm(norm(Det2.det)*norm(Det2.quel));
        Det2.zSV = (Det2.zDet + (Det2.DetRadius * sind(Det2.Quelltheta)))/2;

        if Det2.Quelltheta == Det2.Dettheta
            Det2.g = 0;
        else
            Det2.g = (Det2.zSV - Det2.zDet)/(Det2.zH - Det2.zDet); 
        end

        Det2.ySV = Det2.yDet + Det2.g * (Det2.yH - Det2.yDet);

        if Det2.g == 0
            Det2.xSV = 0;
        else
            Det2.xSV = Det2.xDet + Det2.g * (Det2.xH - Det2.xDet); 
        end

        if MeasurementDet2(j_c).Motors.Chi == 0
            Det2.xOFN = 0;
        else
            Det2.xOFN = -cosd(90 - abs(MeasurementDet2(j_c).Motors.Chi)) * sind(Det2.Omega);
        end

        Det2.yOFN = cosd(90 - abs(MeasurementDet2(j_c).Motors.Chi)) * cosd(Det2.Omega);
        Det2.zOFN = sind(90 - abs(MeasurementDet2(j_c).Motors.Chi));
        Det2.SV = [Det2.xSV Det2.ySV Det2.zSV];
        Det2.OFN = [Det2.xOFN Det2.yOFN Det2.zOFN];
        Det2.Skalar2 = dot(Det2.SV, Det2.OFN);
        Det2.Norm2 = norm(norm(Det2.SV)*norm(Det2.OFN));
        Det2.Skalar3 = dot(Det2.det, Det2.OFN);
        Det2.Norm3 = norm(norm(Det2.det)*norm(Det2.OFN));
        Det2.Skalar4 = dot(Det2.quel, Det2.OFN);
        Det2.Norm4 = norm(norm(Det2.quel)*norm(Det2.OFN));

        % Unterscheidung von Mode 3 (LEDDI-Mode-1) und 4 (LEDDI-Mode-2)
        % noetig,da bei Mode 3, Det1 (rausgefahren), der Winkel Det1_rot = 0
        % ist. Zur Berechnung wird der Winkel Det2_rot benoetigt.
        if Mode == 3
            MeasurementDet2(j_c).twotheta = 2 * abs(MeasurementDet2(j_c).Motors.Det2_rot);

        elseif Mode == 4
            MeasurementDet2(j_c).twotheta = 180 - acosd(Det2.Skalar1/Det2.Norm1);
        end

        if Mode == 3
            MeasurementDet2(j_c).SCSAngles.psi = acosd(Det2.Skalar2/Det2.Norm2);
        elseif Mode == 4
            MeasurementDet2(j_c).SCSAngles.psi = acosd(Det2.Skalar2/Det2.Norm2); 
        end

        % Berechnung der Strahleinfalls- und ausfallswinkel.    
        if Mode == 3
            MeasurementDet2(j_c).SCSAngles.alpha = asind(sind(abs(MeasurementDet2(j_c).Motors.Det2_rot))*(cosd(abs(MeasurementDet2(j_c).SCSAngles.chi))));
            MeasurementDet2(j_c).SCSAngles.beta = asind(sind(abs(MeasurementDet2(j_c).Motors.Det2_rot))*(cosd(abs(MeasurementDet2(j_c).SCSAngles.chi))));
        elseif Mode == 4
            MeasurementDet2(j_c).SCSAngles.alpha = asind(sind(MeasurementDet2(j_c).twotheta/2)*(cosd(abs(MeasurementDet2(j_c).SCSAngles.chi)) + ...
                (1/sqrt(3)*sind(abs(MeasurementDet2(j_c).SCSAngles.chi)))));
            MeasurementDet2(j_c).SCSAngles.beta = asind(sind(MeasurementDet2(j_c).twotheta/2)*(cosd(abs(MeasurementDet2(j_c).SCSAngles.chi)) - ...
            (1/sqrt(3)*sind(abs(MeasurementDet2(j_c).SCSAngles.chi)))));
        end

        % Unterscheidung von Mode 3 (LEDDI-Mode-1) und 4 (LEDDI-Mode-2)
        % noetig, da die Grenzen fuer chi bei Mode 3 = 0° und 90° und 
        % fuer Mode 4 = 0° und 60° sind.
        if Mode == 3
            if MeasurementDet2(j_c).SCSAngles.chi == 0
                MeasurementDet2(j_c).SCSAngles.eta = 90 + Det2.Omega;
            elseif MeasurementDet2(j_c).SCSAngles.chi == 90
                MeasurementDet2(j_c).SCSAngles.eta = 90 + Det2.Omega;
            else
                MeasurementDet2(j_c).SCSAngles.eta = acosd((sind(MeasurementDet2(j_c).twotheta ./ 2).*cosd(MeasurementDet2(j_c).SCSAngles.psi) - ...
                    sind(MeasurementDet2(j_c).SCSAngles.alpha)) ./ ...
                    ((cosd(MeasurementDet2(j_c).twotheta ./ 2) .* sind(MeasurementDet2(j_c).SCSAngles.psi))));
            end

            if MeasurementDet2(j_c).SCSAngles.chi < 0 
                MeasurementDet2(j_c).SCSAngles.phi = 180;
            elseif MeasurementDet2(j_c).SCSAngles.chi >= 0
%                 MeasurementDet2(j_c).SCSAngles.phi = MeasurementDet2(j_c).Motors_all.Phi;
                MeasurementDet2(j_c).SCSAngles.phi = 0;
            end

        elseif Mode == 4
            if MeasurementDet2(j_c).SCSAngles.chi == 0
                MeasurementDet2(j_c).SCSAngles.eta = 90 + Det2.Omega;
            elseif MeasurementDet2(j_c).SCSAngles.chi == 60
                MeasurementDet2(j_c).SCSAngles.eta = 90 + Det2.Omega;
            else
                MeasurementDet2(j_c).SCSAngles.eta = acosd((sind(MeasurementDet2(j_c).twotheta ./ 2).*cosd(MeasurementDet2(j_c).SCSAngles.psi) - ...
                    sind(MeasurementDet2(j_c).SCSAngles.alpha)) ./ ...
                    ((cosd(MeasurementDet2(j_c).twotheta ./ 2) .* sind(MeasurementDet2(j_c).SCSAngles.psi))));
            end
        elseif Mode == 5 % Horizontal
            
            MeasurementDet2(j_c).SCSAngles.alpha = sind(MeasurementDet2(j_c).twotheta/2);
            MeasurementDet2(j_c).SCSAngles.beta = sind(MeasurementDet2(j_c).twotheta/2);  
%             MeasurementDet2(j_c).SCSAngles.eta = MeasurementDet2(j_c).SCSAngles.eta;        
%             MeasurementDet2(j_c).SCSAngles.phi = abs(MeasurementDet2(j_c).Motors_all.Phi);
%             MeasurementDet2(j_c).SCSAngles.chi = MeasurementDet2(j_c).Motors_all.Chi;
        elseif Mode == 6 % Vertical
            
            MeasurementDet2(j_c).SCSAngles.alpha = sind(MeasurementDet2(j_c).twotheta/2);
            MeasurementDet2(j_c).SCSAngles.beta = sind(MeasurementDet2(j_c).twotheta/2);  
%             MeasurementDet2(j_c).SCSAngles.eta = MeasurementDet2(j_c).SCSAngles.eta;        
%             MeasurementDet2(j_c).SCSAngles.phi = abs(MeasurementDet2(j_c).Motors_all.Phi);
%             MeasurementDet2(j_c).SCSAngles.chi = MeasurementDet2(j_c).Motors_all.Chi;
        end

    if (CorrectRingCurrent),        MeasurementDet2(j_c).CorrectRingCurrent(260);  end
    if (CorrectAbsorption),         MeasurementDet2(j_c).CorrectAbsorption(Mode);  end
    if (CorrectWigglerSpectrum),    MeasurementDet2(j_c).CorrectWigglerSpectrum(Mode);  end

    end
end
    
    
%         P.Quelltheta = abs(Measurement(j_c).Motors.Source_rot);
%     
%         if P.Det == 2    
%             P.Dettheta = abs(Measurement(1).Motors.Det2_rot);
%             P.Detalpha = 0;
%         else
%             P.Dettheta = abs(Measurement(1).Motors.Det1_rot);
%             P.Detalpha = abs(Measurement(1).Motors.Det1); % eingestellter
% %             Wert Messungen nach dem 01022016
% %             P.Detalpha = abs(Measurement(1).Motors.Det1) - 1; %
% %             eingestellter Wert Messungen vor 01022016
%         end   
%     
%     P.Omega = abs(Measurement(1).Motors.Omega); % Messungen nach dem
% %     01022016
% %     P.Omega = abs(Measurement(1).Motors.Omega - 1.3); % Mesungen vor dem
% %     01022016
%     P.h = 2 * P.DetRadius * sind(P.Dettheta/2);
%     P.qD = P.h * sind(P.Dettheta/2);
%     P.l = 2 * sind(P.Detalpha/2) * (P.DetRadius - P.qD);
%     P.l1D = sind(P.Detalpha) * (P.DetRadius - P.qD);
%     P.h1D = P.DetRadius * sind(P.Dettheta);
%     P.s = sqrt(P.l^2 + P.h1D^2);
%     P.pD = (P.DetRadius - P.qD) * cosd(P.Detalpha);
%     P.xDet = P.pD;
%     P.yDet = P.l1D;
%     P.zDet = P.h1D;
%     P.hQ = 2 * P.QuellRadius * sind(P.Quelltheta/2);
%     P.h1Q = P.QuellRadius * sind(P.Quelltheta);
%     P.qQ = P.h1Q * tand(P.Quelltheta/2);
%     P.xQuel = -(P.QuellRadius-P.qQ);
%     P.yQuel = 0;
%     P.zQuel = P.h1Q;
%     P.zH = P.DetRadius*sind(P.Quelltheta);
%     P.yH = 0;
%     P.xH = -(P.DetRadius-(P.zH*tand(P.Quelltheta/2)));
%     P.det = [P.xDet P.yDet P.zDet];
%     P.quel = [P.xQuel P.yQuel P.zQuel];
%     P.Skalar1 = dot(P.det, P.quel);
%     P.Norm1 = norm(norm(P.det)*norm(P.quel));
%     P.zSV = (P.zDet + (P.DetRadius * sind(P.Quelltheta)))/2;
%     
%     if P.Quelltheta == P.Dettheta,    P.g = 0;
%     else    P.g = (P.zSV - P.zDet)/(P.zH - P.zDet); end
%     
%     P.ySV = P.yDet + P.g * (P.yH - P.yDet);
%    
%     if P.g == 0,    P.xSV = 0;
%     else    P.xSV = P.xDet + P.g * (P.xH - P.xDet); end
%     
%     if Measurement(j_c).Motors.Chi == 0,    P.xOFN = 0;
%     else
%         P.xOFN = -cosd(90 - abs(Measurement(j_c).Motors.Chi)) * sind(P.Omega);
%     end
%     
%     P.yOFN = cosd(90 - abs(Measurement(j_c).Motors.Chi)) * cosd(P.Omega);
%     P.zOFN = sind(90 - abs(Measurement(j_c).Motors.Chi));
%     P.SV = [P.xSV P.ySV P.zSV];
%     P.OFN = [P.xOFN P.yOFN P.zOFN];
%     P.Skalar2 = dot(P.SV, P.OFN);
%     P.Norm2 = norm(norm(P.SV)*norm(P.OFN));
%     P.Skalar3 = dot(P.det, P.OFN);
%     P.Norm3 = norm(norm(P.det)*norm(P.OFN));
%     P.Skalar4 = dot(P.quel, P.OFN);
%     P.Norm4 = norm(norm(P.quel)*norm(P.OFN));
%     
%     % Unterscheidung von Mode 2 (LEDDI-Mode-1) und 3 (LEDDI-Mode-1)
%     % noetig,da bei Mode 2, Det1 (rausgefahren), der Winkel Det1_rot = 0
%     % ist. Zur Berechnung wird der Winkel Det2_rot benoetigt.
%     if Mode == 3
%         if P.Det == 2
%             Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det2_rot);
%         elseif P.Det == 1
%             if Measurement(j_c).Motors.Det1 == 0
%                 Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det1_rot);
%             else
%                 Measurement(j_c).twotheta = 2 * asind((1/sqrt(2))*sind(abs(Measurement(j_c).Motors.Det2_rot)));
%             end
%         end
%     elseif Mode == 4
% %         if P.Det == 2
%             Measurement(j_c).twotheta = 180 - acosd(P.Skalar1/P.Norm1);
% %         elseif P.Det == 1
% %             Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det2_rot);
% %         end
%     end
% 
%     if Mode == 3
%         Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2);
%     elseif Mode == 4
%         if P.Det == 1
% %             if Measurement(j_c).Motors.Det1 == 0
% %                 Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2);
% %             else
%                 Measurement(j_c).SCSAngles.psi = 60 - Measurement(j_c).SCSAngles.chi;
% %             end
%         elseif P.Det == 2
%             Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2); 
%         end
%     end
%     
%     % Berechnung der Strahleinfalls- und ausfallswinkel. Berechnung von
%     % Matthias ist auskommentiert, da es zu Fehlern bei der Berechnung von
%     % alpha und beta kam. Die verwendeten Formeln sind aus dem Skript von
%     % Christoph. Es muss darauf geachtet werden, dass mit dem theta von
%     % Detektor 2 gerechnet werden muss. Daher wird hier Det2_rot verwendet.    
%     if Mode == 3
%             Measurement(j_c).SCSAngles.alpha = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
%         if P.Det == 2
%             Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
%         elseif P.Det == 1
%             if Measurement(j_c).Motors.Det1 == 0
%                 Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det1_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
%             else
%                 Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(sind(abs(Measurement(j_c).SCSAngles.chi))));
%             end
%         end
%     end
% 
%     if Mode == 4
%         Measurement(j_c).SCSAngles.alpha = asind(sind(Measurement(j_c).twotheta/2)*(cosd(abs(Measurement(j_c).SCSAngles.chi)) + ...
%             (1/sqrt(3)*sind(abs(Measurement(j_c).SCSAngles.chi)))));
%         if P.Det == 2
%             Measurement(j_c).SCSAngles.beta = asind(sind(Measurement(j_c).twotheta/2)*(cosd(abs(Measurement(j_c).SCSAngles.chi)) - ...
%             (1/sqrt(3)*sind(abs(Measurement(j_c).SCSAngles.chi)))));
%         elseif P.Det ==1
%             Measurement(j_c).SCSAngles.beta = asind((2/sqrt(3)*sind(Measurement(j_c).twotheta/2)*sind(abs(Measurement(j_c).SCSAngles.chi))));
%         end
%     end
%      
%     % Unterscheidung von Mode 2 (LEDDI-Mode-1) und 3 (LEDDI-Mode-2)
%     % noetig, da die Grenzen fuer chi bei Mode 2 = 0° und 90° und 
%     % fuer Mode 3 = 0° und 60° sind.
%     if Mode == 3
%         if P.Det == 1
%             if Measurement(j_c).Motors.Det1 == 0
%                 if Measurement(j_c).SCSAngles.chi == 0
%                     Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%                 elseif Measurement(j_c).SCSAngles.chi == 90
%                     Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%                 else
%                     Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
%                         sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
%                         ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
%                 end
%                 
%                 if Measurement(j_c).SCSAngles.chi < 0 
%                     Measurement(j_c).SCSAngles.phi = 180;
%                 elseif Measurement(j_c).SCSAngles.chi >= 0
%                     Measurement(j_c).SCSAngles.phi = 0;
%                 end
%                 
%             else
%                 if Measurement(j_c).SCSAngles.psi == 0
%                     Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%                 else
%                     Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
%                         sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
%                         ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
%                 end
%                 
%                 % Unterscheidung, ob der Detektor in positiver oder negativer Richtung verfahren wurde 
%                 if Measurement(j_c).Motors.Det1 < 0
%                     if Measurement(j_c).SCSAngles.chi <= 44 
%                         Measurement(j_c).SCSAngles.phi = 180;
%                     elseif Measurement(j_c).SCSAngles.chi >= 45
%                         Measurement(j_c).SCSAngles.phi = 0;
%                     end
%                 else    
%                     if Measurement(j_c).SCSAngles.chi >= -44 
%                         Measurement(j_c).SCSAngles.phi = 180;
%                     elseif Measurement(j_c).SCSAngles.chi <= -45
%                         Measurement(j_c).SCSAngles.phi = 0;
%                     end
%                 end    
%             end
% %             Measurement(j_c).SCSAngles.phi = 0;
%             
%         elseif P.Det == 2
%             if Measurement(j_c).SCSAngles.chi == 0
%                 Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%             elseif Measurement(j_c).SCSAngles.chi == 90
%                 Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%             else
%                 Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
%                     sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
%                     ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
%             end
% %             Measurement(j_c).SCSAngles.phi = 0;
%             
%             if Measurement(j_c).SCSAngles.chi < 0 
%                 Measurement(j_c).SCSAngles.phi = 180;
%             elseif Measurement(j_c).SCSAngles.chi >= 0
%                 Measurement(j_c).SCSAngles.phi = 0;
%             end
%         end
%         
%     elseif Mode == 4
%         if Measurement(j_c).SCSAngles.chi == 0
%             Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%         elseif Measurement(j_c).SCSAngles.chi == 60
%             Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
%         else
%             Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
%                 sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
%                 ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
%         end
%         
%         if P.Det == 1
%             Measurement(j_c).SCSAngles.phi = Measurement(j_c).SCSAngles.phi + 180;
% %         elseif P.Det == 2
% %             Measurement(j_c).SCSAngles.phi = 0;
%         end
% 
%     end
% 
%     if (CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(Mode);  end
%     if (CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(Mode);  end
%     if (CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(260);  end
%     end
% end

% Save the material parameter for usage with different program 
% (e.g. Rietveld). 
for i = 1:length(Measurement)
    S.Density = Measurement(1).Sample.Materials.MaterialDensity;
    S.DeadTime(:,i) = Measurement(i).DeadTime;
    S.RingCurrent(:,i) = Measurement(i).RingCurrent;
    S.Chi(:,i) = Measurement(i).SCSAngles.chi;
    S.Psi(:,i) = Measurement(i).SCSAngles.psi;
    S.Phi(:,i) = Measurement(i).SCSAngles.phi;
    S.Eta(:,i) = Measurement(i).SCSAngles.eta;
    S.alpha(:,i) = Measurement(i).SCSAngles.alpha;
    S.beta(:,i) = Measurement(i).SCSAngles.beta;
    S.EDSpectrum{i} = Measurement(i).EDSpectrum;
end
% assignin('base','S',S)
% Export the data files.
if (P.SaveToFile)
    save(fullfile(P.Pathdir,P.MaterialParameterFileName), 'S');
end

DataTmp = Measurement;
ResetCurrentMeasData;

if (P.CleanUpTemporaryVariables)
    clear('P');
    clear j_c;
    clear i;
end
disp('corrections performed');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++