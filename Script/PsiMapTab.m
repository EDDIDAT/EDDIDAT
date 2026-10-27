function api = PsiMapTab(parent)
% PSIMAPTAB  Inhalt des Tabs "Create fit maps" der EDDIDAT-GUI (Entwurf).
%
%   api = PsiMapTab(parentTab)
%
% Erzeugt Karten (Intensitaet, Energielage, Integralbreite, d-Wert ...) aus den psi-Dateien der Batch-Auswertung.
% Je Binning ein Ordner (Datensatz). Ansichten:
%   A  nebeneinander: alle Datensaetze mit gekoppelten Achsen und gemeinsamer Farbskala (+ vergroesserter Bereich)
%   B  gemeinsames Raster: zwei Datensaetze werden exakt auf das kleinste gemeinsame Vielfache der Blockgroessen
%      umgerechnet (4x4 und 6x6 -> 12x12) und als Karten, Differenz/Verhaeltnis/Rauschbreiten und Streudiagramm verglichen.
% Rueckgabe api: Funktionshandles fuer Tests (addFolder, setView, setRegion, redraw, state).

%% ---------------- Zustand ----------------
DS = [];                 % Struct-Array der Datensaetze (psiLoadFolder + Use, DispName)
matchIdx = [];           % je Datensatz: Index des zum gewaehlten Peak passenden Peaks (NaN = keiner)
refE = NaN; refD = NaN;  % Referenzwerte aus dem ersten benutzten Datensatz (fuer Delta E und Delta d)
region = [0 0 0 0]; fullExt = [0 1 0 1]; selRow = [];
tl = []; statsData = cell(0,8); lastStats = '';

%% ---------------- Oberflaeche ----------------
bg = get(parent,'BackgroundColor');
fig = ancestor(parent,'figure');
P1 = uipanel('Parent',parent,'Title','1  Datasets (one folder per binning)','Units','normalized','Position',[0.005 0.735 0.260 0.260]);
P2 = uipanel('Parent',parent,'Title','2  Quantity','Units','normalized','Position',[0.005 0.440 0.260 0.290]);
P3 = uipanel('Parent',parent,'Title','3  View','Units','normalized','Position',[0.005 0.265 0.260 0.170]);
P4 = uipanel('Parent',parent,'Title','4  Region (mm)','Units','normalized','Position',[0.005 0.140 0.260 0.120]);
P5 = uipanel('Parent',parent,'Title','5  Export','Units','normalized','Position',[0.005 0.060 0.260 0.075]);
PM = uipanel('Parent',parent,'Title','Maps','Units','normalized','Position',[0.270 0.225 0.725 0.770]);
PT = uipanel('Parent',parent,'Title','Statistics of the region (original grid, filters applied)','Units','normalized','Position',[0.270 0.040 0.725 0.180]);
txtStatus = uicontrol('Parent',parent,'Style','text','Units','normalized','Position',[0.270 0.003 0.725 0.032],'HorizontalAlignment','left','BackgroundColor',bg,'String','Add a folder with psi files.');

% --- Panel 1: Datensaetze
mk(P1,'pushbutton',[0.02 0.85 0.30 0.13],'Add folder...',@(~,~) addFolder(''));
mk(P1,'pushbutton',[0.34 0.85 0.30 0.13],'Remove',@(~,~) removeDataset());
mk(P1,'pushbutton',[0.66 0.85 0.32 0.13],'Reload',@(~,~) reloadAll());
tblDS = uitable('Parent',P1,'Units','normalized','Position',[0.02 0.03 0.96 0.78],'RowName',[], ...
    'ColumnName',{'Use','Name','Bin','Spectra','Grid'},'ColumnFormat',{'logical','char','numeric','numeric','char'}, ...
    'ColumnEditable',[true true false false false],'ColumnWidth',{35 120 35 60 70},'Data',cell(0,5), ...
    'CellEditCallback',@(~,~) datasetsEdited(),'CellSelectionCallback',@(~,ev) setSel(ev));

% --- Panel 2: Groesse
mk(P2,'text',[0.02 0.88 0.18 0.09],'Peak',[],'left');
popPeak = mk(P2,'popupmenu',[0.22 0.88 0.76 0.10],{'(no data)'},@(~,~) redraw());
mk(P2,'text',[0.02 0.77 0.18 0.09],'Quantity',[],'left');
popQty = mk(P2,'popupmenu',[0.22 0.77 0.76 0.10],{'Iint per pixel (counts/100/px)','Iint as fitted (counts/100)','Emax (keV)','dEmax (keV)','Ib (keV)', ...
    'Delta E vs. reference (eV)','d spacing (A)','Delta d / d0 vs. reference (%)'},@(~,~) redraw());
