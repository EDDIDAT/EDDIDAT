% Diese Funktion ist vor allem für die Verwendung der Get-Methode gedacht.
% Sie verwandelt wie gehalb ein Cell-Array in eine Matrix, ist die Eingabe
% aber bereites eine Matrix, so wird diese unverändert übergeben
% Input: M, die umzuwandelnde (Cell-)Matrix, variant|cell
% Output: M_out, die konvertierte Matrix, variant
function M_out = Cell2Mat(M)
    if iscell(M)
        M_out = cell2mat(M);
    else
        M_out = M;
    end
end

