tic;
% Find all PDFCardNumbers that match the d-spacings calculated from the
% peak positonsfrom the measurement.
% Tolerance value of difference between d-spacings in database
tol = 0.001;
% Create vector with d-spacings from measurement.
reflex_meas = Peaks;
% Log how many matches were found.
hitcountlog = zeros(1,numel(PDFDataBasesorted));
% Search and match routine. If the difference between the d-spacing value
% of the reference d-spacing and the measured d-spacing is smaller than
% tol, raise hitcount by one. The PDFCard with the highest hitcount are
% the best possible matches. The min. hitcount value can be adjusted if the
% number of matches is to high or to low.
for g = 1:numel(PDFDataBasesorted)
    hit_count = 0;
    reflex_db = PDFDataBasesorted(g).dSpacing;
    for k = 1:size(reflex_db,1)
        for m = 1:size(reflex_meas,1)
            if (abs(reflex_db(k) - reflex_meas(m))) <= tol
            hit_count = hit_count+1;
            end
        end
        hitcountlog(g) = hit_count;
    end
end
   

% Find indices with the highest hitcount.
hitcountmin = 9;
IndexHitCount = find(hitcountlog >= hitcountmin & hitcountlog <= size(reflex_meas,1));

% Store results 
for k =1:length(IndexHitCount)
    ResultSaM{k,1} = PDFDataBasesorted(IndexHitCount(k)).PDFCardNumber;
    ResultSaM{k,2} = PDFDataBasesorted(IndexHitCount(k)).ElementSymbol;
    ResultSaM{k,3} = PDFDataBasesorted(IndexHitCount(k)).ElementName;
    ResultSaM{k,4} = PDFDataBasesorted(IndexHitCount(k)).spaceGroupSymbol;
    ResultSaM{k,5} = PDFDataBasesorted(IndexHitCount(k)).spaceGroupNumber;
    ResultSaM{k,5} = PDFDataBasesorted(IndexHitCount(k)).dSpacing;
end

toc;

% Filter element in Search and Match result.
Element = 'Au';
l = 1;
IndexElementSaM = 1;
for k = 1:size(ResultSaM,1)
if strfind(char(ResultSaM{k,2}),Element);
IndexElementSaM(l) = k;
l = l+1;
end
end
FilterElementSaM = ResultSaM(IndexElementSaM,:);
% 
% % Filter spacegroup in Search and Match result.
% SpaceGroup = 'Fm-3m';
% l = 1;
% IndexSpaceGroupSaM = 1;
% for k = 1:size(ResultSaM,1)
% if strfind(char(ResultSaM{k,4}),SpaceGroup);
% IndexSpaceGroupSaM(l) = k;
% l = l+1;
% end
% end
% FilterSpaceGroupSaM = ResultSaM(IndexSpaceGroupSaM,:);
% 
% % Search PDFDatabase.
% % % Find all machtes in PCPDFDataBase containing element.
% % Element = 'Au';
% % l = 1;
% % for k = 1:numel(PDFDataBase)
% % if strfind(char(PDFDataBase(k).ElementSymbol),Element);
% % IndexElementPDFDatabase(l) = k;
% % l = l+1;
% % end
% % end
% % IndexElementPDFDatabase(IndexElementPDFDatabase==0)=[];
% % 
% % For exact machtes in PCPDFDataBase containing element.
% Element = 'Au';
% l = 1;
% for k=1:numel(PDFDataBase)
% if strcmp(char(PDFDataBase(k).ElementSymbol),Element);
% IndexElementExactPDFDatabase(l) = k;
% l = l+1;
% end
% end
% IndexElementExactPDFDatabase(IndexElementExactPDFDatabase==0)=[];
% 
% % IndexSel= IndexElementPDFDatabase;
% IndexSel= IndexElementExactPDFDatabase;
% % Find element names of the found macthes.
% for k = 1:length(IndexSel)
% MatchElement(k,:) = PDFDataBase(IndexSel(k)).ElementSymbol;
% end
% 
% % Find PDFCardNumber of the found matches.
% for k = 1:length(IndexSel)
% MatchPDFCardNumber(k) = cellstr(PDFDataBase(IndexSel(k)).PDFCardNumber);
% MatchPDFCardNumber = MatchPDFCardNumber';
% end
% 
% % Find d-spacing values of the found matches.
% for k = 1:length(IndexSel)
% Matchdspacing{k,:} = PDFDataBase(IndexSel(k)).dSpacing;
% Matchdspacing = Matchdspacing';
% end

% reflex_db = PDFDataBase(116477).dSpacing;
% hit_count1 = 0;
% for k = 1:size(reflex_db,1)
%     for m = 1:size(Peaks,1)
%         if (abs(reflex_db(k) - reflex_meas(m))) < 0.01
%         hit_count1 = hit_count1+1;
%         end
%     end
% end