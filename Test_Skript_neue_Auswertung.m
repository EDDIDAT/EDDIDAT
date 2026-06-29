%% Test-Skript: d vs sin²χ Methode
% Spannungsanalyse nach RSA-Grundgleichung:
% d(φ,χ) = a·sin²χ + b·sin2χ + c

clear; clc;

%% ── Messdaten ────────────────────────────────────────────────────────
data = [
-89.4968719482422	29.6658538878171	0.00381888011691910
-87.4970550537109	29.6476935200400	0.00253448595637603
-85.4972534179688	29.6507005817739	0.00138178775877888
-83.4974365234375	29.6509941830894	0.00142622182834066
-81.4976196289063	29.6488251474789	0.00138196180394426
-79.4978027343750	29.6438179490614	0.00224871298841728
-77.4980010986328	29.6640921472241	0.00289490764720911
-75.4981842041016	29.6592554246127	0.00239269457833491
-73.4983673095703	29.6537538941532	0.00212522289709233
-71.4985504150391	29.6566908262600	0.00344912726400553
-69.4987487792969	29.6521588426029	0.00364856390070975
-67.4989318847656	29.6387891025859	0.00273251984705960
-65.4991149902344	29.6346806409517	0.00315180072311558
-63.4992980957031	29.6677960620499	0.00435893764282997
-61.4994964599609	29.6785312748812	0.00468220622417618
-59.4996795654297	29.6248494331093	0.00192624209551663
-51.5004272460938	29.6656252299887	0.00257895540184594
-49.5006103515625	29.6694303580469	0.00366986002473939
-47.5007934570313	29.6649712967002	0.00290205387871400
-45.5009918212891	29.6303946028436	0.00267956275278959
-43.5011749267578	29.6227073950555	0.00313101499871814
-41.5013580322266	29.5958092957662	0.00165624882052599
-39.5015411376953	29.6082567557161	0.00248243194671568
-37.5017318725586	29.6041269357241	0.00264236442559838
-35.5019226074219	29.6393649401308	0.00158782845893535
-147.525108337402	29.6437017921245	0.00194678177392786
-145.525299072266	29.6320276491730	0.00218160545052750
-143.525482177734	29.6165984394686	0.00274013497830963
-135.526229858398	29.6332677951614	0.00214109057522965
-133.526412963867	29.6322026377097	0.00150949444297586
-131.526611328125	29.6634554987842	0.00222069408060987
-129.526794433594	29.6629027575218	0.00266711969242480
-127.526977539063	29.6533412995932	0.00165343865902428
-125.527160644531	29.6584859074009	0.00189968881489785
-123.527359008789	29.6522938841948	0.00219708599311163
-121.527542114258	29.6350824691022	0.00311851054474094
-113.528289794922	29.6777552129572	0.00316165310159219
-111.528472900391	29.6764034867790	0.00330597873112798
-109.528656005859	29.6516874019290	0.00186980749009630
-107.528854370117	29.6436114900625	0.00158929321231713
-105.529037475586	29.6208900595012	0.00133632869832842
-103.529220581055	29.6242609233071	0.00243689282396249
-95.5299682617188	29.6587201856816	0.00232762719313693
-93.5301666259766	29.6370441333849	0.00215344090025283
-91.5303497314453	29.6303156661131	0.00156259797824564
];

gamma_deg  = data(:,1);   % γ in Grad
tth_deg    = data(:,2);   % 2θ in Grad
tth_err    = data(:,3);   % 2θ-Fehler in Grad

%% ── Parameter ────────────────────────────────────────────────────────
lambda = 1.34012e-10;   % Wellenlänge in m (Ga K-alpha)
lambda_A = lambda * 1e10;   % in Angström

% Röntgenographische Elastizitätskonstanten (aus DEK-Tabelle anpassen)
S1  = -3.2630e-07;   % S1 in MPa^-1 — bitte anpassen
HS2 =  2.5030e-06;   % 1/2 S2 in MPa^-1 — bitte anpassen

%% ── Umrechnung 2θ → d ────────────────────────────────────────────────
theta_rad = deg2rad(tth_deg / 2);
d_meas    = lambda_A ./ (2 .* sind(tth_deg/2));   % d in Angström

