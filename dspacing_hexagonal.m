function [d] = dspacing_hexagonal(a,c,h,k,l)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
d = sqrt(1./(4.*(h.^2 + h.*k + k.^2)./(3*a.^2) + (l.^2./c.^2)));

end

