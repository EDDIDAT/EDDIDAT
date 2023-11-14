function [func,funcz,FitParams] = UPlotFitFunctions(h,FitData,StressComponent)
%UNTITLED2 Summary of this function goes here
% Polynomial fit functions for stress distributions
    % Sigma11 and sigma22
    % Damped polynomials
    % Laplace space 'tau'
    polydeg0 = @(a,x) a(1)./((1./x+a(2)).*x);
    polydeg1 = @(a,x) (a(1)./(1./x+a(3)) + a(2)./(1./x+a(3)).^2)./x;
    polydeg2 = @(a,x) (a(1)./(1./x+a(4)) + a(2)./(1./x+a(4)).^2 + 2.*a(3)./(1./x+a(4)).^3)./x;
    polydeg3 = @(a,x) (a(1)./(1./x+a(5)) + a(2)./(1./x+a(5)).^2 + 2.*a(3)./(1./x+a(5)).^3 + 6.*a(4)./(1./x+a(5)).^4)./x;
    polydeg4 = @(a,x) (a(1)./(1./x+a(6)) + a(2)./(1./x+a(6)).^2 + 2.*a(3)./(1./x+a(6)).^3 + 6.*a(4)./(1./x+a(6)).^4 + 24.*a(5)./(1./x+a(6)).^5)./x;
    polydeg5 = @(a,x) (a(1)./(1./x+a(7)) + a(2)./(1./x+a(7)).^2 + 2.*a(3)./(1./x+a(7)).^3 + 6.*a(4)./(1./x+a(7)).^4 + 24.*a(5)./(1./x+a(7)).^5 + 120.*a(6)./(1./x+a(7)).^6)./x;
    % Real space 'z'
    polydeg0z = @(a,x) a(1).*exp(-a(2).*x);
    polydeg1z = @(a,x) (a(1) + a(2).*x).*exp(-a(3).*x);
    polydeg2z = @(a,x) (a(1) + a(2).*x + (a(3)./2).*x.^2).*exp(-a(4).*x);
    polydeg3z = @(a,x) (a(1) + a(2).*x + (a(3)./2).*x.^2 + (a(4)./6).*x.^3).*exp(-a(5).*x);
    polydeg4z = @(a,x) (a(1) + a(2).*x + (a(3)./2).*x.^2 + (a(4)./6).*x.^3 + (a(5)./24).*x.^4).*exp(-a(6).*x);
    polydeg5z = @(a,x) (a(1) + a(2).*x + (a(3)./2).*x.^2 + (a(4)./6).*x.^3 + (a(5)./24).*x.^4 + (a(6)./120).*x.^5).*exp(-a(7).*x);

    % not damped polynomials
    % Laplace space 'tau'
    nodamppoly1 = @(a,x) a(1) + a(2).*x;
    nodamppoly2 = @(a,x) a(1) + a(2).*x + a(3).*x.^2;
    nodamppoly3 = @(a,x) a(1) + a(2).*x + a(3).*x.^2 + a(4).*x.^3;
    nodamppoly4 = @(a,x) a(1) + a(2).*x + a(3).*x.^2 + a(4).*x.^3 + a(5).*x.^4;
    nodamppoly5 = @(a,x) a(1) + a(2).*x + a(3).*x.^2 + a(4).*x.^3 + a(5).*x.^4 + a(6).*x.^5;
    % Real space 'z'
    nodamppoly1z = @(a,x) a(1) + a(2).*x;
    nodamppoly2z = @(a,x) a(1) + a(2).*x + a(3)./2.*x.^2;
    nodamppoly3z = @(a,x) a(1) + a(2).*x + a(3)./2.*x.^2 + a(4)./6.*x.^3;
    nodamppoly4z = @(a,x) a(1) + a(2).*x + a(3)./2.*x.^2 + a(4)./6.*x.^3 + a(5)./24.*x.^4;
    nodamppoly5z = @(a,x) a(1) + a(2).*x + a(3)./2.*x.^2 + a(4)./6.*x.^3 + a(5)./24.*x.^4 + a(6)./120.*x.^5;
    
    % Sigma13 aznd sigma23
    % Damped polynomials
    % Laplace space 'tau'
    polydeg1ij = @(a,x) a(1)./(x.*(1./x+a(2)).^2);
    polydeg2ij = @(a,x) ((2.*a(2))./(1./x+a(3)).^3 + a(1)./(1./x+a(3)).^2)./x;
    polydeg3ij = @(a,x) (6.*a(3)./(1./x+a(4)).^4 + 2.*a(2)./(1./x+a(4)).^3 + a(1)./(1./x+a(4)).^2)./x;
    polydeg4ij = @(a,x) (24.*a(4)./(1./x+a(5)).^5 + 6.*a(3)./(1./x+a(5)).^4 + 2.*a(2)./(1./x+a(5)).^3 + a(1)./(1./x+a(5)).^2)./x;
    polydeg5ij = @(a,x) (120.*a(5)./(1./x+a(6)).^5 + 24.*a(4)./(1./x+a(6)).^5 + 6.*a(3)./(1./x+a(6)).^4 + 2.*a(2)./(1./x+a(6)).^3 + a(1)./(1./x+a(6)).^2)./x;
    % Real space 'z'
    polydeg1ijz = @(a,x) a(1).*x.*exp(-a(2).*x);
    polydeg2ijz = @(a,x) (a(1).*x + (a(2)./2).*x.^2).*exp(-a(3).*x);
    polydeg3ijz = @(a,x) (a(1).*x + (a(2)./2).*x.^2 + (a(3)./6).*x.^3).*exp(-a(4).*x);
    polydeg4ijz = @(a,x) (a(1).*x + (a(2)./2).*x.^2 + (a(3)./6).*x.^3 + (a(4)./24).*x.^4).*exp(-a(5).*x);
    polydeg5ijz = @(a,x) (a(1).*x + (a(2)./2).*x.^2 + (a(3)./6).*x.^3 + (a(4)./24).*x.^4 + (a(5)./120).*x.^5).*exp(-a(6).*x);
    
    % Not damped polynomials
    % Laplace space 'tau'
    nodamppoly1ij = @(a,x) a(1).*x;
    nodamppoly2ij = @(a,x) a(1).*x + a(2).*x.^2;
    nodamppoly3ij = @(a,x) a(1).*x + a(2).*x.^2 + a(3).*x.^3;
    nodamppoly4ij = @(a,x) a(1).*x + a(2).*x.^2 + a(3).*x.^3 + a(4).*x.^4;
    nodamppoly5ij = @(a,x) a(1).*x + a(2).*x.^2 + a(3).*x.^3 + a(4).*x.^4 + a(5).*x.^5;
    % Real space 'z'
    nodamppoly1ijz = @(a,x) a(1).*x;
    nodamppoly2ijz = @(a,x) a(1).*x + a(2)./2.*x.^2;
    nodamppoly3ijz = @(a,x) a(1).*x + a(2)./2.*x.^2 + a(3)./6.*x.^3;
    nodamppoly4ijz = @(a,x) a(1).*x + a(2)./2.*x.^2 + a(3)./6.*x.^3 + a(4)./24.*x.^4;
    nodamppoly5ijz = @(a,x) a(1).*x + a(2)./2.*x.^2 + a(3)./6.*x.^3 + a(4)./24.*x.^4 + a(5)./120.*x.^5;
    
    % Get degree of polynomial and damping decision
    polydegsigma11 = str2double(get(h.editdegree1,'String'));
    dampingsigma11 = get(h.dampingcheckbox1,'Value');

    polydegsigma22 = str2double(get(h.editdegree2,'String'));
    dampingsigma22 = get(h.dampingcheckbox2,'Value');

    polydegsigma13 = str2double(get(h.editdegree3,'String'));
    dampingsigma13 = get(h.dampingcheckbox3,'Value');

    polydegsigma23 = str2double(get(h.editdegree4,'String'));
    dampingsigma23 = get(h.dampingcheckbox4,'Value');

    % Fit stress data using polynomials
    % Get start params for fitting
    PolyDegSigma = [polydegsigma11; polydegsigma22; polydegsigma13; polydegsigma23];
    DampSigma = [dampingsigma11; dampingsigma22; dampingsigma13; dampingsigma23];
    
    Startparams = FitData(1,2);
    
    if StressComponent == 1 || StressComponent == 2
        if PolyDegSigma(StressComponent) == 0
            if DampSigma(StressComponent) == 0
                % Warning message that deg must be >= 1
                warndlg('Polynomial degree should be >= 1 if damping is unwanted.','Warning')
                func = nodamppoly1;
                funcz = nodamppoly1z;
                FitParams = [Startparams, Startparams/10];
            else
                func = polydeg0;
                funcz = polydeg0z;
                FitParams = [Startparams, 0.1];
            end

        elseif PolyDegSigma(StressComponent) == 1
            if DampSigma(StressComponent) == 0
                func = nodamppoly1;
                funcz = nodamppoly1z;
                FitParams = [Startparams, Startparams/10];
            else
                func = polydeg1;
                funcz = polydeg1z;
                FitParams = [Startparams, Startparams/10, 0.1];
            end

        elseif PolyDegSigma(StressComponent) == 2
            if DampSigma(StressComponent) == 0
                func = nodamppoly2;
                funcz = nodamppoly2z;
                FitParams = [Startparams, Startparams/10, Startparams/100];
            else
                func = polydeg2;
                funcz = polydeg2z;
                FitParams = [Startparams, Startparams/10, Startparams/100, 0.1];
            end

        elseif PolyDegSigma(StressComponent) == 3
            if DampSigma(StressComponent) == 0
                func = nodamppoly3;
                funcz = nodamppoly3z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000];
            else
                func = polydeg3;
                funcz = polydeg3z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, 0.1];
            end

        elseif PolyDegSigma(StressComponent) == 4
            if DampSigma(StressComponent) == 0
                func = nodamppoly4;
                funcz = nodamppoly4z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000];
            else
                func = polydeg4;
                funcz = polydeg4z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000, 0.1];
            end

        elseif PolyDegSigma(StressComponent) == 5
            if DampSigma(StressComponent) == 0
                func = nodamppoly5;
                funcz = nodamppoly5z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000, Startparams/100000];
            else
                func = polydeg5;
                funcz = polydeg5z;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000, Startparams/100000, 0.1];
            end

        end
    elseif StressComponent == 3 ||StressComponent == 4
        if PolyDegSigma(StressComponent) == 0
            % Warning message that deg must be >= 1
            warndlg('Polynomial degree should be >= 1.','Warning')
            if DampSigma(StressComponent) == 0
                func = nodamppoly1ij;
                funcz = nodamppoly1ijz;
                FitParams = Startparams;
            else
                func = polydeg1ij;
                funcz = polydeg1ijz;
                FitParams = [Startparams, 0.1];
            end   
        elseif PolyDegSigma(StressComponent) == 1
            if DampSigma(StressComponent) == 0
                func = nodamppoly1ij;
                funcz = nodamppoly1ijz;
                FitParams = [Startparams];
            else
                func = polydeg1ij;
                funcz = polydeg1ijz;
                FitParams = [Startparams, 0.1];
            end
        elseif PolyDegSigma(StressComponent) == 2
            if DampSigma(StressComponent) == 0
                func = nodamppoly2ij;
                funcz = nodamppoly2ijz;
                FitParams = [Startparams, Startparams/10];
            else
                func = polydeg2ij;
                funcz = polydeg2ijz;
                FitParams = [Startparams, Startparams/10, 0.1];
            end  
        elseif PolyDegSigma(StressComponent) == 3
            if DampSigma(StressComponent) == 0
                func = nodamppoly3ij;
                funcz = nodamppoly3ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100];
            else
                func = polydeg3ij;
                funcz = polydeg3ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100, 0.1];
            end   
        elseif PolyDegSigma(StressComponent) == 4
            if DampSigma(StressComponent) == 0
                func = nodamppoly4ij;
                funcz = nodamppoly4ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000];
            else
                func = polydeg4ij;
                funcz = polydeg4ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, 0.1];
            end
        elseif PolyDegSigma(StressComponent) == 5
            if DampSigma(StressComponent) == 0
                func = nodamppoly5ij;
                funcz = nodamppoly5ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000];
            else
                func = polydeg5ij;
                funcz = polydeg5ijz;
                FitParams = [Startparams, Startparams/10, Startparams/100, Startparams/1000, Startparams/10000, 0.1];
            end   
        end
    end
end

