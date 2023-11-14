% Diese Funktion errechnet zu den Beugungsreflexen gehörigen 
% Strahlungsenergien mit der Bragg-Gleichung, d. h. zu den Intensitäten der
% Beugungs-Reflexe lassen sich die Energien (keV) zuordnen (Index des 
% Arguments Index_Reflexes). Die Vorgabegröße ist hier der
% Beugungswinkel 2*theta.
% Input: DiffractionAngle, Beugungswinkel 2*theta, °, double|va /
%        Index_Reflexes, Index der zu betrachtenden Beugungsreflexe,
%          Null bedeutet, dass alle Reflexe genommen werden, double|opt|va
% Output: E, Energien der Refexe für 2*theta, keV,
%          double|[length(DiffractionLines) length(DiffractionAngle)]
function E = EnergyPositions(obj,DiffractionAngle,Index_Reflexes)

%% (* Stringenzprüfung *)
    %--> Möglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        E = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(DiffractionAngle,{'double'},...
        {'>',0,'<',180,'real'});
    if nargin == 3
        validateattributes(Index_Reflexes,{'double'},...
            {'integer','vector','nonnegative'});
    else
        Index_Reflexes = 0;
    end
    
%% (* Übergabe der relevanten Eigenschaften *)
    twotheta = DiffractionAngle(:);
    %--> Netzebenenabstände aus den Reflexen des Gitters
    if Index_Reflexes == 0
        d = [obj.CrystalLattice.DiffractionLines(:).LatticeSpacing];
    else
        d = [obj.CrystalLattice.DiffractionLines(Index_Reflexes,1). ...
            LatticeSpacing];
    end

%% (* Compute *)
    %Meshgrid
    [twotheta,d] = meshgrid(twotheta,d);
    %Berechnung der Energien aus den HKLDI-Werten und den Beugungswinkeln
    E = Tools.Science.Physics.BraggEq_E(1,twotheta ./ 2,[],d);
    %Zurückformen der Matrix zur Form von DiffractionAngle, wobei sie um
    %eine weitere Dimension mit der Länge von d ergänzt wurde 
    %(1. Dimension)
    E = squeeze(reshape(E,[size(d,1),size(DiffractionAngle)]));
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode für den Plot
function rtn = StandardRangeX(obj)
    %############### ToDo: sinnvoller Bereich
    rtn = [10 90];
end
%--------------------------------------------------------------------------
% Labels-Methode für den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['E(2\theta) for ',obj.Name]);
    xlabel('Diffraction angle [°]');
    ylabel('Energy [keV]');
end

% function [sigma,I0,E0] = CreateGauss(I0,E0)
% %******* SOLLTE SPÄTER PER HANDLE AUF EINE DIFFRAKTOMETERSPEZIFISCHE
% %FUNKTION ÜBERGEBEN WERDEN **********
%     sigma = sqrt((106.3)^2 + 5.546*0.113*3000*E0) / (2000 * sqrt(log(4)));
%     x = (-4*sigma+E0):0.001:(4*sigma+E0);
%     y = I0 * exp(-(x-E0*ones(1,size(x,2))).^2/(2*sigma^2));
%     plot(x,y);
% end
% 
% %Fluoreszenzlinien plotten?, einzeilig und nicht leer
%     ip.addParamValue('FluorescenceLines','none',...
%         @(x)validateattributes(x,{'char'},{'row'}));

%     %InputParser
%     ip = inputParser();
%     %Funktionsargumente hinzufügen
%     ip.addRequired('DiffractionAngle',...
%         @(x)validateattributes(x,{'double'},...
%         {'>',0,'<',180,'real'}));
%     %Index der zu betrachtenden Beugungsreflexe,
%     %Null bedeutet, dass alle Reflexe genommen werden
%     ip.addOptional('Index_Reflexes',0,...
%         @(x)validateattributes(x,{'double'},...
%         {'integer','vector','nonnegative'}));
%     %Parse
%     ip.parse(DiffractionAngle,varargin{:});