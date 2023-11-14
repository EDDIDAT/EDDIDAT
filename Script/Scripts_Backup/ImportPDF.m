function [ PCPDF ] = ImportPDF(Data)
% FileName = Data;
% % Path of the database.
% Path = fullfile('Data', FileName);
% % Read database and save to char array.
% text = fileread(Path);
text = Data;
% text = d;
% Define expressions to search the data base file.
% The expression specifies this pattern:
% P must be the first character.
% P must be followed by 6 numeric characters: \d{6}.
% The 6 numeric characters must be followed by one alphabetic, numeric
% or underscore character: \w{1}.
% The last character must be the one defined in the expression (as
% indicated by the (?!\w) operator (not followed by any alphabetic, numeric
% or underscore character).
T.expression1 = 'P\d{6}\w{1}1(?!\w)';	% 1st row containing the values of the lattice parameter and the # of the pdf card
T.expression2 = 'P\d{6}\w{1}2(?!\w)';	% 2nd row containing the values of the angles (alpha, beta, gamma)
T.expression3 = 'P\d{6}\w{1}3(?!\w)';	% 3rd row containing the spacegroup and spacegroup number
T.expression4 = 'P\d{6}\w{1}4(?!\w)';	% 3rd row containing the density and molecular weight
T.expression5 = 'P\d{6}\w{1}5(?!\w)';	% needed for indexing
T.expression6 = 'P\d{6}\w{1}6(?!\w)';	% 6th row containing the name of the Element
T.expression7 = 'P\d{6}\w{1}7(?!\w)';	% 7th row containing the symbol of the Element
T.expression8 = 'P\d{6}\w{1}G(?!\w)';	% needed for indexing
T.expression9 = 'P\d{6}\w{1}I(?!\w)';	% 8th row containing the values of d-spacing, relative intensity and hkl-values

% Find startIndex of the expressions.
T.startIndex1 = regexp(text,T.expression1);
T.startIndex2 = regexp(text,T.expression2);
T.startIndex3 = regexp(text,T.expression3);
T.startIndex4 = regexp(text,T.expression4);
T.startIndex5 = regexp(text,T.expression5);
T.startIndex6 = regexp(text,T.expression6);
T.startIndex7 = regexp(text,T.expression7);
T.startIndex8 = regexp(text,T.expression8);
T.startIndex9 = regexp(text,T.expression9);
% Combine Index8 and Index 9 in order to loop through all lines containing
% information about d-spacing, hkl-values and relative intensity.
T.startIndex10 = circshift(T.startIndex9',1)';
T.startIndex10(1) = T.startIndex8;
% Number needed to add to the startIndex for reading the property.
T.IndexCorrection = 9;

% Match string according to the experssion in order to check if the expressions are correct.
T.matchStr1 = regexp(text,T.expression1,'match');
T.matchStr2 = regexp(text,T.expression2,'match');
T.matchStr3 = regexp(text,T.expression3,'match');
T.matchStr4 = regexp(text,T.expression4,'match');
T.matchStr5 = regexp(text,T.expression5,'match');
T.matchStr6 = regexp(text,T.expression6,'match');
T.matchStr7 = regexp(text,T.expression7,'match');
T.matchStr8 = regexp(text,T.expression8,'match');
T.matchStr9 = regexp(text,T.expression9,'match');

% Extract the material properties.
% Get pdf card number from expression1.
pdfcardNumber_tmp = regexp(T.matchStr1,'\d*','match');
pdfcardNumber_tmp = vertcat(pdfcardNumber_tmp{:});
pdfcardNumber = pdfcardNumber_tmp{1};

% Get lattice parameter.
latticeParameter = sscanf(text(1:T.startIndex1),'%f');

% Get angles
structureAngles = []; %sscanf(text(T.startIndex1+T.IndexCorrection:T.startIndex2-23),'%f');

% Get spacegroup symbol, spacegroup number, density and molecular weight.
if ~isempty(T.startIndex4)
    if ~isempty(T.startIndex3)
        data_tmp = textscan(text(T.startIndex3+T.IndexCorrection:T.startIndex4-1),'%s%f%f%f%s%f%f%f');
        % Check if spacegroupname is valid. If not, the space group is left
        % empty.
        checkForSpaceGroup = regexp(data_tmp{1,1},'[.]','match');
        checkForSpaceGroup = [checkForSpaceGroup{:}];
        % 
        if isempty(checkForSpaceGroup)
            spaceGroupSymbol = cell2mat(data_tmp{1,1});
            spaceGroupNumber = data_tmp{1,2};
            density = data_tmp{1,6};
            molecularWeight = data_tmp{1,7};
        else
            spaceGroupSymbol = [];
            spaceGroupNumber = [];
            density = [];
            molecularWeight = [];
        end
    else
        spaceGroupSymbol = [];
        spaceGroupNumber = [];
        density = [];
        molecularWeight = [];
    end
elseif isempty(T.startIndex2)  && isempty(T.startIndex4)
        spaceGroupSymbol = [];
        spaceGroupNumber = [];
        density = [];
        molecularWeight = [];
else
    if ~isempty(T.startIndex3)
        data_tmp = textscan(text(T.startIndex2+T.IndexCorrection:T.startIndex3-1),'%s%f%*s%f%f%f');
        % Check if spacegroupname is valid. If not, the space group is left
        % empty.
        checkForSpaceGroup = regexp(data_tmp{1,1},'[.]','match');
        checkForSpaceGroup = [checkForSpaceGroup{:}];
        % 
        if isempty(checkForSpaceGroup)
            spaceGroupSymbol = cell2mat(data_tmp{1,1});
            spaceGroupNumber = data_tmp{1,2};
            density = data_tmp{1,4};
            molecularWeight = data_tmp{1,5};
        else
            spaceGroupSymbol = [];
            spaceGroupNumber = [];
            density = [];
            molecularWeight = [];
        end
    else
        spaceGroupSymbol = [];
        spaceGroupNumber = [];
        density = [];
        molecularWeight = [];
    end
end

% Get element name (maximum names considered is eleven!) 
data_tmp = textscan(text(T.startIndex5+T.IndexCorrection:T.startIndex6-1),'%s%s%s%s%s%s%s%s%s%s%s');
% Delete empty cells.
data_tmp(cellfun(@isempty,data_tmp))=[];
% Delete last entry since it is not part of the name.
data_tmp(end) = [];
% Unnest cell array.
data_tmp = vertcat(data_tmp{:})';
% Check if cell array is part of the name or just a symbol (<3 characters).
% for k = 1:length(data_tmp)
%     if length(data_tmp{k}) < 3
%         data_tmp(k)= [];
%     end
% end
% Get element name from data_tmp.
elementName = strjoin(data_tmp);

% Get element symbol (maximum of elements considered is eleven!) 
data_tmp = textscan(text(T.startIndex6(end)+T.IndexCorrection:T.startIndex7-1),'%s%s%s%s%s%s%s%s%s%s%s');
% Delete empty cells.
data_tmp(cellfun(@isempty,data_tmp))=[];
% Unnest cell array.
data_tmp = vertcat(data_tmp{:})';
% Get element name from data_tmp.
elementSymbol = strjoin(data_tmp);

% Read d-spacing, relative intensity and hkl-values.
if ~isempty(latticeParameter)
    % Prealloc cell array.
    data_tmp2 = cell(1,15);
    % Check for alphabetic character.
    for k = 1:size(T.startIndex10,2)
        % Check if the current text contains an alphabetic character.
        % If true, search the position and use the corresponding format
        % to scan the text.
        checkstringtmp1 = isstrprop(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),'alpha');
        a = find(checkstringtmp1);
        % Check if current text contains an asterisk *. Output marks
        % position of the *.
        checkstringtmp2 = regexp(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),'*');
        % Consider all possible cases. 
        % If "a" is not empty (an alphabetic character is present) and
        % "checkstringtmp2" is emtpy (no asterisk is present).
        if ~isempty(a) && isempty(checkstringtmp2)
            if find(checkstringtmp1) == 23
                % 1.68070  4   3  1  3E  1.65070  7   0  0  6   1.60910 11   2  1  5    5P501244TI
                format1 = '%7f%3f%f%f%f%*s%7f%3f%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format1);
            elseif find(checkstringtmp1) == 46
                % 1.48110  5   4  1  1   1.45460  5   3  3  0E  1.43460  3   4  1  2    7P501244TI
                format2 = '%7f%3f%f%f%f%7f%3f%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format2);    
            elseif find(checkstringtmp1) == 69
                % 1.41800  4   2  1  6   1.40710  3   3  2  4   1.39310  2   3  1  5E   8P501244TI
                format3 = '%7f%3f%f%f%f%7f%3f%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format3);
            elseif size(a,2) == 2 && a(1) == 23 && a(2) == 46
                % 1.68070  4   3  1  3E  1.65070  7   0  0  6E  1.60910 11   2  1  5    5P501244TI
                format4 = '%7f%3f%f%f%f%*s%7f%3f%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format4);
            elseif size(a,2) == 2 && a(1) == 23 && a(2) == 69
                % 1.68070  4   3  1  3E  1.65070  7   0  0  6   1.60910 11   2  1  5E   5P501244TI
                format5 = '%7f%3f%f%f%f%*s%7f%3f%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format5);
            elseif size(a,2) == 2 && a(1) == 46 && a(2) == 69
                % 1.41800  4   2  1  6   1.40710  3   3  2  4E  1.39310  2   3  1  5E   8P501244TI
                format6 = '%7f%3f%f%f%f%7f%3f%f%f%f%*s%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format6);
            elseif size(find(checkstringtmp1),2) == 3
                % 2.35500100	1	1	1C	2.03900	52	2	0	0C	1.44200	32	2	2	0C	1P040784CI
                format7 = '%7f%3d%d%d%d%*s%7f%3d%d%d%d%*s%7f%3d%d%d%d%*s%*d';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format7);
            end
        % If "a" is not empty (an alphabetic character is present) and
        % "checkstringtmp2" is not emtpy (asterisk is present).    
        elseif ~isempty(a) && ~isempty(checkstringtmp2)
            if  size(checkstringtmp2,2) == 1 && checkstringtmp2 == 13 && a(1) == 23
                % 2.02289999*  1  1  0C  1.43040115   2  0  0   1.16792175   2  1  1    1P870722CI
                format4 = '%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format4);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 36 && a(1) == 23
                % 2.02289175   1  1  0C  1.43040999*  2  0  0   1.16792175   2  1  1    1P870722CI
                format5 = '%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format5);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 59 && a(1) == 23
                % 2.02289175   1  1  0C  1.43040999   2  0  0   1.16792175*  2  1  1    1P870722CI
                format6 = '%7f%3f%f%f%f%*s%7f%3f%f%f%f%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format6);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 13 && a(1) == 46
                % 2.02289999*  1  1  0   1.43040115   2  0  0C  1.16792175   2  1  1    1P870722CI
                format7 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format7);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 36 && a(1) == 46
                % 2.02289175   1  1  0   1.43040999*  2  0  0C  1.16792175   2  1  1    1P870722CI
                format8 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format8);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 59 && a(1) == 46
                % 2.02289175   1  1  0   1.43040999   2  0  0C  1.16792175*  2  1  1    1P870722CI
                format9 = '%7f%3f%f%f%f%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format9);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 13 && a(1) == 69
                % 2.02289999*  1  1  0   1.43040115   2  0  0   1.16792175   2  1  1C   1P870722CI
                format10 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format10);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 36 && a(1) == 69
                % 2.02289175   1  1  0   1.43040999*  2  0  0   1.16792175   2  1  1C   1P870722CI
                format11 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format11);
            elseif size(checkstringtmp2,2) == 1 && checkstringtmp2 == 59 && a(1) == 69
                % 2.02289175   1  1  0   1.43040999   2  0  0   1.16792175*  2  1  1C   1P870722CI
                format12 = '%7f%3f%f%f%f%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format12);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 36 && size(a,2) == 1 && a(1) == 23
                % 2.02289999*  1  1  0E  1.43040115*  2  0  0   1.16792175   2  1  1    1P870722CI
                format15 = '%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format15);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 59 && size(a,2) == 1 &&  a(1) == 23
                % 2.02289999*  1  1  0E  1.43040115   2  0  0   1.16792175*  2  1  1    1P870722CI
                format16 = '%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format16);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 36 && size(a,2) == 1 &&  a(1) == 46
                % 2.02289999*  1  1  0   1.43040115*  2  0  0E  1.16792175   2  1  1    1P870722CI
                format17 = '%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format17);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 59 && size(a,2) == 1 &&  a(1) == 46
                % 2.02289999*  1  1  0   1.43040115   2  0  0E  1.16792175*  2  1  1    1P870722CI
                format18 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format18);  
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 36 && size(a,2) == 1 &&  a(1) == 69
                % 2.02289999*  1  1  0   1.43040115*  2  0  0   1.16792175   2  1  1E   1P870722CI
                format19 = '%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format19);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 59 && size(a,2) == 1 &&  a(1) == 69
                % 2.02289999*  1  1  0   1.43040115   2  0  0   1.16792175*  2  1  1E   1P870722CI
                format20 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format20);      
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(2) == 59 && size(a,2) == 1 &&  a(1) == 23
                % 2.02289999   1  1  0E  1.43040115*  2  0  0   1.16792175*  2  1  1    1P870722CI
                format21 = '%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format21);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(1) == 59 && size(a,2) == 1 &&  a(1) == 46
                % 2.02289175   1  1  0   1.43040999*  2  0  0E  1.16792175*  2  1  1    1P870722CI
                format22 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format22);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(2) == 59 && size(a,2) == 1 &&  a(1) == 69
                % 2.02289999   1  1  0   1.43040115*  2  0  0   1.16792175*  2  1  1C   1P870722CI
                format23 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format23);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 36 && size(a,2) == 2 && a(1) == 23 && a(1) == 46
                % 2.02289999*  1  1  0E  1.43040115*  2  0  0E  1.16792175   2  1  1    1P870722CI
                format24 = '%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format24);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 36 && size(a,2) == 2 &&  a(1) == 23 && a(1) == 69
                % 2.02289999*  1  1  0E  1.43040115*  2  0  0   1.16792175   2  1  1E   1P870722CI
                format25 = '%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format25);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 36 && size(a,2) == 2 &&  a(1) == 46 && a(1) == 69
                % 2.02289999*  1  1  0   1.43040115*  2  0  0E  1.16792175   2  1  1E   1P870722CI
                format26 = '%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format26);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 59 && size(a,2) == 2 &&  a(1) == 23 && a(1) == 46
                % 2.02289999*  1  1  0E  1.43040115   2  0  0E  1.16792175*  2  1  1    1P870722CI
                format27 = '%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format27);  
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(2) == 59 && size(a,2) == 2 &&  a(1) == 23 && a(1) == 69
                % 2.02289999*  1  1  0E  1.43040115   2  0  0   1.16792175*  2  1  1E   1P870722CI
                format28 = '%7f%3f%*s%f%f%f%*s%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format28);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 13 && checkstringtmp2(1) == 59 && size(a,2) == 2 &&  a(1) == 46 && a(1) == 69
                % 2.02289999*  1  1  0   1.43040115   2  0  0E  1.16792175*  2  1  1E   1P870722CI
                format29 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format29);      
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(2) == 59 && size(a,2) == 2 &&  a(1) == 23 && a(1) == 46
                % 2.02289999   1  1  0E  1.43040115*  2  0  0E  1.16792175*  2  1  1    1P870722CI
                format30 = '%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format30);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(1) == 59 && size(a,2) == 2 &&  a(1) == 23 && a(1) == 69
                % 2.02289175   1  1  0E  1.43040999*  2  0  0   1.16792175*  2  1  1E   1P870722CI
                format31 = '%7f%3f%f%f%f%*s%7f%3f%*s%f%f%f%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format31);
            elseif size(checkstringtmp2,2) == 2 && checkstringtmp2(1) == 36 && checkstringtmp2(2) == 59 && size(a,2) == 2 &&  a(1) == 46 && a(1) == 69
                % 2.02289999   1  1  0   1.43040115*  2  0  0E  1.16792175*  2  1  1E   1P870722CI
                format32 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%*s%7f%3f%*s%f%f%f%*s%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format32);
            end
        % If "a" is  empty (no alphabetic character is present) and
        % "checkstringtmp2" is not emtpy (asterisk is present).    
        elseif isempty(a) && ~isempty(checkstringtmp2)
            if checkstringtmp2 == 13
                % 2.02289999*  1  1  0   1.43040115   2  0  0   1.16792175   2  1  1    1P870722CI
                format1 = '%7f%3f%*s%f%f%f%7f%3f%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format1);
            elseif checkstringtmp2 == 36
                % 2.02289115   1  1  0   1.43040999*  2  0  0   1.16792175   2  1  1    1P870722CI
                format2 = '%7f%3f%f%f%f%7f%3f%*s%f%f%f%7f%3f%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format2);    
            elseif checkstringtmp2 == 59
                % 2.02289175   1  1  0   1.43040115   2  0  0   1.16792999*  2  1  1    1P870722CI
                format3 = '%7f%3f%f%f%f%7f%3f%f%f%f%7f%3f%*s%f%f%f%*f';
                data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format3);
            end
        % If "a" is  empty (no alphabetic character is present) and
        % "checkstringtmp2" is  emtpy (no asterisk is present).    
        else
            % 2.35500100	1	1	1 	2.03900	52	2	0	0 	1.44200	32	2	2	0 	1P040784CI
            format1 = '%7f%3f%f%f%f%7f%3f%f%f%f%7f%3f%f%f%f%*f';
            data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format1);
        end
    end
        
