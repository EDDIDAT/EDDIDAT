% =========================================================================
% INTEGRATION GUIDE
% How to wire openTrackFitSettings.m into XRD2DStressAnalysis_modPV_pyFAI
% =========================================================================
%
% STEP 1 – Replace the existing "Track & Fit Parameter" button block
% -----------------------------------------------------------------------
% Find the block that starts with:
%
%   h.TrackFitParamText = uicontrol(...)   % "Track & Fit Parameter"
%
% and ends with:
%
%   h.TrackFitButton = uicontrol(...)      % "Track & Fit Peaks"
%
% Replace the WHOLE block (windowDeg, pvoigtMinR2, pvoigtMuBound,
% adaptiveWindowCheck, autoWindowCheck rows PLUS the two header texts)
% with the code below.  The Track & Fit Peaks button itself stays.
%
% ---- PASTE THIS into the main GUI layout section --------------------

% =========================================================
% BLOCK 7b (REPLACED): Settings button + Track & Fit button
% =========================================================

% Bold section header
h.TrackFitParamText = uicontrol(h.myfig,'Style','text','Units','normalized',...
    'Position',[P 0.200 LW-P RH2],...
    'HorizontalAlignment','left','FontWeight','bold',...
    'String','Track & Fit Parameter');

% Single settings button that opens the modal dialog
h.TrackFitSettingsButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[P 0.167 LW-P RH],...
    'String',char(9881) + " " + "Open Settings ...",...  % ⚙ symbol
    'FontSize',9,...
    'Tooltip','Open all Track & Fit parameter settings',...
    'Callback',@trackfitsettingscallback);

% (Keep windowDeg only as a compact read-only display of the window value,
%  or simply remove those lines entirely now that the dialog replaces them)

% Track & Fit Button (unchanged)
h.TrackFitButton = uicontrol(h.myfig,...
    'Style','Pushbutton','Units','normalized',...
    'Position',[P 0.104 LW-P RH],...
    'String','Track & Fit Peaks','FontWeight','bold',...
    'Tooltip','Track and fit peaks directly from pyFAI output',...
    'Callback',@trackfitpeakscallback);

% ---- END PASTE -------------------------------------------------------
%
%
% STEP 2 – Initialise default opts in guidata after guidata(h.myfig, h)
% -----------------------------------------------------------------------
% Right before the final "guidata(h.myfig, h);" call at the bottom of the
% main function, add:

h.trackFitOpts = openTrackFitSettings();   % load defaults silently
% (If you want to pre-fill from a saved file, load it here instead.)

% The call will open the dialog at startup – to AVOID that, initialise
% with the struct directly:
%
%   h.trackFitOpts = struct( ...
%       'profileChiRange',  [-150 -80], ...
%       'trackChiBin',      4,          ...
%       ...                             );
%
% Or simply call openTrackFitSettings with no display by reading the
% defaults from the function without showing the dialog (see STEP 4).


% ---- RECOMMENDED: silent default init --------------------------------
% Add this helper at the bottom of the main GUI function (before callbacks):

% h.trackFitOpts = getTrackFitDefaults();   % see STEP 4


% =========================================================================
% STEP 3 – Add the settings callback
% =========================================================================
% Add the following callback function alongside the other callbacks:

function trackfitsettingscallback(hObj, ~)
    h = guidata(hObj);

    % Open the modal dialog, pre-filled with current opts
    if isfield(h, 'trackFitOpts')
        newOpts = openTrackFitSettings(h.trackFitOpts);
    else
        newOpts = openTrackFitSettings();
    end

    % Store updated opts
    h.trackFitOpts = newOpts;

    % Sync the legacy GUI fields that other callbacks still read directly
    % (keeps backward compatibility with opengammafilecallback etc.)
    set(h.trackChiRangeMinEdit, 'String', num2str(newOpts.profileChiRange(1)));
    set(h.trackChiRangeMaxEdit, 'String', num2str(newOpts.profileChiRange(2)));
    set(h.trackChiBinEdit,      'String', num2str(newOpts.trackChiBin));
    set(h.trackChiAvgBinsEdit,  'String', num2str(newOpts.trackChiAvgBins));
    set(h.smoothPointsEdit,     'String', num2str(newOpts.smoothPoints));

    baselineModes = get(h.baselineModePopup,'String');
    idx = find(strcmp(baselineModes, newOpts.baselineMode), 1);
    if ~isempty(idx)
        set(h.baselineModePopup,'Value',idx);
    end

    guidata(hObj, h);
end


% =========================================================================
% STEP 4 – Use opts in trackfitpeakscallback / opengammafilecallback
% =========================================================================
%
% In opengammafilecallback, replace the manual opts construction block:
%
%   opts = struct();
%   opts.profileChiRange = [chiMin chiMax];
%   opts.trackChiRange   = [chiMin chiMax];
%   ...
%
% with:
%
%   if isfield(h,'trackFitOpts')
%       opts = h.trackFitOpts;
%       % override chi range from the small GUI fields (kept for quick access)
%       opts.profileChiRange = [chiMin chiMax];
%       opts.trackChiRange   = [chiMin chiMax];
%   else
%       opts = struct();
%       opts.profileChiRange = [chiMin chiMax];
%       opts.trackChiRange   = [chiMin chiMax];
%       opts.trackChiBin     = trackChiBin;
%       opts.trackChiAvgBins = trackChiAvgBins;
%       opts.smoothPoints    = smoothPts;
%       opts.baselineMode    = baselineMode;
%   end
%
% In trackfitpeakscallback, pass h.trackFitOpts directly to your
% tracking function instead of building opts locally.
