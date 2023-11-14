%Bragg-Gleichung f�r Energiedispersion
%rtn = BraggEq_E(varargin)

% Bragg Gleichung f�r Energiedispersive Messungen, d. h. die Energie 
% (und nicht die Wellenl�nge) ist eine abh�ngige Gr��e. Vorgegeben
% werden jeweils 3 der folgenden Gr��en:
% (BraggAngle, Winkel,� / Energy, Energie, keV / LatticeSpacing, 
% Netzebenenabstand, nm / DiffractionOrder, Beugungsordnung, no unit)
% Die fehlende Gr��e ist dann rtn. Die Eingabe Argumente k�nnen skalar oder
% ein Array sein, wobei alle Arrays gleichgro� sein m�ssen.
% Input: varargin, die drei Eingabeargumente, ip
% Output: rtn, berechnetes fehlendes Argument, double
function rtn = BraggEq_E(varargin)

%% (* Stringenzpr�fung *)
    %--> Anzahl der Eingabeargumente �berpr�fen (drei Argumente)
    if nargin ~= 6
        error('Invalid input arguments!')
    end
    %InputParser
    ip = inputParser;
    %Hinzuf�gen der m�glichen Argumente
    ip.addParamValue('DiffractionOrder',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'positive','integer','finite'}));
    ip.addParamValue('BraggAngle',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'real','finite'}));
    ip.addParamValue('Energy',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'positive','real','finite'}));
    ip.addParamValue('LatticeSpacing',NaN,...
        @(x)validateattributes(x,{'double'},...
        {'positive','real','finite'}));
    %Parse
    ip.parse(varargin{:});
    
%% (* �bergabe der relevanten Eigenschaften *)
    n = ip.Results.DiffractionOrder;
    theta = ip.Results.BraggAngle;
    %Intern wird mit der Wellenl�nge (in nm) gerechnet (klassisch)
    lambda = Tools.Science.Physics.EWR(ip.Results.Energy); 
    d = ip.Results.LatticeSpacing;

%% (* Compute *)
    %Kontrolle, welche Gr��e NICHT gegeben ist
    %--> E gesucht
    if isnan(lambda)
        rtn = Tools.Science.Physics.EWR(...
            2 .* d .* sind(theta) ./ n);
    %--> d gesucht
    elseif isnan(d)
        rtn = n .* lambda ./ (2 .* sind(theta));
    %--> theta gesucht
    elseif isnan(theta)
        rtn = asind(n .* lambda ./ (2 .* d));
    %--> n gesucht
    elseif isnan(n)
        rtn = 2 .* d .* sind(theta) ./ lambda;
    end
end