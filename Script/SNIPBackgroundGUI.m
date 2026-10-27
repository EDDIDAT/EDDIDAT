function [Measurement,DataTmp,T,BkgTmp] = SNIPBackgroundGUI(Measurement,DataTmp,calib,WindowValue)
%% (* Vollautomatische globale Untergrundkorrektur mittels SNIP *)
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Statistics-sensitive Non-linear Iterative Peak-clipping (Ryan et al.
% 1988). Laeuft unabhaengig von manuell markierten Peak-Regionen ueber
% das gesamte Spektrum -- jeder Peak (egal ob erwartet/markiert oder
% nicht) wird automatisch erkannt und im Untergrund ausgespart. Gedacht
% als separater, vorgeschalteter Schritt VOR der gewohnten Klick-Routine
% (Define Background/Fit Background), die anschliessend etwaigen lokalen
% Rest-Untergrund um die gewuenschten Peaks weiter feinkorrigieren kann.
%
% WindowValue: Fensterhalbbreite, vom Nutzer im GUI eingestellt --
% bestimmt, bis zu welcher Peakbreite eine Struktur noch als "Peak"
% erkannt (und erhalten) wird. WICHTIG: ein zu KLEINES Fenster (schmaler
% als die eigentliche Peakbreite) erodiert den Peak von innen (die
% Vergleichspunkte liegen noch auf dem Peak selbst); ein zu GROSSES
% Fenster kann bei eng benachbarten Peaks (kleiner Peakabstand) die
% Vergleichspunkte auf einen Nachbarpeak statt auf echten Untergrund
% legen. Es muss also groesser als die breiteste zu erhaltende Peakbreite,
% aber kleiner als der kleinste Peakabstand sein. Bei 'Channel_scale' in
% Kanaelen angegeben, sonst in keV (Energieachse).
if nargin < 4 || isempty(WindowValue)
    if strcmp(calib,'Channel_scale')
        WindowValue = 40;
    else
        WindowValue = 2.0;
    end
end
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
for c = 1:length(Measurement)
    T.X = DataTmp{c}(:, 1);
    T.Y = DataTmp{c}(:, 2);

    if strcmp(calib,'Channel_scale')
        MaxHalfWindow = WindowValue;
    else
        % Energiewert in Kanaleinheiten umrechnen, analog zu
        % ReductionFilter.m
        MaxHalfWindow = round(length(T.X) * WindowValue / (T.X(end)-T.X(1)));
    end
    MaxHalfWindow = max(MaxHalfWindow, 1);

    T.Bkg = Tools.Data.Fitting.SNIPBackground(T.Y, MaxHalfWindow);
    T.Y = T.Y - T.Bkg;

    DataTmp{c} = [T.X, T.Y];
    BkgTmp{c} = [T.X, T.Bkg];

end
assignin('base','T',T)

disp('SNIP background reduction performed');
