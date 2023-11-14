function [h] = SliderCallbackPlotfitdata(h, PlotWindow, XDataStr, YDataStr, valueSlider)

Axes = join(['axesplotfitdata',PlotWindow]);
PlotPhi0 = join(['fitdata',PlotWindow,'plotphi0']);
PlotErrPhi0 = join(['fitdata',PlotWindow,'ploterrphi0']);
PlotPhi90 = join(['fitdata',PlotWindow,'plotphi90']);
PlotErrPhi90 = join(['fitdata',PlotWindow,'ploterrphi90']);
PlotPhi180 = join(['fitdata',PlotWindow,'plotphi180']);
PlotErrPhi180 = join(['fitdata',PlotWindow,'ploterrphi180']);
PlotPhi270 = join(['fitdata',PlotWindow,'plotphi270']);
PlotErrPhi270 = join(['fitdata',PlotWindow,'ploterrphi270']);
dataforplotting = join(['dataforplotting',PlotWindow]);
LegendPlot = join(['legendplotfitdata',PlotWindow]);
maxValLatticeSpacing = join(['maxValLatticeSpacing',PlotWindow]);
minValLatticeSpacing = join(['minValLatticeSpacing',PlotWindow]);
maxValEnergy_Max = join(['maxValEnergy_Max',PlotWindow]);
minValEnergy_Max = join(['minValEnergy_Max',PlotWindow]);
maxValIntegralWidth = join(['maxValIntegralWidth',PlotWindow]);
minValIntegralWidth = join(['minValIntegralWidth',PlotWindow]);
maxValFWHM = join(['maxValFWHM',PlotWindow]);
minValFWHM = join(['minValFWHM',PlotWindow]);
maxValIntegralInt = join(['maxValIntegralInt',PlotWindow]);
minValIntegralInt = join(['minValIntegralInt',PlotWindow]);
eta = join(['eta',PlotWindow]);
phi = join(['phi',PlotWindow]);

    if ~isfield(h,['eta', PlotWindow]) && ~isfield(h,['phi', PlotWindow])
        % Set plot properties
        if strcmp(XDataStr,'tau')
            XLimtau = ceil(round(h.TauMaxAxesLimits{1}(valueSlider),1)/5)*5;
            h.(Axes).XLim = [0 XLimtau];
            if XLimtau <= 5
                h.(Axes).XTick = (0:0.5:XLimtau);
            elseif XLimtau > 5 && XLimtau <= 10
                h.(Axes).XTick = (0:1:XLimtau);
            elseif XLimtau > 10 && XLimtau <= 25
                h.(Axes).XTick = (0:2.5:XLimtau);
            elseif XLimtau > 25 && XLimtau <= 50
                h.(Axes).XTick = (0:5:XLimtau);    
            elseif XLimtau > 50 && XLimtau <= 100
                h.(Axes).XTick = (0:10:XLimtau);    
            end
        end

        if strcmp(YDataStr,'Energy')
            h.(Axes).YLim = [floor(h.(minValEnergy_Max){valueSlider}./0.05).*0.05 ceil(h.(maxValEnergy_Max){valueSlider}/0.05).*0.05];

            if abs(h.(Axes).YLim(1) - h.(minValEnergy_Max){valueSlider}) < 0.005
                h.(Axes).YLim(1) = h.(Axes).YLim(1) - 0.05;
            end
            
            if abs(h.(Axes).YLim(2) - h.(maxValEnergy_Max){valueSlider}) < 0.005
                h.(Axes).YLim(2) = h.(Axes).YLim(2) + 0.05;
            end
            
            Ymin = h.(Axes).YLim(1);
            Ymax = h.(Axes).YLim(2);

            if (Ymax - Ymin) <= 0.11
                h.(Axes).YTick = (Ymin:0.01:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.11 && (Ymax - Ymin) <= 0.19
                h.(Axes).YTick = (Ymin:0.025:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.19
                h.(Axes).YTick = (Ymin:0.05:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
            end

        elseif strcmp(YDataStr,'Integral Breadth')
            h.(Axes).YLim = [floor(h.(minValIntegralWidth){valueSlider}./0.05).*0.05 ceil(h.(maxValIntegralWidth){valueSlider}/0.05).*0.05];

            Ymin = h.(Axes).YLim(1);
            Ymax = h.(Axes).YLim(2);

            if (Ymax - Ymin) <= 0.11
                h.(Axes).YTick = (Ymin:0.025:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.11 && (Ymax - Ymin) <= 0.51
                h.(Axes).YTick = (Ymin:0.05:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
            elseif (Ymax - Ymin) > 0.51
                h.(Axes).YTick = (Ymin:0.1:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
            end

        elseif strcmp(YDataStr,'FWHM')
            h.(Axes).YLim = [floor(h.(minValFWHM){valueSlider}./0.05).*0.05 ceil(h.(maxValFWHM){valueSlider}/0.05).*0.05];

            Ymin = h.(Axes).YLim(1);
            Ymax = h.(Axes).YLim(2);

            if (Ymax - Ymin) <= 0.11
                h.(Axes).YTick = (Ymin:0.025:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.3f ';
            elseif (Ymax - Ymin) > 0.11 && (Ymax - Ymin) <= 0.51
                h.(Axes).YTick = (Ymin:0.05:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.2f ';
            elseif (Ymax - Ymin) > 0.51
                h.(Axes).YTick = (Ymin:0.1:Ymax);
                h.(Axes).YAxis.TickLabelFormat = ' %.1f ';
            end

        elseif strcmp(YDataStr,'Weighting Factor')
            h.(Axes).YLim = [0 1];
        elseif strcmp(YDataStr,'Form Factor')
            h.(Axes).YLim = [0.6 1];
        elseif strcmp(YDataStr,'Int. Intensity')

        elseif strcmp(YDataStr,'Max. Intensity')

        end

        % Set plot data
        if ~isempty(h.idxphi0)
            if strcmp(YDataStr,'d-spacing')
                set(h.(PlotErrPhi0), {'Xdata','Ydata','YPositiveDelta','YNegativeDelta'}, {h.(dataforplotting).phi0.X{valueSlider}, h.(dataforplotting).phi0.Y{valueSlider}, h.(dataforplotting).phi0.Yerror{valueSlider}, h.(dataforplotting).phi0.Yerror{valueSlider}})
                set(h.(PlotErrPhi0), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
                h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
%                 h.(Axes).YLim = [2.83 2.87];
            else
                set(h.(PlotPhi0), {'Xdata','Ydata'}, {h.(dataforplotting).phi0.X{valueSlider}, h.(dataforplotting).phi0.Y{valueSlider}})
                set(h.(PlotPhi0), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
            end
        end

        if ~isempty(h.idxphi90)
            if strcmp(YDataStr,'d-spacing')
                set(h.(PlotErrPhi90), {'Xdata','Ydata','YPositiveDelta','YNegativeDelta'}, {h.(dataforplotting).phi90.X{valueSlider}, h.(dataforplotting).phi90.Y{valueSlider}, h.(dataforplotting).phi90.Yerror{valueSlider}, h.(dataforplotting).phi90.Yerror{valueSlider}})
                set(h.(PlotErrPhi90), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
                h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
%                 h.(Axes).YLim = [2.83 2.87];
            else
                set(h.(PlotPhi90), {'Xdata','Ydata'}, {h.(dataforplotting).phi90.X{valueSlider}, h.(dataforplotting).phi90.Y{valueSlider}})
                set(h.(PlotPhi90), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
            end
        end

        if ~isempty(h.idxphi180)
            if strcmp(YDataStr,'d-spacing')
                set(h.(PlotErrPhi180), {'Xdata','Ydata','YPositiveDelta','YNegativeDelta'}, {h.(dataforplotting).phi180.X{valueSlider}, h.(dataforplotting).phi180.Y{valueSlider}, h.(dataforplotting).phi180.Yerror{valueSlider}, h.(dataforplotting).phi180.Yerror{valueSlider}})
                set(h.(PlotErrPhi180), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
                h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
%                 h.(Axes).YLim = [0.2870 0.2886];
            else
                set(h.(PlotPhi180), {'Xdata','Ydata'}, {h.(dataforplotting).phi180.X{valueSlider}, h.(dataforplotting).phi180.Y{valueSlider}})
                set(h.(PlotPhi180), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
            end
        end

        if ~isempty(h.idxphi270)
            if strcmp(YDataStr,'d-spacing')
                set(h.(PlotErrPhi270), {'Xdata','Ydata','YPositiveDelta','YNegativeDelta'}, {h.(dataforplotting).phi270.X{valueSlider}, h.(dataforplotting).phi270.Y{valueSlider}, h.(dataforplotting).phi270.Yerror{valueSlider}, h.(dataforplotting).phi270.Yerror{valueSlider}})
                set(h.(PlotErrPhi270), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
                h.(Axes).YLim = [floor((h.(minValLatticeSpacing){valueSlider}-0.0001)./0.0002).*0.0002 ceil((h.(maxValLatticeSpacing){valueSlider}+0.0001)/0.0002).*0.0002];
%                 h.(Axes).YLim = [2.83 2.87];
            else
                set(h.(PlotPhi270), {'Xdata','Ydata'}, {h.(dataforplotting).phi270.X{valueSlider}, h.(dataforplotting).phi270.Y{valueSlider}})
                set(h.(PlotPhi270), {'Color','MarkerFaceColor','MarkerEdgeColor'}, {'k',h.Colors{valueSlider},'k'})
            end
        end
        % assignin('base','labelforplot',h.labelforplot)
        title(h.(LegendPlot),[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
    else
        if isfield (h,['eta', PlotWindow])
            % Set previous plots invisible
            for k = 1:size(h.(eta).etaplot,2)
                set(h.(eta).etaplot{k},'Visible','off')
            end

            % Clear legend data
            h.(eta) = rmfield(h.(eta),'leglabel');
            h.(eta) = rmfield(h.(eta),'LegData');
            h.(eta) = rmfield(h.(eta),'legend');
            legend(h.(Axes),'off')

            % Plot sin²eta data. First, only zeros are plotted. Later the user can
            % choose which peak information he wants to plot as a function of eta
            % or sin²eta.
            hold(h.(Axes),'on')
            for i = 1:length(h.(eta).psiIndex{valueSlider})
                if strcmp(XDataStr,'Eta')
                    h.(eta).etaplot{i} = errorbar(h.(Axes),h.(eta).TableEta{valueSlider,i},h.(eta).Tabledspacing{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{valueSlider});
                elseif strcmp(XDataStr,'sin²Eta')
                    h.(eta).etaplot{i} = errorbar(h.(Axes),sind(h.(eta).TableEta{valueSlider,i}).^2,h.(eta).Tabledspacing{valueSlider,i}.*0,h.(eta).Tabledspacingdelta{valueSlider,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor','k','MarkerFaceColor',h.Colors{valueSlider});
                end
                % Create label data from psi angles
                h.(eta).leglabel{i} = ['\psi = ',num2str(h.(eta).psiIndex{valueSlider}(i,:))];
            end

            hold(h.(Axes),'off')

            % If eta measurements are analyzed, data has to be prepared in a different
            % way.
            if strcmp(YDataStr,'d-spacing')
                for i = 1:length(h.(eta).psiIndex{valueSlider})
                    set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).Tabledspacing{valueSlider,i},h.(eta).Tabledspacingdelta{valueSlider,i},h.(eta).Tabledspacingdelta{valueSlider,i}});
                end
            elseif strcmp(YDataStr,'Integral Breadth')
                for i = 1:length(h.(eta).psiIndex{valueSlider})
                    set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).TableIB{valueSlider,i},h.(eta).TableIB{valueSlider,i}.*0,h.(eta).TableIB{valueSlider,i}.*0});
                end
            elseif strcmp(YDataStr,'Int. Intensity')
                for i = 1:length(h.(eta).psiIndex{valueSlider})
                    set(h.(eta).etaplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(eta).TableIntensity_Int{valueSlider,i},h.(eta).TableIntensity_Int{valueSlider,i}.*0,h.(eta).TableIntensity_Int{valueSlider,i}.*0});
                end
            end    

            % Create data matrix for legend entries.
            for k = 1:length(h.(eta).psiIndex{valueSlider})
                h.(eta).LegData(k) = h.(eta).etaplot{k};
            end

            % Add legend to plot
            h.(eta).legend = legend(h.(Axes),h.(eta).LegData,h.(eta).leglabel);

        %     assignin('base','etaneu1',h.(eta))

            % Add reflex hkl to plot legend
            title(h.(eta).legend,[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
        elseif isfield(h,['phi', PlotWindow])
            % Set previous plots invisible
            for k = 1:size(h.(phi).phiplot,2)
                set(h.(phi).phiplot{k},'Visible','off')
            end

            % Clear legend data
            h.(phi) = rmfield(h.(phi),'leglabel');
            h.(phi) = rmfield(h.(phi),'LegData');
            h.(phi) = rmfield(h.(phi),'legend');
            legend(h.(Axes),'off')

            % Plot sin²phi data. First, only zeros are plotted. Later the user can
            % choose which peak information he wants to plot as a function of phi
            % or sin²phi.
            hold(h.(Axes),'on')
            for i = 1:length(h.(phi).psiIndex{valueSlider})
                h.(phi).phiplot{i} = errorbar(h.(Axes),h.(phi).Tablephi{valueSlider,i},h.(phi).Tabledspacing{valueSlider,i}.*0,h.(phi).Tabledspacingdelta{valueSlider,i}.*0,'s','LineStyle','--','Color','k','MarkerSize',12,'MarkerEdgeColor',h.Colors{valueSlider},'MarkerFaceColor',h.Colors{valueSlider});
                % Create label data from psi angles
                h.(phi).leglabel{i} = ['\psi = ',num2str(h.(phi).psiIndex{valueSlider}(i,:))];
            end

            hold(h.(Axes),'off')

            % If phi measurements are analyzed, data has to be prepared in a different
            % way.
            if strcmp(YDataStr,'d-spacing')
                for i = 1:length(h.(phi).psiIndex{valueSlider})
                    set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).Tabledspacing{valueSlider,i},h.(phi).Tabledspacingdelta{valueSlider,i},h.(phi).Tabledspacingdelta{valueSlider,i}});
                end
            elseif strcmp(YDataStr,'Integral Breadth')
                for i = 1:length(h.(phi).psiIndex{valueSlider})
                    set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).TableIB{valueSlider,i},h.(phi).TableIB{valueSlider,i}.*0,h.(phi).TableIB{valueSlider,i}.*0});
                end
            elseif strcmp(YDataStr,'Int. Intensity')
                for i = 1:length(h.(phi).psiIndex{valueSlider})
                    set(h.(phi).phiplot{i},{'YData','YNegativeDelta','YPositiveDelta'},{h.(phi).TableIntensity_Int{valueSlider,i},h.(phi).TableIntensity_Int{valueSlider,i}.*0,h.(phi).TableIntensity_Int{valueSlider,i}.*0});
                end
            end    

            % Create data matrix for legend entries.
            for k = 1:length(h.(phi).psiIndex{valueSlider})
                h.(phi).LegData(k) = h.(phi).phiplot{k};
            end

            % Add legend to plot
            h.(phi).legend = legend(h.(Axes),h.(phi).LegData,h.(phi).leglabel);

        %     assignin('base','phineu1',h.(phi))

            % Add reflex hkl to plot legend
            title(h.(phi).legend,[h.labelforplot(valueSlider,:),' ','Reflex'],'FontSize',11,'FontWeight','normal')
        end
    end
end
