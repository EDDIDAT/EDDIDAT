%% (* Correction of the measurements *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Specify which corrections you'd like to perform.
% For synchrotron measurements, all corrections need to be performed.
% For LEDDI measurements the RingCurrent correction must be turned off.
% For Data Preparation all corrections must be turned off ('false')!
P.CorrectAbsorption = true;                                           % <--
P.CorrectWigglerSpectrum = true;                                      % <--
P.CorrectRingCurrent = true;                                          % <--
% Chose the diffractometer that was used for the measurement. This options
% decides which absorption correction has to be applied (only for manual
% fitting, not for Rietveld)
P.Mode = 1;  % <--
% 1 = EDDI Reflection Mode
% 2 = LEDDI_Mode_1
% 3 = LEDDI_Mode_2
% 4 = EDDI Transmission Mode
P.SampleThickness = 1; % in [mm]
P.DeltaTwoTheta = 0.084;
% Note from programmer:
% Bei Messungen vor dem 01.02.2016 muessen die Parameter P.Detalpha und
% P.Omega angepasst werden. Am 01.02.2016 wurden die Referenzwerte des
% Diffraktometers geaendert.
% Specifiy the parameters that are needed to calculate the incidence and
% reflection angles, alpha and beta. For the "EDDI" diffractometer, the
% values have to be set to Zero.
if P.Mode == 1
    P.DetRadius = 0; % EDDI Reflection Mode
    P.QuellRadius = 0; % EDDI Reflection Mode
elseif P.Mode == 4
    P.DetRadius = 0; % EDDI Transmission Mode
    P.QuellRadius = 0; % EDDI Transmission Mode
else
    P.Det = 1; % 1 for Det1 (rausgefahren) and 2 für Det2 (Primaerstrahl)
    P.DetRadius = Measurement(1).Motors.radd1; %Measurement(1).Motors.radd1; % LEDDI
    P.QuellRadius = 360; % LEDDI
end
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
for j_c = 1:length(Measurement)
    if P.Mode == 1
        Measurement(j_c).twotheta = Measurement(j_c).twotheta + P.DeltaTwoTheta;
        if (P.CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(260);  end
        if (P.CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(P.Mode);  end
        if (P.CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(P.Mode);  end
    elseif P.Mode == 4
        set(Measurement, 'SampleThickness', P.SampleThickness);
        Measurement(j_c).twotheta = Measurement(j_c).twotheta + P.DeltaTwoTheta;
        if (P.CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(260);  end
        if (P.CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(P.Mode);  end
        if (P.CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(P.Mode);  end
    else
        P.Quelltheta = abs(Measurement(j_c).Motors.Source_rot);
    
        if P.Det == 2    
            P.Dettheta = abs(Measurement(1).Motors.Det2_rot);
            P.Detalpha = 0;
        else
            P.Dettheta = abs(Measurement(1).Motors.Det1_rot);
            P.Detalpha = abs(Measurement(1).Motors.Det1); % eingestellter
%             Wert Messungen nach dem 01022016
%             P.Detalpha = abs(Measurement(1).Motors.Det1) - 1; %
%             eingestellter Wert Messungen vor 01022016
        end   
    
    P.Omega = abs(Measurement(1).Motors.Omega); % Messungen nach dem
%     01022016
%     P.Omega = abs(Measurement(1).Motors.Omega - 1.3); % Mesungen vor dem
%     01022016
    P.h = 2 * P.DetRadius * sind(P.Dettheta/2);
    P.qD = P.h * sind(P.Dettheta/2);
    P.l = 2 * sind(P.Detalpha/2) * (P.DetRadius - P.qD);
    P.l1D = sind(P.Detalpha) * (P.DetRadius - P.qD);
    P.h1D = P.DetRadius * sind(P.Dettheta);
    P.s = sqrt(P.l^2 + P.h1D^2);
    P.pD = (P.DetRadius - P.qD) * cosd(P.Detalpha);
    P.xDet = P.pD;
    P.yDet = P.l1D;
    P.zDet = P.h1D;
    P.hQ = 2 * P.QuellRadius * sind(P.Quelltheta/2);
    P.h1Q = P.QuellRadius * sind(P.Quelltheta);
    P.qQ = P.h1Q * tand(P.Quelltheta/2);
    P.xQuel = -(P.QuellRadius-P.qQ);
    P.yQuel = 0;
    P.zQuel = P.h1Q;
    P.zH = P.DetRadius*sind(P.Quelltheta);
    P.yH = 0;
    P.xH = -(P.DetRadius-(P.zH*tand(P.Quelltheta/2)));
    P.det = [P.xDet P.yDet P.zDet];
    P.quel = [P.xQuel P.yQuel P.zQuel];
    P.Skalar1 = dot(P.det, P.quel);
    P.Norm1 = norm(norm(P.det)*norm(P.quel));
    P.zSV = (P.zDet + (P.DetRadius * sind(P.Quelltheta)))/2;
    
    if P.Quelltheta == P.Dettheta,    P.g = 0;
    else    P.g = (P.zSV - P.zDet)/(P.zH - P.zDet); end
    
    P.ySV = P.yDet + P.g * (P.yH - P.yDet);
   
    if P.g == 0,    P.xSV = 0;
    else    P.xSV = P.xDet + P.g * (P.xH - P.xDet); end
    
    if Measurement(j_c).Motors.Chi == 0,    P.xOFN = 0;
    else
        P.xOFN = -cosd(90 - abs(Measurement(j_c).Motors.Chi)) * sind(P.Omega);
    end
    
    P.yOFN = cosd(90 - abs(Measurement(j_c).Motors.Chi)) * cosd(P.Omega);
    P.zOFN = sind(90 - abs(Measurement(j_c).Motors.Chi));
    P.SV = [P.xSV P.ySV P.zSV];
    P.OFN = [P.xOFN P.yOFN P.zOFN];
    P.Skalar2 = dot(P.SV, P.OFN);
    P.Norm2 = norm(norm(P.SV)*norm(P.OFN));
    P.Skalar3 = dot(P.det, P.OFN);
    P.Norm3 = norm(norm(P.det)*norm(P.OFN));
    P.Skalar4 = dot(P.quel, P.OFN);
    P.Norm4 = norm(norm(P.quel)*norm(P.OFN));
    
    % Unterscheidung von P.Mode 2 (LEDDI-Mode-1) und 3 (LEDDI-Mode-1)
    % noetig,da bei P.Mode 2, Det1 (rausgefahren), der Winkel Det1_rot = 0
    % ist. Zur Berechnung wird der Winkel Det2_rot benoetigt.
    if P.Mode == 2
        if P.Det == 2
            Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det2_rot);
        elseif P.Det == 1
            if Measurement(j_c).Motors.Det1 == 0
                Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det1_rot);
            else
                Measurement(j_c).twotheta = 2 * asind((1/sqrt(2))*sind(abs(Measurement(j_c).Motors.Det2_rot)));
            end
        end
    elseif P.Mode == 3
%         if P.Det == 2
            Measurement(j_c).twotheta = 180 - acosd(P.Skalar1/P.Norm1);
%         elseif P.Det == 1
%             Measurement(j_c).twotheta = 2 * abs(Measurement(j_c).Motors.Det2_rot);
%         end
    end

    if P.Mode == 2
        Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2);
    elseif P.Mode == 3
        if P.Det == 1
%             if Measurement(j_c).Motors.Det1 == 0
%                 Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2);
%             else
                Measurement(j_c).SCSAngles.psi = 60 - Measurement(j_c).SCSAngles.chi;
%             end
        elseif P.Det == 2
            Measurement(j_c).SCSAngles.psi = acosd(P.Skalar2/P.Norm2); 
        end
    end
    
    % Berechnung der Strahleinfalls- und ausfallswinkel. Berechnung von
    % Matthias ist auskommentiert, da es zu Fehlern bei der Berechnung von
    % alpha und beta kam. Die verwendeten Formeln sind aus dem Skript von
    % Christoph. Es muss darauf geachtet werden, dass mit dem theta von
    % Detektor 2 gerechnet werden muss. Daher wird hier Det2_rot verwendet.    
    if P.Mode == 2
            Measurement(j_c).SCSAngles.alpha = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
        if P.Det == 2
            Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
        elseif P.Det == 1
            if Measurement(j_c).Motors.Det1 == 0
                Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det1_rot))*(cosd(abs(Measurement(j_c).SCSAngles.chi))));
            else
                Measurement(j_c).SCSAngles.beta = asind(sind(abs(Measurement(j_c).Motors.Det2_rot))*(sind(abs(Measurement(j_c).SCSAngles.chi))));
            end
        end
    end

    if P.Mode == 3
        Measurement(j_c).SCSAngles.alpha = asind(sind(Measurement(j_c).twotheta/2)*(cosd(abs(Measurement(j_c).SCSAngles.chi)) + ...
            (1/sqrt(3)*sind(abs(Measurement(j_c).SCSAngles.chi)))));
        if P.Det == 2
            Measurement(j_c).SCSAngles.beta = asind(sind(Measurement(j_c).twotheta/2)*(cosd(abs(Measurement(j_c).SCSAngles.chi)) - ...
            (1/sqrt(3)*sind(abs(Measurement(j_c).SCSAngles.chi)))));
        elseif P.Det ==1
            Measurement(j_c).SCSAngles.beta = asind((2/sqrt(3)*sind(Measurement(j_c).twotheta/2)*sind(abs(Measurement(j_c).SCSAngles.chi))));
        end
    end
     
    % Unterscheidung von P.Mode 2 (LEDDI-Mode-1) und 3 (LEDDI-Mode-2)
    % noetig, da die Grenzen fuer chi bei P.Mode 2 = 0° und 90° und 
    % fuer P.Mode 3 = 0° und 60° sind.
    if P.Mode == 2
        if P.Det == 1
            if Measurement(j_c).Motors.Det1 == 0
                if Measurement(j_c).SCSAngles.chi == 0
                    Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
                elseif Measurement(j_c).SCSAngles.chi == 90
                    Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
                else
                    Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
                        sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
                        ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
                end
                
                if Measurement(j_c).SCSAngles.chi < 0 
                    Measurement(j_c).SCSAngles.phi = 180;
                elseif Measurement(j_c).SCSAngles.chi >= 0
                    Measurement(j_c).SCSAngles.phi = 0;
                end
                
            else
                if Measurement(j_c).SCSAngles.psi == 0
                    Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
                else
                    Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
                        sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
                        ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
                end
                
                % Unterscheidung, ob der Detektor in positiver oder negativer Richtung verfahren wurde 
                if Measurement(j_c).Motors.Det1 < 0
                    if Measurement(j_c).SCSAngles.chi <= 44 
                        Measurement(j_c).SCSAngles.phi = 180;
                    elseif Measurement(j_c).SCSAngles.chi >= 45
                        Measurement(j_c).SCSAngles.phi = 0;
                    end
                else    
                    if Measurement(j_c).SCSAngles.chi >= -44 
                        Measurement(j_c).SCSAngles.phi = 180;
                    elseif Measurement(j_c).SCSAngles.chi <= -45
                        Measurement(j_c).SCSAngles.phi = 0;
                    end
                end    
            end
