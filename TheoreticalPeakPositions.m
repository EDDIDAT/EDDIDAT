function Peakhandles = TheoreticalPeakPositions(Measurement,DataTmp,calib,Diffractometer)

% Check if ETA3000 was used
if strcmp(Diffractometer,'ETA3000')
    % Plot of substrate peaks
    PlotSubstratePeaks = Measurement(1).Sample.Materials.ShowSubstratePeaks;
    % TwoTheta of measurement
    T.twotheta = Measurement(1).twotheta;
    
%     if strcmp(h.Measurement.Anode,'Cu')
%         h.lambda = 0.154056;
%     elseif strcmp(h.Measurement.Anode,'Co')
%         lambdaka1 = 1.78897;
%         lambdaka2 = 1.79278;
%     end

    if strcmp(Measurement(1).Anode,'Cu')
        T.lambdaka1 = 1.54056;
        T.lambdaka2 = 1.54433;
        T.XRay_Energy = 8.04778;
    elseif strcmp(Measurement(1).Anode,'Co')
        T.lambdaka1 = 1.78897;
        T.lambdaka2 = 1.79278;
        T.XRay_Energy = 6.93032;
    elseif strcmp(Measurement(1).Anode,'Ag')
        T.lambdaka1 = 0.55941;
        T.lambdaka2 = 0.56380;
        T.XRay_Energy = 22.16292;
    elseif strcmp(Measurement(1).Anode,'Fe')
        T.lambdaka1 = 1.93579;
        T.lambdaka2 = 1.93991;
        T.XRay_Energy = 6.40384;
    elseif strcmp(Measurement(1).Anode,'Mo')
        T.lambdaka1 = 0.70926;
        T.lambdaka2 = 0.71354;
        T.XRay_Energy = 17.47934;
    elseif strcmp(Measurement(1).Anode,'Cr')    
        T.lambdaka1 = 2.28962;
        T.lambdaka2 = 2.29351;
        T.XRay_Energy = 5.41472;
    end



    % X-Ray wave lengths
%     agka1 = 0.055941; agka2 = 0.056380;
%     moka1 = 0.070926; moka2 = 0.071354;
%     cuka1 = 0.154056; cuka2 = 0.154433;
%     coka1 = 0.178897; coka2 = 0.179278;
%     feka1 = 0.193579; feka2 = 0.193991;
%     crka1 = 0.228962; crka2 = 0.229351;
    
    % Info from material
    % Maximum angle up to which peak positions are calculated
    T.EMax = 165;
    % Crystal structure of the material
    T.cs = Measurement(1).Sample.Materials.CrystalStructure;
    % Lattice parameter of the material
    T.a0 = Measurement(1).Sample.Materials.LatticeParameter;
    
