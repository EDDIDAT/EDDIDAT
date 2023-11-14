% Test subplot

%             sigma11 = sigmatau{:,1};
%             sigma22 = sigmatau{:,2};
%             sigma13 = sigmatau{:,3};
%             sigma23 = sigmatau{:,4};
%             assignin('base', 'sigmatau', sigmatau)
%             tauneu = cell(1,4);
%            
%             for p = 1:4
%                 tauneu{1,p} = tausorted(PhiIndexTable(p,1):PhiIndexTable(p,2),:);
%             end
% 
% %             for p = 1:4
% %                 for i = 1:cellfun('length',Phisorted(p))
% %                     tauneu{i,p} = tau1(i,:);
% %                 end
% %             end
%             
%             range11 = psirange11;
%             range22 = psirange22;
%             range13 = psirange13;
%             range23 = psirange23;
%             
%             % Create 
%             tau11 = tauneu{1,1};
%             tau22 = tauneu{1,2};
%             tau13 = tauneu{1,3};
%             tau23 = tauneu{1,4};
            hold on
            show = 'off';
            % Create figure for subplot
            figure
            % subplot sigma_11
            subplot(2,2,1);
            plot(tau11(range11,:), sigma11(range11,:),'o');
%             axis([0 inf -inf inf]);
            % Numerate the data points
                % offset for data point labels
                offset_x = 0;
                offset_y = 0;
                % reduce tau and sigma values according to the chosen range
                tau11red = tau11(range11,:);
                sigma11red = sigma11(range11,:);
                % data point labels, use repmat to account for the number
                % of peaks
                number = repmat(range11,1,size(tau11,2));
                % write text to data points
                for k = 1:(length(tau11(range11,:))*size(tau11,2));
                    text(tau11red(k)+offset_x,sigma11red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show)
                end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{11} [MPa]');
            legend('1','2','3','4','5','6','7')
			axis tight
			grid
            
            % Subplot sigma_13
            subplot(2,2,2);
            plot(tau13(range13,:), sigma13(range13,:),'o');
%             axis([0 inf -inf inf]);
            % Numerate the data points
            offset_x = 0;
            offset_y = 0;
            tau13red = tau13(range13,:);
            sigma13red = sigma13(range13,:);
            number = repmat(range13,1,size(tau13,2));
            for k = 1:(length(tau13(range13,:))*size(tau13,2));
                text(tau13red(k)+offset_x,sigma13red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show)
            end
            xlabel('\tau [µm]');
			ylabel('\sigma_{13} [MPa]');
			axis tight
			grid
            
            % Subplot sigma_22
            subplot(2,2,3);
            plot(tau22(range22,:), sigma22(range22,:),'o');
%             axis([0 inf -inf inf]);
            % Numerate the data points
            offset_x = 0;
            offset_y = 0;
            tau22red = tau22(range22,:);
            sigma22red = sigma22(range22,:);
            number = repmat(range22,1,size(tau22,2));
            for k = 1:(length(tau22(range22,:))*size(tau22,2));
                text(tau22red(k)+offset_x,sigma22red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show)
            end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{22} [MPa]');
			axis tight
			grid
            
            % Subplot sigma_23
            subplot(2,2,4);
            plot(tau23(range23,:), sigma23(range23,:),'o');
%             axis([0 inf -inf inf]);
            % Numerate the data points
            offset_x = 0;
            offset_y = 0;
            tau23red = tau23(range23,:);
            sigma23red = sigma23(range23,:);
            number = repmat(range23,1,size(tau23,2));
            for k = 1:(length(tau23(range23,:))*size(tau23,2));
                text(tau23red(k)+offset_x,sigma23red(k)+offset_y,num2str(number(k)), ...
                        'Clipping', 'on', 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top',...
                        'Visible', show)
            end
            % Plot label
            xlabel('\tau [µm]');
			ylabel('\sigma_{23} [MPa]');
			axis tight
			grid
            
            
            