% Fehler auf d propagieren: dd = -d · cot(θ) · dθ
d_err = abs(d_meas .* cotd(tth_deg/2) .* deg2rad(tth_err));

%% ── Umrechnung γ → χ ─────────────────────────────────────────────────
% In deiner GUI gilt: γ = χ + 90° → χ = γ - 90°
chi_deg = gamma_deg - 90;   % χ in Grad
chi_rad = deg2rad(chi_deg);

%% ── φ aus α und χ berechnen ──────────────────────────────────────────
% Mit alpha = 4° und theta0 = median(tth/2)
alpha_deg = 4.0;
theta0    = median(tth_deg(isfinite(tth_deg))) / 2;

psi_deg = zeros(size(chi_deg));
phi_deg = zeros(size(chi_deg));

for i = 1:numel(chi_deg)
    val = sind(alpha_deg)*sind(theta0) + ...
          cosd(alpha_deg)*cosd(theta0)*cosd(chi_deg(i)+90);
    val = max(-1, min(1, val));
    if chi_deg(i)+90 < 0
        psi_deg(i) = -acosd(val);
    else
        psi_deg(i) =  acosd(val);
    end

    if abs(sind(psi_deg(i))) < 1e-10
        phi_deg(i) = 0;
    else
        val2 = cosd(theta0)*sind(chi_deg(i)+90) / sind(psi_deg(i));
        val2 = max(-1, min(1, val2));
        if chi_deg(i)+90 < 0
            phi_deg(i) = acosd(val2) - 180;
        else
            phi_deg(i) = -acosd(val2);
        end
    end
end

%% ── d₀ schätzen ──────────────────────────────────────────────────────
% Erster Schätzwert: Mittelwert der d-Werte
d0_est = mean(d_meas(isfinite(d_meas)));
fprintf('d₀ Schätzwert: %.6f Å\n', d0_est);

%% ── Nichtlinearer Fit: d = a·sin²χ + b·sin2χ + c ────────────────────
% Fitparameter: p = [a, b, c]
% Modell: d_fit = a·sin²(χ) + b·sin(2χ) + c

idxFin = isfinite(d_meas) & isfinite(d_err) & (d_err > 0);
chi_fit = chi_deg(idxFin);
d_fit   = d_meas(idxFin);
d_wt    = 1 ./ d_err(idxFin).^2;   % Gewichte = 1/σ²
phi_fit = phi_deg(idxFin);
psi_fit = psi_deg(idxFin);

fprintf('Anzahl Datenpunkte für Fit: %d\n', sum(idxFin));

% Designmatrix für gewichteten linearen Fit
% d = a·sin²χ + b·sin2χ + c
A_mat = [sind(chi_fit).^2, sind(2*chi_fit), ones(size(chi_fit))];

% Gewichteter linearer Fit mit lscov
W = diag(d_wt);
[params, params_err, mse] = lscov(A_mat, d_fit, d_wt);

a_fit = params(1);
b_fit = params(2);
c_fit = params(3);   % ≈ d₀ (spannungsfreier d-Abstand)

fprintf('\n── Fit-Ergebnisse ───────────────────────────────────\n');
fprintf('a = %.6f ± %.6f Å\n', a_fit, params_err(1));
fprintf('b = %.6f ± %.6f Å\n', b_fit, params_err(2));
fprintf('c = %.6f ± %.6f Å  (≈ d₀)\n', c_fit, params_err(3));
fprintf('MSE = %.2e\n', mse);

%% ── Spannungen aus a, b, c berechnen ────────────────────────────────
% a = 1/2·S2·d0·(σφ‖ - σ33)
% b = 1/2·S2·d0·σφ⊥
% c ≈ [S1·(σ11+σ22+σ33) + 1/2·S2·σ33 + 1]·d0
%
% σφ‖ = σ11·cos²φ + σ22·sin²φ + σ12·sin2φ
% σφ⊥ = σ13·cosφ + σ23·sinφ
%
% Mit φ ≈ -150° und σ12=σ23=σ33=0 (vereinfacht):
% σφ‖ ≈ σ11·cos²φ + σ22·sin²φ
% σφ⊥ ≈ σ13·cosφ

d0 = c_fit;   % d₀ aus Fit

