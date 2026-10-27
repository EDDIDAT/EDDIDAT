% Schaetzt den Untergrund eines Spektrums automatisch mittels SNIP
% (Statistics-sensitive Non-linear Iterative Peak-clipping, Ryan et al.
% 1988, Nucl. Instr. Meth. B34, 396-402) -- ohne dass Peakregionen manuell
% markiert werden muessen. Jede Struktur, die schmaler als
% 2*MaxHalfWindow Kanaele ist, wird automatisch als Peak erkannt und
% bleibt im Untergrund ausgespart; breitere Strukturen werden Teil des
% Untergrunds. Die LLS-Transformation (log-log-sqrt) stabilisiert dabei
% die Poisson-Zaehlstatistik, damit starke und schwache Peaks gleich
% behandelt werden.
% Input: Y, Wertebereich (Zaehlraten), Unit, double|column /
%        MaxHalfWindow, groesste Fensterhalbbreite in Kanaelen, double|va /
%        varargin, Optionen, ip
% Output: Y_Background, geschaetzte Untergrundlinie, Unit, double|[size(Y)]
function Y_Background = SNIPBackground(Y,MaxHalfWindow,varargin)

%% (* Stringenzpruefung *)
    ip = inputParser;
    ip.addRequired('Y',@(x)validateattributes(x,{'double'},...
        {'real','finite','column'}));
    ip.addRequired('MaxHalfWindow',@(x)validateattributes(x,{'double'},...
        {'integer','positive','scalar'}));
    %LLS-Transformation zur Stabilisierung der Zaehlstatistik, Standard: an
    ip.addParamValue('UseLLS',true,@(x)validateattributes(x,{'logical'},...
        {'scalar'}));
    ip.parse(Y,MaxHalfWindow,varargin{:});
    UseLLS = ip.Results.UseLLS;

%% (* Transformation *)
    n = length(Y);
    if UseLLS
        v = log(log(sqrt(Y + 1) + 1) + 1);
    else
        v = Y;
    end

%% (* Iteratives Peak-Clipping *)
    for m = 1:MaxHalfWindow
        idx = (m+1):(n-m);
        v(idx) = min(v(idx), (v(idx-m) + v(idx+m)) / 2);
    end

%% (* Ruecktransformation *)
    if UseLLS
        Y_Background = (exp(exp(v) - 1) - 1).^2 - 1;
    else
        Y_Background = v;
    end
end
