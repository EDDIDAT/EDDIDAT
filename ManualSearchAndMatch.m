%% (* Manual for the search and match routine *)
% This manual explains the usage of the search and match routine. Only
% three scripts are needed for the search and match.
% 
%   1.CreateSample.m - script
%   2.SpecFileConversion.m - script
%   3.PlotSearchAndMatch.m - script
% 
% The 1. script is needed to create the objects to define the measurement
% conditions. The material information can be anything. It has no influence
% on the search and match. The 2. script is for the specfile conversion in
% order to access the measured spectra. The 3. script opens the GUI for the
% Search and Match routine. If the script is started for the first time the
% PCPDFDatabase is loaded, which may take some time. Then the GUI opens.
% The following list shortly explains how the Search and Match is executed.
% 
% 1. Select all peaks that you want to include in the Search and Match. If
%    you want to exclude peaks from the Search and Match, klick the
%    respective checkbox in the table.
% 2. ++ Search and Match tab ++
%    Define 'tolerance' and 'hits' values. The tolerance value defines how
%    big the difference between the peak positions (d-spacing values) of
%    the measured and reference peaks can be. A larger tolerance valuegives
%    more results. The hits value exludes results were less than 'hits'
%    peaks were matched. A smaller value gives more results. The maximum
%    value should equal the number of peaks selected for the Search and
%    Match.
% 3. ++ Results tab ++
%    The results from the Search and Match are displayed in the table in
%    the results tab. Since there are mostly a large number of results you
%    can filter the results. Press the 'Filter options' button to open a
%    new window with the filter options. You can filter the results
%    according to:
% 
%       1. Element filter: Enter element(s) (comma separated) you want to
%       filter. All phases containing one of the elements will be shown.
%       You can choose the options single element, which searches for
%       phases containing only one element. You can search for compounds
%       which searches for phases containing all elements entered.
%       2. Name filter: Enter name(s) of the element(s) you want to search
%       for. All phases containing the entered names will be filtered.
%       3. Crystal system: choose the crystal system of the desired phase.
%       The phases are filtered according to their spacegroup number.
% 
% Push 'Ok' to transfer the filtered table to the results tab. Push
% 'Cancel' to dismiss the filter and load the original table from Search
% and Match.
% You can now choose phases to plot by checking the checkbox in the table.
% If you want to plot more than one phase you can do so. If you want to add
% another phase to the plot after you already plotted another phase, please 
% clear the previously chosen phases by unchecking the respective checkbox 
% and press 'Clear'. Now you can select another phase to plot. If you add
% another phase to the plot after you previously plotted phases, those
% phases will not be cleared from the plot, even if you clear all phases.
% This is a bug. 
% 
% You can use the PDFCardNumber of your selected phase in the evaluation
% program.