function api = BCFTab(parent)
% BCFTAB  Inhalt des Tabs "BCF import" der EDDIDAT-GUI (Entwurf).
%
%   api = BCFTab(parentTab)
%
% Bearbeitung von Bruker-Mappings (.bcf) mit energiedispersiven Beugungsspektren je Bildpunkt:
%   1) BCF-Datei waehlen, groben Uebersichtswuerfel laden (Python, einmalig, wird zwischengespeichert)
%   2) Rechteck auf der Karte aufziehen (oder x/y in mm eintippen) und das Summenspektrum ansehen
%   3) Reflexe: automatische Peaksuche oder per Klick; Intensitaetskarten (Netto, ohne Fit) berechnen
%   4) Streifen-MAT-Dateien fuer die Fit-Auswertung erzeugen (Binning, Bereich, optionale Probenmaske)
% Alles Interaktive laeuft in MATLAB auf dem Uebersichtswuerfel; Python (Data\Tools\bcf_tool.py) wird nur
% zum Lesen der BCF-Datei (Cache, Export) und fuer die Kopfdaten aufgerufen.
%
% Rueckgabe api: Funktionshandles zum Testen/Skripten (openBcf, loadOverview, setRegion, findPeaks,
% computeMaps, exportStrips, state).

%% ---------------- Zustand ----------------
Cube = []; E = []; B = 8; psx = 0; psy = 0; nx = 0; ny = 0;
info = struct(); bcfFile = '';
Maps = struct('Name',{},'E',{},'HW',{},'M',{});
region = [0 0 0 0]; hRect = []; selRows = []; lastResult = struct();
specE = []; specY = [];
root = programRoot();
toolDir = fullfile(root,'Data','Tools');

%% ---------------- Oberflaeche ----------------
fig = ancestor(parent,'figure');
bg = get(parent,'BackgroundColor');
P1 = uipanel('Parent',parent,'Title','1  BCF file','Units','normalized','Position',[0.005 0.745 0.295 0.250]);
P2 = uipanel('Parent',parent,'Title','2  Region (mm)','Units','normalized','Position',[0.005 0.610 0.295 0.130]);
P3 = uipanel('Parent',parent,'Title','3  Reflexes','Units','normalized','Position',[0.005 0.290 0.295 0.315]);
P4 = uipanel('Parent',parent,'Title','4  Export strips','Units','normalized','Position',[0.005 0.005 0.295 0.280]);
PM = uipanel('Parent',parent,'Title','Overview map','Units','normalized','Position',[0.305 0.470 0.690 0.525]);
PS = uipanel('Parent',parent,'Title','Spectrum of the region','Units','normalized','Position',[0.305 0.040 0.690 0.425]);
txtStatus = uicontrol('Parent',parent,'Style','text','Units','normalized','Position',[0.305 0.003 0.690 0.032], ...
    'HorizontalAlignment','left','BackgroundColor',bg,'String','Select a BCF file.');

% --- Panel 1: Datei
mk(P1,'pushbutton',[0.03 0.78 0.30 0.19],'Open BCF...',@(~,~) openBcf(''));
txtFile = mk(P1,'text',[0.35 0.78 0.62 0.19],'(no file)',[],'left');
txtInfo = mk(P1,'text',[0.03 0.54 0.94 0.24],'',[],'left');
mk(P1,'text',[0.03 0.38 0.30 0.13],'Overview E max (keV)',[],'left');
edEmaxC = mk(P1,'edit',[0.34 0.37 0.14 0.15],'15',[]);
mk(P1,'text',[0.03 0.20 0.30 0.14],'Overview binning',[],'left');
popBin = mk(P1,'popupmenu',[0.34 0.19 0.14 0.17],{'4','6','8','10','12','16'},[]); set(popBin,'Value',3);
btnLoad = mk(P1,'pushbutton',[0.52 0.17 0.45 0.20],'Load overview',@(~,~) loadOverview());
mk(P1,'text',[0.03 0.02 0.14 0.13],'Python',[],'left');
edPy = mk(P1,'edit',[0.17 0.02 0.63 0.15],getpref('EDDIDAT','BCF_Python','python'),@(s,~) setpref('EDDIDAT','BCF_Python',strtrim(get(s,'String'))),'left');
mk(P1,'pushbutton',[0.82 0.02 0.15 0.15],'...',@(~,~) browsePython());

