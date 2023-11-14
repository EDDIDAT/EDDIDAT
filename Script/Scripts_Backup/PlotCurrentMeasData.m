%% (* plot the current measurement data *)
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
% Choose "true" if the x-data should be keV
P.XInUnit = true;
% Clean up all temporary variables
P.CleanUpTemporaryVariables = true;
%% ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
T.Figure = figure('name','Current Measurement Data', 'NumberTitle','off', 'Toolbar', 'figure','units','normalized','OuterPosition',[0.125 0.125 0.75 0.75]);
% Create GUI-data and save handle structure
Plothandles = guihandles(T.Figure);
Plothandles.PopupValue = 0;
Plothandles.h = 0;
Plothandles.hphase = 0;
Plothandles.SliderValue = 0;
Plothandles.MPDFile = 0;
Plothandles.PhaseInfo = 0;
guidata(T.Figure,Plothandles);
% Daten fuer das Slider-Callback
T.Plots = zeros(length(Measurement),2);
T.Texts = zeros(length(Measurement),2);
T.Title = cell(length(Measurement),1);
% Plot of substrate peaks
T.PlotSubstratePeaks = Measurement(1).Sample.Materials.ShowSubstratePeaks;
% TwoTheta of measurement
T.twotheta = Measurement(1).twotheta;

% Info from material
% Maximum Energy up to which peak positions are calculated
T.EMax = Measurement(1).Sample.Materials.EnergyMax;
% Crystal structure of the material
T.cs = Measurement(1).Sample.Materials.CrystalStructure;
% Lattice parameter of the material
T.a0 = Measurement(1).Sample.Materials.LatticeParameter;
% Calculation of minimum d spacing
T.dmin = (0.6199/sind(T.twotheta/2))/T.EMax;
% Calculation of maximum hkl²
if ~isempty(T.a0)
    T.hklquadratmax = (T.a0(1)/T.dmin)^2;
else
    T.hklquadratmax = [];
end

% Info from substrate
if (T.PlotSubstratePeaks)
    % Maximum Energy up to which peak positions are calculated
    S.EMax = Measurement(1).Sample.Substrate.EnergyMax;
    % Crystal structure of the material
    S.cs = Measurement(1).Sample.Substrate.CrystalStructure;
    % Lattice parameter of the material
    S.a0 = Measurement(1).Sample.Substrate.LatticeParameter;
    % Calculation of minimum d spacing
    S.dmin = (0.6199/sind(T.twotheta/2))/S.EMax;
    % Calculation of maximum hkl²
    S.hklquadratmax = (S.a0(1)/S.dmin)^2;
end

% Calculation of the maximum peak intensities of the respecive spectrum
T.Peaks_y = zeros(length(Measurement),1);
% Find intensity maximum
for i = 1:length(Measurement)
    T.Peaks_y(i,:) = max(DataTmp{i}(:, 2));
end
% Create matrix for the line plot of the peak positions (Y values)
for i = 1:length(Measurement)
    T.Y1(i,:) = [0 T.Peaks_y(i) nan];
end

%% Plot diffraction lines from Material
% Calculation of peak positions for bcc materials
if strcmp(T.cs,'bcc')
    % Calculation of all possible hkl combinations
    [T.h, T.k, T.l] = ndgrid(1:10, 0:9, 0:9);
    T.d = T.h+T.k+T.l;
    i = find(rem(T.d,2) == 0);
    T.p = [T.h(i),T.k(i),T.l(i)];
    % Use only hkl with hkl² < hkl²max
    for i=1:length(T.p)
        if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
            T.y(i,:) = T.p(i,:);
        end
    end
    % delete zero rows
    T.y(all(T.y == 0,2),:)=[];
    % Use only hkl that are allowed for bcc materials
    for i=1:length(T.y)
        if T.y(i,1) >= T.y(i,2) && T.y(i,1) >= T.y(i,3) && T.y(i,2) >= T.y(i,3)
           T.z(i,:) = T.y(i,:);
        end
    end
    % delete zero rows
    T.z(all(T.z == 0,2),:)=[];
    % Calculation of theoretical d spacings for the used hkl values
    for i = 1:length(T.z)
        T.dtheo(i,:) = T.a0/(sqrt(T.z(i,1)^2+T.z(i,2)^2+T.z(i,3)^2));
    end

    T.hkl = [T.z T.dtheo];
    % Sort columns in descending order
    T.hkl_sort = sortrows(T.hkl, -4);
    % Calculation of theoreitcal energy positons for the used hkl values
    for i = 1:size(T.hkl_sort,1)
        T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
    end
    
    T.Peaks = [T.hkl_sort T.Etheo];

