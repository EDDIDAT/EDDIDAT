function kplotbutton_Callback(source,~,data) 
    % This callback calculates the peak positions of the phase entered in
    % the edit text field. If the MPD fiel does not exist, an error
    % message occurs.
    % Reset plot to the spectrum data.
    Plothandles = guidata(gcbo);
    MPDFile = Plothandles.MPDFile;
    % Create path of mpd file.
    Path = fullfile('Data','Materials',[MPDFile '.mpd']);
    % Import and read MPD file.
    M = Tools.StringOperations.AsciiFile2Text(Path,'\r\n');
    % Create data structure
    T = data;
    % Read crystal structure.
    Index_tmp = Tools.StringOperations.SearchString(M,'Gittertyp');
    T.CrystalStructure = sscanf(M(Index_tmp(1)+1,:),'%s');
    % Read lattice parameter.
    Index_tmp = Tools.StringOperations.SearchString(M,'Gitterparameter');
    LatticeParameter = sscanf(M(Index_tmp(1)+1,:),'%f');
    T.LatticeParameter = LatticeParameter';
    % If no cubic material is present, read the hkl- and d-spacing values
    % from the MPD file.
    if strcmp(T.CrystalStructure,'none')
        % Einlesen der hkl- und d-Werteliste
        Index_tmp = Tools.StringOperations.SearchString(M,'hkl- und d-Wertliste');
        % Neues Char Array erzeugen, dass nur die hkl- und d-Werte enthält
        M1 = M(Index_tmp+1:size(M,1),:);
        % Werte einlesen (cell) um d-spacing Werte zu extrahieren
        for k = 1:size(M1,1)
            hkldtmp(:,k) = textscan(M1(k,:),'%s%f');
        end
        % Werte in eine Matrix schreiben
%         hkl_d_spacing = cell2mat(hkldtmp);
        % Matrix umstellen, nur d-Werte einschreiben
%         d_spacing = [hkl_d_spacing(2,:)]';
        for k = 1:size(M1,1)
            d_spacing(k) = hkldtmp{2,k};
        end
        % h- k- und l-Werte speichern
        h = str2num(M1(:,1));
        k = str2num(M1(:,2));
        l = str2num(M1(:,3));
        % h-, k-, l- und d-Werte sortieren und zusammenfügen und für den Plot vorbereiten
        T.HKLdspacing = [h k l d_spacing'];
    end
    Plothandles.PhaseInfo = T;
    
    % Crystal structure of the material
    T.cs = 0;
    T.cs = T.CrystalStructure;
    % Lattice parameter of the material
    T.a0 = 0;
    if strcmp(T.cs, 'none')
        T.a0 = 0;
    else
        T.a0 = T.LatticeParameter;
    end

    % Calculation of minimum d spacing
    T.dmin = 0;
    T.dmin = (0.6199/sind(T.twotheta/2))/T.EMax;
    % Calculation of maximum hkl²
    T.hklquadratmax = 0;
    T.hklquadratmax = (T.a0(1)/T.dmin)^2;
    
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
        T.dtheo = 0;
        for i = 1:length(T.z)
            T.dtheo(i,:) = T.a0/(sqrt(T.z(i,1)^2+T.z(i,2)^2+T.z(i,3)^2));
        end
        
        T.hkl = 0;
        T.hkl = [T.z T.dtheo];
        % Sort columns in descending order
        T.hkl_sort = sortrows(T.hkl, -4);
        % Calculation of theoreitcal energy positons for the used hkl values
        T.Etheo = 0;
        for i = 1:size(T.hkl_sort,1)
            T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
        T.Peaks = 0;
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
        T.dtheo = 0;
        for i = 1:length(T.w)
            T.dtheo(i,:) = T.a0/(sqrt(T.w(i,1)^2+T.w(i,2)^2+T.w(i,3)^2));
        end
        
        T.hkl = 0;
        T.hkl = [T.w, T.dtheo];
        % Sort columns in descending order
        T.hkl_sort = sortrows(T.hkl, -4);
        % Calculation of theoreitcal energy positons for the used hkl values
        T.Etheo = 0;
        for i = 1:size(T.hkl_sort,1)
            T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
        
        T.Peaks = 0;
        T.Peaks = [T.hkl_sort T.Etheo];
    %--------------------------------------------------------------------------
    else
        T.hkl = 0;
        T.hkl = T.HKLdspacing;
            
        T.Etheo = 0;
        for i = 1:size(T.hkl,1)
            T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl(i,4);
        end

        T.Peaks = 0;
        T.Peaks = [T.hkl T.Etheo];
    end
    
    % Create matrix for the line plot of the peak positions (X values)
    Peaks = T.Peaks;
    for k = 1:size(Peaks,1)
        X1(k,:) = [Peaks(k,5) Peaks(k,5) nan];
    end
    
    % Adjust the size of matrix to the measurement
    T.X1 = 0;
    T.X1 = X1;
    T.X2 = 0;
    T.X2 = reshape(T.X1',size(T.Peaks,1).*3,1);
    T.X2(size(T.Peaks,1).*3,:) = [];
    T.X3 = 0;
    T.X3 = repmat(T.X2,1,length(T.Peaks_y));
    
    % Adjust the size of matrix to the measurement
    T.Y2 = 0;
    T.Y2 = reshape(T.Y1',3,length(T.Peaks_y));
    T.Y3 = 0;
    T.Y3 = repmat(T.Y2,size(T.Peaks,1),1);
    T.Y3(size(T.Peaks,1).*3,:)= [];

    % Line plot of the diffraction lines of the choosen phase.
    if size(T.Y3,2) == 1
        hphase = line(T.X3(:,1),T.Y3(:,size(T.Y3,2)));
    elseif size(T.Y3,2) == 3
        hphase = line(T.X3(:,1),T.Y3(:,size(T.Y3,2)-2));
    end
    hphase.Color = 'green';
    hphase.LineWidth = 1.2;
    Plothandles.hphase = hphase;
    guidata(gcbo,Plothandles);
end