mk(P2,'text',[0.02 0.66 0.18 0.09],'Colormap',[],'left');
popCmap = mk(P2,'popupmenu',[0.22 0.66 0.30 0.10],{'parula','turbo','jet','hot','gray','bone'},@(~,~) redraw());
chkClip = mk(P2,'checkbox',[0.55 0.66 0.43 0.10],'clip 2-98 %',@(~,~) redraw()); set(chkClip,'Value',1);
mk(P2,'text',[0.02 0.55 0.30 0.09],'Color limits',[],'left');
edCmin = mk(P2,'edit',[0.32 0.55 0.20 0.10],'',@(~,~) redraw());
edCmax = mk(P2,'edit',[0.55 0.55 0.20 0.10],'',@(~,~) redraw());
mk(P2,'text',[0.77 0.55 0.21 0.09],'(empty = auto)',[],'left');
mk(P2,'text',[0.02 0.44 0.18 0.09],'Smooth',[],'left');
popSmooth = mk(P2,'popupmenu',[0.22 0.44 0.45 0.10],{'none','median 3x3 (separable)','Gauss sigma 1'},@(~,~) redraw());
chkCommon = mk(P2,'checkbox',[0.02 0.33 0.96 0.10],'common color scale for all datasets',@(~,~) redraw()); set(chkCommon,'Value',1);
mk(P2,'text',[0.02 0.22 0.55 0.09],'Hide if dEmax > (keV)',[],'left');
edFd = mk(P2,'edit',[0.62 0.22 0.20 0.10],'',@(~,~) redraw());
mk(P2,'text',[0.02 0.11 0.55 0.09],'Show only Ib from/to (keV)',[],'left');
edFb0 = mk(P2,'edit',[0.62 0.11 0.17 0.10],'',@(~,~) redraw());
edFb1 = mk(P2,'edit',[0.81 0.11 0.17 0.10],'',@(~,~) redraw());
mk(P2,'text',[0.02 0.00 0.55 0.09],'Hide if |Emax - ref| > (eV)',[],'left');
edFe = mk(P2,'edit',[0.62 0.00 0.20 0.10],'',@(~,~) redraw());

% --- Panel 3: Ansicht
mk(P3,'text',[0.02 0.82 0.18 0.14],'View',[],'left');
popView = mk(P3,'popupmenu',[0.20 0.82 0.78 0.15],{'A  side by side (linked axes)','B  common grid (compare two)'},@(~,~) redraw());
mk(P3,'text',[0.02 0.64 0.18 0.14],'A',[],'left');
popA = mk(P3,'popupmenu',[0.20 0.64 0.78 0.15],{'-'},@(~,~) redraw());
mk(P3,'text',[0.02 0.46 0.18 0.14],'B',[],'left');
popB = mk(P3,'popupmenu',[0.20 0.46 0.78 0.15],{'-'},@(~,~) redraw());
mk(P3,'text',[0.02 0.28 0.18 0.14],'Show',[],'left');
popBview = mk(P3,'popupmenu',[0.20 0.28 0.78 0.15],{'Difference (B - A)','Ratio (B / A)','Difference / std. error of the cell mean'},@(~,~) redraw());
mk(P3,'text',[0.02 0.08 0.50 0.14],'Min. coverage of a cell (%)',[],'left');
edCov = mk(P3,'edit',[0.55 0.08 0.20 0.16],'100',@(~,~) redraw());

% --- Panel 4: Bereich
mk(P4,'text',[0.02 0.62 0.08 0.30],'x',[],'left');
edX0 = mk(P4,'edit',[0.10 0.62 0.20 0.33],'0',@(~,~) regionEdited());
edX1 = mk(P4,'edit',[0.33 0.62 0.20 0.33],'0',@(~,~) regionEdited());
mk(P4,'text',[0.57 0.62 0.08 0.30],'y',[],'left');
edY0 = mk(P4,'edit',[0.65 0.62 0.15 0.33],'0',@(~,~) regionEdited());
edY1 = mk(P4,'edit',[0.82 0.62 0.15 0.33],'0',@(~,~) regionEdited());
mk(P4,'pushbutton',[0.02 0.08 0.46 0.40],'Select on map',@(~,~) selectOnMap());
mk(P4,'pushbutton',[0.52 0.08 0.46 0.40],'Full map',@(~,~) fullMap());

% --- Panel 5: Export
mk(P5,'pushbutton',[0.01 0.12 0.24 0.70],'All maps (PNG)',@(~,~) exportAllPng());
mk(P5,'pushbutton',[0.26 0.12 0.24 0.70],'This view (PNG)',@(~,~) exportFigure());
mk(P5,'pushbutton',[0.51 0.12 0.22 0.70],'Grids (MAT)',@(~,~) exportGrids());
mk(P5,'pushbutton',[0.74 0.12 0.25 0.70],'Statistics (CSV)',@(~,~) exportStats());

% --- Statistik-Tabelle
tblStat = uitable('Parent',PT,'Units','normalized','Position',[0.005 0.02 0.99 0.96],'RowName',[], ...
    'ColumnName',{'Dataset','N','Mean','Median','Std','MAD (% of median)','Min','Max'},'Data',cell(0,8), ...
    'ColumnWidth',{190 70 85 85 85 110 85 85});

