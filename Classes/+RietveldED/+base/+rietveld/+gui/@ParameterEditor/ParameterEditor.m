classdef ParameterEditor < hgsetget
%% (* ParameterEditor *)
% Diese Klasse erzeugt ein Fenster mit dem komfortabel die
% Rieveld-Parameter konfiguriert werden koennen.
% -------------------------------------------------------------------------

%% Steuerelemente

	properties (Access = private)
		
		% Figure handle
		fig;
		
		% Java-Table, Java- und Matlab-Handle
		rvTable;
		rvTableMH;
		
		% Matlabspezifische Steuerelemente
		
		% Beschreibung
		wsNameDesc;
		% Name des RVContainers im Haupt-Workspace
		wsName;
        % Mode Beschreibung
        wsModeDescription
		% Import/Export-Modus
		wsMode;
		% Import aus Workspace
		wsImport;
		% Export nach Workspace
		wsExport;
        
	end
	
%% Konstanten
	
	properties (Access = private)
		
		% Hoehe der Matlab-Bar
		WORKSPACEBAR_HEIGHT = 25;
		% Randdicke der Steuerelemente (siehe addBorder)
		DEFAULT_BORDER = 3;
	end
	
	methods (Access = private)
		
		function resize(obj, h, data) %#ok
		% Resize callback des Fensters.
			
			function corrPos = addBorder(pos)
			% Hilfsfunktion, die einen Rand auf einen Bound addiert.

				corrPos(1) = pos(1) + obj.DEFAULT_BORDER;
				corrPos(2) = pos(2) + obj.DEFAULT_BORDER;
				corrPos(3) = pos(3) - 2 * obj.DEFAULT_BORDER;
				corrPos(4) = pos(4) - 2 * obj.DEFAULT_BORDER;
			end
			
			% Layout des Fensters
			try
				figPos = get(obj.fig, 'Position');

				set(obj.rvTableMH, 'Position', addBorder([0, obj.WORKSPACEBAR_HEIGHT, figPos(3), figPos(4) - obj.WORKSPACEBAR_HEIGHT]));

				set(obj.wsNameDesc, 'Position', addBorder([0, 0, 258, obj.WORKSPACEBAR_HEIGHT]));
				set(obj.wsName, 'Position', addBorder([258, 0, 150, obj.WORKSPACEBAR_HEIGHT]));
				set(obj.wsMode, 'Position', addBorder([408, 0, 300, obj.WORKSPACEBAR_HEIGHT]));
				set(obj.wsImport, 'Position', addBorder([708, 0, 180, obj.WORKSPACEBAR_HEIGHT]));
				set(obj.wsExport, 'Position', addBorder([888, 0, 180, obj.WORKSPACEBAR_HEIGHT]));				
			catch ex
				
				disp(ex.message);
			end
		end
		
		function wsImportClick(obj, h, data) %#ok
		% Callback fuer Import.
			disp('ok-Import')
			try
				% Undoable machen
				obj.rvTable.getRVDataModel().addToUndoList();

				% Modus auslesen
				mode = 'all';
				
				switch get(obj.wsMode, 'Value')
					
					case 1
						mode = 'all';
					case 2
						mode = 'once phase';
					case 3
						mode = 'once spec';
					case 4
						mode = 'once';
				end
				
				% Import
				obj.rvTable.getRVDataModel().setContainer(...
					rietveld.gui.ParameterEditor.import(data.rc, mode));
%                 obj.rvTable.getRVDataModel().setContainer(...
% 					rietveld.gui.ParameterEditor.import(evalin('base', get(obj.wsName, 'String')), mode));
			catch e
				
				rethrow(e);
			end
				
		end
			
		function wsExportClick(obj, h, data) %#ok
		% Callback fuer Export.
			disp('ok-Export')
			try		
				
				% Undoable machen und evtl. als Datei speichern
				obj.rvTable.getRVDataModel().addToUndoList();
				obj.rvTable.saveToFileHistory();
				
				% Modus auslesen
				mode = 'all';
				
				switch get(obj.wsMode, 'Value')
					
					case 1
						mode = 'all';
					case 2
						mode = 'once phase';
					case 3
						mode = 'once spec';
					case 4
						mode = 'once';
				end

				% Export
				rietveld.gui.ParameterEditor.export(obj.rvTable.getRVDataModel().getContainer(),...
					data.rc, mode);