%     % Calculate twotheta positions and only use real values
%     twothetapos_tmp = 2.*asind(lambda./(20.*TPeaks.T.Peaks(:,4)));
%     for k = 1:length(twothetapos_tmp)
%         twothetapos_tmpidx(k,1) = isreal(twothetapos_tmp(k));
%     end
%     twothetapos = twothetapos_tmp(twothetapos_tmpidx);
%     %
%     % Calculation of minimum d spacing
%     dmin_tmp = TPeaks.T.Peaks(:,4).*twothetapos_tmpidx;
%     dmin_tmp(dmin_tmp==0) = [];
%     T.dmin = min(dmin_tmp);
    T.dmin = 0.09;
    % Calculation of maximum hkl²
    if ~isempty(T.a0)
        T.hklquadratmax = (T.a0(1)/T.dmin)^2;
    else
        T.hklquadratmax = [];
    end
    
    % Info from substrate
    if (PlotSubstratePeaks)
        % Maximum Energy up to which peak positions are calculated
        S.EMax = Measurement(1).Sample.Substrate.EnergyMax;
        % Crystal structure of the material
        S.cs = Measurement(1).Sample.Substrate.CrystalStructure;
        % Lattice parameter of the material
        S.a0 = Measurement(1).Sample.Substrate.LatticeParameter;
        % Calculation of minimum d spacing
        S.dmin = (0.6199/sind(T.twotheta/2))/S.EMax;
        % Calculation of maximum hkl²
        if ~isempty(S.a0)
            S.hklquadratmax = (S.a0(1)/S.dmin)^2;
        else
            S.hklquadratmax = [];
        end
        
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
        for i=1:size(T.p,1)
            if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
                T.y(i,:) = T.p(i,:);
            end
        end
        % delete zero rows
        T.y(all(T.y == 0,2),:)=[];
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
            Etheoka1_tmp(i,:) = 2.*asind(T.lambdaka1./(20.*T.hkl_sort(i,4)));
            Etheoka2_tmp(i,:) = 2.*asind(T.lambdaka2./(20.*T.hkl_sort(i,4)));
    %         T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
        
        for k = 1:length(Etheoka1_tmp)
            Etheoka1_tmp1(k,1) = isreal(Etheoka1_tmp(k));
        end
        Etheoka1_tmp2 = Etheoka1_tmp.*Etheoka1_tmp1;
        Etheoka1_tmp2(Etheoka1_tmp2==0) = [];
        T.Etheoka1 = Etheoka1_tmp2;

        for k = 1:length(Etheoka2_tmp)
            Etheoka2_tmp1(k,1) = isreal(Etheoka2_tmp(k));
        end
        Etheoka2_tmp2 = Etheoka2_tmp.*Etheoka2_tmp1;
        Etheoka2_tmp2(Etheoka2_tmp2==0) = [];
        T.Etheoka2 = Etheoka2_tmp2;


        T.Peaks = [T.hkl_sort(Etheoka1_tmp1,:) T.Etheoka1 T.Etheoka2];
        
    % Calculation of peak positions for bcc materials
    elseif strcmp(T.cs,'fcc')
        % Calculation of all possible hkl combinations
        [T.h, T.k, T.l] = ndgrid(1:10, 0:9, 0:9);
        T.d = T.h+T.k+T.l;
        i = find(rem(T.d,2) == 0);
        j = find(rem(T.d,2) == 1);
        T.p = [T.h(i),T.k(i),T.l(i);T.h(j),T.k(j),T.l(j)];
        % Use only hkl with hkl² < hkl²max
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
%         % Calculation of theoreitcal energy positons for the used hkl values
%         for i = 1:size(T.hkl_sort,1)
%             T.Etheo(i,:) = 2.*asind(T.lambdaka1./(20.*T.hkl_sort(i,4)));
%             T.Etheoka2 = 2.*asind(T.lambdaka2./(20.*T.hkl_sort(i,4)));
%     %         T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
%         end
        
        % Calculation of theoreitcal energy positons for the used hkl values
        for i = 1:size(T.hkl_sort,1)
            Etheoka1_tmp(i,:) = 2.*asind(T.lambdaka1./(20.*T.hkl_sort(i,4)));
            Etheoka2_tmp(i,:) = 2.*asind(T.lambdaka2./(20.*T.hkl_sort(i,4)));
    %         T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
        
        for k = 1:length(Etheoka1_tmp)
            Etheoka1_tmp1(k,1) = isreal(Etheoka1_tmp(k));
        end
        Etheoka1_tmp2 = Etheoka1_tmp.*Etheoka1_tmp1;
        Etheoka1_tmp2(Etheoka1_tmp2==0) = [];
        T.Etheoka1 = Etheoka1_tmp2;

        for k = 1:length(Etheoka2_tmp)
            Etheoka2_tmp1(k,1) = isreal(Etheoka2_tmp(k));
        end
        Etheoka2_tmp2 = Etheoka2_tmp.*Etheoka2_tmp1;
        Etheoka2_tmp2(Etheoka2_tmp2==0) = [];
        T.Etheoka2 = Etheoka2_tmp2;


        T.Peaks = [T.hkl_sort(Etheoka1_tmp1,:) T.Etheoka1 T.Etheoka2];

    %--------------------------------------------------------------------------
    else
        T.hkl = Measurement(1).Sample.Materials.HKLdspacing;
        [C,ia,ic] = unique(T.hkl(:,4),'rows','last');
        T.hkl = T.hkl(ia,1:4);
        T.hkl_sort = sortrows(T.hkl, -4);
