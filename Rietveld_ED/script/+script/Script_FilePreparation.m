clear all
% for m = 1:32
% x = importdata(['Data_', num2str(m),'.dat']);
% % X = (2500:11500)';
% % Y_alt = x(:,3);
% % Y = x(:,3);
% X_alt = x(:,1);
% Y_alt = x(:,3);
% % sigma = linspace(10,2,32); %0.75; %noise standard deviation
% % sigma = 0.75;
% % X = X_alt;
% % Y = Y_alt;
% % Y = Y_alt + sigma(m)*randn(size(X)); %noisy signal
% % Y = Y_alt + sigma*randn(size(X)); %noisy signal
% X = X_alt(3001:9301);
% Y = Y_alt(3001:9301);
% 
% clear x X_alt Y_alt
% save(['Data_', num2str(m),'.mat']);
% end


% delimiterIn = ' ';
% headerlinesIn = 0;
for m = 1:55
x = importdata(['Simulationsdaten_correct_23062016_', num2str(m), '.dat']); %, delimiterIn, headerlinesIn);

Data = x;

X_alt = Data(:,1);
Y_alt = Data(:,3);

X = X_alt(:);
Y = Y_alt(:);

clear x X_alt Y_alt textdata
save(['Simulationsdaten_correct_23062016_', num2str(m),'.mat']);
end


% plot(X_alt,Y_alt)
% X = X_alt(1583:10130);
% Y = Y_alt(1583:10130);
% clear x
% save('Data_32');
% clear all
% plot(X,Y)
% textscan