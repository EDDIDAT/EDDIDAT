function Y = sprepmat(X, D)

    if (~issparse(X))
        
        X = sparse(X);
    end

    M = D(1);
    N = D(2);

    [m,n] = size(X);
    
    rowIdx = [1 : m]';
    colIdx = [1 : n]';

    Y = X(rowIdx(:, ones(M,1)), colIdx(:, ones(N,1)));
end