else
    % Prealloc cell array.
    data_tmp2 = cell(1,6);
    % Check for alphabetic character.
    for k = 1:size(T.startIndex10,2)
        % 20.0000100             9.90000 18             3.40000  5              1P010001XI
        format1 = '%7f%3f%7f%3f%7f%3f%*f';
        data_tmp2(k,:) = textscan(text(T.startIndex10(k)+T.IndexCorrection:T.startIndex9(k)-1),format1);
    end
end

% Check for empty entries in data_tmp2
checkEmpty = cellfun('isempty',data_tmp2);
% Replace all empty cells with nan. Those cells are later deleted. 
data_tmp2(checkEmpty) = {nan};
% Rearrange data_tmp array so that all values are listed columnar.
if ~isempty(latticeParameter)
    data_tmp = [data_tmp2(:,1:5);data_tmp2(:,6:10);data_tmp2(:,11:15)];
else
    data_tmp = [data_tmp2(:,1:2);data_tmp2(:,3:4);data_tmp2(:,5:6)];
end
% Delete rows that contain nan.
data_tmp(any(cellfun(@(x) any(isnan(x)),data_tmp),2),:) = [];
% Convert cell array to matrix.
% Delete cells containing more than one entry.
m = cellfun(@length,data_tmp,'uni',false);
m = cell2mat(m);
m(m==2,:) = 0;
m = m(1:size(data_tmp,1),:);
[row,col] = find(m==0);
data_tmp(row,:) = [];
% data_tmp = cell2mat(data_tmp);
data_tmp = cellfun(@double, data_tmp);
% % Delete lines that contain nan.
% data_tmp = data_tmp(~any(isnan(data_tmp),2),:);

