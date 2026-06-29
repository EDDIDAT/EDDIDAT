% Merge data from different detector positions
% Export peak positions from user definded data
col1 = cell2mat(UserPeaksdata(:,1));
% Get unique peak positions and indices
[vals,~,idx] = unique(col1);
pos = accumarray(idx, (1:numel(col1))', [], @(x){x});

% Now merge data from FitDataMod that are from the same peak, but from
% different detector positions and alphas

MergedFitData = cell(size(pos));

for i = 1:numel(pos)
    idx = pos{i};

    tmp = cell(numel(idx),1);
    for k = 1:numel(idx)
        n = size(FitDataMod{idx(k)},1);
        tmp{k} = [FitDataMod{idx(k)} , idx(k)*ones(n,1)];
    end

    MergedFitData{i} = vertcat(tmp{:});
end



A = cell2mat(MergedFitData);
vals = unique(A(:,6));

Cells = cell(numel(vals),1);

for k = 1:numel(vals)
    NewFitData{k} = A(A(:,6) == vals(k), :);
end


% Now separate the cell arrays for each alpha


% Plot data
for i = 1:numel(MergedFitData)
    data = MergedFitData{i};
    origin = data(:,end);    % Herkunft
    origins = unique(origin);
    figure;
    hold on;
    grid on;
    for k = 1:numel(origins)
        idx = origin == origins(k);
        plot(data(idx,1), data(idx,2), 'o', ...
        'DisplayName', sprintf('FitDataMod{%d}', origins(k)));
    end
    xlabel('Spalte 1 (z.B. Energie)');
    ylabel('Spalte 2 (z.B. Peaklage)');
    title(sprintf('MergedFitData{%d}', i));
    legend('Location','best');
end