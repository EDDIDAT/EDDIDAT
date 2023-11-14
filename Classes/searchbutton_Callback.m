function searchbutton_Callback(source,~,data1,data2,data3,data4)
    % Load plothandles.
    Plothandles = guidata(gcbo);
    % Callback for pushbutton. During the search the button changes it's
    % colour to red. When the search is finished, the colour changes back.
    h = source; % Get the caller's handle.
    col = get(h,'backg');  % Get the background color of the figure.
    set(h,'str','RUNNING...','backg',[1 .6 .6]) % Change color of button. 
    % The pause (or drawnow) is necessary to make button changes appear.
    pause(.01)  % FLUSH the event queue, drawnow would work too.
    % Load peak information from uitable.
    tabledata = get(data1,'Data');
    % Convert peak positions to matrix (first column).
    Peakstmp = cell2mat(tabledata(:,1));
    % Get logical from table (second column).
    ChoiceLogical = cell2mat(tabledata(:,2));
    % Use only peaks selected by the user.
    Peaks = Peakstmp(ChoiceLogical);
    % Calculate d-values from energy positions.
    dSpacing = 6.199./sind(Plothandles.TwoTheta./2).*1./Peaks;
    % Load PCPDFdatabase.
    PDFDataBasesorted = evalin('base','PDFDataBasesorted');
    assignin('base','dSpacing',dSpacing)
    % Find all PDFCardNumbers that match the d-spacings calculated from the
    % peak positons from the measurement.
    % Tolerance value of difference between d-spacings in databaseas
    % defined by the user.
    tol = str2double(data2.String);
    % Create vector with d-spacings from measurement.
    reflex_meas = dSpacing;
    % Log how many matches were found.
    hitcountlog = zeros(1,numel(PDFDataBasesorted));
    % Search and match routine. If the difference between the d-spacing 
    % value of the reference d-spacing and the measured d-spacing is 
    % smaller than tol, raise hitcount by one. The PDFCards with the 
    % highest hitcount are the best possible matches. The hits value can 
    % be adjusted if the number of matches is to high or to low.
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
    hitcountmin = str2double(data3.String);
    IndexHitCount = find(hitcountlog >= hitcountmin & hitcountlog <= size(reflex_meas,1));

    % Store results. 
    for k =1:length(IndexHitCount)
        ResultSaM{k,1} = PDFDataBasesorted(IndexHitCount(k)).PDFCardNumber;
        ResultSaM{k,2} = PDFDataBasesorted(IndexHitCount(k)).ElementSymbol;
        ResultSaM{k,3} = PDFDataBasesorted(IndexHitCount(k)).ElementName;
        ResultSaM{k,4} = PDFDataBasesorted(IndexHitCount(k)).spaceGroupSymbol;
        ResultSaM{k,5} = PDFDataBasesorted(IndexHitCount(k)).spaceGroupNumber;
        ResultSaM{k,6} = PDFDataBasesorted(IndexHitCount(k)).dSpacing;
    end
    % Save results to Plothandles.
    Plothandles.ResultSaM = ResultSaM;
    Plothandles.IndexHitCount = IndexHitCount;
    guidata(gcbo,Plothandles);
    % Now reset the button features (colour).
    set(h,'str','Search Database','backg',col)
    % Save the number of found matches.
    set(data4,'String',num2str(length(IndexHitCount)))
end