elseif strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
        for k = 1:length(meas)
            psi(k) = meas(k).SCSAngles.psi;
            phi(k) = meas(k).SCSAngles.phi;
        end
        % Count number of phiS angles
        phiwinkelcount = unique(phi);
        % Get number of measurements for each phi angle
        for k = 1:length(phiwinkelcount)
            NumberPhiMeas(k) = length(phi(phi == phiwinkelcount(k)));
        end
        
        %
        phiangles = [0 90 180 270];
        % If more than one phiS was measured, check if number of psi values
        % with phiS = 0° and phiS = 90° is equal
        if length(phiwinkelcount) ~= 1
            if isequal(phiangles(ismember([0 90 180 270],phiwinkelcount)),[0 180])
                if length(phi(phi == phiwinkelcount(1))) ~= length(phi(phi == phiwinkelcount(2)))
                    [~,b1] = find(phi==0);
                    phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phi(b1)));
                    psizerodata = find(psi == 0);
                    datacopy = meas(psizerodata).Clone;
                    for k = 1:length(datacopy)
                        datacopy(k).Motors_all.Phi = phimissingpsi;
                        datacopy(k).Motors.Phi = phimissingpsi;
                        datacopy(k).SCSAngles.phi = abs(phimissingpsi);
                    end
                    [~,b1] = find(phi==180);
                    meascorrected = [meas(1:b1(1)-1) datacopy meas(b1(1):end)];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) {datacopy.EDSpectrum} DataTmp(b1(1):end)];
                    meas = meascorrected;
                    DataTmp = DataTmpcorrected;
                end
            elseif isequal(phiangles(ismember([0 90 180 270],phiwinkelcount)),[90 270])
                if length(phi(phi == phiwinkelcount(1))) ~= length(phi(phi == phiwinkelcount(2)))
                    [~,b1] = find(phi==0);
                    phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phi(b1)));
                    psizerodata = find(psi == 0);
                    datacopy = meas(psizerodata).Clone;
                    for k = 1:length(datacopy)
                        datacopy(k).Motors_all.Phi = phimissingpsi;
                        datacopy(k).Motors.Phi = phimissingpsi;
                        datacopy(k).SCSAngles.phi = abs(phimissingpsi);
                    end
                    [~,b1] = find(phi==180);
                    meascorrected = [meas(1:b1(1)-1) datacopy meas(b1(1):end)];
                    DataTmpcorrected = [DataTmp(1:b1(1)-1) {datacopy.EDSpectrum} DataTmp(b1(1):end)];
                    meas = meascorrected;
                    DataTmp = DataTmpcorrected;
                end
            elseif isequal(phiangles(ismember([0 90 180 270],phiwinkelcount)),[0 90])

            elseif isequal(phiangles(ismember([0 90 180 270],phiwinkelcount)),[180 270])

            elseif isequal(phiangles(ismember([0 90 180 270],phiwinkelcount)),[0 90 180 270])

            end

        end
elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
        for k = 1:length(meas)
            psi(k) = meas(k).SCSAngles.psi;
            phi(k) = meas(k).SCSAngles.phi;
        end
        % Count number of phiS angles
        phiwinkelcount = unique(phi);
        % If more than one phiS was measured, check if number of psi values
        % with phiS = 0° and phiS = 90° is equal
        if length(phiwinkelcount) ~= 1
            if length(phi(phi == phiwinkelcount(1))) ~= length(phi(phi == phiwinkelcount(2)))
                [~,b1] = find(phi==0);
                phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phi(b1)));
                psizerodata = find(psi == 0);
                datacopy = meas(psizerodata).Clone;
                for k = 1:length(datacopy)
                    datacopy(k).Motors_all.Phi = phimissingpsi;
                    datacopy(k).Motors.Phi = phimissingpsi;
                    datacopy(k).SCSAngles.phi = abs(phimissingpsi);
                end
                [~,b1] = find(phi==180);
                meascorrected = [meas(1:b1(1)-1) datacopy meas(b1(1):end)];
                DataTmpcorrected = [DataTmp(1:b1(1)-1) {datacopy.EDSpectrum} DataTmp(b1(1):end)];
                meas = meascorrected;
                DataTmp = DataTmpcorrected;
            end
        end





% Get psi and phi angles from meas object
for k = 1:length(meas)
    psi(k) = meas(k).SCSAngles.psi;
    phi(k) = meas(k).SCSAngles.phi;
