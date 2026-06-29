for l = 1:size(dataY,2)
    for k = 1:size(dataY{l},2)
        A = islocalmax(dataY{l}(:,k), 'MinProminence', 5);
        Locations{l,k} = dataX{l}(A);
        Amplitude{l,k} = dataY{l}(A,k);
        % h.Locations{l,k} = Locations{l,k}; % + 29;
    end
end