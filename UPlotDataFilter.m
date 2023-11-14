function [UPlot] = UPlotDataFilter(h)
%Filter for universal plot data. Values that are Inf are deleted as well as
%values with large errors (err > 500 MPa) and values larger than
%2.*meanerror.
% Load UPlot structure
UPlot = h.UPlot;

% Get indices of user defined peaks
indkeeppeaks = find(h.userpeaksuplot==1);

% Repmat tau for deleting Inf and large error values for each stress
% component
tautmp = repmat(UPlot.TauCalc.tau,4,1);
for k = 1:size(indkeeppeaks,1)
    sinsquarepsi{k} = h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(:,1);
end
sin2psitmp = repmat(sinsquarepsi,4,1);
% Find inf values in cell arrays
IndInfsigma11 = cellfun(@isinf,UPlot.sigma11,'UniformOutput',false);
IndInfsigma22 = cellfun(@isinf,UPlot.sigma22,'UniformOutput',false);
IndInfsigma13 = cellfun(@isinf,UPlot.sigma13,'UniformOutput',false);
IndInfsigma23 = cellfun(@isinf,UPlot.sigma23,'UniformOutput',false);
IndDel = [IndInfsigma11;IndInfsigma22;IndInfsigma13;IndInfsigma23];
% Delete inf values in tau and stress data
for k = 1:4
    for l = 1:size(IndDel,2)
        tautmp{k,l}(IndDel{k,l}) = [];
        sin2psitmp{k,l}(IndDel{k,l}) = [];
    end
end

for l = 1:size(IndDel,2)
    UPlot.sigma11{l}(IndDel{1,l}) = [];
    UPlot.sigma11delta{l}(IndDel{1,l}) = [];
    UPlot.sigma22{l}(IndDel{2,l}) = [];
    UPlot.sigma22delta{l}(IndDel{2,l}) = [];
    UPlot.sigma13{l}(IndDel{3,l}) = [];
    UPlot.sigma13delta{l}(IndDel{3,l}) = [];
    UPlot.sigma23{l}(IndDel{4,l}) = [];
    UPlot.sigma23delta{l}(IndDel{4,l}) = [];
end

% For sigma13 and sigma23 the errors can be quite large, therefore filter
% error values larger than 500 first
sigma11higherr = cellfun(@(x) x>str2double(get(h.editfilter1sigma11,'String')), UPlot.sigma11delta, 'UniformOutput', false);
sigma22higherr = cellfun(@(x) x>str2double(get(h.editfilter1sigma22,'String')), UPlot.sigma22delta, 'UniformOutput', false);
sigma13higherr = cellfun(@(x) x>str2double(get(h.editfilter1sigma13,'String')), UPlot.sigma13delta, 'UniformOutput', false);
sigma23higherr = cellfun(@(x) x>str2double(get(h.editfilter1sigma23,'String')), UPlot.sigma23delta, 'UniformOutput', false);

% Delete large error values from tau and stress data
for l = 1:size(sigma11higherr,2)
    tautmp{1,l}(sigma11higherr{l}) = [];
    sin2psitmp{1,l}(sigma11higherr{l}) = [];
    UPlot.sigma11{l}(sigma11higherr{l}) = [];
    UPlot.sigma11delta{l}(sigma11higherr{l}) = [];
end

for l = 1:size(sigma22higherr,2)
    tautmp{2,l}(sigma22higherr{l}) = [];
    sin2psitmp{2,l}(sigma22higherr{l}) = [];
    UPlot.sigma22{l}(sigma22higherr{l}) = [];
    UPlot.sigma22delta{l}(sigma22higherr{l}) = [];
end

for l = 1:size(sigma13higherr,2)
    tautmp{3,l}(sigma13higherr{l}) = [];
    sin2psitmp{3,l}(sigma13higherr{l}) = [];
    UPlot.sigma13{l}(sigma13higherr{l}) = [];
    UPlot.sigma13delta{l}(sigma13higherr{l}) = [];
end

for l = 1:size(sigma23higherr,2)
    tautmp{4,l}(sigma23higherr{l}) = [];
    sin2psitmp{4,l}(sigma23higherr{l}) = [];
    UPlot.sigma23{l}(sigma23higherr{l}) = [];
    UPlot.sigma23delta{l}(sigma23higherr{l}) = [];
end

% Calculate mean error values for each stress component
sigma11meanerr = cellfun(@mean,UPlot.sigma11delta,'UniformOutput',false);
sigma22meanerr = cellfun(@mean,UPlot.sigma22delta,'UniformOutput',false);
sigma13meanerr = cellfun(@mean,UPlot.sigma13delta,'UniformOutput',false);
sigma23meanerr = cellfun(@mean,UPlot.sigma23delta,'UniformOutput',false);

% Get indices for error value slarger than 2*meanerr
for k = 1:size(UPlot.sigma11delta,2)
    Indsigma11del{k} = UPlot.sigma11delta{k} > str2double(get(h.editfilter2sigma11,'String')).*sigma11meanerr{k};
    Indsigma22del{k} = UPlot.sigma22delta{k} > str2double(get(h.editfilter2sigma22,'String')).*sigma22meanerr{k};
    Indsigma13del{k} = UPlot.sigma13delta{k} > str2double(get(h.editfilter2sigma13,'String')).*sigma13meanerr{k};
    Indsigma23del{k} = UPlot.sigma23delta{k} > str2double(get(h.editfilter2sigma23,'String')).*sigma23meanerr{k};
end

% Delete values higher than 2*meanerr
for l = 1:size(UPlot.sigma11,2)
    UPlot.sigma11{l}(Indsigma11del{l}) = [];
    UPlot.sigma11delta{l}(Indsigma11del{l}) = [];
    UPlot.sigma22{l}(Indsigma22del{l}) = [];
    UPlot.sigma22delta{l}(Indsigma22del{l}) = [];
    UPlot.sigma13{l}(Indsigma13del{l}) = [];
    UPlot.sigma13delta{l}(Indsigma13del{l}) = [];
    UPlot.sigma23{l}(Indsigma23del{l}) = [];
    UPlot.sigma23delta{l}(Indsigma23del{l}) = [];
    tautmp{1,l}(Indsigma11del{l}) = [];
    sin2psitmp{1,l}(Indsigma11del{l}) = [];
    tautmp{2,l}(Indsigma22del{l}) = [];
    sin2psitmp{2,l}(Indsigma22del{l}) = [];
    tautmp{3,l}(Indsigma13del{l}) = [];
    sin2psitmp{3,l}(Indsigma13del{l}) = [];
    tautmp{4,l}(Indsigma23del{l}) = [];
    sin2psitmp{4,l}(Indsigma23del{l}) = [];
end

UPlot.TauCalc.tau = tautmp;
UPlot.sin2psi = sin2psitmp;

end