api = struct('addFolder',@addFolder,'setView',@setView,'setRegion',@setRegion,'setQuantity',@setQuantity,'redraw',@redraw,'state',@getState,'setSmooth',@setSmooth,'exportAllPng',@exportAllPng);

%% ---------------- Datensaetze ----------------
    function addFolder(folder)
        if isempty(folder)
            start = getpref('EDDIDAT','PsiMap_Dir',pwd);
            folder = uigetdir(start,'Select a folder with psi files (one binning)');
            if isequal(folder,0), return, end
        end
        setpref('EDDIDAT','PsiMap_Dir',fileparts(folder));
        wb = waitbar(0,'Reading psi files ...','Name','Create fit maps');
        try
            D = psiLoadFolder(folder,'ProgressFcn',@(k,n,nm) waitbarSafe(wb,k/n,sprintf('%d / %d: %s',k,n,nm)));
        catch ME
            if ishandle(wb), delete(wb); end
            errordlg(ME.message,'Create fit maps'); return
        end
        if ishandle(wb), delete(wb); end
        D.Use = true; D.DispName = D.Name; D.Name = D.Name;
        if isempty(DS), DS = D; else, DS(end+1) = D; end %#ok<AGROW>
        if ~D.Aligned, warndlg('The grid of this dataset is not aligned to the global block grid. Comparisons on the common grid are only approximate.','Create fit maps'); end
        computeFull(); refreshAfterDatasets();
        setStatus(sprintf('%s: %d spectra, %d x %d grid, binning %d x %d, pixel %.3f x %.3f um.',D.DispName,D.NSpectra,D.nx,D.ny,D.Bin,D.Bin,D.PixelUm));
    end

    function removeDataset()
        if isempty(DS) || isempty(selRow), return, end
        DS(unique(selRow)) = []; selRow = [];
        refreshAfterDatasets();
    end

    function reloadAll()
        if isempty(DS), return, end
        folders = {DS.Folder}; use = [DS.Use]; names = {DS.DispName}; DS = [];
        for k = 1:numel(folders)
            try
                D = psiLoadFolder(folders{k},'UseCache',false); D.Use = use(k); D.DispName = names{k};
                if isempty(DS), DS = D; else, DS(end+1) = D; end %#ok<AGROW>
            catch ME
                warndlg(ME.message,'Create fit maps');
            end
        end
        refreshAfterDatasets();
    end

    function datasetsEdited()
        D = get(tblDS,'Data');
        for k = 1:numel(DS), DS(k).Use = logical(D{k,1}); DS(k).DispName = D{k,2}; end
        refreshAfterDatasets(true);
    end

    function setSel(ev)
        if isempty(ev.Indices), selRow = []; else, selRow = ev.Indices(:,1); end
    end

    function refreshAfterDatasets(keepPeak)
        if nargin < 1, keepPeak = false; end
        D = cell(numel(DS),5);
        for k = 1:numel(DS), D(k,:) = {DS(k).Use,DS(k).DispName,DS(k).Bin,DS(k).NSpectra,sprintf('%dx%d',DS(k).nx,DS(k).ny)}; end
        set(tblDS,'Data',D);
        used = find([DS.Use]);
        if isempty(used)
            set(popPeak,'String',{'(no data)'},'Value',1); set(popA,'String',{'-'},'Value',1); set(popB,'String',{'-'},'Value',1);
            matchIdx = []; cla_all(); return
        end
        if ~keepPeak || get(popPeak,'Value') > numel(DS(used(1)).Peaks)
            set(popPeak,'String',{DS(used(1)).Peaks.Name},'Value',1);
        else
            set(popPeak,'String',{DS(used(1)).Peaks.Name});
        end
        names = {DS(used).DispName};
        set(popA,'String',names,'Value',min(get(popA,'Value'),numel(names)));
        set(popB,'String',names,'Value',min(max(get(popB,'Value'),min(2,numel(names))),numel(names)));
        if numel(names) >= 2 && get(popB,'Value') == get(popA,'Value'), set(popB,'Value',min(numel(names),get(popA,'Value')+1)); end
        redraw();
    end

    function cla_all()
        delete(allchild(PM)); set(tblStat,'Data',cell(0,8));
    end