% --- Panel 2: Region
mk(P2,'text',[0.03 0.62 0.08 0.28],'x',[],'left');
edX0 = mk(P2,'edit',[0.12 0.62 0.20 0.30],'0',@(~,~) regionEdited());
mk(P2,'text',[0.33 0.62 0.05 0.28],'-',[],'center');
edX1 = mk(P2,'edit',[0.39 0.62 0.20 0.30],'0',@(~,~) regionEdited());
mk(P2,'text',[0.03 0.30 0.08 0.28],'y',[],'left');
edY0 = mk(P2,'edit',[0.12 0.30 0.20 0.30],'0',@(~,~) regionEdited());
mk(P2,'text',[0.33 0.30 0.05 0.28],'-',[],'center');
edY1 = mk(P2,'edit',[0.39 0.30 0.20 0.30],'0',@(~,~) regionEdited());
txtRegion = mk(P2,'text',[0.62 0.30 0.36 0.62],'',[],'left');
mk(P2,'pushbutton',[0.03 0.02 0.50 0.25],'Select on map',@(~,~) selectOnMap());
mk(P2,'pushbutton',[0.55 0.02 0.40 0.25],'Full map',@(~,~) fullMap());

% --- Panel 3: Reflexe
tbl = uitable('Parent',P3,'Units','normalized','Position',[0.02 0.34 0.96 0.64], ...
    'RowName',[],'ColumnName',{'Use','Name','E (keV)','HW (keV)'},'ColumnFormat',{'logical','char','numeric','numeric'}, ...
    'ColumnEditable',[true true true true],'ColumnWidth',{35 105 80 80},'Data',cell(0,4), ...
    'CellEditCallback',@(~,~) windowsEdited(),'CellSelectionCallback',@(~,ev) set_sel(ev));
mk(P3,'pushbutton',[0.02 0.20 0.28 0.11],'Find peaks',@(~,~) findPeaks());
mk(P3,'pushbutton',[0.32 0.20 0.28 0.11],'Add (click)',@(~,~) addByClick());
mk(P3,'pushbutton',[0.62 0.20 0.17 0.11],'Delete',@(~,~) deleteRows());
mk(P3,'pushbutton',[0.81 0.20 0.17 0.11],'Clear',@(~,~) clearWindows());
mk(P3,'text',[0.02 0.04 0.22 0.11],'Flank (keV)',[],'left');
edFlank = mk(P3,'edit',[0.25 0.04 0.12 0.12],'0.30',[]);
mk(P3,'pushbutton',[0.42 0.03 0.56 0.14],'Compute maps',@(~,~) computeMaps());

% --- Panel 4: Export
mk(P4,'text',[0.03 0.86 0.30 0.10],'Binning',[],'left');
popBinEx = mk(P4,'popupmenu',[0.35 0.86 0.20 0.11],{'2','3','4','5','6','8'},[]); set(popBinEx,'Value',5);
mk(P4,'text',[0.58 0.86 0.14 0.10],'E (keV)',[],'left');
edExE0 = mk(P4,'edit',[0.70 0.86 0.12 0.11],'5',[]);
edExE1 = mk(P4,'edit',[0.84 0.86 0.13 0.11],'15',[]);
mk(P4,'text',[0.03 0.74 0.30 0.10],'Strip width (mm)',[],'left');
edStrip = mk(P4,'edit',[0.35 0.74 0.20 0.11],'1.0',[]);
mk(P4,'text',[0.57 0.74 0.40 0.10],'0 = one file',[],'left');
mk(P4,'text',[0.03 0.62 0.30 0.10],'Sample mask',[],'left');
popRef = mk(P4,'popupmenu',[0.35 0.62 0.62 0.11],{'None (keep all blocks)'},[]);
mk(P4,'text',[0.03 0.50 0.30 0.10],'Threshold (%)',[],'left');
edThr = mk(P4,'edit',[0.35 0.50 0.20 0.11],'30',[]);
mk(P4,'text',[0.03 0.38 0.30 0.10],'2theta (deg)',[],'left');
edTth = mk(P4,'edit',[0.35 0.38 0.20 0.11],'125.9',[]);
mk(P4,'pushbutton',[0.57 0.37 0.40 0.12],'from angles...',@(~,~) tthFromAngles());
mk(P4,'text',[0.03 0.26 0.30 0.10],'Output folder',[],'left');
edOut = mk(P4,'edit',[0.35 0.26 0.48 0.11],fullfile(root,'Data','Measurements','IKZ'),[],'left');
mk(P4,'pushbutton',[0.85 0.26 0.12 0.11],'...',@(~,~) browseOut());
mk(P4,'text',[0.03 0.14 0.30 0.10],'Subfolder',[],'left');
edSub = mk(P4,'edit',[0.35 0.14 0.62 0.11],'',[],'left');
btnExport = mk(P4,'pushbutton',[0.03 0.01 0.58 0.12],'Create strips',@(~,~) exportStrips());
mk(P4,'pushbutton',[0.64 0.01 0.33 0.12],'Open folder',@(~,~) openFolder());

