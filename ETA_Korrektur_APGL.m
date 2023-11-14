twotheta = linspace(50.4,54.4,81);
X = twotheta;
psi = 0;
eta = 90;
lambda = 0.178897;
ordzahlsum = 26;    % Ag: 47; LaB6: 87; Cu: 29; Pd: 46
materialdichte = 7.87; % Ag: 10.49 LaB6: 4.711; Cu: 8.96; Pd: 12.004
atgewichtsum = 55.85;  % Ag: 107.87 LaB6: 204.77; Cu: 63.546; Pd: 106.40
cgsfactor = (2.701*10^10.*ordzahlsum.*(materialdichte./atgewichtsum*10^-14));
delta = cgsfactor.*(lambda)^2;
alphaof = X./2;
epsilon = (delta*cotd(alphaof)).*57.2957;
sinalphawahr = sind((X./2) - epsilon);
sinbetawahr = sind((X./2) - epsilon); 
zweithetawahr = acosd(((cosd((X./2)-epsilon)) .* ...
                cosd((X./2)-epsilon)) ./ ...
                (cosd(X./2).*cosd(X./2)) .* ...
                (cosd(X)+ sind(X./2).*sind(X./2)) - sind((X./2) - epsilon) .* ...
                sind((X./2) - epsilon));
apglfaktor = (1+cosd(zweithetawahr).^2)./(8.*sind(X./2).*sind(zweithetawahr))./(((1./sinalphawahr)+(1./sinbetawahr)).*sinalphawahr);

% APGL Korrektur gemaeß Mathematica

% epsilon[lambda, alpha]
% epsilon[lambda, beta]
% 
% sinalphawahr = sind(alpha(twotheta,psi,eta) - epsilon(lambda,alpha(twotheta,psi,eta)));
% sinbetawahr = sind(beta(twotheta,psi,eta) - epsilon(lambda,beta(twotheta,psi,eta)));
% 
% zweithetawahr = acosd((cosd(alpha(twotheta,psi,eta)-epsilon(lambda,alpha(twotheta,psi,eta))) .* ...
%                 cosd(beta(twotheta,psi,eta)-epsilon(lambda,beta(twotheta,psi,eta)))) ./ ...
%                 (cosd(alpha(twotheta,psi,eta)).*cosd(beta(twotheta,psi,eta))) .* ...
%                 (cosd(twotheta)+ sind(alpha(twotheta,psi,eta)).*sind(beta(twotheta,psi,eta))) - sind(alpha(twotheta,psi,eta) - epsilon(lambda,alpha(twotheta,psi,eta))) .* ...
%                 sind(beta(twotheta,psi,eta) - epsilon(lambda,beta(twotheta,psi,eta))));

alpha = asind(sind(twotheta/2)*cosd(psi) - cosd(twotheta/2)*sind(psi)*cosd(eta));
beta = asind(sind(twotheta/2)*cosd(psi) + cosd(twotheta/2)*sind(psi)*cosd(eta));

epsilonalpha = (delta*cotd(alpha));
epsilonbeta = (delta*cotd(beta));

sinalphawahr = sind(alpha - epsilonalpha);
sinbetawahr = sind(beta - epsilonbeta);

zweithetawahr = acosd(((cosd(alpha-epsilonalpha)) .* ...
                cosd(beta-epsilonbeta)) ./ ...
                (cosd(alpha).*cosd(beta)) .* ...
                (cosd(twotheta) + sind(alpha).*sind(beta)) - sind(alpha - epsilonalpha) .* ...
                sind(beta - epsilonbeta));

apglfaktor = (1+cosd(zweithetawahr).^2)./(8.*sind(twotheta./2).*sind(zweithetawahr))./(((1./sinalphawahr)+(1./sinbetawahr)).*sinalphawahr);

%% Wenn Materialdicke ~= Infinity, wird zusätzlich der Absorptionskoeffizient benötigt