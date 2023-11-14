% Diese Funktion berechnet die Eindringtiefe tau als Funktion von 2*theta 
% und dem optionalen Kippwinkel phi. Weiterhin kann optional ein Schalter
% angegebenen werden, der bestimmt, ob der Mittelwert aus tau_min und
% tau_max ausgegeben werden soll. Dabei werden Reflexe aus Index_Reflexes
% verwendet (siehe auch EnergyPositions). Das Ergebnis hei�t bei phi = 0
% tau_max, andernfalls tau_min.
% Input: DiffractionAngle, Beugungswinkel 2*theta, �, double|va /
%        varargin, Spezifizierungen, ip
% Output: tau, Eindringtiefe tau, �m,
%          double|[length(DiffractionLines) length(DiffractionAngle)]
function tau = PenetrationDepth(obj,DiffractionAngle,varargin)

%% (* Stringenzpr�fung *)
    %--> M�glichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        tau = {@Labels,@StandardRangeX};
        return;
    end
    %InputParser
    ip = inputParser;
    %Funktionsargumente hinzuf�gen
    ip.addRequired('DiffractionAngle',...
        @(x)validateattributes(x,{'double'},...
        {'>',0,'<',180,'real'}));
    %Index der zu betrachtenden Beugungsreflexe,
    %Null bedeutet, dass alle Reflexe genommen werden
    ip.addOptional('Index_Reflexes',0,...
        @(x)validateattributes(x,{'double'},...
        {'integer','vector','nonnegative'}));
    %Kippwinkel phi als weitere Vorgabegr��e, �
    ip.addParamValue('TiltAngle',0,...
        @(x)validateattributes(x,{'double'},...
        {'real','finite'}));
    %Schalter, ob das arithmetische Mittel aus tau_min und tau_max wieder
    %gegeben werden soll
    ip.addParamValue('MeanMinMax',false,...
        @(x)validateattributes(x,{'logical'},{'scalar'}));
    %Parse
    ip.parse(DiffractionAngle,varargin{:});
    
%% (* �bergabe der relevanten Eigenschaften *)
    [twotheta,phi] = Tools.ArrayOperations.MatchSize(...
        {ip.Results.DiffractionAngle,ip.Results.TiltAngle});
    Index_Reflexes = ip.Results.Index_Reflexes;
    
%% (* Sonderfall *)
    %--> �berpr�fung des Schalters MeanMinMax
    if ip.Results.MeanMinMax
        %tau = 1/2 * (tau_max + tau_min)
        tau = 0.5 * (obj.PenetrationDepth(twotheta,Index_Reflexes) + ...
            obj.PenetrationDepth(twotheta,Index_Reflexes,'TiltAngle',phi));
        %Keine weiteren Berechnungen
        return;
    end
    
%% (* Vorbereitung *)
    ReshapeSize = size(twotheta);
    twotheta = twotheta(:);
    phi = phi(:);
    %Reflexenergien
    E = obj.EnergyPositions(twotheta,ip.Results.Index_Reflexes);
    
%% (* Compute *)
    %Berechnung von tau in �m (= cm * 10^-4)
    tau = (1 ./ obj.LAC(E)) * diag(sind(twotheta ./2)) ./ 2e-04 .* ...
        repmat(cosd(phi)',size(E,1),1);
    %Zur�ckformen der Matrix zur urspr�nglichen Form, wobei sie um 
    %eine weitere Dimension mit der L�nge von E erg�nzt wurde 
    %(1. Dimension)
    tau = squeeze(reshape(tau,[size(E,1),ReshapeSize]));
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode f�r den Plot
function rtn = StandardRangeX(obj)
    %############### ToDo: sinnvoller Bereich
    rtn = [7 16];
end
%--------------------------------------------------------------------------
% Labels-Methode f�r den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['\tau(2\theta) for ',obj.Name]);
    xlabel('Diffraction angle [�]');
    ylabel('Penetration depth [�m]');
end

% % + Dimensionierung der Eingabegr��en (zun�chst Size von 2*theta)
% %   Alte Variante (2x schneller)
%     twotheta = ip.Results.DiffractionAngle(:);
%     phi = ip.Results.TiltAngle(:);
%     ReshapeSize = size(ip.Results.DiffractionAngle);
%     %--> Gr��en der Eingabevektoren anpassen
%     if isscalar(phi)
%         phi = phi(ones(size(twotheta)));
%     end
%     if isscalar(twotheta)
%         twotheta = twotheta(ones(size(phi)));
%         ReshapeSize = size(ip.Results.TiltAngle);
%     end