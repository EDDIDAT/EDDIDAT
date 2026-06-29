% delta-Gamma from pyFAI multigeometry script
dGamma = 0.494;

% Gamma-Range ueber die Aufsummiert werden soll (Bins in dGamma)
opts.trackChiAvgBins = 4;

% Schrittweite zwischen zwei Profilzentren (Bins in dGamma)
opts.trackChiBin = 4;

profileWidthDeg = (2*opts.trackChiAvgBins + 1) * dGamma;
stepWidthDeg = opts.trackChiBin * dGamma;

fprintf('Gamma-Binbreite: %.3f°\n', dGamma);
fprintf('Breite jedes 1D-Profils: %.3f°\n', profileWidthDeg);
fprintf('Schrittweite zwischen zwei Profilzentren: %.3f°\n', stepWidthDeg);