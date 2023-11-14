% Lorentz-Funktion mit den entsprechenden Vorgabe Parametern. Aus
% Performance Gr�nden wird an dieser Stelle keine Stringenzpr�fung 
% durchgef�hrt. Alle �bergabeparameter k�nnen entweder skalar oder ein
% Array sein, wo bei die Array gleich gro� sein m�ssen. Das Ergebnis ist
% dann ebenfalls ein solches Array oder skalar.
% Input: x, double|real /
%        p_n, Parmeter, double|real|finite
% Output: y, double|real
function y = FF_Lorentz(x,p_1,p_2,p_3)

%% (* Compute *)
    y = p_1 ./ (1 + 4 * ((x-p_2)./p_3).^2);
end