% --- Karte
popMap = uicontrol('Parent',PM,'Style','popupmenu','Units','normalized','Position',[0.01 0.93 0.30 0.06],'String',{'Total counts'},'Callback',@(~,~) drawMap());
chkClip = uicontrol('Parent',PM,'Style','checkbox','Units','normalized','Position',[0.33 0.93 0.22 0.06],'String','clip 2-98 %','Value',1,'Callback',@(~,~) drawMap());
axMap = axes('Parent',PM,'Units','normalized','Position',[0.07 0.10 0.80 0.80]);
set(axMap,'Box','on'); xlabel(axMap,'x (mm)'); ylabel(axMap,'y (mm)');

% --- Spektrum
popMode = uicontrol('Parent',PS,'Style','popupmenu','Units','normalized','Position',[0.01 0.92 0.14 0.07],'String',{'Sum','Mean per block'},'Callback',@(~,~) updateSpectrum());
chkLog = uicontrol('Parent',PS,'Style','checkbox','Units','normalized','Position',[0.17 0.92 0.08 0.07],'String','log','Value',0,'Callback',@(~,~) updateSpectrum());
uicontrol('Parent',PS,'Style','text','Units','normalized','Position',[0.27 0.92 0.12 0.06],'String','E from/to (keV)','HorizontalAlignment','right');
edE0 = uicontrol('Parent',PS,'Style','edit','Units','normalized','Position',[0.40 0.92 0.06 0.07],'String','5','Callback',@(~,~) updateSpectrum());
edE1 = uicontrol('Parent',PS,'Style','edit','Units','normalized','Position',[0.47 0.92 0.06 0.07],'String','15','Callback',@(~,~) updateSpectrum());
axSpec = axes('Parent',PS,'Units','normalized','Position',[0.07 0.13 0.90 0.72]);
set(axSpec,'Box','on'); xlabel(axSpec,'E (keV)'); ylabel(axSpec,'counts');

enableData(false);
if ~isempty(getpref('EDDIDAT','BCF_Python','')), set(edPy,'String',getpref('EDDIDAT','BCF_Python','python')); end

api = struct('openBcf',@openBcf,'loadOverview',@loadOverview,'setRegion',@setRegion,'findPeaks',@findPeaks, ...
    'computeMaps',@computeMaps,'exportStrips',@exportStrips,'setWindows',@setWindows,'state',@getState);

