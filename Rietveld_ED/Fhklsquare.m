function y = Fhklsquare( APConst, APFitParams, APFitPattern, AtomCoordCnts, TwoTheta, EnergyPos, SF_a, SF_b, SF_c, H, K, L, DebyeWallerFactor, Laf1, Laf2, Bf1, Bf2)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
        	ap = APConst;
			ap(APFitPattern ~= 0) = 0;
			
            for i = 1:length(APFitParams)
				
				ap = ap + APFitParams(i) * ((abs(APFitPattern) == i) .* sign(APFitPattern));
            end
            
            svm = (sind(TwoTheta./2) .* EnergyPos) ./ 12.398;
			cutPos = cumsum(AtomCoordCnts) - AtomCoordCnts + 1;
			
            f1 = {Laf1; Bf1};
            f2 = {Laf2; Bf2};
            
			StructureFactor = 0;
			
            DebyeWaller = DebyeWallerFactor;
			cutPos = [cutPos; size(ap, 1)+1];
			for i = 1:(length(cutPos)-1)
		
				f = sum(repmat(SF_a(i,:), length(svm),1) ...
				.* exp(-repmat(SF_b(i,:), length(svm),1) .* repmat(svm.^2,1, 4)),2) ...
				+ SF_c(i);
                
                f1element = interp1(f1{i}(:,1),f1{i}(:,2),EnergyPos,'linear');
                f2element = exp(interp1(log(f2{i}(:,1)),log(f2{i}(:,2)),log(EnergyPos),'linear'));
                
                AtomFactor = (f + f1element + f2element) .* exp(-DebyeWaller(i).*svm.^2);
            
				Fhkl = sum(exp(2 * pi * 1i * ([H, K, L] * ap(cutPos(i):(cutPos(i+1)-1),:)')),2);

				StructureFactor = StructureFactor + AtomFactor .* Fhkl;
			end
			
			y = abs(StructureFactor).^2;
            

end

