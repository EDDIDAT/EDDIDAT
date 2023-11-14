% Diese Funktion berechnet die enegieabhängige Transmission T (%) von 
% Synchrotonröntgenstrahlung durch beliebige Material Kombinationen, wobei
% zwischen Schichtsystemen und Phasengemengen unterschieden werden muss.
% Input: Energy, Energie, keV, double|va
% Output: T, Transmission, %, double|[size(Energy)]
function T = Transmission(obj,Energy)

%% (* Stringenzprüfung *)
    %--> Möglichkeit Handles auf die Subfunctions zu bekommen
    if nargin == 1
        T = {@Labels,@StandardRangeX};
        return;
    end
    validateattributes(Energy,{'double'},{'positive','real','finite'});
        
%% (* Übergabe der relevanten Eigenschaften *)
    %Als Row
    E = Energy(:);
    
%% (* Vorbereitung *)
    %Schichtdicken in cm
    d = [obj.Materials(:).CoatingThickness] ./ 10;
    %LACs der einzelnen Materialen
    mu_mat = cellfun(@(obj)LAC(obj,E),...
        num2cell(obj.Materials),'UniformOutput',false);
    %Für den Fall, dass man einen Zeilenvektor als Argument übergibt
    mu_mat = reshape([mu_mat{:}],length(E),[]);
            
%% (* Compute *)
    T = exp(-mu_mat * d.') .* 100;
    %Zurück dimensionieren
    T = reshape(T,size(Energy));
end
%--------------------------------------------------------------------------
% StandardRangeX-Methode für den Plot
function rtn = StandardRangeX(obj)
    %Liste alle Elemente erstellen, zur Übersicht
    Elements_tmp = [obj.Materials(:).ChemicalElements];
    %Kleinstes bzw. größstes Element der MAC_Data für jedes Element
    %einlesen
    E_Min = cell2mat(cellfun(@min,{Elements_tmp(:).MAC_Data},...
        'UniformOutput',false));
    E_Max = cell2mat(cellfun(@max,{Elements_tmp(:).MAC_Data},...
        'UniformOutput',false));
    %Vergleichskriterium ist die Energie und nicht der MSK
    rtn = [max(E_Min(1:2:end)) min(E_Max(1:2:end))]; disp(rtn);
end
%--------------------------------------------------------------------------
% Labels-Methode für den Plot
function Labels(obj,ip)
    %Beschriftung
    title(['T(E) for ',obj.Name]);
    xlabel('Energy [keV]');
    ylabel('Transmission [%]');
end