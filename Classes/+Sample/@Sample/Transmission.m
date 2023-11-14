% Diese Funktion berechnet die enegieabh�ngige Transmission T (%) von 
% Synchrotonr�ntgenstrahlung durch beliebige Material Kombinationen, wobei
% zwischen Schichtsystemen und Phasengemengen unterschieden werden muss.
% Input: Energy, Energie, keV, double|va
% Output: T, Transmission, %, double|[size(Energy)]
function T = Transmission(obj,Energy)

%% (* Stringenzpr�fung *)
    %--> M�glichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        T = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'positive','real','finite'});
        
%% (* �bergabe der relevanten Eigenschaften *)
    %Als Row
    E = Energy(:);
    
%% (* Vorbereitung *)
    %Schichtdicken in cm
    d = [obj.Materials(:).CoatingThickness] ./ 10;
    %LACs der einzelnen Materialen
    mu_mat = cellfun(@(obj)LAC(obj,E),...
        num2cell(obj.Materials),'UniformOutput',false);
    %F�r den Fall, dass man einen Zeilenvektor als Argument �bergibt
    mu_mat = reshape([mu_mat{:}],length(E),[]);
            
%% (* Compute *)
    T = exp(-mu_mat * d.') .* 100;
    %Zur�ck dimensionieren
    T = reshape(T,size(Energy));
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode f�r den Plot
function rtn = StandardRangeX(obj)
    %Liste alle Elemente erstellen, zur �bersicht
    Elements_tmp = [obj.Materials(:).ChemicalElements];
    %Kleinstes bzw. gr��stes Element der MAC_Data f�r jedes Element
    %einlesen
    E_Min = cell2mat(cellfun(@min,{Elements_tmp(:).MAC_Data},...
        'UniformOutput',false));
    E_Max = cell2mat(cellfun(@max,{Elements_tmp(:).MAC_Data},...
        'UniformOutput',false));
    %Vergleichskriterium ist die Energie und nicht der MSK
    rtn = [max(E_Min(1:2:end)) min(E_Max(1:2:end))]; disp(rtn);
end
%--------------------------------------------------------------------------
% Labels-Methode f�r den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['T(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Transmission [%]');
end