% Bild in MATLAB importieren
% img = imread('stitched_left_alpha06-caked.tif');
img = imread('stitched_left_alpha06.tif');

% Falls das Bild RGB ist:
if ndims(img) == 3
    img = rgb2gray(img);
end

% In Double umwandeln (empfohlen für Plot & Skalierung):
img = double(img);

% Achsenvektoren erzeugen
nx = size(img,2);   % x = Spalten
ny = size(img,1);   % y = Zeilen

twoTheta = linspace(0.7281, 54.0832, nx);
gamma    = linspace(-89.08, 85.55, ny);

% 2D-Plot (empfohlen: imagesc)
figure
imagesc(twoTheta, gamma, img)
set(gca,'YDir','normal')   % wichtig für physikalisch richtige Orientierung

xlabel('2\theta (°)')
ylabel('\gamma (°)')
colorbar
title('2D Röntgendetektor – Intensität')

% Alternative: echte 2D-Fläche (surf)
[TT, GG] = meshgrid(twoTheta, gamma);

figure
surf(TT, GG, img, 'EdgeColor','none')
view(2)
axis tight
colorbar

xlabel('2\theta (°)')
ylabel('\gamma (°)')

% Typische Extras (sehr nützlich)
% logarithmische Intensität
imagesc(twoTheta, gamma, log10(img + 1))
colorbar

% Kontrast automatisch anpassen
imagesc(twoTheta, gamma, img)
caxis(prctile(img(:),[1 99]))

% Vertikalen Schnitt bei festem 2θ
[~,idx] = min(abs(twoTheta - 20)); % 20°
figure
plot(gamma, img(:,idx))
xlabel('\gamma (°)')
ylabel('Intensität')

% Merksatz (wichtig)
% Detektorbilder immer zuerst in physikalische Koordinaten transformieren,
% dann plotten – nie umgekehrt.

% Die Hintergrundsubtraktion vor der γ-Integration ist entscheidend für 
% saubere 1D-Diffraktogramme
% Methode 1: Methode 1: Konstanter Hintergrund (schnell & einfach)
bg = median(img(:));   % robuster als mean
img_corr = img - bg;
img_corr(img_corr < 0) = 0;

% Methode 2: γ-abhängiger Hintergrund (sehr häufig!)
bg = prctile(img, 10, 1);    % 10%-Quantil entlang γ
img_corr = img - bg;        % MATLAB broadcastet automatisch
img_corr(img_corr < 0) = 0;

% Methode 3: Glatter 2D-Hintergrund (professionell)
img_smooth = imgaussfilt(img, [30 5]);   % (γ, 2θ)
img_corr = img - img_smooth;
img_corr(img_corr < 0) = 0;

% Danach: Integration über γ (immer gleich)
I_2theta = trapz(gamma, img_corr, 1);

% Plot: Vergleich roh vs. korrigiert
figure
plot(twoTheta, trapz(gamma,img,1), 'k--', 'DisplayName','roh')
hold on
plot(twoTheta, I_2theta, 'r', 'LineWidth',1.5, 'DisplayName','hintergrundkorr.')
hold off

xlabel('2\theta (°)')
ylabel('Intensität')
legend
grid on


% Ringweise Integration
% Vorbereitung: Achsen korrekt definieren

% Detektorgröße
N = 1000;

% Achsen
twoTheta = linspace(0.7281, 54.0832, N);   % x-Achse
gamma    = linspace(-89.08, 85.55, N);     % y-Achse

% Bild einlesen:
img = double(imread('stitched_left_alpha06-caked.tif'));

% Hintergrundsubtraktion (empfohlen)
% γ-abhängiger Hintergrund (Standard!)
bg = prctile(img, 10, 1);     % 10%-Quantil über γ
img_corr = img - bg;
img_corr(img_corr < 0) = 0;

% Ringweise Integration (Kernschritt)
I_2theta = trapz(gamma, img_corr, 1);

% Ergebnis plotten (klassisches Diffraktogramm)
figure
plot(twoTheta, I_2theta, 'k', 'LineWidth',1.5)
xlabel('2\theta (°)')
ylabel('Intensität (ringintegriert)')
grid on

% Häufig extrem sinnvoll: begrenzter γ-Bereich
gammaRange = [-33 43];
mask = gamma >= gammaRange(1) & gamma <= gammaRange(2);

I_2theta = trapz(gamma(mask), img_corr(mask,:), 1);

% Normierung auf effektive Ringlänge
% Sehr wichtig bei Masken oder Detektorlücken:
nEff = sum(mask);    % Anzahl gültiger γ-Pixel
I_2theta_norm = I_2theta / nEff;

% Oder kontinuierlich korrekt:
I_2theta_norm = I_2theta / trapz(gamma(mask), ones(sum(mask),1));

% Fehlerabschätzung (optional, aber professionell)
% Poisson-Statistik:
sigma = sqrt(trapz(gamma(mask), img_corr(mask,:), 1));

% Plot mit Fehler
errorbar(twoTheta, I_2theta_norm, sigma, '.')


%% azimutale (γ-abhängige) Auswertung einzelner Peaks
% Peak-Bereich in 2θ definieren
twoTheta0 = 38.5;     % Peakzentrum (Grad)
dTT = 0.5;            % Halbbreite

ttMask = twoTheta >= (twoTheta0 - dTT) & ...
         twoTheta <= (twoTheta0 + dTT);

% Hintergrundsubtraktion (Pflicht!)
% 2θ-abhängiger Hintergrund (empfohlen)
bg = prctile(img, 10, 2);      % 10%-Quantil über 2θ
img_corr = img - bg;
img_corr(img_corr < 0) = 0;

