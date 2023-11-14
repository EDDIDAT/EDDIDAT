% Pseudo-Voigt-Funktion mit den entsprechenden Vorgabe Parametern. Aus
% Performance Gr�nden wird an dieser Stelle keine Stringenzpr�fung
% durchgef�hrt. Es handelt sich um eine Linear-Kombination aus einer Gauss-
% und Lorentzfunktion. Alle �bergabeparameter k�nnen entweder skalar oder
% ein Array sein, wo bei die Array gleich gro� sein m�ssen. Das Ergebnis
% ist dann ebenfalls ein solches Array oder skalar.
% Input: x, double|real /
%        p_n, Parmeter, double|real|finite
% Output: y, double|real
function y = FF_PseudoVoigt(x,p_1,p_2,p_3,p_4)

%% (* Compute *)
    y = p_4 .* Tools.Science.Math.FF_Gauss(x,p_1,p_2,p_3) + ...
        (1-p_4) .* Tools.Science.Math.FF_Lorentz(x,p_1,p_2,p_3);
    
%     y = p_4 .* (p_1 .* ((2/(pi*p_3)) .* (1+4.*((x-p_2)./p_3).^2)).^-1) + ...
%         (1-p_4).*(p_1.*(2.*sqrt(log(2)/pi)/p_3).*exp(-4.*log(2).*((x-p_2)/p_3).^2));
end