%                 rietveld.gui.ParameterEditor.export(obj.rvTable.getRVDataModel().getContainer(),...
% 					evalin('base', get(obj.wsName, 'String')), mode);
			catch e
				
				rethrow(e);
			end
		end
	end
	
	methods (Access = public, Static = true)

		javaRVPC = import(rc, mode);
		% Erzeugt mit dem "RVContainer" "rc" und einem Modus ein 
		% "RVParameterContainer" (Java), der fuer weiteres genutzt werden
		% kann.
		
		export(javaRVPC, rc, mode);
		% Schreibt den "RVParameterContainer" javaRVPC (Java) in den
		% "RVContainer" "rc" mit dem Modus "mode".
	end
	
	methods (Access = public)
	
		function obj = ParameterEditor(uipanel)
		% Standard-Konstruktor der die Steuerelemente erzeugt.
		% uipanel = input variable from tabbedGUI (h.RVAnalysisParamEditorPanel)
        
			%% Figure			
% 			obj.fig = figure('Tag', 'ParameterEditor',...
% 				'Name', 'Rietveld-parameter-editor',...
% 				'Resize', 'on',...
% 				'Position', [100 100 880 514],...
% 				'DockControls', 'on',...
% 				'MenuBar', 'none',...
% 				'ToolBar', 'none',...
% 				'NumberTitle', 'off',...
% 				'ResizeFcn', @(h, evtdata, data)resize(obj, h, guidata(h)));

			
			%% Tabelle			
			obj.rvTable = rvgui.table.RVTable(...
				rvgui.table.RVDataModel(...
				rvgui.param.RVParameterContainer(...
				java.util.ArrayList())));
			obj.rvTable.initComponents();
			
			[~, obj.rvTableMH] = javacomponent(obj.rvTable, [4 25 1730 875], uipanel);
% 			[~, obj.rvTableMH] = javacomponent(obj.rvTable, [4 25 1730 935], uipanel);
%             uipanel.ResizeFcn = @(h, evtdata, data)resize(obj, h, guidata(h));
            
			%% Workspace-Steuerung		    	
			obj.wsNameDesc = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.002 0.01 0.1075 0.015],...
				'Style', 'text',...
                'BackgroundColor', 'w',...
				'String', 'Rietveld-container-name in workspace:',...
                'Visible', 'off',...
				'HorizontalAlignment', 'left');
			obj.wsName = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.11 0.0005 0.03 0.025],...
				'Style', 'edit',...
				'String', 'rc',...
                'Visible', 'off',...
				'HorizontalAlignment', 'left');
            obj.wsModeDescription = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.885 0.965 0.1 0.02],...
				'Style', 'text',...
				'String', 'Select parameter import mode.',...
                'Visible', 'on',...
				'HorizontalAlignment', 'left');
			obj.wsMode = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.885 0.937 0.11 0.025],...
				'Style', 'popup',...
				'String', 'Use all parameters|Use each parameter once (for all phases)|Use each parameter once (for all spectrums)|Use each parameter once',...
				'HorizontalAlignment', 'left');
			obj.wsImport = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.89 0.85 0.07 0.03],...                
				'Style', 'pushbutton',...
				'String', 'Import parameters',...
				'Callback', @(h, evtdata, data)wsImportClick(obj, h, guidata(h)));
			obj.wsExport = uicontrol('Parent', uipanel,...
				'Units', 'normalized',...
                'Position', [0.89 0.8 0.07 0.03],...                
				'Style', 'pushbutton',...
				'String', 'Export parameters',...
				'Callback', @(h, evtdata, data)wsExportClick(obj, h, guidata(h)));
			
		end
	end
