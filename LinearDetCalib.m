function twothetachannel = LinearDetCalib(n,w,nzero,twothetanzero,L,beta)
% Distance d from each channel n of the detector from the detector center
% n0
% d - distance from channel n to detector center channel n0
% n - current channel
% nzero - center channel detector
% w - width of one pixel
d = (n - nzero)*w;

twothetachannel = twothetanzero + asind(d./L .* cosd(beta)./(1 + (d./L).^2 - 2.*(d./L).*sind(beta)).^0.5);

end