%% ---------------- Daten je Datensatz ----------------
    function matchPeaks()
        used = find([DS.Use]); matchIdx = nan(1,numel(DS));
        if isempty(used), return, end
        pv = get(popPeak,'Value'); r = DS(used(1));
        pv = min(pv,numel(r.Peaks)); Eref = r.Peaks(pv).Emed;
        for k = used
            [dm,i] = min(abs([DS(k).Peaks.Emed] - Eref));
            if dm < 0.30, matchIdx(k) = i; end
        end
        % Referenzwerte (Delta E, d0) aus dem ersten benutzten Datensatz
        G = r.Peaks(pv).Grid; refE = median(G.Emax(:),'omitnan');
        dd = 12.398./(2*sind(r.Peaks(pv).tth/2).*G.Emax); refD = median(dd(:),'omitnan');
        % Auswahllisten A/B nur mit Datensaetzen, die den Peak enthalten
        us = find([DS.Use] & isfinite(matchIdx)); nm = {DS(us).DispName}; if isempty(nm), nm = {'-'}; end
        set(popA,'String',nm,'Value',min(get(popA,'Value'),numel(nm))); set(popB,'String',nm,'Value',min(get(popB,'Value'),numel(nm)));
    end

    function [Z,W,lab] = getZ(k)
        % Werte des k-ten Datensatzes fuer die gewaehlte Groesse (Filter angewandt), Gewichte (Iint) fuer gewichtete Mittel
        P = DS(k).Peaks(matchIdx(k)); G = P.Grid; q = get(popQty,'Value');
        switch q
            case 1, Z = G.Iint / DS(k).Bin^2;                         lab = 'Iint per pixel (counts/100/px)';
            case 2, Z = G.Iint;                                       lab = 'Iint (counts/100)';
            case 3, Z = G.Emax;                                       lab = 'Emax (keV)';
            case 4, Z = G.dEmax;                                      lab = 'dEmax (keV)';
            case 5, Z = G.Ib;                                         lab = 'Ib (keV)';
            case 6, Z = (G.Emax - refE)*1000;                         lab = 'Emax - reference (eV)';
            case 7, Z = 12.398./(2*sind(P.tth/2).*G.Emax);            lab = 'd (A)';
            case 8, Z = (12.398./(2*sind(P.tth/2).*G.Emax)/refD - 1)*100; lab = 'Delta d / d0 (%)';
        end
        W = G.Iint; W(~(W > 0)) = NaN;
        v = str2double(get(edFd,'String')); if ~isnan(v), Z(G.dEmax > v) = NaN; end
        a = str2double(get(edFb0,'String')); b = str2double(get(edFb1,'String'));
        if ~isnan(a), Z(G.Ib < a) = NaN; end
        if ~isnan(b), Z(G.Ib > b) = NaN; end
        v = str2double(get(edFe,'String')); if ~isnan(v), Z(abs(G.Emax - refE)*1000 > v) = NaN; end
    end

    function Zs = smoothZ(Z)
        switch get(popSmooth,'Value')
            case 2
                Zs = movmedian(movmedian(Z,3,1,'omitnan'),3,2,'omitnan'); Zs(~isfinite(Z)) = NaN;
            case 3
                g = exp(-((-2:2).^2)/2); K = g'*g; K = K/sum(K(:));
                M = double(isfinite(Z)); Z0 = Z; Z0(~isfinite(Z0)) = 0;
                Zs = conv2(Z0,K,'same') ./ conv2(M,K,'same'); Zs(~isfinite(Z)) = NaN;
            otherwise
                Zs = Z;
        end
    end