%         for i = 1:size(T.hkl_sort,1)
%             T.Etheo(i,:) = 2.*asind(T.lambdaka1./(20.*T.hkl_sort(i,4)));
%             T.Etheoka2 = 2.*asind(T.lambdaka2./(20.*T.hkl_sort(i,4)));
%     %         T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
%         end

        for i = 1:size(T.hkl_sort,1)
            Etheoka1_tmp(i,:) = 2.*asind(T.lambdaka1./(20.*T.hkl_sort(i,4)));
            Etheoka2_tmp(i,:) = 2.*asind(T.lambdaka2./(20.*T.hkl_sort(i,4)));
    %         T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
        
        for k = 1:length(Etheoka1_tmp)
            Etheoka1_tmp1(k,1) = isreal(Etheoka1_tmp(k));
        end
        Etheoka1_tmp2 = Etheoka1_tmp.*Etheoka1_tmp1;
        Etheoka1_tmp2(Etheoka1_tmp2==0) = [];
        T.Etheoka1 = Etheoka1_tmp2;

        for k = 1:length(Etheoka2_tmp)
            Etheoka2_tmp1(k,1) = isreal(Etheoka2_tmp(k));
        end
        Etheoka2_tmp2 = Etheoka2_tmp.*Etheoka2_tmp1;
        Etheoka2_tmp2(Etheoka2_tmp2==0) = [];
        T.Etheoka2 = Etheoka2_tmp2;

%         assignin('base','TEtheoka1',T.Etheoka1)
%         assignin('base','TEtheoka2',T.Etheoka2)
%         assignin('base','Thkl_sort',T.hkl_sort)
        T.Peaks = [T.hkl_sort(Etheoka1_tmp1,:) T.Etheoka1 T.Etheoka2];
        
    end