% Mittleres φ für Spannungsberechnung
phi_mean = mean(phi_fit);
fprintf('\nMittleres φ = %.1f°\n', phi_mean);

% Aus b: σ13
% b = 1/2·S2·d0·σ13·cos(φ)
sigma13 = b_fit / (HS2 * d0 * cosd(phi_mean));

% Aus a: σφ‖ - σ33 (mit σ33 = 0 angenommen)
% a = 1/2·S2·d0·(σ11·cos²φ + σ22·sin²φ)
% → σφ‖ = a / (1/2·S2·d0)
sigma_phi_par = a_fit / (HS2 * d0);

% σ11 und σ22 aus σφ‖ trennen erfordert mehrere φ-Winkel
% Mit nur φ ≈ -150° kann nur σφ‖ bestimmt werden
% Als Näherung: σ11 ≈ σφ‖ / cos²φ  (wenn σ22 ≈ 0)
sigma11_approx = sigma_phi_par / cosd(phi_mean)^2;

fprintf('\n── Spannungsergebnisse ──────────────────────────────\n');
fprintf('σφ‖ = %.1f MPa  (= σ11·cos²φ + σ22·sin²φ)\n', sigma_phi_par);
fprintf('σ13 = %.1f MPa\n', sigma13);
fprintf('σ11 (Näherung, σ22=0) = %.1f MPa\n', sigma11_approx);
fprintf('d₀  = %.6f Å\n', d0);

%% ── Fit-Qualität ─────────────────────────────────────────────────────
d_modell = A_mat * params;
residuals = d_fit - d_modell;
SStot = sum(d_wt .* (d_fit - mean(d_fit)).^2);
SSres = sum(d_wt .* residuals.^2);
Rsq   = 1 - SSres/SStot;
fprintf('\nR² = %.4f\n', Rsq);

%% ── Plot ─────────────────────────────────────────────────────────────
figure('Name', 'd vs sin²χ', 'Position', [100 100 900 400]);

subplot(1,2,1);
sin2chi = sind(chi_fit).^2;
errorbar(sin2chi, d_fit, d_err(idxFin), 's', ...
    'MarkerSize', 5, 'MarkerFaceColor', [0.094 0.373 0.647], ...
    'Color', [0.094 0.373 0.647]);
hold on;
x_line = linspace(min(sin2chi), max(sin2chi), 200);
% Für den Plot: sin2χ-Achse, b-Term auf null gesetzt (Haupttrend)
plot(x_line, a_fit*x_line + c_fit, '-r', 'LineWidth', 1.5);
xlabel('sin²χ');
ylabel('d [Å]');
title('d vs sin²χ');
legend('Daten', 'Fit (b=0)', 'Location','best');
grid on; box on;

subplot(1,2,2);
errorbar(chi_fit, d_fit, d_err(idxFin), 's', ...
    'MarkerSize', 5, 'MarkerFaceColor', [0.094 0.373 0.647], ...
    'Color', [0.094 0.373 0.647]);
hold on;
chi_line = linspace(min(chi_fit), max(chi_fit), 200);
d_line   = a_fit*sind(chi_line).^2 + b_fit*sind(2*chi_line) + c_fit;
plot(chi_line, d_line, '-r', 'LineWidth', 1.5);
xlabel('χ [°]');
ylabel('d [Å]');
title('d vs χ');
legend('Daten', 'Fit', 'Location','best');
grid on; box on;

fprintf('\nFertig.\n');

%% ── Plot: Ableitungen (wie Referenzbild) ─────────────────────────────
% d(φ,χ) = a·sin²χ + b·sin2χ + c
% ∂d/∂χ  = a·sin2χ + 2b·cos2χ      → proportional zu σφ⊥
% ∂²d/∂χ² = 2a·cos2χ - 4b·sin2χ   → proportional zu σφ‖

chi_plot = linspace(-90, 90, 500);

% Ableitungen berechnen
dd_dchi   = a_fit .* sind(2*chi_plot) + 2*b_fit .* cosd(2*chi_plot);
d2d_dchi2 = 2*a_fit .* cosd(2*chi_plot) - 4*b_fit .* sind(2*chi_plot);