% Azimutale Integration (Kernschritt)
I_gamma = trapz(twoTheta(ttMask), img_corr(:,ttMask), 2);

% Plot: Azimutale Intensitätsverteilung
figure
plot(gamma, I_gamma, 'LineWidth',1.5)
xlabel('\gamma (°)')
ylabel('Intensität')
title(sprintf('Azimutale Intensität bei 2\\theta = %.2f°', twoTheta0))
grid on

% Typische Erweiterungen (sehr wichtig!)
% A) γ-Bereich einschränken
gammaRange = [-60 60];
gMask = gamma >= gammaRange(1) & gamma <= gammaRange(2);

gamma_sel = gamma(gMask);
I_gamma = I_gamma(gMask);

% B) Normierung auf Peakbreite
I_gamma = I_gamma / trapz(twoTheta(ttMask), ones(sum(ttMask),1));

% C) Glättung (optional)
I_gamma_smooth = smoothdata(I_gamma, 'sgolay', 11);

% Visuale Kontrolle im 2D-Bild (empfohlen!)
figure
% imagesc(twoTheta, gamma, img_corr)
% imagesc(twoTheta, gamma, log10(img_corr + 1))
imagesc(twoTheta, gamma, img_corr)
caxis(prctile(img(:),[1 99]))
axis xy
colormap hot
colorbar
hold on
xline(twoTheta0-dTT,'c--')
xline(twoTheta0+dTT,'c--')
hold off

% Fehlerabschätzung (Poisson)
sigma_gamma = sqrt(trapz(twoTheta(ttMask), img_corr(:,ttMask), 2));

%% Ansatz A: γ-Binning + 1D-Peakfits (Standard, robust)
% γ-Binning
gammaEdges = -80:5:80;   % Binbreite 5°
gammaCenters = (gammaEdges(1:end-1)+gammaEdges(2:end))/2;

% Integration pro γ-Bin
twoTheta0 = 38.5;
dTT = 0.5;
ttMask = twoTheta > twoTheta0-dTT & twoTheta < twoTheta0+dTT;

peakPos = nan(numel(gammaCenters),1);

for i = 1:numel(gammaCenters)
    gMask = gamma >= gammaEdges(i) & gamma < gammaEdges(i+1);
    if sum(gMask) < 5, continue, end

    prof = trapz(gamma(gMask), img_corr(gMask,ttMask), 1);

    % Peak-Fit (Gauss)
    ft = fit(twoTheta(ttMask)', prof', 'gauss1');
    peakPos(i) = ft.b1;   % Peakzentrum
end

% Ergebnis plotten
figure
plot(gammaCenters, peakPos, 'o-')
xlabel('\gamma (°)')
ylabel('2\theta_{Peak} (°)')
grid on

% Ansatz B: Direkter 2D-Fit des Rings (fortgeschritten & elegant)
% Prinzip
% Der Ring ist eine Kurve im 2D-Bild:
% 2θ(γ)=2θ_0​+Asin²(γ−γ0​)
% Man fittet direkt die Ringposition ohne Integration.

% Methode B1: Maxima-Tracking (sehr praktikabel) 
% Peakposition pro γ-Zeile bestimmen
ttRange = twoTheta > twoTheta0-dTT & twoTheta < twoTheta0+dTT;
thetaSub = twoTheta(ttRange);   % 1×N Vektor vorbereiten

thetaPeak = nan(size(gamma));

for i = 1:length(gamma)

    line = img_corr(i, ttRange);

    if max(line) < 5        % Schwellwert gegen Rauschen
        continue
    end

    [~, idx] = max(line);   % Peakposition im Teilbereich
    thetaPeak(i) = thetaSub(idx);

end

[~, idx] = max(line);

if idx > 1 && idx < length(line)
    p = polyfit(thetaSub(idx-1:idx+1), line(idx-1:idx+1), 2);
    thetaPeak(i) = -p(2)/(2*p(1));   % Parabelmaximum
else
    thetaPeak(i) = thetaSub(idx);
end

% Ausreißer entfernen
thetaPeak = filloutliers(thetaPeak, 'linear', 'movmedian', 11);

% Glätten für Visualisierung
thetaSmooth = smoothdata(thetaPeak, 'sgolay', 21);

% Kontrolle im 2D-Bild (sehr empfohlen!)
figure
imagesc(twoTheta, gamma, img_corr)
axis xy
colormap hot
hold on
plot(thetaSmooth, gamma, 'c', 'LineWidth',2)
hold off
xlabel('2\theta (°)')
ylabel('\gamma (°)')





% Glätten & Fit
valid = ~isnan(thetaPeak);
thetaSmooth = smoothdata(thetaPeak(valid), 'sgolay', 21);

ft = fit(gamma(valid)', thetaSmooth', 'poly2');

% Visualisierung
figure
imagesc(twoTheta, gamma, img_corr)
axis xy
hold on
plot(thetaSmooth, gamma(valid), 'c', 'LineWidth',2)
hold off

% Methode B2: Globaler 2D-Fit (High-End)
% Modell
I(γ,2θ) = A exp(-(2θ - μ(γ))^2 / (2σ^2)) + B
μ(γ) = μ0 + a sin^2(γ)

% Physikalischer Bonus (Spannungsanalyse)
% Für Eigenspannungen: 2θ(γ)=2θ_0​+Ksin²γ
ft = fit(gammaCenters', peakPos, 'a*sin(x*pi/180).^2 + b');
