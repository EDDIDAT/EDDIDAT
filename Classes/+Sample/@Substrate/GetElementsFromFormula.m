% Diese Funktion interpretiert die Summenformel entsprechend dem
% Vorgabemuster (E_1n_1 E_2n_2 ... E_in_i). Sie sucht die passenden
% Elemente aus den Dateien und erg�nzt die St�chiometrieanteile.
% Input: none
% Output: none
function GetElementsFromFormula(obj)

%% (* Verwendung von regexp *)
    %Summenformel zum Bearbeiten
    ElementalFormula_tmp = [obj.ElementalFormula,' '];
    %Indizies der verschiedenen Anteile
    Index = regexp(ElementalFormula_tmp,'[a-zA-Z]\s') + 1;  % Index legt die Stelle fest, an dem sich ein Leerzeichen befindet.
    %--> Wenn der St�chiometrieanteil weggelassen wurde, wird eine 1
    %    eingef�gt
    if ~isempty(Index), ElementalFormula_tmp(Index) = '1'; end % Wenn die Stelle am Index "leer" ist, wird eine 1 eingefuegt.
    %Elementnamen finden
    Names = regexp(ElementalFormula_tmp,'([a-zA-Z])*','match'); % 
    %St�chiometrieanteile als cellarray von doubles finden
    Stoichiometry = num2cell(str2double(regexp(ElementalFormula_tmp,...
        '([0-9.])*','match')));

%% (* Laden der Elemente *)
    %Prealloc
    obj.ChemicalElements = repmat(Sample.ChemicalElement,1,length(Names));
    %--> Laden der Elemente anhand der Liste
    for i_c = 1:length(Names)
        try
            obj.ChemicalElements(i_c) =...
                Sample.ChemicalElement.LoadFromFile(Names{i_c},...
                Sample.ChemicalElement);
        catch Exception
            warning(Exception.identifier,['The Formula seems to be',...
                ' invalid!']);
        end
    end
    %Zuweisen der St�chiometrieliste
    [obj.ChemicalElements(:).Stoichiometry] = deal(Stoichiometry{:});
end