function [UPlot] = UniversalPlotCalc(h)
%UNTITLED2 Summary of this function goes here

indkeeppeaks = find(h.userpeaksuplot==1);

TauCalc.absorbcoeff = cell(1);
for k = 1:size(indkeeppeaks,1)
    for l = 1:size(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)},1)
        TauCalc.absorbcoeff{k}(:,l) = h.Sample.Materials(1).LAC((0.6199/sind(h.Measurement(1).twotheta./2))/h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,2));
        TauCalc.absorbcoefforg{k} = h.Sample.Materials(1).LAC((0.6199/sind(h.Measurement(1).twotheta./2))/h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(1,2));
    end
end

TauCalc.tau = cell(1);
for k = 1:size(indkeeppeaks,1)
    for l = 1:size(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)},1)
        TauCalc.tau{k}(l) = (sind(h.Measurement(1).twotheta./2).*cosd(asind(sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1)))))./(2.*TauCalc.absorbcoeff{k}(l)./10000);
        TauCalc.tauorg{k} = (sind(h.Measurement(1).twotheta./2).*cosd(asind(sqrt(sind((0:1:89)).^2))))./(2.*TauCalc.absorbcoefforg{k}./10000);
    end
end

%% Calculate stress factors f
DEKdatatmp = get(h.loadDEKtable,'data');
% assignin('base','DEKdatatmp',DEKdatatmp)

% Set dzero values
if get(h.dzerozgradientcheckbox,'Value') == 0
    if h.dzerovauleschkbx == 0
        dzero = h.sin2psi.dzero(indkeeppeaks);
    else
        dzero = h.dzerouser(indkeeppeaks);
    end
    
    % Calculate f+ and delta_f+
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fplussigma{k}(l) = (((h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,2) + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,2)) - 2.*dzero(k))./2./dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1)+2.*DEKdatatmp(k,4));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fplussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,3).^2)/2/dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1)+2.*DEKdatatmp(k,4)));
        end
    end

    % Calculate f- and delta_f-
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi90p270{indkeeppeaks(k)},1)
            if h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1) == 0
                fminussigma{k}(l) = 0;
            else
                fminussigma{k}(l) = (h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,2) - h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,2))/2/dzero(k)/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1));
            end
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fminussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,3).^2)/2/dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1)));
        end
    end

    % Calculate f13 and delta_f13
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f13sigma{k}(l) = h.sin2psi.dphi0m180sinquadratpsi{indkeeppeaks(k)}(l,2)/dzero(k)/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f13sigmadelta{k}(l) = (h.sin2psi.dphi0m180sinquadratpsi{indkeeppeaks(k)}(l,3)/dzero(k))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    % Calculate f23 and delta_f23
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi90p270{indkeeppeaks(k)},1)
            f23sigma{k}(l) = h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,2)/dzero(k)/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f23sigmadelta{k}(l) = (h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,3)/dzero(k))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end
    
else
    % Calculate dzero(tau) in case of d0 gradient
    samplethickness = str2double(get(h.editsamplethickness,'String'));
    param1 = str2double(get(h.editdzeropoly1,'String'));
    param2 = str2double(get(h.editdzeropoly2,'String'));
    param3 = str2double(get(h.editdzeropoly3,'String'));

    dzerotau = @(x)integral(@(z)(param1 + param2.*z + param3.*z.^2).*exp(-z./x),0,samplethickness)./integral(@(z)exp(-z./x),0,samplethickness);
    
    % Calculate f+ and delta_f+
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fplussigma{k}(l) = (((h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,2) + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,2)) - 2.*dzerotau(TauCalc.tau{k}(l)))./2./dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1)+2.*DEKdatatmp(k,4));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fplussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,3).^2)/2/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1)+2.*DEKdatatmp(k,4)));
        end
    end

    % Calculate f- and delta_f-
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi90p270{indkeeppeaks(k)},1)
            fminussigma{k}(l) = (h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,2) - h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,2))/2/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            fminussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,3).^2)/2/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1)));
        end
    end

    % Calculate f13 and delta_f13
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f13sigma{k}(l) = h.sin2psi.dphi0m180sinquadratpsi{indkeeppeaks(k)}(l,2)/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f13sigmadelta{k}(l) = (h.sin2psi.dphi0m180sinquadratpsi{indkeeppeaks(k)}(l,3)/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    % Calculate f23 and delta_f23
    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi90p270{indkeeppeaks(k)},1)
            f23sigma{k}(l) = h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,2)/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end

    for k = 1:size(indkeeppeaks,1)
        for l = 1:size(h.sin2psi.dphi0p180{indkeeppeaks(k)},1)
            f23sigmadelta{k}(l) = (h.sin2psi.dphi90m270sinquadratpsi{indkeeppeaks(k)}(l,3)/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1).*(1-h.sin2psi.dphi90p270sinquadratpsi{indkeeppeaks(k)}(l,1))));
        end
    end