%             Measurement(j_c).SCSAngles.phi = 0;
            
        elseif P.Det == 2
            if Measurement(j_c).SCSAngles.chi == 0
                Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
            elseif Measurement(j_c).SCSAngles.chi == 90
                Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
            else
                Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
                    sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
                    ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
            end
%             Measurement(j_c).SCSAngles.phi = 0;
            
            if Measurement(j_c).SCSAngles.chi < 0 
                Measurement(j_c).SCSAngles.phi = 180;
            elseif Measurement(j_c).SCSAngles.chi >= 0
                Measurement(j_c).SCSAngles.phi = 0;
            end
        end
        
    elseif P.Mode == 3
        if Measurement(j_c).SCSAngles.chi == 0
            Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
        elseif Measurement(j_c).SCSAngles.chi == 60
            Measurement(j_c).SCSAngles.eta = 90 + P.Omega;
        else
            Measurement(j_c).SCSAngles.eta = acosd((sind(Measurement(j_c).twotheta ./ 2).*cosd(Measurement(j_c).SCSAngles.psi) - ...
                sind(Measurement(j_c).SCSAngles.alpha)) ./ ...
                ((cosd(Measurement(j_c).twotheta ./ 2) .* sind(Measurement(j_c).SCSAngles.psi))));
        end
        
        if P.Det == 1
            Measurement(j_c).SCSAngles.phi = Measurement(j_c).SCSAngles.phi + 180;
%         elseif P.Det == 2
%             Measurement(j_c).SCSAngles.phi = 0;
        end

    end

    if (P.CorrectAbsorption),         Measurement(j_c).CorrectAbsorption(P.Mode);  end
    if (P.CorrectWigglerSpectrum),    Measurement(j_c).CorrectWigglerSpectrum(P.Mode);  end
    if (P.CorrectRingCurrent),        Measurement(j_c).CorrectRingCurrent(259);  end
    end
end

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
% Export the data files.
if (P.SaveToFile)
    save(fullfile(P.Pathdir,P.MaterialParameterFileName), 'S');
end

ResetCurrentMeasData;

if (P.CleanUpTemporaryVariables)
    clear('P');
    clear j_c;
    clear i;
end
disp('corrections performed');
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++