%% ---------------- Zeichnen ----------------
    function redraw()
        if isempty(DS) || ~any([DS.Use]), return, end
        matchPeaks();
        delete(allchild(PM)); tl = [];
        if get(popView,'Value') == 1, drawA(); else, drawB(); end
        updateStats();
    end

    function drawA()
        used = find([DS.Use] & isfinite(matchIdx));
        if isempty(used), uicontrol('Parent',PM,'Style','text','Units','normalized','Position',[0.1 0.45 0.8 0.1],'String','No dataset contains the selected peak.'); return, end
        n = numel(used); full = isFullRegion(); wide = isWide();
        Z = cell(1,n); lab = '';
        for j = 1:n, [z,~,lab] = getZ(used(j)); Z{j} = smoothZ(z); end
        clim = climOf(Z);
        if wide        % breite Karten: untereinander, vergroesserter Bereich rechts daneben
            tl = tiledlayout(PM,n,4,'TileSpacing','compact','Padding','loose');
        else           % kompakte Felder: nebeneinander, vergroesserter Bereich in der zweiten Zeile
            tl = tiledlayout(PM,1 + ~full,n,'TileSpacing','compact','Padding','loose');
        end
        cm = currentMap();
        top = gobjects(1,n); axLast = [];
        for j = 1:n
            if wide
                if full, ax = nexttile(tl,(j-1)*4+1,[1 4]); else, ax = nexttile(tl,(j-1)*4+1,[1 2]); end
            else
                ax = nexttile(tl,j);
            end
            top(j) = ax; axLast = ax;
            showMap(ax,DS(used(j)).x,DS(used(j)).y,Z{j},clim,cm);
            title(ax,sprintf('%s (%dx%d)',DS(used(j)).DispName,DS(used(j)).Bin,DS(used(j)).Bin),'Interpreter','none','FontSize',9);
            if ~full, hold(ax,'on'); plot(ax,region([1 2 2 1 1]),region([3 3 4 4 3]),'r-','LineWidth',1.2); hold(ax,'off'); end
            if (wide && j == n) || (~wide && full), xlabel(ax,'x (mm)'); end
            if wide || j == 1, ylabel(ax,'y (mm)'); end
            if ~get(chkCommon,'Value'), colorbar(ax); end
        end
        linkaxes(top,'xy');
        if ~full
            for j = 1:n
                if wide, ax = nexttile(tl,(j-1)*4+3,[1 2]); else, ax = nexttile(tl,n+j); end
                showMap(ax,DS(used(j)).x,DS(used(j)).y,Z{j},clim,cm); axis(ax,'normal');
                set(ax,'XLim',region(1:2),'YLim',region(3:4),'DataAspectRatio',[1 1 1]);
                if (wide && j == n) || ~wide, xlabel(ax,'x (mm)'); end
                if wide && j == 1, title(ax,'enlarged region','FontSize',9); end
                if ~wide && j == 1, ylabel(ax,'y (mm)'); end
                if ~get(chkCommon,'Value'), colorbar(ax); end
            end
        end
        if get(chkCommon,'Value')
            cb = colorbar(axLast); cb.Layout.Tile = 'east'; ylabel(cb,lab,'Interpreter','none');
        end
        title(tl,peakName(),'Interpreter','none');
        % Statistik-Daten fuer die Tabelle
        setappdata(PM,'statZ',Z); setappdata(PM,'statIdx',used);
    end

    function drawB()
        used = find([DS.Use] & isfinite(matchIdx));
        if numel(used) < 2, uicontrol('Parent',PM,'Style','text','Units','normalized','Position',[0.1 0.45 0.8 0.1],'String','Select at least two datasets with the chosen peak.'); return, end
        names = get(popA,'String'); ia = used(min(get(popA,'Value'),numel(used))); ib = used(min(get(popB,'Value'),numel(used)));
        if ia == ib, uicontrol('Parent',PM,'Style','text','Units','normalized','Position',[0.1 0.45 0.8 0.1],'String','Choose two different datasets A and B.'); return, end
        [za,wa,lab] = getZ(ia); [zb,wb,~] = getZ(ib);
        cov = str2double(get(edCov,'String'))/100; if isnan(cov) || cov <= 0, cov = 1; end
        weighted = get(popQty,'Value') >= 3;
        if weighted, Wc = {wa,wb}; else, Wc = []; end
        R = psiResampleCommon(DS([ia ib]),{za,zb},'W',Wc,'MinCoverage',cov);
        A = R.Z{1}; Bm = R.Z{2}; both = isfinite(A) & isfinite(Bm); A(~both) = NaN; Bm(~both) = NaN;
        Sa = R.S{1}; Sb = R.S{2};
        switch get(popBview,'Value')
            case 1, T = Bm - A; tlab = 'B - A';
            case 2, T = Bm ./ A; tlab = 'B / A';
            case 3
                s = sqrt(nansq(Sa) + nansq(Sb)); T = (Bm - A) ./ s; T(~isfinite(s) | s == 0) = NaN; tlab = '(B - A) / std. error';
        end
        T(~both) = NaN;
        clim = climOf({A,Bm}); cm = currentMap();
        wide = isWide();
        if wide       % drei breite Karten untereinander, rechts das Streudiagramm
            tl = tiledlayout(PM,3,3,'TileSpacing','compact','Padding','loose');
            ax1 = nexttile(tl,1,[1 2]); ax2 = nexttile(tl,4,[1 2]); ax3 = nexttile(tl,7,[1 2]);
        else
            tl = tiledlayout(PM,2,2,'TileSpacing','compact','Padding','loose');
            ax1 = nexttile(tl,1); ax2 = nexttile(tl,2); ax3 = nexttile(tl,3);
        end
        showMap(ax1,R.x,R.y,A,clim,cm); title(ax1,sprintf('A: %s (%dx%d)',DS(ia).DispName,DS(ia).Bin,DS(ia).Bin),'Interpreter','none','FontSize',9);
        showMap(ax2,R.x,R.y,Bm,clim,cm); title(ax2,sprintf('B: %s (%dx%d)',DS(ib).DispName,DS(ib).Bin,DS(ib).Bin),'Interpreter','none','FontSize',9);
        cb1 = colorbar(ax1); ylabel(cb1,lab,'Interpreter','none'); cb = colorbar(ax2); ylabel(cb,lab,'Interpreter','none');
        ylabel(ax1,'y (mm)'); ylabel(ax2,'y (mm)'); ylabel(ax3,'y (mm)'); xlabel(ax3,'x (mm)');
        if get(popBview,'Value') == 2, c3 = [0 2]; cmap3 = cm; if get(chkClip,'Value'), v = T(isfinite(T)); if ~isempty(v), c3 = [pr(v,2) pr(v,98)]; end, end
        else, m = max(abs(pr(T(isfinite(T)),98)),abs(pr(T(isfinite(T)),2))); if isempty(m) || ~isfinite(m) || m == 0, m = 1; end, c3 = [-m m]; cmap3 = divMap(); end
        showMap(ax3,R.x,R.y,T,c3,cmap3); title(ax3,tlab,'Interpreter','none','FontSize',9); cb3 = colorbar(ax3); ylabel(cb3,tlab,'Interpreter','none');
        linkaxes([ax1 ax2 ax3],'xy');
        if wide, ax4 = nexttile(tl,3,[3 1]); else, ax4 = nexttile(tl,4); end
        in = cellInRegion(R.x,R.y); a = A(in & both); b = Bm(in & both);
        if isempty(a)
            text(ax4,0.5,0.5,'no common cells','HorizontalAlignment','center'); axis(ax4,'off');
        else
            plot(ax4,a,b,'.','MarkerSize',4,'Color',[0.2 0.35 0.7]); hold(ax4,'on');
            lim = [min([a;b]) max([a;b])]; plot(ax4,lim,lim,'k-'); hold(ax4,'off'); grid(ax4,'on'); axis(ax4,'tight');
            xlabel(ax4,sprintf('A: %s',lab),'Interpreter','none'); ylabel(ax4,sprintf('B: %s',lab),'Interpreter','none');
            r = corr(a,b); rat = median(b./a,'omitnan'); df = b - a;
            title(ax4,sprintf('N = %d cells, r = %.4f, median B/A = %.4f, median(B-A) = %.4g, rms(B-A) = %.4g',numel(a),r,rat,median(df),sqrt(mean(df.^2))),'FontSize',8,'Interpreter','none');
            lastStats = sprintf('B vs A on a %d x %d pixel grid: N = %d cells, r = %.4f, median B/A = %.4f',R.L,R.L,numel(a),r,rat);
            if get(popBview,'Value') == 3
                lastStats = [lastStats '. Note: both binnings use the same counts, so their noise is strongly correlated and differences look small in units of the standard error.'];
            end
            setStatus(lastStats);
        end
        title(tl,peakName(),'Interpreter','none');
        subtitle(tl,sprintf('common cell %d x %d pixel (%.3f mm): %d blocks of A and %d blocks of B per cell',R.L,R.L,R.L*mean(arrayfun(@(d) d.PixelUm(1),DS([ia ib])))/1000,R.Kmax(1),R.Kmax(2)),'Interpreter','none');
        setappdata(PM,'statZ',{za,zb}); setappdata(PM,'statIdx',[ia ib]);
        setappdata(PM,'commonR',R);
    end

    function showMap(ax,x,y,Z,clim,cm)
        imagesc(ax,x,y,Z,'AlphaData',double(isfinite(Z)));
        set(ax,'YDir','reverse','Color',[1 1 1]); axis(ax,'image'); colormap(ax,cm);
        if all(isfinite(clim)) && clim(2) > clim(1), clim_(ax,clim); end
        set(ax,'XLim',[min(x)-0.01 max(x)+0.01],'YLim',[min(y)-0.01 max(y)+0.01]);
    end

    function clim_(ax,c)
        set(ax,'CLim',c);
    end

    function c = climOf(Zc)
        a = str2double(get(edCmin,'String')); b = str2double(get(edCmax,'String'));
        if ~isnan(a) && ~isnan(b) && b > a, c = [a b]; return, end
        v = cell2mat(cellfun(@(z) z(isfinite(z)),Zc(:),'UniformOutput',false));
        if isempty(v), c = [0 1]; return, end
        if get(chkClip,'Value'), c = [pr(v,2) pr(v,98)]; else, c = [min(v) max(v)]; end
        if ~isnan(a), c(1) = a; end
        if ~isnan(b), c(2) = b; end
        if c(2) <= c(1), c = [c(1) c(1)+1]; end
    end

    function cm = currentMap()
        names = get(popCmap,'String'); cm = feval(names{get(popCmap,'Value')},256);
    end