end

% Calculate sigma
for k = 1:size(fplussigma,2)
    sigma11{k} = fplussigma{k} + fminussigma{k};
    sigma11delta{k} = sqrt(fplussigmadelta{k}.^2 + fminussigmadelta{k}.^2)/2;
    sigma22{k} = fplussigma{k} - fminussigma{k};
    sigma22delta{k} = sqrt(fplussigmadelta{k}.^2 + fminussigmadelta{k}.^2)/2;
end

sigma13 = f13sigma;
sigma13delta = f13sigmadelta;
sigma23 = f23sigma;
sigma23delta = f23sigmadelta;

UPlot.TauCalc = TauCalc;
UPlot.fplussigma = fplussigma;
UPlot.fplussigmadelta = fplussigmadelta;
UPlot.fminussigma = fminussigma;
UPlot.fminussigmadelta = fminussigmadelta;
UPlot.f13sigma = f13sigma;
UPlot.f13sigmadelta = f13sigmadelta;
UPlot.f23sigma = f23sigma;
UPlot.f23sigmadelta = f23sigmadelta;
UPlot.sigma11 = sigma11;
UPlot.sigma11delta = sigma11delta;
UPlot.sigma22 = sigma22;
UPlot.sigma22delta = sigma22delta;
UPlot.sigma13 = sigma13;
UPlot.sigma13delta = sigma13delta;
UPlot.sigma23 = sigma23;
UPlot.sigma23delta = sigma23delta;

end




