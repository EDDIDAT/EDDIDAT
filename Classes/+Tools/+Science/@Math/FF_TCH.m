% Pseudo-Voigt-Funktion mit den entsprechenden Vorgabe Parametern. Aus
% Performance Gründen wird an dieser Stelle keine Stringenzprüfung
% durchgeführt. Es handelt sich um eine Linear-Kombination aus einer Gauss-
% und Lorentzfunktion. Alle Übergabeparameter können entweder skalar oder
% ein Array sein, wo bei die Array gleich groß sein müssen. Das Ergebnis
% ist dann ebenfalls ein solches Array oder skalar.
% Input: x, double|real /
%        p_n, Parmeter, double|real|finite
% Output: y, double|real
function y = FF_TCH(x,p_1,p_2,p_3,p_4)

% p_1 = Intensität
% p_2 = Energielage
% p_3 = GammaGauss
% p_4 = GammaLorentz

%% (* Compute *)
    Gamma = (p_3.^5 + 2.69269.*p_3.^4.*p_4 + 2.42843.*p_3.^3.*p_4.^2 + ...
        4.47163.*p_3.^2.*p_4.^3 + 0.07842.*p_3.*p_4.^4 + p_4.^5).^0.2;

    eta = 1.36603.*(p_4/Gamma) - 0.47719.*(p_4/Gamma).^2 + 0.1116.*(p_4/Gamma).^3;
    
    y = p_1 .* ((2.*eta)/(pi.*Gamma).*(1+4.*((x-p_2)./Gamma).^2).^(-1) + ...
        (1-eta).*(2./Gamma).*(log(2)./pi).^(1/2) .* exp(-4.*log(2).*((x-p_2)./Gamma).^2));
    
end