%% ---------------- Callbacks ----------------
    function openBcf(file)
        if isempty(file)
            startDir = getpref('EDDIDAT','BCF_Dir',pwd);
            [fn,pn] = uigetfile({'*.bcf','Bruker BCF (*.bcf)'},'Select BCF file',startDir);
            if isequal(fn,0), return, end
            file = fullfile(pn,fn);
        end
        setpref('EDDIDAT','BCF_Dir',fileparts(file));
        setStatus('Reading BCF header ...');
        r = runTool({'info','--bcf',file});
        if ~r.ok, errorBox(r.msg); return, end
        bcfFile = file; info = r.result;
        set(txtFile,'String',info.Datei);
        set(txtInfo,'String',sprintf(['%d x %d pixel, pixel %.3f x %.3f um\n%d channels, %.2f ms per pixel\n' ...
            'detector elevation %.0f deg, beam %.0f kV, %s'],info.Width,info.Height,info.PixelXum,info.PixelYum,info.Channels, ...
            info.MsPerPixel,info.ElevationAngle,info.BeamEnergy_kV,info.Date));
        [~,stem] = fileparts(file); set(edSub,'String',stem);
        Cube = []; Maps(:) = []; set(tbl,'Data',cell(0,4)); enableData(false); cla(axMap); cla(axSpec);
        setStatus('BCF file opened. Press "Load overview" (builds a coarse cube once, about 30 s).');
    end

    function loadOverview()
        if isempty(bcfFile), errorBox('Open a BCF file first.'); return, end
        binVals = [4 6 8 10 12 16]; B = binVals(get(popBin,'Value'));
        cacheDir = fullfile(tempdir,'EDDIDAT_bcf_cache'); if ~exist(cacheDir,'dir'), mkdir(cacheDir); end
        [~,stem] = fileparts(bcfFile);
        emaxC = str2double(get(edEmaxC,'String')); if isnan(emaxC) || emaxC < 2, emaxC = 15; set(edEmaxC,'String','15'); end
        cacheFile = fullfile(cacheDir,sprintf('%s_B%d_E%g.mat',stem,B,emaxC));
        d = dir(bcfFile); ok = false;
        if exist(cacheFile,'file')
            try
                m = load(cacheFile,'BcfSize','BcfMTime'); ok = (m.BcfSize == d.bytes);
            catch, ok = false; end
        end
        if ~ok
            wb = waitbar(0.3,'Reading the BCF file (about 30 to 60 s) ...','Name','BCF overview');
            r = runTool({'cache','--bcf',bcfFile,'--out',cacheFile,'--bin',num2str(B),'--emin','0.5','--emax',num2str(emaxC)});
            if ishandle(wb), delete(wb); end
            if ~r.ok, errorBox(r.msg); return, end
        end
        setStatus('Loading overview cube ...'); drawnow
        L = load(cacheFile);
        Cube = L.Cube; E = double(L.E(:)); B = double(L.Bin); psx = L.PixelXum/1000; psy = L.PixelYum/1000;
        [ny,nx,~] = size(Cube);
        set(edE0,'String',num2str(max(5,round(E(1),1)))); set(edE1,'String',num2str(round(E(end),1)));
        enableData(true);
        setRegion([0 nx*B*psx 0 ny*B*psy]);
        Maps(:) = []; set(popMap,'String',{'Total counts'},'Value',1); set(popRef,'String',{'None (keep all blocks)'},'Value',1);
        drawMap();
        setStatus(sprintf('Overview %d x %d blocks (%d x %d pixel), %.2f x %.2f mm. Draw a rectangle or look at the full spectrum.',nx,ny,B,B,nx*B*psx,ny*B*psy));
    end

    function setRegion(r)
        r = [min(r(1:2)) max(r(1:2)) min(r(3:4)) max(r(3:4))];
        W = nx*B*psx; H = ny*B*psy;
        r = [max(0,r(1)) min(W,r(2)) max(0,r(3)) min(H,r(4))];
        region = r;
        set(edX0,'String',sprintf('%.3f',r(1))); set(edX1,'String',sprintf('%.3f',r(2)));
        set(edY0,'String',sprintf('%.3f',r(3))); set(edY1,'String',sprintf('%.3f',r(4)));
        drawRect(); updateSpectrum();
    end

    function regionEdited()
        v = [str2double(get(edX0,'String')) str2double(get(edX1,'String')) str2double(get(edY0,'String')) str2double(get(edY1,'String'))];
        if any(isnan(v)), setStatus('Region: please enter numbers.'); return, end
        setRegion(v);
    end

    function fullMap()
        if isempty(Cube), return, end
        setRegion([0 nx*B*psx 0 ny*B*psy]);
    end

    function selectOnMap()
        if isempty(Cube), return, end
        setStatus('Drag a rectangle on the overview map (press, drag, release).');
        figure(fig); set(fig,'CurrentAxes',axMap);
        try
            k = waitforbuttonpress;
            if k ~= 0, setStatus('Selection cancelled.'); return, end
            p1 = get(axMap,'CurrentPoint'); rbbox; p2 = get(axMap,'CurrentPoint');
            setRegion([p1(1,1) p2(1,1) p1(1,2) p2(1,2)]);
            setStatus('Region set. Spectrum updated.');
        catch ME
            setStatus(['Selection failed: ' ME.message]);
        end
    end

    function [ix,iy] = blockRange()
        bw = B*psx; bh = B*psy;
        ix = [max(1,ceil(region(1)/bw - 0.5) + 1), min(nx,floor(region(2)/bw - 0.5) + 1)];
        iy = [max(1,ceil(region(3)/bh - 0.5) + 1), min(ny,floor(region(4)/bh - 0.5) + 1)];
    end

    function updateSpectrum()
        if isempty(Cube), return, end
        [ix,iy] = blockRange();
        if ix(2) < ix(1) || iy(2) < iy(1)
            cla(axSpec); set(txtRegion,'String','no complete block in the region'); return
        end
        nb = (ix(2)-ix(1)+1)*(iy(2)-iy(1)+1);
        S = squeeze(sum(Cube(iy(1):iy(2),ix(1):ix(2),:),[1 2],'double'));
        if get(popMode,'Value') == 2, S = S / nb; end
        specE = E; specY = S;
        set(txtRegion,'String',sprintf('%d x %d blocks\n(%d x %d pixel)',ix(2)-ix(1)+1,iy(2)-iy(1)+1,(ix(2)-ix(1)+1)*B,(iy(2)-iy(1)+1)*B));
        drawSpectrum();
    end

    function drawSpectrum()
        if isempty(specE), return, end
        e0 = str2double(get(edE0,'String')); e1 = str2double(get(edE1,'String'));
        if isnan(e0) || isnan(e1) || e1 <= e0, e0 = E(1); e1 = E(end); end
        cla(axSpec); hold(axSpec,'on');
        m = specE >= e0 & specE <= e1;
        yl = [min(specY(m)) max(specY(m))]; if get(chkLog,'Value'), yl(1) = max(yl(1),1); end
        yl = [yl(1) - 0.02*diff(yl), yl(2) + 0.08*diff(yl)]; if get(chkLog,'Value'), yl(1) = max(1,yl(1)); end
        D = get(tbl,'Data');
        for k = 1:size(D,1)
            if D{k,1} && ~isnan(D{k,3}) && ~isnan(D{k,4})
                patch('Parent',axSpec,'XData',D{k,3}+D{k,4}*[-1 1 1 -1],'YData',[yl(1) yl(1) yl(2) yl(2)], ...
                    'FaceColor',[1 0.8 0.3],'FaceAlpha',0.35,'EdgeColor','none');
                if get(chkLog,'Value'), yt = 10^(log10(yl(2)) - 0.03*diff(log10(yl))); else, yt = yl(2) - 0.03*diff(yl); end
                text(D{k,3}+0.03,yt,D{k,2},'Parent',axSpec,'Rotation',90,'VerticalAlignment','top','HorizontalAlignment','left','FontSize',8,'Clipping','on');
            end
        end
        plot(axSpec,specE(m),specY(m),'k-','LineWidth',1);
        hold(axSpec,'off');
        set(axSpec,'XLim',[e0 e1],'YLim',yl,'YScale',ternary(get(chkLog,'Value'),'log','linear'));
        xlabel(axSpec,'E (keV)'); ylabel(axSpec,ternary(get(popMode,'Value')==1,'counts (sum)','counts per block'));
    end

    function drawMap()
        if isempty(Cube), return, end
        sel = get(popMap,'Value');
        if sel == 1
            m = E >= str2double(get(edE0,'String')) & E <= str2double(get(edE1,'String'));
            if ~any(m), m = true(size(E)); end
            Z = sum(Cube(:,:,m),3,'double'); ttl = 'Total counts';
        else
            Z = Maps(sel-1).M; ttl = sprintf('Net intensity %s',Maps(sel-1).Name);
        end
        bw = B*psx; bh = B*psy;
        imagesc(axMap,((1:nx)-0.5)*bw,((1:ny)-0.5)*bh,Z);
        set(axMap,'YDir','reverse'); axis(axMap,'image'); colormap(axMap,parula(256));
        v = Z(isfinite(Z)); if get(chkClip,'Value') && ~isempty(v)
            lo = prctile_(v,2); hi = prctile_(v,98); if hi > lo, set(axMap,'CLim',[lo hi]); end
        end
        colorbar(axMap); title(axMap,ttl,'Interpreter','none'); xlabel(axMap,'x (mm)'); ylabel(axMap,'y (mm)');
        hRect = []; drawRect();
    end

    function drawRect()
        if isempty(Cube), return, end
        if ~isempty(hRect) && all(ishandle(hRect)), delete(hRect); end
        r = region; hold(axMap,'on');
        hRect = plot(axMap,[r(1) r(2) r(2) r(1) r(1)],[r(3) r(3) r(4) r(4) r(3)],'r-','LineWidth',1.5);
        hold(axMap,'off');
    end

    function findPeaks()
        if isempty(specE), return, end
        e0 = str2double(get(edE0,'String')); e1 = str2double(get(edE1,'String'));
        m = specE >= e0 & specE <= e1;
        Pk = bcfFindPeaks(specE(m),specY(m),'MaxPeaks',8);
        if isempty(Pk), setStatus('No peaks found in the shown spectrum.'); return, end
        D = cell(numel(Pk),4);
        for k = 1:numel(Pk)
            D(k,:) = {true, sprintf('%.2f keV',Pk(k).E), round(Pk(k).E,3), round(max(0.15,0.75*Pk(k).FWHM),3)};
        end
        set(tbl,'Data',D); Maps(:) = []; refreshMapLists(); drawSpectrum();
        setStatus(sprintf('%d peak candidates (fluorescence lines and diffraction reflexes cannot be told apart here). Uncheck unwanted rows, edit E/HW, then "Compute maps".',numel(Pk)));
    end

    function setWindows(rows)
        % rows: Nx4 Zellarray {Use,Name,E,HW}, zum Testen/Skripten
        set(tbl,'Data',rows); windowsEdited();
    end

    function addByClick()
        if isempty(specE), return, end
        setStatus('Click on a peak in the spectrum.');
        figure(fig); set(fig,'CurrentAxes',axSpec);
        try
            [xc,~] = ginput(1);
        catch, return, end
        if isempty(xc), return, end
        m = abs(specE - xc) <= 0.15; [~,i] = max(movmean(specY,3).*m);
        e = specE(i);
        D = get(tbl,'Data'); D(end+1,:) = {true, sprintf('%.2f keV',e), round(e,3), 0.30}; %#ok<AGROW>
        set(tbl,'Data',D); windowsEdited();
    end

    function deleteRows()
        D = get(tbl,'Data'); if isempty(D) || isempty(selRows), return, end
        D(unique(selRows),:) = []; set(tbl,'Data',D); selRows = []; windowsEdited();
    end

    function clearWindows()
        set(tbl,'Data',cell(0,4)); windowsEdited();
    end

    function set_sel(ev)
        if isempty(ev.Indices), selRows = []; else, selRows = ev.Indices(:,1); end
    end

    function windowsEdited()
        Maps(:) = []; refreshMapLists(); drawSpectrum();
    end

    function computeMaps()
        if isempty(Cube), return, end
        D = get(tbl,'Data'); fl = str2double(get(edFlank,'String'));
        if isnan(fl) || fl <= 0, fl = 0.3; end
        Maps(:) = []; names = {'Total counts'};
        wb = waitbar(0,'Computing net intensity maps ...','Name','BCF maps');
        for k = 1:size(D,1)
            if ~D{k,1}, continue, end
            try
                M = bcfNetIntensity(Cube,E,D{k,3},D{k,4},fl);
            catch ME
                setStatus(['Map failed for ' D{k,2} ': ' ME.message]); continue
            end
            Maps(end+1) = struct('Name',D{k,2},'E',D{k,3},'HW',D{k,4},'M',M); %#ok<AGROW>
            names{end+1} = D{k,2}; %#ok<AGROW>
            if ishandle(wb), waitbar(k/size(D,1),wb); end
        end
        if ishandle(wb), delete(wb); end
        set(popMap,'String',names,'Value',min(2,numel(names)));
        set(popRef,'String',[{'None (keep all blocks)'} names(2:end)],'Value',1);
        drawMap();
        setStatus(sprintf('%d maps computed. Choose the map in the list above the overview.',numel(Maps)));
    end

    function refreshMapLists()
        set(popMap,'String',{'Total counts'},'Value',1); set(popRef,'String',{'None (keep all blocks)'},'Value',1);
        if ~isempty(Cube), drawMap(); end
    end

    function tthFromAngles()
        def = {num2str(ternary(isfield(info,'ElevationAngle'),info.ElevationAngle,50)),'50','90'};
        a = inputdlg({'Elevation of the detector (deg)  [from BCF file]','Elevation of the source (deg)  [assumption]','Azimuth between source and detector (deg)  [assumption]'}, ...
            '2theta from the geometry',1,def);
        if isempty(a), return, end
        v = str2double(a); if any(isnan(v)), return, end
        cg = sind(v(1))*sind(v(2)) + cosd(v(1))*cosd(v(2))*cosd(v(3));
        set(edTth,'String',sprintf('%.2f',180 - acosd(cg)));
        setStatus(sprintf('2theta = 180 - gamma = %.2f deg (cos gamma = %.4f). The source angles are assumptions from the paper.',180-acosd(cg),cg));
    end

    function exportStrips()
        if isempty(bcfFile), errorBox('Open a BCF file first.'); return, end
        Bex = [2 3 4 5 6 8]; Bex = Bex(get(popBinEx,'Value'));
        regionArg = {};
        if ~isempty(Cube) && ~isequal(round(region*1000),round([0 nx*B*psx 0 ny*B*psy]*1000))
            regionArg = {'--region',sprintf('%.4f,%.4f,%.4f,%.4f',region)};
        end
        strip = str2double(get(edStrip,'String')); if isnan(strip) || strip < 0, errorBox('Strip width: please enter a number >= 0.'); return, end
        ee = [str2double(get(edExE0,'String')) str2double(get(edExE1,'String'))];
        if any(isnan(ee)) || ee(2) <= ee(1) || ee(1) < 0, errorBox('Export energy range: please enter E min < E max (keV).'); return, end
        thr = str2double(get(edThr,'String'))/100; tth = str2double(get(edTth,'String'));
        if isnan(thr) || isnan(tth), errorBox('Threshold and 2theta must be numbers.'); return, end
        refArg = {'--ref-fenster','none'};
        k = get(popRef,'Value');
        if k > 1 && numel(Maps) >= k-1
            mp = Maps(k-1); refArg = {'--ref-fenster',sprintf('%.4f,%.4f',mp.E-mp.HW,mp.E+mp.HW),'--schwelle',sprintf('%.4f',thr)};
        end
        outDir = fullfile(strtrim(get(edOut,'String')),strtrim(get(edSub,'String')));
        if exist(outDir,'dir') && ~isempty(dir(fullfile(outDir,'*.mat')))
            a = questdlg(sprintf('The folder already contains .mat files:\n%s\n\nFiles with the same name are overwritten.',outDir),'Create strips','Continue','Cancel','Cancel');
            if ~strcmp(a,'Continue'), return, end
        end
        [~,stem] = fileparts(bcfFile);
        args = [{'export','--bcf',bcfFile,'--outdir',outDir,'--bin',num2str(Bex),'--streifenbreite-mm',num2str(strip),'--prefix',stem,'--2theta',num2str(tth),'--emin',num2str(ee(1)),'--emax',num2str(ee(2))},regionArg,refArg];
        wb = waitbar(0.3,'Reading the BCF file and writing the strips (about 30 to 90 s) ...','Name','Create strips');
        r = runTool(args);
        if ishandle(wb), delete(wb); end
        if ~r.ok, errorBox(r.msg); return, end
        lastResult = r.result;
        setStatus(sprintf('%d spectra in %d file(s) written to %s',r.result.spectra,numel(r.result.files),r.result.outdir));
        msgbox(sprintf('%d spectra in %d file(s) written to\n%s\n\nLoad them with "Open File" (Xlab-IKZ) in the Fitting tab.',r.result.spectra,numel(r.result.files),r.result.outdir),'Create strips');
    end

    function openFolder()
        d = fullfile(strtrim(get(edOut,'String')),strtrim(get(edSub,'String')));
        if ~exist(d,'dir'), d = strtrim(get(edOut,'String')); end
        if exist(d,'dir'), winopen(d); else, errorBox('Folder does not exist yet.'); end
    end

    function browseOut()
        d = uigetdir(strtrim(get(edOut,'String')),'Output folder (the subfolder is created inside)');
        if ~isequal(d,0), set(edOut,'String',d); end
    end

    function browsePython()
        [fn,pn] = uigetfile({'*.exe','Executable (*.exe)'},'Select python.exe or bcf_tool.exe');
        if isequal(fn,0), return, end
        set(edPy,'String',fullfile(pn,fn)); setpref('EDDIDAT','BCF_Python',fullfile(pn,fn));
    end

