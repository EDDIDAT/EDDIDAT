function [MeasurementOut, DataTmpOut] = IntegrateSpectraGUI(Measurement, Binning, Mode, DiscardRemainder, EnergyRange, EnergyRes)
% INTEGRATESPECTRAGUI  Combine consecutive spectra ("binning") by summing
% their intensities, interpolated onto a common energy grid.
%
% Spectra are never combined across a change in psi (SCSAngles.psi):
% e.g. for a Z-scan measured twice, first at psi=-90 for all Z positions
% and then at psi=0 for all Z positions, integration runs independently
% within each of the two psi blocks -- a group/window can never straddle
% the psi=-90/psi=0 boundary. If psi is constant throughout, this has no
% effect (there is only a single block, identical to before).
%
% Input:
%   Measurement       1xN array of measurement objects (as used in
%                     EDDIDAT's h.Measurement), each with .EDSpectrum
%                     [Mx2] (Energy, Intensity), .RealTime, .DeadTime,
%                     .SampleStagePos, .SCSAngles, .twotheta and a
%                     .Clone method.
%   Binning           Positive integer, number of spectra to combine.
%   Mode              'Block' (non-overlapping groups: 1:N, N+1:2N, ...)
%                     or 'Sliding' (overlapping windows, step 1: 1:N,
%                     2:N+1, 3:N+2, ...).
%   DiscardRemainder  [true|false] In 'Block' mode: if a psi block's
%                     length is not a multiple of Binning, discard its
%                     last, incomplete group instead of integrating it
%                     over fewer than Binning spectra. Ignored in
%                     'Sliding' mode (every window is always complete).
%   EnergyRange       [Emin Emax], common energy scale used for the
%                     interpolation before summing.
%   EnergyRes         Energy resolution [keV] of the common energy scale.
%
% Output:
%   MeasurementOut    1xM array (M <= N), clone of Measurement with
%                     .EDSpectrum replaced by the combined spectrum,
%                     .RealTime summed, .DeadTime/.SampleStagePos/
%                     .SCSAngles/.twotheta averaged over its group of
%                     source spectra (e.g. a Z-scan measured at slightly
%                     different Z positions gets the group's mean Z).
%                     All other, non-averaged properties (Name, Sample,
%                     Motors, ...) are taken from the group's first
%                     source spectrum.
%   DataTmpOut        1xM cell array holding the same EDSpectrum data
%                     (for direct use as h.DataTmp/h.DataTmpDet1/2).

    if nargin < 3 || isempty(Mode)
        Mode = 'Block';
    end
    if nargin < 4 || isempty(DiscardRemainder)
        DiscardRemainder = false;
    end

    NrMeas = length(Measurement);
    if ~(isscalar(Binning) && isfinite(Binning) && Binning == round(Binning) && Binning >= 1)
        error('IntegrateSpectraGUI:InvalidBinning', ...
            '"Binning" must be a positive integer.');
    end

    X = linspace(EnergyRange(1), EnergyRange(2), ...
        round((EnergyRange(2)-EnergyRange(1))/EnergyRes))';

    % Split into maximal runs of constant psi -- integration is applied
    % independently within each run further below.
    PsiVec = arrayfun(@(m) m.SCSAngles.psi, Measurement);
    BlockEdges = [0, find(abs(diff(PsiVec)) > 1e-9), NrMeas];

    MeasurementOutList = {};
    DataTmpOutList = {};
    for b = 1:(length(BlockEdges)-1)
        BlockIdx = (BlockEdges(b)+1):BlockEdges(b+1);
        [MeasBlockOut, DataTmpBlockOut] = IntegrateOneBlock( ...
            Measurement(BlockIdx), Binning, Mode, DiscardRemainder, X);
        MeasurementOutList{end+1} = MeasBlockOut; %#ok<AGROW>
        DataTmpOutList{end+1} = DataTmpBlockOut; %#ok<AGROW>
    end

    MeasurementOut = [MeasurementOutList{:}];
    DataTmpOut = [DataTmpOutList{:}];
end

function [MeasurementOut, DataTmpOut] = IntegrateOneBlock(Measurement, Binning, Mode, DiscardRemainder, X)
% Integrates one maximal run of constant-psi spectra (see caller).

    NrMeas = length(Measurement);
    BinningBlock = min(Binning, NrMeas);

    switch Mode
        case 'Sliding'
            GroupStarts = 1:(NrMeas-BinningBlock+1);
        otherwise % 'Block'
            GroupStarts = 1:BinningBlock:NrMeas;
    end
    NrGroups = length(GroupStarts);

    if NrGroups == 0
        % Sliding mode with a psi-block shorter than Binning: no full
        % window fits without crossing into the next psi value. Plain
        % [] concatenates cleanly with the other blocks' object arrays.
        MeasurementOut = [];
        DataTmpOut = {};
        return
    end

    % Template array of the correct custom class, sized to the final
    % result -- cloned from each group's FIRST source spectrum, so any
    % property not explicitly averaged below (Name, Sample, Motors, ...)
    % is at least taken from a spectrum that actually belongs to that
    % group (not an unrelated one at the same array position).
    MeasurementOut = Measurement(GroupStarts).Clone;

    for g = 1:NrGroups
        idxStart = GroupStarts(g);
        idxEnd = min(idxStart+BinningBlock-1, NrMeas);
        GroupIdx = idxStart:idxEnd;

        MeasurementOut(g).RealTime = sum([Measurement(GroupIdx).RealTime]);
        MeasurementOut(g).DeadTime = mean([Measurement(GroupIdx).DeadTime]);
        % Position/angle parameters can genuinely differ between the
        % spectra being combined (e.g. a Z-scan) -- assign the group's
        % mean instead of silently keeping only the first spectrum's
        % value.
        MeasurementOut(g).SampleStagePos = mean(vertcat(Measurement(GroupIdx).SampleStagePos), 1);
        MeasurementOut(g).twotheta = mean([Measurement(GroupIdx).twotheta]);
        AngleFields = fieldnames(Measurement(idxStart).SCSAngles);
        for af = 1:numel(AngleFields)
            AngleVals = arrayfun(@(m) m.SCSAngles.(AngleFields{af}), Measurement(GroupIdx));
            MeasurementOut(g).SCSAngles.(AngleFields{af}) = mean(AngleVals);
        end

        Intensity_interp = zeros(length(GroupIdx), length(X));
        for j = 1:length(GroupIdx)
            EDSpectrum = Measurement(GroupIdx(j)).EDSpectrum;
            Intensity_interp(j,:) = interp1(EDSpectrum(:,1), EDSpectrum(:,2), X, 'linear', NaN);
        end
        NewEDSpectrum = [X, sum(Intensity_interp,1)'];
        % Drop channels where any of the group's spectra had no coverage
        NewEDSpectrum = NewEDSpectrum(~any(isnan(NewEDSpectrum),2),:);
        MeasurementOut(g).EDSpectrum = NewEDSpectrum;
    end

    % Discard a genuinely incomplete trailing group (Block mode only --
    % every window in Sliding mode is already exactly Binning spectra)
    if strcmp(Mode,'Block') && DiscardRemainder && NrGroups >= 1
        LastGroupLen = min(GroupStarts(end)+BinningBlock-1, NrMeas) - GroupStarts(end) + 1;
        if LastGroupLen < BinningBlock
            MeasurementOut(end) = [];
        end
    end

    DataTmpOut = cell(1, length(MeasurementOut));
    for c = 1:length(MeasurementOut)
        DataTmpOut{c} = MeasurementOut(c).EDSpectrum;
    end
end