% Calculation of peak positions for bcc materials
elseif strcmp(T.cs,'fcc')
    % Calculation of all possible hkl combinations
    [T.h, T.k, T.l] = ndgrid(1:10, 0:9, 0:9);
    T.d = T.h+T.k+T.l;
    i = find(rem(T.d,2) == 0);
    j = find(rem(T.d,2) == 1);
    T.p = [T.h(i),T.k(i),T.l(i);T.h(j),T.k(j),T.l(j)];
    % Use only hkl with hkl² < hkl²max
    for i=1:length(T.p)
        if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
            T.y(i,:) = T.p(i,:);
        end
    end
    % delete zero rows
    T.y(all(T.y == 0,2),:)=[];
    % Use only hkl that are allowed for fcc materials
    for i=1:length(T.y)
        if T.y(i,1) >= T.y(i,2) && T.y(i,1) >= T.y(i,3) && T.y(i,2) >= T.y(i,3)
            T.z(i,:) = T.y(i,:);
        end
    end
    % delete zero rows
    T.z(all(T.z == 0,2),:)=[];
    % Find only hkl that are all even
    for i=1:length(T.z)
        if rem(T.z(i,1),2) == 0 && rem(T.z(i,2),2) == 0 && rem(T.z(i,3),2) == 0
            T.w1(i,:) = T.z(i,:);
        end
    end
    % delete zero rows
    T.w1(all(T.w1 == 0,2),:)=[];
    % Find only hkl that are all odd
    for i=1:length(T.z)
        if rem(T.z(i,1),2) == 1 && rem(T.z(i,2),2) == 1 && rem(T.z(i,3),2) == 1
            T.w2(i,:) = T.z(i,:);
        end
    end
    % delete zero rows
    T.w2(all(T.w2 == 0,2),:)=[];

    T.w = [T.w1; T.w2];
    % delete zero rows
    T.w(all(T.w == 0,2),:)=[];
    % Calculation of theoretical d spacings for the used hkl values
    for i = 1:size(T.w,1)
        T.dtheo(i,:) = T.a0/(sqrt(T.w(i,1)^2+T.w(i,2)^2+T.w(i,3)^2));
    end

    T.hkl = [T.w, T.dtheo];
    % Sort columns in descending order
    T.hkl_sort = sortrows(T.hkl, -4);
    % Calculation of theoreitcal energy positons for the used hkl values
    for i = 1:size(T.hkl_sort,1)
        T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
    end

    T.Peaks = [T.hkl_sort T.Etheo];
%--------------------------------------------------------------------------
else
    T.hkl = Measurement(1).Sample.Materials.HKLdspacing;
    
    for i = 1:size(T.hkl,1)
        T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl(i,4);
    end
    
    T.Peaks = [T.hkl T.Etheo];
end

% Create matrix for the line plot of the peak positions (X values)
for i = 1:size(T.Peaks,1)
    T.X1(i,:) = [T.Peaks(i,5) T.Peaks(i,5) nan];