end
% Find index of psi = 0°
[~,bpsi0] = find(psi==0);
% Get measured phi angles
phiwinkelcount = unique(phi);
% Get missing phi angles
phimissingpsi = phiwinkelcount(~ismember(phiwinkelcount,phi(bpsi0)));
% Get measures phi angles
phipsimeas = phiwinkelcount(ismember(phiwinkelcount,phi(bpsi0)));
if ~isempty(phimissingpsi)
    % If LEDDI KETEK TWODET, phimissingpsi variable needs to be adjusted for
    % two detektor mode
    if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
        phimissingreplace = repelem(phimissingpsi,2);
    elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
        phimissingreplace = phimissingpsi;
    end
    % Clone meas objects with measured phi angles
    datacopy = meas(bpsi0).Clone;
    
    % Replace phi with missing phi
    for k = 1:length(datacopy)
        datacopy(k).Motors_all.Phi = phimissingreplace(k);
        datacopy(k).Motors.Phi = phimissingreplace(k);
        datacopy(k).SCSAngles.phi = abs(phimissingreplace(k));
    end
    % Combine cloned meas objects and put them at the right position
    if length(phimissingpsi) == 1
        [~,b1] = find(phi==phimissingpsi);
        if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
            meascorrected = [meas(1:b1(1)-1) datacopy(1:2) meas(b1(1):end)];
            DataTmpcorrected = [DataTmpLoad(1:b1(1)-1) {datacopy(1:2).EDSpectrum} DataTmpLoad(b1(1):end)];
        elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
            meascorrected = [meas(1:b1(1)-1) datacopy(1) meas(b1(1):end)];
            DataTmpcorrected = [DataTmpLoad(1:b1(1)-1) datacopy(1).EDSpectrum DataTmpLoad(b1(1):end)];
        end
    elseif length(phimissingpsi) == 2
        [~,b1] = find(phi==phimissingpsi(1));
        [~,b2] = find(phi==phimissingpsi(2));
        if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
            meascorrected = [meas(1:b1(1)-1) datacopy(1:2) meas(b1(1):b2(1)-1) datacopy(3:4) meas(b2(1):b2(end))];
            DataTmpcorrected = [DataTmpLoad(1:b1(1)-1) {datacopy(1:2).EDSpectrum} DataTmpLoad(b1(1):b2(1)-1) {datacopy(3:4).EDSpectrum} DataTmpLoad(b2(1):b2(end))];
        elseif strcmp(Diffractometer.Name,'MetalJet-LIMAX-160')
            meascorrected = [meas(1:b1(1)-1) datacopy(1) meas(b1(1):b2(1)-1) datacopy(2) meas(b2(1):b2(end))];
            DataTmpcorrected = [DataTmpLoad(1:b1(1)-1) datacopy(1).EDSpectrum DataTmpLoad(b1(1):b2(1)-1) datacopy(2).EDSpectrum DataTmpLoad(b2(1):b2(end))];
        end
    end

end


if strcmp(Diffractometer.Name,'LEDDI_KETEK_TWODET')
    if strcmp(ScanType,{'ascan'})
        % Im Falle von ascans am LEDDI muss noch phi angepasst werden (fuer
        % Kippung in + und - psi)
        for k = 1:size(obj,2)
            psiAScan(k) = obj(k).Motors_all.Chi;
        end

        % Fallunterscheidung: wenn gemischt pos. und neg. psi-Werte
        % vorliegen, muss geprueft werden, ob die Messung bei psi = 0
        % verdoppelt werden muss.
        % Get unique psi values
        psivalues = unique(psiAScan);
        % Find non zero psi values
        idxpsinonzero = find(psivalues~=0);
        % If mixed pos and neg psi values are present, copy scan from
        % psi = 0 and create new meas object
        if ~all(psivalues(idxpsinonzero)>0) && ~all(psivalues(idxpsinonzero)<0)
            % Finde Index von psi = 0° 
            idxpsi0 = find(psiAScan(1:2:end)==0);
            % Clone object in order to create independent object
            datacopy = obj.Clone;

            % Index of Det1
            idx1 = 1:2:length(psiAScan);
            % Kopiere den Scan bei psi = 0° und erzeuge neues meas-Objekt
            objneu = [obj(1:idx1(idxpsi0)+1) datacopy(idx1(idxpsi0):idx1(idxpsi0)+1) obj(idx1(idxpsi0)+2:end)];
        
            % Setze phi an den entsprechenden Stellen und unterscheide zwischen +
            % und - psi Werten
            for k = 1:size(objneu,2)
                psiAScanmerge(k) = objneu(k).Motors_all.Chi;
                phiAScanmerge(k) = objneu(k).Motors_all.Phi;
            end
            % Get index of Det2
            idxpsiPos = 1:2:length(psiAScanmerge);
            % Find index of neg, pos und zero psi data
            idxpsineg = find(psiAScanmerge(idxpsiPos)<0);
            idxpsizero = find(psiAScanmerge(idxpsiPos)==0);
            idxpsipos = find(psiAScanmerge(idxpsiPos)>0);
            % Create new vector with correct phi data
            phineu = zeros(1,size(objneu,2));

            phineu(1:idxpsiPos(idxpsizero(1))) = 0;
            phineu(idxpsiPos(idxpsizero(2)):end) = 180;
            % Replace phi data with corrected phi data
            for k = 1:size(objneu,2)
                objneu(k).Motors_all.Phi = phineu(k);
            end

            obj = objneu;
        end

    end
end