%% ---------------- Bereich ----------------
    function tf = isFullRegion()
        tf = all(abs(region - fullExt) < 1e-6);
    end

    function tf = isWide()
        tf = (fullExt(2) - fullExt(1)) / max(fullExt(4) - fullExt(3),eps) > 2.5;
    end

    function in = cellInRegion(x,y)
        [XX,YY] = meshgrid(x,y); in = XX >= region(1) & XX <= region(2) & YY >= region(3) & YY <= region(4);
    end

    function setRegion(r)
        r = [min(r(1:2)) max(r(1:2)) min(r(3:4)) max(r(3:4))];
        r = [max(fullExt(1),r(1)) min(fullExt(2),r(2)) max(fullExt(3),r(3)) min(fullExt(4),r(4))];
        if r(2) <= r(1) || r(4) <= r(3), return, end
        region = r; showRegionEdits(); redraw();
    end

    function showRegionEdits()
        set(edX0,'String',sprintf('%.3f',region(1))); set(edX1,'String',sprintf('%.3f',region(2)));
        set(edY0,'String',sprintf('%.3f',region(3))); set(edY1,'String',sprintf('%.3f',region(4)));
    end

    function computeFull()
        if isempty(DS), return, end
        ex = [min(arrayfun(@(d) min(d.x - d.Step(1)/2),DS)) max(arrayfun(@(d) max(d.x + d.Step(1)/2),DS)) ...
              min(arrayfun(@(d) min(d.y - d.Step(2)/2),DS)) max(arrayfun(@(d) max(d.y + d.Step(2)/2),DS))];
        fullExt = ex; region = ex; showRegionEdits();
    end

    function fullMap()
        if isempty(DS), return, end
        computeFull(); redraw();
    end

    function regionEdited()
        v = [str2double(get(edX0,'String')) str2double(get(edX1,'String')) str2double(get(edY0,'String')) str2double(get(edY1,'String'))];
        if any(isnan(v)), return, end
        setRegion(v);
    end

    function selectOnMap()
        if isempty(DS), return, end
        setStatus('Drag a rectangle on one of the upper maps (press, drag, release).');
        figure(fig);
        try
            k = waitforbuttonpress;
            if k ~= 0, setStatus('Selection cancelled.'); return, end
            ax = gca; p1 = get(ax,'CurrentPoint'); rbbox; p2 = get(ax,'CurrentPoint');
            setRegion([p1(1,1) p2(1,1) p1(1,2) p2(1,2)]);
            setStatus('Region set. The enlarged maps are shown in the second row (view A).');
        catch ME
            setStatus(['Selection failed: ' ME.message]);
        end
    end