% %% Calculate tau
% TauCalc.absorbcoeff = cell(1);
% for k = 1:size(h.sin2psi.dphi0p180sinquadratpsi,2)
%         for l = 1:size(h.sin2psi.dphi0p180sinquadratpsi{k},1)
%             TauCalc.absorbcoeff{k}(:,l) = h.Sample.Materials(1).LAC((0.6199/sind(h.Measurement(1).twotheta./2))/h.sin2psi.dphi0p180sinquadratpsi{k}(l,2));
%         end
% end
% 
% TauCalc.tau = cell(1);
% for k = 1:size(h.sin2psi.dphi0p180sinquadratpsi,2)
%     for l = 1:size(h.sin2psi.dphi0p180sinquadratpsi{k},1)
%         TauCalc.tau{k}(l) = (sind(h.Measurement(1).twotheta./2).*cosd(asind(sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,1)))))./(2.*TauCalc.absorbcoeff{k}(l)./10000);
%     end
% end
% 
% %% Calculate stress factors f
% DEKdatatmp = get(h.loadDEKtable,'data');
% % assignin('base','DEKdatatmp',DEKdatatmp)
% 
% % Set dzero values
% if get(h.dzerozgradientcheckbox,'Value') == 0
%     if h.dzerovauleschkbx == 0
%         dzero = h.sin2psi.dzero;
%     else
%         dzero = h.dzerouser;
%     end
%     
%     % Calculate f+ and delta_f+
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fplussigma{k}(l) = (((h.sin2psi.dphi0p180sinquadratpsi{k}(l,2) + h.sin2psi.dphi90p270sinquadratpsi{k}(l,2)) - 2.*dzero(k))./2./dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{k}(l,1)+2.*DEKdatatmp(k,4));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fplussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{k}(l,3).^2)/2/dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{k}(l,1)+2.*DEKdatatmp(k,4)));
%         end
%     end
% 
%     % Calculate f- and delta_f-
%     for k = 1:size(h.sin2psi.dphi90p270,2)
%         for l = 1:size(h.sin2psi.dphi90p270{k},1)
%             fminussigma{k}(l) = (h.sin2psi.dphi0p180sinquadratpsi{k}(l,2) - h.sin2psi.dphi90p270sinquadratpsi{k}(l,2))/2/dzero(k)/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{k}(l,1));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fminussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{k}(l,3).^2)/2/dzero(k))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{k}(l,1)));
%         end
%     end
% 
%     % Calculate f13 and delta_f13
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f13sigma{k}(l) = h.sin2psi.dphi0m180sinquadratpsi{k}(l,2)/dzero(k)/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f13sigmadelta{k}(l) = (h.sin2psi.dphi0m180sinquadratpsi{k}(l,3)/dzero(k))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     % Calculate f23 and delta_f23
%     for k = 1:size(h.sin2psi.dphi90p270,2)
%         for l = 1:size(h.sin2psi.dphi90p270{k},1)
%             f23sigma{k}(l) = h.sin2psi.dphi90m270sinquadratpsi{k}(l,2)/dzero(k)/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90m270sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi90m270sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f23sigmadelta{k}(l) = (h.sin2psi.dphi90m270sinquadratpsi{k}(l,3)/dzero(k))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90p270sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi90p270sinquadratpsi{k}(l,1))));
%         end
%     end
%     
% else
%     % Calculate dzero(tau) in case of d0 gradient
%     samplethickness = str2double(get(h.editsamplethickness,'String'));
%     param1 = str2double(get(h.editdzeropoly1,'String'));
%     param2 = str2double(get(h.editdzeropoly2,'String'));
%     param3 = str2double(get(h.editdzeropoly3,'String'));
% 
%     dzerotau = @(x)integral(@(z)(param1 + param2.*z + param3.*z.^2).*exp(-z./x),0,samplethickness)./integral(@(z)exp(-z./x),0,samplethickness);
%     
%     % Calculate f+ and delta_f+
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fplussigma{k}(l) = (((h.sin2psi.dphi0p180sinquadratpsi{k}(l,2) + h.sin2psi.dphi90p270sinquadratpsi{k}(l,2)) - 2.*dzerotau(TauCalc.tau{k}(l)))./2./dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{k}(l,1)+2.*DEKdatatmp(k,4));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fplussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{k}(l,3).^2)/2/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi0p180sinquadratpsi{k}(l,1)+2.*DEKdatatmp(k,4)));
%         end
%     end
% 
%     % Calculate f- and delta_f-
%     for k = 1:size(h.sin2psi.dphi90p270,2)
%         for l = 1:size(h.sin2psi.dphi90p270{k},1)
%             fminussigma{k}(l) = (h.sin2psi.dphi0p180sinquadratpsi{k}(l,2) - h.sin2psi.dphi90p270sinquadratpsi{k}(l,2))/2/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{k}(l,1));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             fminussigmadelta{k}(l) = abs((sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,3).^2 + h.sin2psi.dphi90p270sinquadratpsi{k}(l,3).^2)/2/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*h.sin2psi.dphi90p270sinquadratpsi{k}(l,1)));
%         end
%     end
% 
%     % Calculate f13 and delta_f13
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f13sigma{k}(l) = h.sin2psi.dphi0m180sinquadratpsi{k}(l,2)/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f13sigmadelta{k}(l) = (h.sin2psi.dphi0m180sinquadratpsi{k}(l,3)/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi0p180sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi0p180sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     % Calculate f23 and delta_f23
%     for k = 1:size(h.sin2psi.dphi90p270,2)
%         for l = 1:size(h.sin2psi.dphi90p270{k},1)
%             f23sigma{k}(l) = h.sin2psi.dphi90m270sinquadratpsi{k}(l,2)/dzerotau(TauCalc.tau{k}(l))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90m270sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi90m270sinquadratpsi{k}(l,1))));
%         end
%     end
% 
%     for k = 1:size(h.sin2psi.dphi0p180,2)
%         for l = 1:size(h.sin2psi.dphi0p180{k},1)
%             f23sigmadelta{k}(l) = (h.sin2psi.dphi90m270sinquadratpsi{k}(l,3)/dzerotau(TauCalc.tau{k}(l)))/(DEKdatatmp(k,5).*2.*sqrt(h.sin2psi.dphi90p270sinquadratpsi{k}(l,1).*(1-h.sin2psi.dphi90p270sinquadratpsi{k}(l,1))));
%         end
%     end 
% end