% Umrechnung auf Spannung [MPa]
% ∂d/∂χ   = 1/2·S2·d0·σφ⊥ · (∂/∂χ von sin2χ-Term)
%          → normieren durch (1/2·S2·d0)
% ∂²d/∂χ² = 1/2·S2·d0·(σφ‖-σ33) · (∂²/∂χ² von sin²χ-Term)
%          → normieren durch (1/2·S2·d0)

norm_factor = HS2 * d0;   % 1/2·S2·d0

% Faktoren aus Theorie (Ableitungen der Grundfunktionen bei χ=0):
% Bei χ=0: ∂/∂χ(sin²χ) = sin2χ = 0, ∂/∂χ(sin2χ) = 2cos2χ = 2
%          1/(1/2·S2·d0) · 1/2 · ∂d/∂χ|χ=0 = b/(HS2·d0) = σφ⊥
% Bei χ=0: 1/(1/2·S2·d0) · 1/2 · ∂²d/∂χ²|χ=0 = a/(HS2·d0) = σφ‖

dd_MPa   = dd_dchi   ./ norm_factor;
d2d_MPa  = d2d_dchi2 ./ norm_factor;

figure('Name', 'Ableitungen d vs chi', 'Position', [100 550 700 450]);
ax_deriv = gca;

plot(ax_deriv, chi_plot, dd_MPa,  '-r', 'LineWidth', 2.0, ...
    'DisplayName', '$\frac{\partial d}{\partial\chi}$ / $({\frac{1}{2}S_2 d_0})$');
hold(ax_deriv, 'on');
plot(ax_deriv, chi_plot, d2d_MPa, '-b', 'LineWidth', 2.0, ...
    'DisplayName', '$\frac{\partial^2 d}{\partial\chi^2}$ / $({\frac{1}{2}S_2 d_0})$');

% Nulllinien
xline(ax_deriv, 0, 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off');
yline(ax_deriv, 0, 'k-', 'LineWidth', 1.2, 'HandleVisibility', 'off');

% Werte bei χ=0 ablesen
[~, idx0] = min(abs(chi_plot));
dd_at0   = dd_MPa(idx0);
d2d_at0  = d2d_MPa(idx0);

% σφ⊥ und σφ‖ aus Ableitungen bei χ=0
sigma_phi_perp_deriv = dd_at0  / 2;   % 1/(HS2·d0) · 1/2 · ∂d/∂χ|χ=0
sigma_phi_par_deriv  = d2d_at0 / 2;   % 1/(HS2·d0) · 1/2 · ∂²d/∂χ²|χ=0

fprintf('\n── Ableitungsmethode (χ=0) ──────────────────────────\n');
fprintf('σφ‖ = %.1f MPa  (aus ∂²d/∂χ²|χ=0)\n', sigma_phi_par_deriv);
fprintf('σφ⊥ = %.1f MPa  (aus ∂d/∂χ|χ=0)\n',   sigma_phi_perp_deriv);

% Annotationen
text(ax_deriv, -75, max(d2d_MPa)*0.85, '$\sigma_\varphi^\parallel$', ...
    'Interpreter','latex','FontSize',14,'Color','b');
text(ax_deriv, -75, min(dd_MPa)*0.85,  '$\sigma_\varphi^\perp$', ...
    'Interpreter','latex','FontSize',14,'Color','r');
text(ax_deriv,  10, max(dd_MPa)*0.85,  '$\sigma_\varphi^\perp$', ...
    'Interpreter','latex','FontSize',14,'Color','r');
text(ax_deriv,  10, min(d2d_MPa)*0.85, '$\sigma_\varphi^\parallel$', ...
    'Interpreter','latex','FontSize',14,'Color','b');

xlabel(ax_deriv, '\chi [°]', 'FontSize', 12);
ylabel(ax_deriv, ...
    '$\frac{\partial d}{\partial\chi}$, $\frac{\partial^2 d}{\partial\chi^2}$ [MPa]', ...
    'Interpreter', 'latex', 'FontSize', 12);
title(ax_deriv, 'Ableitungen der RSA-Grundgleichung', 'FontSize', 11);

legend(ax_deriv, 'Interpreter', 'latex', 'Location', 'southeast', 'FontSize', 10);
grid(ax_deriv, 'on');
box(ax_deriv, 'on');
ax_deriv.LineWidth = 1.0;
xlim(ax_deriv, [-90 90]);