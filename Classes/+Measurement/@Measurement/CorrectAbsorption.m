% Korrigiert das Spektrum gegen die Absorption. Bis jetzt nur fuer ein 
% Material und nicht Schichtsysteme.
% Input: none
% Output: obj, korrigiertes Objekt, Measurement
function obj = CorrectAbsorption(obj,Mode,Diffsel)
    %% (* Stringenzprüfung *)
    validateattributes(Mode,{'double'},...
        {'finite','real','scalar','positive'})
    Modus = Mode;
    % Korrektur benutzt zunaechst NUR den LAK des ersten Materials der Probe
    if strcmp(Diffsel,'ETA3000')
        
        twotheta = obj.EDSpectrum(:,1);
        psi = obj.Motors.Chi;
        eta = 90;
        Anode = obj.Anode;
        
        if strcmp(Anode,'Cu')
            lambdaka1 = 1.54056;
%             lambdaka2 = 1.54433;
        elseif strcmp(Anode,'Co')
            lambdaka1 = 1.78897;
%             lambdaka2 = 1.79278;
        elseif strcmp(Anode,'Ag')
            lambdaka1 = 0.55941;
%             lambdaka2 = 0.56380;
        elseif strcmp(Anode,'Fe')
            lambdaka1 = 1.93579;
%             lambdaka2 = 1.93991;
        elseif strcmp(Anode,'Mo')
            lambdaka1 = 0.70926;
%             lambdaka2 = 0.71354;
        elseif strcmp(Anode,'Cr')    
            lambdaka1 = 2.28962;
%             lambdaka2 = 2.29351;
        end

        ordzahlsum = obj.Sample.Materials.ChemicalElements.AtomicNumber;
        materialdichte = obj.Sample.Materials.ChemicalElements.MassDensity;
        atgewichtsum = obj.Sample.Materials.ChemicalElements.AtomicMass;
        cgsfactor = (2.701*10^10.*ordzahlsum.*(materialdichte./atgewichtsum*10^-14));
        delta = cgsfactor.*(lambdaka1)^2;

        alpha = asind(sind(twotheta/2)*cosd(psi) - cosd(twotheta/2)*sind(psi)*cosd(eta));
        beta = asind(sind(twotheta/2)*cosd(psi) + cosd(twotheta/2)*sind(psi)*cosd(eta));
        
        epsilonalpha = (delta*cotd(alpha));
        epsilonbeta = (delta*cotd(beta));
        
        sinalphawahr = sind(alpha - epsilonalpha);
        sinbetawahr = sind(beta - epsilonbeta);
        
        zweithetawahr = acosd(((cosd(alpha-epsilonalpha)) .* ...
                        cosd(beta-epsilonbeta)) ./ ...
                        (cosd(alpha).*cosd(beta)) .* ...
                        (cosd(twotheta) + sind(alpha).*sind(beta)) - sind(alpha - epsilonalpha) .* ...
                        sind(beta - epsilonbeta));
        
        apglfaktor = (1+cosd(zweithetawahr).^2)./(8.*sind(twotheta./2).*sind(zweithetawahr))./(((1./sinalphawahr)+(1./sinbetawahr)).*sinalphawahr);

        obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./apglfaktor;
    else
        if Modus == 1 % Reflection
    %         obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./ ...
    %             ((1 ./ obj.Sample.Materials(1).LAC(obj.EDSpectrum(:,1))) .* ...
    %             sind(obj.SCSAngles.beta) ./ (sind(obj.SCSAngles.alpha)+sind(obj.SCSAngles.beta)));
            obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./ ...
                ((0.5 ./ obj.Sample.Materials(1).LAC(obj.EDSpectrum(:,1))) .* ...
                (1 + tand(obj.SCSAngles.psi) * cotd(obj.twotheta / 2) * ...
                cosd(obj.SCSAngles.eta)));
        elseif Modus == 2 % Transmission
            obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./ ...
                exp(-obj.Sample.Materials(1).LAC(obj.EDSpectrum(:,1)).* ... 
                (obj.SampleThickness./1000).*cosd(obj.twotheta / 2));
        else
            if obj.SCSAngles.beta == 0
                obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2);
            else
                obj.EDSpectrum(:,2) = obj.EDSpectrum(:,2) ./ ...
			    (sind(abs(obj.SCSAngles.beta)) ./ (obj.Sample.Materials(1).LAC(obj.EDSpectrum(:,1)) .* ...
			    (sind(obj.SCSAngles.alpha) + sind(abs(obj.SCSAngles.beta)))));
            end
        end
    end
end