% Klassische Gauss-Funktion mit den entsprechenden Vorgabe Parametern. Aus
% Performance Gründen wird an dieser Stelle keine Stringenzprüfung 
% durchgeführt. Alle Übergabeparameter können entweder skalar oder ein
% Array sein, wo bei die Array gleich groß sein müssen. Das Ergebnis ist
% dann ebenfalls ein solches Array oder skalar.
% Input: x, double|real /
%        p_n, Parmeter, double|real|finite
% Output: y, double|real
function y = FF_Gauss(x,p_1,p_2,p_3)

%% (* Compute *)
    y = p_1 .* exp(-(((x-p_2)./p_3).^2)./2);
end