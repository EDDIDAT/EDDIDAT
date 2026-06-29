function plotPseudoVoigtFit(x, y, params, errors, fitResult)
% PLOTPSEUDOVOIGTFIT Plottet Rohdaten + Pseudo-Voigt-Fit + Residuen
%
% EINGABE:
%   x         - x-Daten (Vektor)
%   y         - y-Daten (Vektor)
%   params    - Struktur mit Fitparametern (aus fitPseudoVoigt)
%   errors    - Struktur mit Fehlern (aus fitPseudoVoigt)
%   fitResult - gefittete y-Werte (aus fitPseudoVoigt)

    x = x(:); y = y(:); fitResult = fitResult(:);
    residuals = y - fitResult;

    % --- Figure mit zwei Subplots ---
    figure('Color', 'white', 'Position', [100 100 800 600]);

    % ==============================
    % Oberer Plot: Daten + Fit
    % ==============================
    ax1 = subplot(3, 1, [1 2]);

    plot(x, y, 'ko', 'MarkerSize', 4, 'MarkerFaceColor', [0.7 0.7 0.7], ...
        'DisplayName', 'Rohdaten');
    hold on;
    plot(x, fitResult, 'r-', 'LineWidth', 2, 'DisplayName', 'Pseudo-Voigt Fit');

    % --- Peak-Annotation: x0 ---
    y_top = max(fitResult);
    xline(params.x0, '--b', 'LineWidth', 1.2, 'Alpha', 0.7, ...
        'Label', sprintf('x_0 = %.4f ± %.4f', params.x0, errors.x0), ...
        'LabelVerticalAlignment', 'bottom', ...
        'LabelHorizontalAlignment', 'right');

    % --- Peak-Annotation: FWHM als Pfeil ---
    y_half   = params.offset + params.A / 2;
    x_left   = params.x0 - params.fwhm / 2;
    x_right  = params.x0 + params.fwhm / 2;

    % Horizontale Linie für FWHM
    plot([x_left, x_right], [y_half, y_half], 'b-', 'LineWidth', 1.5, ...
        'HandleVisibility', 'off');

    % Endmarker
    plot([x_left, x_right], [y_half, y_half], 'b|', 'MarkerSize', 8, ...
        'LineWidth', 1.5, 'HandleVisibility', 'off');

    % FWHM Beschriftung
    text(params.x0, y_half * 1.02, ...
        sprintf('FWHM = %.4f ± %.4f', params.fwhm, errors.fwhm), ...
        'HorizontalAlignment', 'center', ...
        'VerticalAlignment',   'bottom', ...
        'Color', 'blue', 'FontSize', 9);

    ylabel('Intensität');
    title('Pseudo-Voigt Fit');
    legend('Location', 'northwest');
    grid on; box on;
    set(ax1, 'XTickLabel', []);   % x-Achse erst im Residuen-Plot

    % ==============================
    % Unterer Plot: Residuen
    % ==============================
    ax2 = subplot(3, 1, 3);

    stem(x, residuals, 'Marker', 'none', 'Color', [0.2 0.6 0.2], ...
        'LineWidth', 0.8);
    hold on;
    yline(0, 'k-', 'LineWidth', 1);

    % ±1 sigma Band
    sigma_res = std(residuals);
    yline( sigma_res, '--', 'Color', [0.5 0.5 0.5], ...
        'Label', '+1\sigma', 'LabelHorizontalAlignment', 'left');
    yline(-sigma_res, '--', 'Color', [0.5 0.5 0.5], ...
        'Label', '-1\sigma', 'LabelHorizontalAlignment', 'left');

    xlabel('x');
    ylabel('Residuen');
    title(sprintf('Residuen  (std = %.4g)', sigma_res));
    grid on; box on;

    % x-Achsen koppeln
    linkaxes([ax1, ax2], 'x');
    xlim([min(x), max(x)]);
end