% Open figure for the user to select the elements of the investigated
% material
UserSelElements = periodic_table;
% Count variable
cnt = 1;
% Number of elements selected by the user
numElements = numel(UserSelElements);
% Pre-alloc
ElementComp = zeros(1);

% Function used to scan the database (db).
for g = 1:numel(PDFDataBasesorted)
    % Get lattice spacings of db entry "g"
    reflex_db = PDFDataBasesorted(g).dSpacing;
    % Get elemental formula of db entry "g"
    elements_db_tmp1 = PDFDataBasesorted(g).ElementSymbol;
    % Delete non alphabetic characters and numbers from  elemental formula
    elements_db_tmp2 = regexprep(elements_db_tmp1, '\(|)|!', '');
	elements_db = regexprep(elements_db_tmp2, '[+-]?\d+\.?\d*', '');
    % Split elements into cell array
    NumElements_db = numel(strsplit(char(elements_db),' '));
    % Compare user selected elements with db
    for k = 1:numel(UserSelElements)
        match = strcmp(strsplit(char(elements_db)),UserSelElements{k}); 
        ElementComp(k) = ~all(match == 0);
    end
    % Check whether the number of elements and the elements match the ones
    % from the current pdf file "g". Write it to the results file.
    if numElements == NumElements_db && all(ElementComp == 1)
        if size(unique(reflex_db),1) > 1
            if abs(max(reflex_db) - max(dSpacing)) <= 2
                Hit = Tools.Data.DataSetOperations.FindNearestIndex(unique(reflex_db),dSpacing);
                if ~all(isnan(Hit))
                    Hit = Hit(~isnan(Hit));
                    IndexHit{cnt,1} = Hit;
                    IndexHit{cnt,2} = g;
                    IndexHit{cnt,3} = PDFDataBasesorted(g).ElementSymbol;
                    IndexHit{cnt,4} = PDFDataBasesorted(g).ElementName;
                    IndexHit{cnt,5} = PDFDataBasesorted(g).dSpacing;
                    IndexHit{cnt,6} = PDFDataBasesorted(g).spaceGroupSymbol;
                    IndexHit{cnt,7} = PDFDataBasesorted(g).spaceGroupNumber;
                    IndexHit{cnt,8} = dSpacing;
                    cnt = cnt + 1;
                end       
            end
        end
    end
end


regexprep(regexprep(a, '\(|)|!', ''), '[+-]?\d+\.?\d*', '');

strsplit(char(regexprep(regexprep(PDFDataBasesorted.ElementSymbol, '\(|)|!', ''), '[+-]?\d+\.?\d*', '')))

find(arrayfun(@(PDFDataBasesorted) strsplit(char(regexprep(regexprep(PDFDataBasesorted.ElementSymbol, '\(|)|!', ''), '[+-]?\d+\.?\d*', '')))=='Au'))


tic
for g = 1:10
    elements_db_tmp1 = PDFDataBasesorted(g).ElementSymbol;
    % Delete non alphabetic characters and numbers from  elemental formula
    elements_db_tmp2 = regexprep(elements_db_tmp1, '\(|)|!', '');
	elements_db = regexprep(elements_db_tmp2, '[+-]?\d+\.?\d*', '');
    % Split elements into cell array
    NumElements_db = numel(strsplit(char(elements_db),' '));
    % Compare user selected elements with db
    for k = 1:numel(UserSelElements)
        match = strcmp(strsplit(char(elements_db)),UserSelElements{k}); 
        ElementComp(k) = ~all(match == 0);
    end
end
toc

