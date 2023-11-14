function ntwotheta = detchannel(L,w,theta,nzero)
%UNTITLED2 Summary of this function goes here
ntwotheta = L/w.*tand(2.*theta) + nzero;
end