% Sort rows according to largest d-spacing.
data_tmp = sortrows(data_tmp,-1);

% Get d-spacing.
d_spacing = data_tmp(:,1);

% Get relative intensity.
relativeIntensity = data_tmp(:,2);

% Get hkl-values.
if ~isempty(latticeParameter)
    h = data_tmp(:,3);
    k = data_tmp(:,4);
    l = data_tmp(:,5);
else
    h = [];
    k = [];
    l = [];
end
% Create cell array containing the materials properties.
PCPDF = cell(1,1);
PCPDF{1,1}{1,1} = pdfcardNumber;
PCPDF{1,1}{2,1} = cellstr(elementSymbol);
PCPDF{1,1}{3,1} = cellstr(elementName);
if isempty(spaceGroupSymbol)
    PCPDF{1,1}{4,1} = spaceGroupSymbol;
    PCPDF{1,1}{5,1} = spaceGroupNumber;
else
    PCPDF{1,1}{4,1} = cellstr(spaceGroupSymbol);
    PCPDF{1,1}{5,1} = spaceGroupNumber;
end
PCPDF{1,1}{6,1} = density;
PCPDF{1,1}{7,1} = molecularWeight;
PCPDF{1,1}{8,1} = latticeParameter;
PCPDF{1,1}{9,1} = structureAngles;
PCPDF{1,1}{10,1} = d_spacing;
PCPDF{1,1}{11,1} = h;
PCPDF{1,1}{12,1} = k;
PCPDF{1,1}{13,1} = l;
PCPDF{1,1}{14,1} = relativeIntensity;
end