%     assignin('base','TPeaks',T)
    % Create matrix for the line plot of the peak positions (X values)
    for i = 1:size(T.Peaks,1)
        T.X1(i,:) = [T.Peaks(i,5) T.Peaks(i,5) nan];
        T.X1ka2(i,:) = [T.Peaks(i,6) T.Peaks(i,6) nan];
    end
    % Adjust the size of matrix to the measurement
    T.X2 = reshape(T.X1',size(T.Peaks,1).*3,1);
    T.X2(size(T.Peaks,1).*3,:) = [];
    T.X3 = repmat(T.X2,1,length(Measurement));
    % kalpha2
    T.X2ka2 = reshape(T.X1ka2',size(T.Peaks,1).*3,1);
    T.X2ka2(size(T.Peaks,1).*3,:) = [];
    T.X3ka2 = repmat(T.X2ka2,1,length(Measurement));
    % Adjust the size of matrix to the measurement
    T.Y2 = reshape(T.Y1',3,length(Measurement));
    T.Y3 = repmat(T.Y2,size(T.Peaks,1),1);
    T.Y3(size(T.Peaks,1).*3,:)= [];
%     assignin('base','TPeaksNeu',T)
    Peakhandles.T = T;
else

    % Plot of substrate peaks
    PlotSubstratePeaks = Measurement(1).Sample.Materials.ShowSubstratePeaks;
    % TwoTheta of measurement
    T.twotheta = Measurement(1).twotheta;
    % T.twotheta = 9;
    
    % Info from material
    % Maximum Energy up to which peak positions are calculated
    if strcmp(calib,'Channel_scale')
        T.EMax = 16383;
    else
        T.EMax = Measurement(1).Sample.Materials.EnergyMax;
    end
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
    if (PlotSubstratePeaks)
        % Maximum Energy up to which peak positions are calculated
        S.EMax = Measurement(1).Sample.Substrate.EnergyMax;
        % Crystal structure of the material
        S.cs = Measurement(1).Sample.Substrate.CrystalStructure;
        % Lattice parameter of the material
        S.a0 = Measurement(1).Sample.Substrate.LatticeParameter;
        % Calculation of minimum d spacing
        S.dmin = (0.6199/sind(T.twotheta/2))/S.EMax;
        % Calculation of maximum hkl²
        if ~isempty(S.a0)
            S.hklquadratmax = (S.a0(1)/S.dmin)^2;
        else
            S.hklquadratmax = [];
        end
        
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
    % assignin('base','T',T)
    % assignin('base','Meas',Measurement)
    %% Plot diffraction lines from Material
    % Calculation of peak positions for bcc materials
    if strcmp(T.cs,'bcc')
        % Calculation of all possible hkl combinations
        [T.h, T.k, T.l] = ndgrid(1:10, 0:9, 0:9);
        T.d = T.h+T.k+T.l;
        i = find(rem(T.d,2) == 0);
        T.p = [T.h(i),T.k(i),T.l(i)];
        % Use only hkl with hkl² < hkl²max
        for i=1:size(T.p,1)
            if (T.p(i,1)^2 + T.p(i,2)^2 + T.p(i,3)^2) <= T.hklquadratmax
                T.y(i,:) = T.p(i,:);
            end
        end
        % delete zero rows
        T.y(all(T.y == 0,2),:)=[];
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
        
        if strcmp(calib,'Channel_scale')
            Etheochannel = 0.31244 + 85.9406.*T.Etheo + 2.13386E-4.*T.Etheo.^2;
            T.Etheo = Etheochannel;
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
                %% 
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
    
        if strcmp(calib,'Channel_scale')
            Etheochannel = 0.31244 + 85.9406.*T.Etheo + 2.13386E-4.*T.Etheo.^2;
            T.Etheo = Etheochannel;
        end
        
        T.Peaks = [T.hkl_sort T.Etheo];
    %--------------------------------------------------------------------------
    else
        T.hkl = Measurement(1).Sample.Materials.HKLdspacing;
        [C,ia,ic] = unique(T.hkl(:,4),'rows','last');
        T.hkl = T.hkl(ia,1:4);
        T.hkl_sort = sortrows(T.hkl, -4);
        for i = 1:size(T.hkl,1)
            T.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/T.hkl_sort(i,4);
        end
    
        if strcmp(calib,'Channel_scale')
            Etheochannel = 0.31244 + 85.9406.*T.Etheo + 2.13386E-4.*T.Etheo.^2;
            T.Etheo = Etheochannel;
        end
        
        T.Peaks = [T.hkl_sort T.Etheo];
        
    end
%     assignin('base','TPeaks',T)
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
    % assignin('base','TEtheo',T)
    %% Plot diffraction lines from Substrate 
    if (PlotSubstratePeaks)
        % Calculation of peak positions for bcc materials
        if strcmp(S.cs,'bcc')
            % Calculation of all possible hkl combinations
            [S.h, S.k, S.l] = ndgrid(1:10, 0:9, 0:9);
            S.d = S.h+S.k+S.l;
            i = find(rem(S.d,2) == 0);
            S.p = [S.h(i),S.k(i),S.l(i)];
            % Use only hkl with hkl² < hkl²max
            for i=1:size(S.p,1)
                if (S.p(i,1)^2 + S.p(i,2)^2 + S.p(i,3)^2) <= S.hklquadratmax
                    S.y(i,:) = S.p(i,:);
                end
            end
            % delete zero rows
            S.y(all(S.y == 0,2),:)=[];
            % Use only hkl that are allowed for bcc materials
            for i=1:size(S.y,1)
                if S.y(i,1) >= S.y(i,2) && S.y(i,1) >= S.y(i,3) && S.y(i,2) >= S.y(i,3)
                   S.z(i,:) = S.y(i,:);
                end
            end
            % delete zero rows
            S.z(all(S.z == 0,2),:)=[];
            % Calculation of theoretical d spacings for the used hkl values
            for i = 1:size(S.z,1)
                S.dtheo(i,:) = S.a0/(sqrt(S.z(i,1)^2+S.z(i,2)^2+S.z(i,3)^2));
            end
    
            S.hkl = [S.z S.dtheo];
            % Sort columns in descending order
            S.hkl_sort = sortrows(S.hkl, -4);
            % Calculation of theoreitcal energy positons for the used hkl values
            for i = 1:size(S.hkl_sort,1)
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
            for i=1:size(S.p,1)
                if (S.p(i,1)^2 + S.p(i,2)^2 + S.p(i,3)^2) <= S.hklquadratmax
                    S.y(i,:) = S.p(i,:);
                end
            end
            % delete zero rows
            S.y(all(S.y == 0,2),:)=[];
            % Use only hkl that are allowed for fcc materials
            for i=1:size(S.y,1)
                if S.y(i,1) >= S.y(i,2) && S.y(i,1) >= S.y(i,3) && S.y(i,2) >= S.y(i,3)
                    S.z(i,:) = S.y(i,:);
                end
            end
            % delete zero rows
            S.z(all(S.z == 0,2),:)=[];
            % Find only hkl that are all even
            for i=1:size(S.z,1)
                if rem(S.z(i,1),2) == 0 && rem(S.z(i,2),2) == 0 && rem(S.z(i,3),2) == 0
                    S.w1(i,:) = S.z(i,:);
                end
            end
            % delete zero rows
            S.w1(all(S.w1 == 0,2),:)=[];
            % Find only hkl that are all odd
            for i=1:size(S.z,1)
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
            for i = 1:size(S.w,1)
                S.dtheo(i,:) = S.a0/(sqrt(S.w(i,1)^2+S.w(i,2)^2+S.w(i,3)^2));
            end
    
            S.hkl = [S.w, S.dtheo];
            % Sort columns in descending order
            S.hkl_sort = sortrows(S.hkl, -4);
            % Calculation of theoreitcal energy positons for the used hkl values
            for i = 1:size(S.hkl_sort,1)
                S.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/S.hkl_sort(i,4);
            end
    
            S.Peaks = [S.hkl_sort S.Etheo];
        %--------------------------------------------------------------------------
        else
            S.hkl = Measurement(1).Sample.Substrate.HKLdspacing;
    
            for i = 1:size(S.hkl,1)
                S.Etheo(i,:) = (0.6199/sind(T.twotheta/2))/S.hkl(i,4);
            end
    
            S.Peaks = [S.hkl S.Etheo];
        end
    
        % Create matrix for the line plot of the peak positions (X values)
        for i = 1:size(S.Peaks,1)
            S.X1(i,:) = [S.Peaks(i,5) S.Peaks(i,5) nan];
        end
        % Adjust the size of matrix to the measurement
        S.X2 = reshape(S.X1',size(S.Peaks,1).*3,1);
        S.X2(size(S.Peaks,1).*3,:) = [];
        S.X3 = repmat(S.X2,1,length(Measurement));
        % Adjust the size of matrix to the measurement
        S.Y2 = reshape(T.Y1',3,length(Measurement));
        S.Y3 = repmat(S.Y2,size(S.Peaks,1),1);
        S.Y3(length(S.Peaks).*3,:)= [];
    end
    Peakhandles.T = T;
    if PlotSubstratePeaks
        Peakhandles.S = S;
    end
    % Peakhandles.SPeaks = S.Peaks;
end

