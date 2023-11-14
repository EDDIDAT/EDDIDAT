%% (* Reset current measurement data *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Clean up all temporary variables
P.CleanUpTemporaryVariables = true;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Create hard-copy of measurement data.
DataTmp = cell(1, length(Measurement));
for c = 1:length(Measurement)
    DataTmp{c} = Measurement(c).EDSpectrum;
end

if (P.CleanUpTemporaryVariables)
    clear c;
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++