%% ---------------- Statistik ----------------
    function updateStats()
        Z = getappdata(PM,'statZ'); idx = getappdata(PM,'statIdx');
        if isempty(Z), return, end
        rowsOut = cell(0,8);
        for j = 1:numel(Z)
            k = idx(j); [z,~,~] = getZ(k);
            [XX,YY] = meshgrid(DS(k).x,DS(k).y);
            in = XX >= region(1) & XX <= region(2) & YY >= region(3) & YY <= region(4);
            v = z(in & isfinite(z)); if isempty(v), continue, end
            med = median(v);
            rowsOut(end+1,:) = {DS(k).DispName,numel(v),mean(v),med,std(v),100*1.4826*median(abs(v - med))/abs(med),min(v),max(v)}; %#ok<AGROW>
        end
        statsData = rowsOut;
        set(tblStat,'Data',rowsOut);
    end

%% ---------------- Export ----------------
    function exportFigure()
        if isempty(tl) || ~isvalid(tl), return, end
        [fn,pn] = uiputfile({'*.png','PNG'},'Save figure',fullfile(getpref('EDDIDAT','PsiMap_Dir',pwd),'fitmaps.png'));
        if isequal(fn,0), return, end
        try
            exportgraphics(tl,fullfile(pn,fn),'Resolution',200);
        catch
            fr = getframe(PM); imwrite(fr.cdata,fullfile(pn,fn));
        end
        setStatus(['Figure saved: ' fullfile(pn,fn)]);
    end

    function exportAllPng(outDir)
        % Alle Peaks x alle Groessen (ohne Delta E / Delta d vs. reference), nur fuer die gewaehlte Ansicht: A = Uebersicht aller Datensaetze,
        % B = je Datensatzpaar eine Vergleichskarte (gewaehlte "Show"-Darstellung).
        if isempty(DS) || ~any([DS.Use]), return, end
        if nargin < 1 || isempty(outDir)
            base = uigetdir(getpref('EDDIDAT','PsiMap_Dir',pwd),'Folder for the PNG files (a subfolder is created)');
            if isequal(base,0), return, end
            outDir = fullfile(base,['fitmaps_' datestr(now,'yyyymmdd_HHMMSS')]);
        end
        if ~exist(outDir,'dir'), mkdir(outDir); end
        sv = struct('peak',get(popPeak,'Value'),'qty',get(popQty,'Value'),'view',get(popView,'Value'),'a',get(popA,'Value'),'b',get(popB,'Value'));
        qtys = [1 2 3 4 5 7]; qnames = {'Iint_per_pixel','Iint','Emax','dEmax','Ib','','d_spacing'};
        nPeaks = numel(get(popPeak,'String')); nFiles = 0; nErr = 0;
        wb = waitbar(0,'Exporting maps ...','Name','Export PNG');
        try
            for ip = 1:nPeaks
                set(popPeak,'Value',ip); matchPeaks();
                used = find([DS.Use] & isfinite(matchIdx));
                if isempty(used), continue, end
                pn = regexprep(peakName(),'[^A-Za-z0-9.()_-]+','_');
                for q = qtys
                    set(popQty,'Value',q);
                    if ishandle(wb), waitbar(((ip-1)*numel(qtys) + find(qtys==q) - 1)/(nPeaks*numel(qtys)),wb,strrep(sprintf('%s, %s',pn,qnames{q}),'_','\_')); end
                    if sv.view == 1
                        set(popView,'Value',1); redraw();
                        [nFiles,nErr] = savePng(fullfile(outDir,sprintf('%s_%s_overview.png',pn,qnames{q})),nFiles,nErr);
                    elseif numel(used) >= 2
                        set(popView,'Value',2);
                        for i = 1:numel(used)-1
                            for j = i+1:numel(used)
                                set(popA,'Value',i); set(popB,'Value',j); redraw();
                                tag = sprintf('B%d_vs_B%d',DS(used(j)).Bin,DS(used(i)).Bin);
                                if DS(used(i)).Bin == DS(used(j)).Bin, tag = sprintf('%s_vs_%s',regexprep(DS(used(j)).DispName,'\W','_'),regexprep(DS(used(i)).DispName,'\W','_')); end
                                [nFiles,nErr] = savePng(fullfile(outDir,sprintf('%s_%s_compare_%s.png',pn,qnames{q},tag)),nFiles,nErr);
                            end
                        end
                    end
                end
            end
        catch ME
            setStatus(['PNG export failed: ' ME.message]);
        end
        if ishandle(wb), close(wb); end
        set(popPeak,'Value',sv.peak); set(popQty,'Value',sv.qty); set(popView,'Value',sv.view); matchPeaks();
        set(popA,'Value',min(sv.a,numel(get(popA,'String')))); set(popB,'Value',min(sv.b,numel(get(popB,'String')))); redraw();
        setStatus(sprintf('%d PNG files saved to %s (%d failed)',nFiles,outDir,nErr));
    end

    function [nFiles,nErr] = savePng(file,nFiles,nErr)
        if isempty(tl) || ~isvalid(tl), nErr = nErr + 1; return, end
        try
            exportgraphics(tl,file,'Resolution',150); nFiles = nFiles + 1;
        catch
            try
                drawnow; fr = getframe(PM); imwrite(fr.cdata,file); nFiles = nFiles + 1;
            catch
                nErr = nErr + 1;
            end
        end
    end

    function exportGrids()
        if isempty(DS) || isempty(matchIdx), return, end
        [fn,pn] = uiputfile({'*.mat','MAT'},'Save grids','fitmaps_grids.mat');
        if isequal(fn,0), return, end
        out = struct('Name',{},'Bin',{},'x',{},'y',{},'Z',{},'Quantity',{});
        for k = find([DS.Use] & isfinite(matchIdx))
            [z,~,lab] = getZ(k);
            out(end+1) = struct('Name',DS(k).DispName,'Bin',DS(k).Bin,'x',DS(k).x,'y',DS(k).y,'Z',z,'Quantity',lab); %#ok<AGROW>
        end
        Common = getappdata(PM,'commonR'); %#ok<NASGU>
        Peak = get(popPeak,'String'); Region = region; %#ok<NASGU>
        save(fullfile(pn,fn),'out','Common','Peak','Region');
        setStatus(['Grids saved: ' fullfile(pn,fn)]);
    end

    function exportStats()
        if isempty(statsData), return, end
        [fn,pn] = uiputfile({'*.csv','CSV'},'Save statistics','fitmaps_statistics.csv');
        if isequal(fn,0), return, end
        T = cell2table(statsData,'VariableNames',{'Dataset','N','Mean','Median','Std','MAD_percent','Min','Max'});
        writetable(T,fullfile(pn,fn),'Delimiter',';');
        setStatus(['Statistics saved: ' fullfile(pn,fn)]);
    end

