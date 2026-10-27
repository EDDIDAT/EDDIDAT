% Split- (bifurkierte) Pseudo-Voigt-Funktion mit den entsprechenden
% Vorgabe-Parametern. Aus Performance Gr�nden wird an dieser Stelle keine
% Stringenzpr�fung durchgef�hrt. Im Gegensatz zur normalen Pseudo-Voigt-
% Funktion hat der Peak zwei unabh�ngige Halbwertsbreiten - eine links,
% eine rechts vom Maximum (p_2). F�r p_3 = p_4 reduziert sich die
% Funktion exakt auf FF_PseudoVoigt (symmetrischer Fall). Alle
% �bergabeparameter k�nnen entweder skalar oder ein Array sein, wobei
% die Arrays gleich gro� sein m�ssen. Das Ergebnis ist dann ebenfalls ein
% solches Array oder skalar.
% Input: x, double|real /
%        p_n, Parmeter, double|real|finite
% Output: y, double|real
function y = FF_SplitPseudoVoigt(x,p_1,p_2,p_3,p_4,p_5)

% p_1 = Intensitaet
% p_2 = Peakposition
% p_3 = Peakbreite links vom Maximum (x < p_2)
% p_4 = Peakbreite rechts vom Maximum (x >= p_2)
% p_5 = Anteil Gauss/Lorentz

%% (* Compute *)
    w = p_3 + (p_4-p_3).*(x>=p_2);
    y = p_5 .* Tools.Science.Math.FF_Gauss(x,p_1,p_2,w) + ...
        (1-p_5) .* Tools.Science.Math.FF_Lorentz(x,p_1,p_2,w);
end
