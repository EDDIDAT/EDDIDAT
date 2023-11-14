function Y = GaussPlot(X,E,Intensity,FWHM)
    Y = 0;
    for i = 1:size(Intensity, 2)
        X_shift = X - E(i);
        Y = Y + Intensity(i)/100 * (2.*sqrt(log(2)./pi)./FWHM(i)) * ...
            exp(-4 * log(2) * (X_shift/FWHM(i)).^2);
    end
end