%% ---------------- Hilfsfunktionen ----------------
    function r = runTool(args)
        % Ruft bcf_tool.py (oder bcf_tool.exe in Data\Tools) auf. r.ok, r.result (aus der Zeile "RESULT {json}"), r.msg, r.log
        r = struct('ok',false,'result',struct(),'msg','','log','');
        exe = fullfile(toolDir,'bcf_tool.exe'); script = fullfile(toolDir,'bcf_tool.py');
        py = strtrim(get(edPy,'String'));
        if exist(exe,'file')
            cmd = ['"' exe '"'];
        elseif exist(script,'file')
            cmd = ['"' py '" "' script '"'];
        else
            r.msg = ['bcf_tool.py not found in ' toolDir]; return
        end
        for k = 1:numel(args), cmd = [cmd ' "' args{k} '"']; end %#ok<AGROW>
        setenv('PYTHONIOENCODING','utf-8');
        [st,out] = system(cmd);
        r.log = out;
        lines = splitlines(out);
        res = lines(startsWith(lines,'RESULT '));
        err = lines(startsWith(lines,'ERROR '));
        if ~isempty(err), r.msg = strjoin(strrep(err,'ERROR ',''),newline); return, end
        if st ~= 0 || isempty(res)
            r.msg = sprintf('The tool failed (exit code %d). Is Python with rosettasciio, numpy and scipy installed?\n\n%s',st,out(max(1,end-600):end)); return
        end
        r.result = jsondecode(res{end}(8:end));
        r.ok = true;
    end

    function setStatus(s)
        set(txtStatus,'String',s); drawnow limitrate
    end

    function errorBox(msg)
        setStatus(['Error: ' strrep(msg,newline,' ')]); errordlg(msg,'BCF import');
    end

    function enableData(tf)
        st = ternary(tf,'on','off');
        set([edX0 edX1 edY0 edY1],'Enable',st);
    end

    function s = getState()
        s = struct('Cube',{Cube},'E',E,'Bin',B,'Region',region,'Maps',{Maps},'Spec',{{specE,specY}},'Table',{get(tbl,'Data')},'Info',info,'Last',lastResult);
    end

    function h = mk(par,style,pos,str,cb,align)
        h = uicontrol('Parent',par,'Style',style,'Units','normalized','Position',pos,'String',str);
        if ~isempty(cb), set(h,'Callback',cb); end
        if nargin >= 6, set(h,'HorizontalAlignment',align); end
        if strcmp(style,'text'), set(h,'BackgroundColor',get(par,'BackgroundColor')); end
    end
end

%% ---------------- Funktionen auf Dateiebene ----------------
function r = programRoot()
try
    r = General.ProgramInfo.Path;
catch
    r = [fileparts(fileparts(mfilename('fullpath'))) filesep];
end
end

function v = ternary(c,a,b)
if c, v = a; else, v = b; end
end

function p = prctile_(v,q)
v = sort(v(:)); n = numel(v);
i = max(1,min(n,round(q/100*(n-1)) + 1)); p = v(i);
end
