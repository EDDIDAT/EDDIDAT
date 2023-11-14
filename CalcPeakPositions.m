function Peakhandles = CalcPeakPositions(ElementalFormula,MPDFileName,twotheta,Emax)

P.ElementalFormula = ElementalFormula;
P.MPDFileName = MPDFileName;
P.ShowSubstratePeaks = 0;

[out, T] = CreateSampleEPostheo(P);

% TwoTheta of measurement
T.twotheta = twotheta;

% Info from material
% Maximum Energy up to which peak positions are calculated
T.EMax = Emax;
% Crystal structure of the material
T.cs = T.Material.CrystalStructure;
% Lattice parameter of the material
T.a0 = T.Material.LatticeParameter;
% Calculation of minimum d spacing
T.dmin = (0.6199/sind(T.twotheta/2))/T.EMax;
% Calculation of maximum hkl�
if ~isempty(T.a0)
    T.hklquadratmax = (T.a0(1)/T.dmin)^2;
else
    T.hklquadratmax = [];
end

% Calculation of the maximum peak intensities of the respecive spectrum
% Intensity maximum
T.Peaks_y = 100;
% Create matrix for the line plot of the peak positions (Y values)
T.Y1 = [0 T.Peaks_y nan];

%% Plot diffraction lines from Material
% Calculation of peak positions for bcc materials
if strcmp(T.cs,'bcc')
    % Calculation of all possible hkl combinations
    [T.h, T.k, T.l] = ndgrid(1:10, 0:9, 0:9);
    T.d = T.h+T.k+T.l;
    i = find(rem(T.d,2) == 0);
    T.p = [T.h(i),T.k(i),T.l(i)];
    % Use only hkl with hkl� < hkl�max
    for i=1:size(T.p,1)
        if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
            T.y(i,:) = T.p(i,:);
        end
    end
    % delete zero rows
    T.y(all(T.y == 0,2),:)=[];
%     assignin('base','y',T.y)
    % Use only hkl that are allowed for bcc materials
    for i=1:size(T.y,1)
        if T.y(i,1) >= T.y(i,2) && T.y(i,1) >= T.y(i,3) && T.y(i,2) >= T.y(i,3)
           T.z(i,:) = T.y(i,:);
        end
    end
    % delete zero rows
    T.z(all(T.z == 0,2),:)=[];
    % Calculation of theoretical d spacings for the used hkl values
    for i = 1:size(T.z,1)
        T.dtheo(i,:) = T.a0/(sqrt(T.z(i,1)^2+T.z(i,2)^2+T.z(i,3)^2));
    end

    T.hkl = [T.z T.dtheo];
    % Sort columns in descending order
    T.hkl_sort = sortrows(T.hkl, -4);
    [C,ia,ic] = unique(T.hkl_sort(:,4),'rows','last');
    T.hkl_sort = T.hkl_sort(ia,1:4);
    T.hkl_sort = sortrows(T.hkl_sort, -4);
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
    % Use only hkl with hkl� < hkl�max
    for i=1:size(T.p,1)
        if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
            T.y(i,:) = T.p(i,:);
        end
    end
    % delete zero rows
    T.y(all(T.y == 0,2),:)=[];
    % Use only hkl that are allowed for fcc materials
    for i=1:size(T.y,1)
        if T.y(i,1) >= T.y(i,2) && T.y(i,1) >= T.y(i,3) && T.y(i,2) >= T.y(i,3)
            T.z(i,:) = T.y(i,:);
        end
    end
    % delete zero rows
    T.z(all(T.z == 0,2),:)=[];
    % Find only hkl that are all even
    for i=1:size(T.z,1)
        if rem(T.z(i,1),2) == 0 && rem(T.z(i,2),2) == 0 && rem(T.z(i,3),2) == 0
            T.w1(i,:) = T.z(i,:);
        end
    end
    % delete zero rows
    T.w1(all(T.w1 == 0,2),:)=[];
    % Find only hkl that are all odd
    for i=1:size(T.z,1)
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
    [C,ia,ic] = unique(T.hkl_sort(:,4),'rows','last');
    T.hkl_sort = T.hkl_sort(ia,1:4);
    T.hkl_sort = sortrows(T.hkl_sort, -4);
    % Calculation of theoreitcal energy positons for the used hkl values
    for i = 1:size(T.hkl_sort,1)
        T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
    end

    T.Peaks = [T.hkl_sort T.Etheo];
%--------------------------------------------------------------------------
else
    T.hkl = T.Material.HKLdspacing;
    [C,ia,ic] = unique(T.hkl(:,4),'rows','last');
    T.hkl = T.hkl(ia,1:4);
    T.hkl_sort = sortrows(T.hkl, -4);
    for i = 1:size(T.hkl,1)
        T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
    end
    a = T.Etheo < T.EMax;
    T.Peaks = [T.hkl_sort(1:length(a(a==1)),:) T.Etheo(a)];
end

for i = 1:size(T.Peaks,1)
    T.X1(i,:) = [T.Peaks(i,5) T.Peaks(i,5) nan];
end
T.X2 = reshape(T.X1',size(T.Peaks,1).*3,1);
T.X2(size(T.Peaks,1).*3,:) = [];
T.X3 = repmat(T.X2,1,1);
% Adjust the size of matrix to the measurement
T.Y2 = reshape(T.Y1',3,1);
T.Y3 = repmat(T.Y2,size(T.Peaks,1),1);
T.Y3(size(T.Peaks,1).*3,:)= [];

Peakhandles = T;
% Show results in command window
fprintf(['\nEnergy positions of ',MPDFileName,' for 2theta = ',num2str(twotheta),'�','\n\n'])
fprintf('%3s   %9s   %5s\n','hkl','d-spacing','E-Pos');
fprintf('%d%d%d   %.4f      %.4f\n', [T.Peaks].')
end

