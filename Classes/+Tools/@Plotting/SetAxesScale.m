% Diese Funktion setzt die Skalierungen für die Achsen (linear oder log).
% Input: Axis, Achsenhandle, double / varargin, Skalierungen, ip
% Output: none
function SetAxesScale(Axis,varargin)

%% (* Stringenzprüfung *)
    %InputParser
    ip = inputParser;
    %Parameter: Skalierung
    ip.addParamValue('XLog',false,@islogical);
    ip.addParamValue('YLog',false,@islogical);
    ip.addParamValue('ZLog',false,@islogical);
    %Parse
    ip.parse(varargin{:});
    
%% (* Setzen der Eigenschaften *)
    if ip.Results.XLog, set(Axis,'XScale','log'); end
    if ip.Results.YLog, set(Axis,'YScale','log'); end
    if ip.Results.ZLog, set(Axis,'ZScale','log'); end
end