end

% classdef ParameterEditor < hgsetget
% %% (* ParameterEditor *)
% % Diese Klasse erzeugt ein Fenster mit dem komfortabel die
% % Rieveld-Parameter konfiguriert werden koennen.
% % -------------------------------------------------------------------------
% 
% %% Steuerelemente
% 
% 	properties (Access = private)
% 		
% 		% Figure handle
% 		fig;
% 		
% 		% Java-Table, Java- und Matlab-Handle
% 		rvTable;
% 		rvTableMH;
% 		
% 		% Matlabspezifische Steuerelemente
% 		
% 		% Beschreibung
% 		wsNameDesc;
% 		% Name des RVContainers im Haupt-Workspace
% 		wsName;
% 		% Import/Export-Modus
% 		wsMode;
% 		% Import aus Workspace
% 		wsImport;
% 		% Export nach Workspace
% 		wsExport;
% 	end
% 	
% %% Konstanten
% 	
% 	properties (Access = private)
% 		
% 		% Hoehe der Matlab-Bar
% 		WORKSPACEBAR_HEIGHT = 25;
% 		% Randdicke der Steuerelemente (siehe addBorder)
% 		DEFAULT_BORDER = 3;
% 	end
% 	
% 	methods (Access = private)
% 		
% 		function resize(obj, h, data) %#ok
% 		% Resize callback des Fensters.
% 			
% 			function corrPos = addBorder(pos)
% 			% Hilfsfunktion, die einen Rand auf einen Bound addiert.
% 
% 				corrPos(1) = pos(1) + obj.DEFAULT_BORDER;
% 				corrPos(2) = pos(2) + obj.DEFAULT_BORDER;
% 				corrPos(3) = pos(3) - 2 * obj.DEFAULT_BORDER;
% 				corrPos(4) = pos(4) - 2 * obj.DEFAULT_BORDER;
% 			end
% 			
% 			% Layout des Fensters
% 			try
% 				figPos = get(obj.fig, 'Position');
% 
% 				set(obj.rvTableMH, 'Position', addBorder([0, obj.WORKSPACEBAR_HEIGHT, figPos(3), figPos(4) - obj.WORKSPACEBAR_HEIGHT]));
% 
% 				set(obj.wsNameDesc, 'Position', addBorder([0, 0, 258, obj.WORKSPACEBAR_HEIGHT]));
% 				set(obj.wsName, 'Position', addBorder([258, 0, 150, obj.WORKSPACEBAR_HEIGHT]));
% 				set(obj.wsMode, 'Position', addBorder([408, 0, 300, obj.WORKSPACEBAR_HEIGHT]));
% 				set(obj.wsImport, 'Position', addBorder([708, 0, 180, obj.WORKSPACEBAR_HEIGHT]));
% 				set(obj.wsExport, 'Position', addBorder([888, 0, 180, obj.WORKSPACEBAR_HEIGHT]));				
% 			catch ex
% 				
% 				disp(ex.message);
% 			end
% 		end
% 		
% 		function wsImportClick(obj, h, data) %#ok
% 		% Callback fuer Import.
% 			
% 			try
% 				
% 				% Undoable machen
% 				obj.rvTable.getRVDataModel().addToUndoList();
% 
% 				% Modus auslesen
% 				mode = 'all';
% 				
% 				switch get(obj.wsMode, 'Value')
% 					
% 					case 1
% 						mode = 'all';
% 					case 2
% 						mode = 'once phase';
% 					case 3
% 						mode = 'once spec';
% 					case 4
% 						mode = 'once';
% 				end
% 				
% 				% Import
% 				obj.rvTable.getRVDataModel().setContainer(...
% 					rietveld.gui.ParameterEditor.import(evalin('base', get(obj.wsName, 'String')), mode));
% 			catch e
% 				
% 				rethrow(e);
% 			end
% 				
% 		end
% 			
% 		function wsExportClick(obj, h, data) %#ok
% 		% Callback fuer Export.
% 			
% 			try		
% 				
% 				% Undoable machen und evtl. als Datei speichern
% 				obj.rvTable.getRVDataModel().addToUndoList();
% 				obj.rvTable.saveToFileHistory();
% 				
% 				% Modus auslesen
% 				mode = 'all';
% 				
% 				switch get(obj.wsMode, 'Value')
% 					
% 					case 1
% 						mode = 'all';
% 					case 2
% 						mode = 'once phase';
% 					case 3
% 						mode = 'once spec';
% 					case 4
% 						mode = 'once';
% 				end
% 
% 				% Export
% 				rietveld.gui.ParameterEditor.export(obj.rvTable.getRVDataModel().getContainer(),...
% 					evalin('base', get(obj.wsName, 'String')), mode);
% 			catch e
% 				
% 				rethrow(e);
% 			end
% 		end
% 	end
% 	
% 	methods (Access = public, Static = true)
% 		
% 		javaRVPC = import(rc, mode);
% 		% Erzeugt mit dem "RVContainer" "rc" und einem Modus ein 
% 		% "RVParameterContainer" (Java), der fuer weiteres genutzt werden
% 		% kann.
% 		
% 		export(javaRVPC, rc, mode);
% 		% Schreibt den "RVParameterContainer" javaRVPC (Java) in den
% 		% "RVContainer" "rc" mit dem Modus "mode".
% 	end
% 	
% 	methods (Access = public)
% 		
% 		function obj = ParameterEditor()
% 		% Standard-Konstruktor der die Steuerelemente erzeugt.
% 			
% 			%% Figure			
% 			obj.fig = figure('Tag', 'ParameterEditor',...
% 				'Name', 'Rietveld-parameter-editor',...
% 				'Resize', 'on',...
% 				'Position', [100 100 880 514],...
% 				'DockControls', 'on',...
% 				'MenuBar', 'none',...
% 				'ToolBar', 'none',...
% 				'NumberTitle', 'off',...
% 				'ResizeFcn', @(h, evtdata, data)resize(obj, h, guidata(h)));
% 			
% 			%% Tabelle			
% 			obj.rvTable = rvgui.table.RVTable(...
% 				rvgui.table.RVDataModel(...
% 				rvgui.param.RVParameterContainer(...
% 				java.util.ArrayList())));
% 			obj.rvTable.initComponents();
% 			
% 			[~, obj.rvTableMH] = javacomponent(obj.rvTable, [0 0 800 800], obj.fig);
% 			
% 			%% Workspace-Steuerung			
% 			obj.wsNameDesc = uicontrol('Parent', obj.fig,...
% 				'Units', 'pixels',...
% 				'Style', 'text',...
% 				'String', 'Rietveld-container-name in workspace:',...
% 				'HorizontalAlignment', 'left');
% 			obj.wsName = uicontrol('Parent', obj.fig,...
% 				'Units', 'pixels',...
% 				'Style', 'edit',...
% 				'String', '',...
% 				'HorizontalAlignment', 'left');
% 			obj.wsMode = uicontrol('Parent', obj.fig,...
% 				'Units', 'pixels',...
% 				'Style', 'popup',...
% 				'String', 'Use all parameters|Use each parameter once (for all phases)|Use each parameter once (for all spectrums)|Use each parameter once',...
% 				'HorizontalAlignment', 'left');
% 			obj.wsImport = uicontrol('Parent', obj.fig,...
% 				'Units', 'pixels',...
% 				'Style', 'pushbutton',...
% 				'String', 'Import from workspace',...
% 				'Callback', @(h, evtdata, data)wsImportClick(obj, h, guidata(h)));
% 			obj.wsExport = uicontrol('Parent', obj.fig,...
% 				'Units', 'pixels',...
% 				'Style', 'pushbutton',...
% 				'String', 'Export to workspace',...
% 				'Callback', @(h, evtdata, data)wsExportClick(obj, h, guidata(h)));
% 			
% 		end
% 	end
% end

