% Beziehung zwischen Energie und Wellenl�nge. Es wird auf die
% Implementierung von zwei Funktionen verzichtet, da die Beziegung die Form
% c = x*y hat. EWR = EnergyWavelengthRelation
% Input: in, Energie oder Wellenl�nge, keV oder nm, double|va
% Output: rtn, Wellenl�nge oder Energie, nm oder keV, double|[size(in)]
function rtn = EWR(in)

%% (* Stringenzpr�fung *)
    validateattributes(in,{'double'},{'positive','real'})

%% (* Compute *)
    rtn = Tools.Science.Physics.h.keVs .* ...
        Tools.Science.Physics.c.nmps ./ in;
end