% Create matrix for the line plot of the peak positions (X values)
for k = 1:nnz(indplot)
    for i = 1:size(IndexHit{k,5},1)
        EPosLinetmp(:,i) = [(6.199./sind(8)).*(1./(IndexHit{k,5}(i))) (6.199./sind(8)).*(1./(IndexHit{k,5}(i))) nan];
    end

    EPosLinetmp1 = reshape(EPosLinetmp,size(EPosLinetmp,1)*size(EPosLinetmp,2),1);
    EPosLinetmp1(size(EPosLinetmp,1)*size(EPosLinetmp,2),:) = [];

    y_tmp = repmat([0 250 nan],1,size(EPosLinetmp,2))';
    % y_tmp = repmat([0 h.axesplotMeasDataQA.YLim(2) nan],1,size(test_tmp1,2))';
    y_tmp(size(EPosLinetmp,1)*size(EPosLinetmp,2),:) = [];
    
    xdata{k} = EPosLinetmp1;
    ydata{k} = y_tmp;
    clear EPosLinetmp
end

% Adjust the size of matrix to the measurement
T.X2 = reshape(T.X1',size(T.Peaks,1).*3,1);
T.X2(size(T.Peaks,1).*3,:) = [];
T.X3 = repmat(T.X2,1,LengthMeas);
% Adjust the size of matrix to the measurement
T.Y2 = reshape(T.Y1',3,LengthMeas);
T.Y3 = repmat(T.Y2,size(T.Peaks,1),1);
T.Y3(size(T.Peaks,1).*3,:)= [];