%% ---------------- Hilfsfunktionen ----------------
    function s = peakName()
        l = get(popPeak,'String'); if ischar(l), l = {l}; end
        s = l{min(get(popPeak,'Value'),numel(l))};
    end
    function setView(v), set(popView,'Value',v); redraw(); end
    function setQuantity(q), set(popQty,'Value',q); redraw(); end
    function setSmooth(s), set(popSmooth,'Value',s); redraw(); end
    function s = getState(), s = struct('DS',{DS},'Match',matchIdx,'Region',region,'Full',fullExt,'Stats',{statsData},'LastStats',lastStats); end
    function setStatus(s), set(txtStatus,'String',s); drawnow limitrate, end
    function waitbarSafe(wb,v,msg), if ishandle(wb), waitbar(v,wb,strrep(msg,'_','\_')); end, end

    function h = mk(par,style,pos,str,cb,align)
        h = uicontrol('Parent',par,'Style',style,'Units','normalized','Position',pos,'String',str);
        if ~isempty(cb), set(h,'Callback',cb); end
        if nargin >= 6, set(h,'HorizontalAlignment',align); end
        if strcmp(style,'text'), set(h,'BackgroundColor',get(par,'BackgroundColor')); end
    end
end

%% ---------------- Funktionen auf Dateiebene ----------------
function p = pr(v,q)
v = sort(v(:)); n = numel(v);
if n == 0, p = NaN; return, end
p = v(max(1,min(n,round(q/100*(n-1)) + 1)));
end

function y = nansq(x)
y = x.^2; y(~isfinite(y)) = 0;
end

function m = divMap()
b = [0.23 0.30 0.75]; w = [0.97 0.97 0.97]; r = [0.71 0.02 0.15];
t = linspace(0,1,256)';
m = zeros(256,3);
lo = t <= 0.5; s1 = t(lo)/0.5; s2 = (t(~lo)-0.5)/0.5;
m(lo,:) = (1-s1).*b + s1.*w;
m(~lo,:) = (1-s2).*w + s2.*r;
end
