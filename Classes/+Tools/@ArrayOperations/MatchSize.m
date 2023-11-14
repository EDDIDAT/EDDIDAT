% Diese Funktion passt die Eingabe beliebiger Arrays in ihrer Gr��e an, so
% dass am Ende alle gleich gro� sind. Gibt man die Endgr��e Size nicht vor
% so wird das Array mit den meisten Elementen genommen.
% Input: Arrays, Cellvarialbe, die die Arrays enth�lt, cell|va /
%        Size, Endgr��e, double|va
% Output: varargout, angepasste Arrays in eine Cellvariable, 
%          cell|[size(Arrays)]
function varargout = MatchSize(Arrays,Size)

%% (* Stringenzpr�fung *)
    %--> Pr�fen, ob die Gr��e gegeben ist
    if nargin >= 2
        validateattributes(Size,{'double'},...
            {'integer','positive','finite','row'});
    %--> Wenn nicht, Gr��e des Arrays mit den meisten Elementen
    else
        [~,Index_tmp] = max(cellfun(@numel,Arrays));
        Size = size(Arrays{Index_tmp});
    end
    
%% (* Ergebnis-Arrays erstellen *)
    %--> Durchlaufen der Arrays
    for i_c = 1:numel(Arrays)
        %--> Wenn die Gr��e nicht bereits angepasst ist Array vergr��ern,
        if any(size(Arrays{i_c}) ~= Size)
            %--> Falls das Array nicht skalar war muss die Gr��e korrigiert
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
            %...sonst einfache �bergabe
            varargout{i_c} = Arrays{i_c};
        end
    end
end