figure
% scatter(tau11neu, sigma11neu, 'filled')
% axis([0 50 -2000 2000])
% % axis tight
% 
% labels = num2str((1:size(tau11neu,1))','%d');    %'
% text(tau11neu, sigma11neu, labels, 'horizontal','left', 'vertical','bottom')

% p = rand(10,2);
% scatter(p(:,1), p(:,2), 'filled')
% axis([0 1 0 1])
% 
% labels = num2str((1:size(p,1))','%d');    %'
% text(p(:,1), p(:,2), labels, 'horizontal','left', 'vertical','bottom')

% ax1 = subplot(2,2,1);
% plot(1:10);
% h = zoom;
% ax2 = subplot(2,2,2);
% plot(rand(3));
% setAllowAxesZoom(h,ax2,false);
% ax3 = subplot(2,2,3);
% plot(peaks);
% setAxesZoomMotion(h,ax3,'horizontal');
% ax4 = subplot(2,2,4);
% contour(peaks);
% setAxesZoomMotion(h,ax4,'vertical');
% % Zoom in on the plots.

plot(tau13(range13,:), sigma13(range13,:),'o');
            axis([0 inf -inf inf]);
            % Numerate the data points
            offset_x = 0;
            offset_y = 0;
            number = repmat(range13,1,size(tau13,2));
            for k = 1:(length(tau13(range13,:))*size(tau13,2));
                text(tau13(k)+offset_x,sigma13(k)+offset_y,num2str(number(k)), 'Clipping', 'on')
            end
            xlabel('\tau [µm]');
			ylabel('\sigma_{13} [MPa]');
% 			axis tight
			grid