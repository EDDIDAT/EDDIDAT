% Diese Funktion erzeugt ein Array von identischen Objekten mit Hilfe eines
% Konstruktors. Die Objekte haben aber unterschiedliche Referenzen.
% Input: Constructor, Aufzurufender Konstruktor, function_handle|va /
%        Size, Gr��e des neuen Arrays, double|va
% Output: obj, Array mit den neuen Objekten, class|[Size]
function obj = CloneConstruction(Constructor,Size)

%% (* Stringenzpr�fung *)
    validateattributes(Constructor,{'function_handle'},{'scalar'});
    validateattributes(Size,{'double'},...
        {'integer','positive','finite','row'});
    
%% (* Replizieren *)
    %Prealloc in der passenden Gr��e
    obj = repmat(Constructor(),Size);
    %--> Erzeugen aller Objekte mit dem Konstruktor
    for i_c = 1:numel(obj)
        obj(i_c) = Constructor();
    end
end