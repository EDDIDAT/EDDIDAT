% Diese Funktion passt die Eingabe beliebiger Arrays in ihrer Größe an, so
% dass am Ende alle gleich groß sind. Gibt man die Endgröße Size nicht vor
% so wird das Array mit den meisten Elementen genommen.
% Input: Arrays, Cellvarialbe, die die Arrays enthält, cell|va /
%        Size, Endgröße, double|va
% Output: varargout, angepasste Arrays in eine Cellvariable, 
%          cell|[size(Arrays)]
function varargout = MatchSize(Arrays,Size)

%% (* Stringenzprüfung *)
    %--> Prüfen, ob die Größe gegeben ist
    if nargin >= 2
        validateattributes(Size,{'double'},...
            {'integer','positive','finite','row'});
    %--> Wenn nicht, Größe des Arrays mit den meisten Elementen
    else
        [~,Index_tmp] = max(cellfun(@numel,Arrays));
        Size = size(Arrays{Index_tmp});
    end
    
%% (* Ergebnis-Arrays erstellen *)
    %--> Durchlaufen der Arrays
    for i_c = 1:numel(Arrays)
        %--> Wenn die Größe nicht bereits angepasst ist Array vergrößern,
        if any(size(Arrays{i_c}) ~= Size)
            %--> Falls das Array nicht skalar war muss die Größe korrigiert
            %    werden (CutMatrix)
            if ~isscalar(Arrays{i_c})
                varargout{i_c} = repmat(Arrays{i_c},Size);
                varargout{i_c} = Tools.ArrayOperations.CutMatrix(...
                    varargout{i_c},[],Size);
            %--> Falls es skalar ist, schnelle Variante
            else
                varargout{i_c} = Arrays{i_c}(ones(Size));
            end
        else
            %...sonst einfache Übergabe
            varargout{i_c} = Arrays{i_c};
        end
    end
end