end
% Adjust the size of matrix to the measurement
T.X2 = reshape(T.X1',size(T.Peaks,1).*3,1);
T.X2(size(T.Peaks,1).*3,:) = [];
T.X3 = repmat(T.X2,1,length(Measurement));
% Adjust the size of matrix to the measurement
T.Y2 = reshape(T.Y1',3,length(Measurement));
T.Y3 = repmat(T.Y2,size(T.Peaks,1),1);
T.Y3(size(T.Peaks,1).*3,:)= [];

%% Plot diffraction lines from Substrate 
if (T.PlotSubstratePeaks)
    % Calculation of peak positions for bcc materials
    if strcmp(S.cs,'bcc')
        % Calculation of all possible hkl combinations
        [S.h, S.k, S.l] = ndgrid(1:10, 0:9, 0:9);
        S.d = S.h+S.k+S.l;
        i = find(rem(S.d,2) == 0);
        S.p = [S.h(i),S.k(i),S.l(i)];
        % Use only hkl with hkl² < hkl²max
        for i=1:length(S.p)
            if (S.p(i,1)^2 + S.p(i,2)^2 + S.p(i,3)^2) <= S.hklquadratmax
                S.y(i,:) = S.p(i,:);
            end
        end
        % delete zero rows
        S.y(all(S.y == 0,2),:)=[];
        % Use only hkl that are allowed for bcc materials
        for i=1:length(S.y)
            if S.y(i,1) >= S.y(i,2) && S.y(i,1) >= S.y(i,3) && S.y(i,2) >= S.y(i,3)
               S.z(i,:) = S.y(i,:);
            end
        end
        % delete zero rows
        S.z(all(S.z == 0,2),:)=[];
        % Calculation of theoretical d spacings for the used hkl values
        for i = 1:length(S.z)
            S.dtheo(i,:) = S.a0/(sqrt(S.z(i,1)^2+S.z(i,2)^2+S.z(i,3)^2));
        end

        S.hkl = [S.z S.dtheo];
        % Sort columns in descending order
        S.hkl_sort = sortrows(S.hkl, -4);
        % Calculation of theoreitcal energy positons for the used hkl values
        for i = 1:length(S.hkl_sort)
            S.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/S.hkl_sort(i,4);
        end

        S.Peaks = [S.hkl_sort S.Etheo];

    % Calculation of peak positions for bcc materials
    elseif strcmp(S.cs,'fcc')
        % Calculation of all possible hkl combinations
        [S.h, S.k, S.l] = ndgrid(1:10, 0:9, 0:9);
        S.d = S.h+S.k+S.l;
        i = find(rem(S.d,2) == 0);
        j = find(rem(S.d,2) == 1);
        S.p = [S.h(i),S.k(i),S.l(i);S.h(j),S.k(j),S.l(j)];
        % Use only hkl with hkl² < hkl²max
        for i=1:length(S.p)
            if (S.p(i,1)^2 + S.p(i,2)^2 + S.p(i,3)^2) <= S.hklquadratmax
                S.y(i,:) = S.p(i,:);
            end
        end
        % delete zero rows
        S.y(all(S.y == 0,2),:)=[];
        % Use only hkl that are allowed for fcc materials
        for i=1:length(S.y)
            if S.y(i,1) >= S.y(i,2) && S.y(i,1) >= S.y(i,3) && S.y(i,2) >= S.y(i,3)
                S.z(i,:) = S.y(i,:);
            end
        end
        % delete zero rows
        S.z(all(S.z == 0,2),:)=[];
        % Find only hkl that are all even
        for i=1:length(S.z)
            if rem(S.z(i,1),2) == 0 && rem(S.z(i,2),2) == 0 && rem(S.z(i,3),2) == 0
                S.w1(i,:) = S.z(i,:);
            end
        end
        % delete zero rows
        S.w1(all(S.w1 == 0,2),:)=[];
        % Find only hkl that are all odd
        for i=1:length(S.z)
            if rem(S.z(i,1),2) == 1 && rem(S.z(i,2),2) == 1 && rem(S.z(i,3),2) == 1
                S.w2(i,:) = S.z(i,:);
            end
        end
        % delete zero rows
        S.w2(all(S.w2 == 0,2),:)=[];

        S.w = [S.w1; S.w2];
        % delete zero rows
        S.w(all(S.w == 0,2),:)=[];
        % Calculation of theoretical d spacings for the used hkl values
        for i = 1:length(S.w)
            S.dtheo(i,:) = S.a0/(sqrt(S.w(i,1)^2+S.w(i,2)^2+S.w(i,3)^2));
        end

        S.hkl = [S.w, S.dtheo];
        % Sort columns in descending order
        S.hkl_sort = sortrows(S.hkl, -4);
        % Calculation of theoreitcal energy positons for the used hkl values
        for i = 1:length(S.hkl_sort)
            S.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/S.hkl_sort(i,4);
        end

        S.Peaks = [S.hkl_sort S.Etheo];
    %--------------------------------------------------------------------------
    else
        S.hkl = Measurement(1).Sample.Substrate.HKLdspacing;

        for i = 1:length(S.hkl)
            S.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/S.hkl(i,4);
        end

        S.Peaks = [S.hkl S.Etheo];
    end

    % Create matrix for the line plot of the peak positions (X values)
    for i = 1:length(S.Peaks)
        S.X1(i,:) = [S.Peaks(i,5) S.Peaks(i,5) nan];
    end
    % Adjust the size of matrix to the measurement
    S.X2 = reshape(S.X1',length(S.Peaks).*3,1);
    S.X2(length(S.Peaks).*3,:) = [];
    S.X3 = repmat(S.X2,1,length(Measurement));
    % Adjust the size of matrix to the measurement
    S.Y2 = reshape(T.Y1',3,length(Measurement));
    S.Y3 = repmat(S.Y2,length(S.Peaks),1);
    S.Y3(length(S.Peaks).*3,:)= [];
end

hold on;
%% Creat Plots
T.positionVector1 = [0.065, 0.15, 0.75, 0.75]; 	% position of plot window

for c = 1:length(Measurement)

    if (P.XInUnit)
        T.Plots(c,1) = plot(DataTmp{c}(:, 1), DataTmp{c}(:, 2));
        T.Title{c} = ['Measurement Data for ', Measurement(c).Name];
        ax = gca;
        box(ax, 'on');
        ax.Position = T.positionVector1;
        set(T.Plots(c,1), 'Color', 'blue');
        xlabel('Energy [keV]');
        ylabel('Intensity [cts]');
    else
        T.Plots(c) = plot(1:length(DataTmp{c}(:, 1)), DataTmp{c}(:, 2));
        T.Title{c} = ['Measurement Data for ', Measurement(c).Name];
        xlabel('Channels [no unit]');
        ylabel('Intensity [cts]');
    end
        
    % Plot of the theortical peak (energy) positions.
    % Account for EMax (to restrict the number of hkl values).
    a = T.Etheo < T.EMax;
    T.EtheoLimit = T.Etheo(a);
    T.X1Limit = T.X1(a,:);
    T.X3Limit = T.X3((1:(3*length(T.EtheoLimit)-1)),:);
    T.Y3Limit = T.Y3((1:(3*length(T.EtheoLimit)-1)),:);
    
    T.Plots(c,2) = line(T.X3Limit(:,1),T.Y3Limit(:,c));
    for i = 1:length(T.X1Limit(:,1))
        T.Texts(c,i) = text(T.X1Limit(i,1)',max(T.Y3Limit(:,c)),num2str(T.EtheoLimit(i),4), ...
            'HorizontalAlignment','right','Clipping','on','rotation',90, ...
            'FontSize', 8,'BackgroundColor',[1 1 1],'LineWidth',0.1);
    end
    set(T.Plots(c,2), 'LineWidth', 1.2);
    set(T.Plots(c,2), 'Color', 'red');
    
    if (T.PlotSubstratePeaks)
    % Plot of the theortical peak (energy) positions
    % Account for EMax (to restrict the number of hkl values).
    S.EMax = T.EMax;
    b = S.Etheo < S.EMax;
    S.EtheoLimit = S.Etheo(b);
    S.X1Limit = S.X1(b,:);
    S.X3Limit = S.X3((1:(3*length(S.EtheoLimit)-1)),:);
    S.Y3Limit = S.Y3((1:(3*length(S.EtheoLimit)-1)),:);
    
    T.Plots(c,3) = line(S.X3Limit(:,1),S.Y3Limit(:,c));
    for i = 1:length(S.X1Limit(:,1))
        T.Textsubstrat(c,i) = text(S.X1Limit(i,1)',max(S.Y3Limit(:,c)),num2str(S.EtheoLimit(i),4), ...
            'HorizontalAlignment','right','Clipping','on','rotation',90, ...
            'FontSize', 8,'BackgroundColor',[1 1 1],'LineWidth',0.1);
    end
    set(T.Plots(c,3), 'LineWidth', 1.2);
    set(T.Plots(c,3), 'Color', [0.4 0.4 0.4]);
    end
    
    xlim([min(DataTmp{c}(:, 1)) max(DataTmp{c}(:, 1))]);
end

% Create table with hkl- dspacing and theoretical energy position values.
T.Table = uitable(T.Figure);
    % Create position vector for the materials hkl- and d-spacing table.
    if size(T.Peaks(a,:),1) > 6
        T.PositionVectorMaterial = [0.8275, 0.899 - (7*0.0192), 0.155, (7*0.0192)];
    else
        T.PositionVectorMaterial = [0.8275, 0.899 - ((size(T.Peaks(a,:),1)+1)*0.0192), 0.155, ((size(T.Peaks(a,:),1)+1)*0.0192)];
    end
    % Position of the table, dependent on the use of substrate information.
    if (T.PlotSubstratePeaks)
        set(T.Table, 'Data', T.Peaks(a,:), 'ColumnName', {'h', 'k', 'l', 'dspacing', ...
            'Energy'}, 'ColumnWidth', {25 25 25 85 85}, 'Units', 'normalized', 'Position', ...
            T.PositionVectorMaterial);
        % Show the elemental formula as title of the table
        T.Titles = uicontrol ('Style', 'edit', ...
                'units', 'normalized', ...
                'Position', [0.875 0.902 0.05 0.02], ...
                'Visible', 'on', ...
                'Enable', 'Inactive', ...
                'FontWeight', 'bold', ...
                'BackgroundColor', 'red', ...
                'ForegroundColor', 'white', ...
                'String', Sample.Materials.Name);
    else
        set(T.Table, 'Data', T.Peaks(a,:), 'ColumnName', {'h', 'k', 'l', 'dspacing', ...
            'Energy'}, 'ColumnWidth', {25 25 25 85 85}, 'Units', 'normalized', 'Position', ...
            T.PositionVectorMaterial);
        % Show the elemental formula as title of the table
        T.Titles = uicontrol ('Style', 'edit', ...
                'units', 'normalized', ...
                'Position', [0.875 0.902 0.05 0.02], ...
                'Visible', 'on', ...
                'Enable', 'Inactive', ...
                'BackgroundColor', 'red', ...
                'ForegroundColor', 'white', ...
                'FontWeight', 'bold', ...
                'String', Sample.Materials.Name);
    end

if (T.PlotSubstratePeaks)
    % Create position vector for the substrates hkl- and d-spacing table.
    if size(T.Peaks(a,:),1) && size(S.Peaks(b,:),1) > 6
        T.PositionVectorSubstrate = [0.8275, 0.899 - 0.027 - (7*0.0202) - (7*0.0202), 0.155, (7*0.0202)];
    else
        T.PositionVectorSubstrate = [0.8275, 0.899 - 0.027 - (size(T.Peaks(a,:),1)+1)*0.0202 - ((size(S.Peaks(b,:),1)+1)*0.0202), 0.155, (size(S.Peaks(b,:),1)+1)*0.0202];
    end
    S.Table = uitable(T.Figure);
    set(S.Table, 'Data', S.Peaks(b,:), 'ColumnName', {'h', 'k', 'l', 'dspacing', ...
        'Energy'}, 'ColumnWidth', {12 12 12 60 50}, 'Units', 'normalized', 'Position', ...
        T.PositionVectorSubstrate);
    % Show the elemental formula as title of the table
    % Create position vector for the susbtrates table title.
    if size(T.Peaks(a,:),1) > 6
        T.PositionVectorSubstrateTitle = [0.875, 0.902 - 0.027 - (7*0.0202), 0.05, 0.02];
    else
        T.PositionVectorSubstrateTitle = [0.875, 0.902 - 0.027 - (size(T.Peaks(a,:),1)+1)*0.0202, 0.05, 0.02];
    end
    T.Titles = uicontrol ('Style', 'edit', ...
        'units', 'normalized', ...
        'Position', T.PositionVectorSubstrateTitle, ...
        'Visible', 'on', ...
        'Enable', 'Inactive', ...
        'FontWeight', 'bold', ...
        'BackgroundColor', [0.4 0.4 0.4], ...
        'ForegroundColor', 'white', ...
        'String', Sample.Substrate.Name);
end    

% Slider erzeugen
T.Slider = uicontrol(...
        'Style','slider',...
        'Tag','Slider',...
        'Parent',T.Figure,...
        'Units','normalized',...
        'Position', [0.3875 0.05 0.1 0.03],...
        'Min',1,...
        'Max',length(Measurement),...
        'SliderStep',[1/(length(Measurement)-1) 1/(length(Measurement)-1)],...
        'Value',1,...
        'Callback',{@SliderCallbackPlot,T});   
    
SliderCallbackPlot(T.Slider, 0, T);

%% GUI - Plot peaks from second phase
% The following components create the GUI panel "Plot peaks from
% additional phase. This panel contains an "Edit" field, where the name of
% a MPD file can be entered in order to show the diffraction peaks of this
% material. If the MPD file exists, a window will open and show that the
% file was succesfully loaded. If the MPD file does not exist, an error
% message will occur. When the import was succesfull, the diffraction lines
% can be plotted by pressing the button "Plot diffraction lines". To delete
% the plotted lines press the "Reset Data" button.
% Uipanel components for plotting additional phase 
    % Uipanel
    kpanel = uipanel('Title', 'Plot peaks from additional phase',...
        'Units','normalized',...
        'Position', [0.827 0.28 0.15 0.125]);
    % Reset button
    kreset = uicontrol('Style','pushbutton','String','Reset Data',...
        'Units','normalized',...
        'Tag', 'hreset',...
        'Position',[0.15 0.075 0.7 0.25],...
        'Parent',kpanel,...
        'Callback',{@kresetbutton_Callback});
    % Plot button
    kplot = uicontrol('Style','pushbutton','String','Plot diffraction lines',...
        'Units','normalized',...
        'Tag', 'hplot',...
        'Position',[0.15 0.375 0.7 0.25],...
        'FontSize', 8,...
        'Parent',kpanel,...
        'Callback',{@kplotbutton_Callback, T});
    % Edit field
    kedit = uicontrol('Style','edit','String','Enter name of MPD file',...
        'Units','normalized',...
        'Tag', 'kreset',...
        'Position',[0.15 0.65 0.7 0.25],...
        'Parent',kpanel,...
        'Callback',{@keditbutton_Callback});


%% GUI - Plot fluorescence lines
% The following components create the GUI panel "Plot of fluorescence
% lines. The panel consists of a popup menu where all elements are listed,
% and two buttons, one to plot the fluorescence lines and one to reset
% (clear) the plotted data.
% Path of the fluorescence line file
fid = fopen(fullfile('Data','Materials','Fluorescence_Lines.dat'));
% Einlesen der Datei und speichern in einem Cell-Array
% Spaltennamen lauten:
% No.;Element;Ka1;Ka2;Kb1;La1;La2;Lb1;Lb2;Lg1
T.FluorCellArray = textscan(fid,'%d %s %f %f %f %f %f %f %f %f',...
    'headerlines',1, 'delimiter','\t');
% String Vektor mit Elementnamen erzeugen, für PopUpMenu
ElementsString = T.FluorCellArray{1,2}(:,1);
% Uipanel components for plotting fluorescence lines
    % Uipanel
    hpanel = uipanel('Title', 'Plot of fluorescence lines',...
        'Units','normalized',...
        'Position', [0.827 0.1475 0.15 0.125]);
    % Reset button
    hreset = uicontrol('Style','pushbutton','String','Reset Data',...
        'Units','normalized',...
        'Tag', 'hreset',...
        'Position',[0.15 0.075 0.7 0.25],...
        'Parent',hpanel,...
        'Callback',{@resetbutton_Callback});
    % Plot button
    hplot = uicontrol('Style','pushbutton','String','Plot fluorescence lines',...
        'Units','normalized',...
        'Tag', 'hplot',...
        'Position',[0.15 0.375 0.7 0.25],...
        'FontSize', 8,...
        'Parent',hpanel,...
        'Callback',{@plotbutton_Callback, T});
    % Popup menu title
    htext2 = uicontrol('Style','text','String','Select Element',...
        'Parent',hpanel,...
        'Tag', 'htext2',...
        'Units','normalized',...
        'Position',[0.151 0.65 0.7 0.225],...
        'HorizontalAlignment', 'left');
    % Popup menu
    hpopup = uicontrol('Style','popupmenu',...
        'String',ElementsString,...
        'Tag', 'hpopup',...
        'Units','normalized',...
        'Position',[0.586 0.7 0.25 0.225],...
        'Parent',hpanel,...
        'Callback',{@popup_menu_Callback});
    
if (P.CleanUpTemporaryVariables)
    clear('P');
    clear('T');
    clear c i h k l;
end