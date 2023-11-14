function y = TCHPV( X, ep, intensity, GL, H_k )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
	X_shift = X - ep;
	y = intensity * (GL * (2 / (pi * H_k)) ./ ...
		(1 + 4 * ((X_shift) / H_k).^2) ...
		+ (1 - GL) * (2 * sqrt(log(2)/pi) / H_k) * ...
		exp(-4 * log(2) * ((X_shift) / H_k).^2));

end

