package rvgui.table;

import com.jidesoft.combobox.*;
import com.jidesoft.comparator.ObjectComparatorManager;
import com.jidesoft.converter.*;
import com.jidesoft.grid.*;
import com.jidesoft.swing.SearchableUtils;
import com.jidesoft.swing.TableSearchable;
import java.awt.*;
import java.awt.event.*;
import java.io.*;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.Locale;
import javax.swing.*;
import javax.swing.filechooser.FileNameExtensionFilter;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.TableModel;
import rvgui.images.ImageReferenceClass;
import rvgui.matrix.*;
import rvgui.param.*;

/**
 * A complex table-panel which also contains some further components. As table
 * we use a GroupTable with an AutofilterHeader. Additionally we added a
 * QuickTableFilterField. On the bottom you'll find some master buttons to
 * modify all selected parameters.
 * @author hsu
 */
public class RVTable extends JPanel {

	// swing components
	private GroupTable table;
	private QuickTableFilterField filterField;
	private MatrixEditorComboBox masterValue;
	private MatrixEditorComboBox masterLowerConstraint;
	private MatrixEditorComboBox masterUpperConstraint;
	private JCheckBox masterValueDistr;
	private JToolBar toolbar;
	private FileNameChooserComboBox fileHistory;
	
	/**
	 * Underlying data model.
	 */
	private RVDataModel rvDataModel;
	
	/**
	 * Init with data model.
	 * @param rvDataModel 
	 */
	public RVTable(RVDataModel rvDataModel) {

		this.rvDataModel = rvDataModel;

		initTableManagers();
	}

	/**
	 * This methods is responsible for all editor, converter and comparator
	 * registrations.
	 */
	private void initTableManagers() {

		// editors
		
		// Embed MatrixEditorCombobox
		CellEditorManager.registerEditor(DoubleMatrix.class, new CellEditorFactory() {

			@Override
			public CellEditor create() {
				return new AbstractComboBoxCellEditor() {

					@Override
					public AbstractComboBox createAbstractComboBox() {
						return new MatrixEditorComboBox(new DoubleMatrixTableModel());
					}
				};
			}
		});
		
		// Converter
		
		// Double converter for matrix editors
		DecimalFormat nf = new DecimalFormat();
		// always use us-format especially use '.'-separator
		nf.setDecimalFormatSymbols(new DecimalFormatSymbols(Locale.US));
		nf.setGroupingUsed(false); // no grouping
		DoubleConverter dc;
		ObjectConverterManager.registerConverter(Double.class, dc = new DoubleConverter(nf) {

			@Override
			public Object fromString(String string, ConverterContext cc) {

				// special symbols, compare to MATLAB syntax
				if ("nan".equals(string.toLowerCase())) {
					return Double.NaN;
				} else if ("inf".equals(string.toLowerCase())) {
					return Double.POSITIVE_INFINITY;
				} else if ("-inf".equals(string.toLowerCase())) {
					return Double.NEGATIVE_INFINITY;
				} else {
					return super.fromString(string, cc);
				}
			}

			@Override
			public String toString(Object o, ConverterContext cc) {

				// special symbols, compare to MATLAB syntax
				if (o instanceof Double) {

					Double d = (Double) o;
					if (d.isNaN()) {
						return "NaN";
					} else if (d == Double.POSITIVE_INFINITY) {
						return "Inf";
					} else if (d == Double.NEGATIVE_INFINITY) {
						return "-Inf";
					} else {
						return super.toString(d, cc);
					}
				}
				return super.toString(o, cc);
			}
		});
		// 5 digits after decimal point
		dc.setFractionDigits(0, 10);
		
		// special converter for the phase index
		ObjectConverterManager.registerConverter(Integer.class, new IntegerConverter() {

			@Override
			public String toString(Object o, ConverterContext cc) {
				
				if (o instanceof Integer) {
					
					// -1 means no phase (empty string)
					Integer i = (Integer) o;
					if (i == -1) {
						return "";
					} else {
						return super.toString(i, cc);
					}
				}
				return super.toString(o, cc);
			}
		}, new ConverterContext("PhaseIndex"));

		// Default inits
		ObjectComparatorManager.initDefaultComparator();
		ObjectConverterManager.initDefaultConverter();
		CellEditorManager.initDefaultEditor();
	}

	public void saveToFileHistory() {

		try {

			String patternString = (String) fileHistory.getSelectedItem();

			if (patternString == null || patternString.isEmpty()) {

				return;
			}

			File pattern = new File(patternString);
			pattern = new File(pattern.getAbsolutePath());

			class HistoryFileFilter implements FileFilter {

				private String fileName;

				public HistoryFileFilter(String fileName) {

					this.fileName = fileName;
				}

				@Override
				public boolean accept(File f) {

					if (f.isFile()) {
						return f.getName().matches(fileName + "\\d+?" + ".rvp");
					} else {
						return false;
					}
				}
			}

			int bkpIndex = 1;

			File[] recentBkp = pattern.getParentFile().listFiles(new HistoryFileFilter(pattern.getName()));

			for (int i = 0; i < recentBkp.length; i++) {

				String currIndex = recentBkp[i].getName();
				currIndex = currIndex.replace(pattern.getName(), "");
				currIndex = currIndex.replace(".rvp", "");
				if (bkpIndex <= Integer.parseInt(currIndex)) {
					bkpIndex = Integer.parseInt(currIndex) + 1;
				}
			}

			getRVDataModel().getContainer().saveToFile(
					new File(pattern.getAbsolutePath() + bkpIndex + ".rvp"));

		} catch (Exception ex) {

			ex.printStackTrace();
		}
	}

	/**
	 * Inits all graphical components. You have to call this method explicitely.
	 */
	public void initComponents() {

		// Mail panel layout
		this.setLayout(new BorderLayout());

		// temporary panel used as sub panel
		JPanel panelTmp;
		// temporary variable for actions
		Action a = null;

		// add Toolbar
		toolbar = new JToolBar();
		toolbar.setLayout(new BorderLayout());
		this.add(toolbar, BorderLayout.NORTH);

		/*
		 * All toolbar buttons
		 */
		panelTmp = new JPanel();
		toolbar.add(panelTmp, BorderLayout.WEST);
		
		// load from file button
		JButton load = new JButton();
		load.setToolTipText("Load parameter config from file");
		load.setIcon(new ImageIcon(new ImageReferenceClass().getClass().getResource("Open24.gif")));
		load.setBorder(BorderFactory.createEmptyBorder());
		load.addActionListener(a = new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent e) {

				// use open dialog
				JFileChooser dialog = new JFileChooser(new File("."));
				dialog.setDialogTitle("Load from file");
				dialog.setFileFilter(new FileNameExtensionFilter("Rietveld-parameter-container", "rvp"));

				if (dialog.showOpenDialog(RVTable.this) == JFileChooser.APPROVE_OPTION) {

					getRVDataModel().setContainer(
							RVParameterContainer.loadFromFile(
							dialog.getSelectedFile()));
				}
			}
		});
		load.getInputMap(WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_O, KeyEvent.CTRL_MASK), load);
		load.getActionMap().put(load, a);
		panelTmp.add(load, BorderLayout.CENTER);

		// save to file button
		JButton save = new JButton();
		save.setToolTipText("Save parameter config to file");
		save.setIcon(new ImageIcon(new ImageReferenceClass().getClass().getResource("Save24.gif")));
		save.setBorder(BorderFactory.createEmptyBorder());
		save.addActionListener(a = new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent e) {

				// use save dialog
				JFileChooser dialog = new JFileChooser(new File("."));
				dialog.setDialogTitle("Save to file");
				dialog.setFileFilter(new FileNameExtensionFilter("Rietveld-parameter-container", "rvp"));
				dialog.setSelectedFile(new File("*.rvp"));

				if (dialog.showSaveDialog(RVTable.this) == JFileChooser.APPROVE_OPTION) {

					getRVDataModel().getContainer().saveToFile(
							dialog.getSelectedFile());
				}
			}
		});
		save.getInputMap(WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_S, KeyEvent.CTRL_MASK), save);
		save.getActionMap().put(save, a);
		panelTmp.add(save, BorderLayout.CENTER);

		// undo button, executes undo-method of the RVDataModel
		JButton undo = new JButton();
		undo.setToolTipText("Get last container stored in history");
		undo.setIcon(new ImageIcon(new ImageReferenceClass().getClass().getResource("Undo24.gif")));
		undo.setBorder(BorderFactory.createEmptyBorder());
		undo.addActionListener(a = new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent e) {

				getRVDataModel().undo();
			}
		});
		undo.getInputMap(WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_Z, KeyEvent.CTRL_MASK), undo);
		undo.getActionMap().put(undo, a);
		panelTmp.add(undo, BorderLayout.CENTER);

		// "save to history"-button, adds the current container to the 
		// data model's undo-list
		JButton history = new JButton();
		history.setToolTipText("Save current container to history (and file)");
		history.setIcon(new ImageIcon(new ImageReferenceClass().getClass().getResource("History24.gif")));
		history.setBorder(BorderFactory.createEmptyBorder());
		history.addActionListener(a = new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent e) {

				getRVDataModel().addToUndoList();
				saveToFileHistory();
			}
		});
		history.getInputMap(WHEN_IN_FOCUSED_WINDOW).put(KeyStroke.getKeyStroke(KeyEvent.VK_Y, KeyEvent.CTRL_MASK), history);
		history.getActionMap().put(history, a);
		panelTmp.add(history, BorderLayout.CENTER);

		// this chooser is used to make a file history besides the internaö
		// history
		fileHistory = new FileNameChooserComboBox();
		fileHistory.setCurrentDirectory(new File("."));
		fileHistory.setToolTipText("Filename pattern for file backups, "
				+ "that mean the container will be saved to a file when you "
				+ "use the history button. A continous number will be added. "
				+ "Leave this field empty, if you do not want to use this feature.");
		panelTmp.add(fileHistory, BorderLayout.CENTER);
		
		/*
		 * Filter-field
		 */
		filterField = new QuickTableFilterField();
		filterField.setTableModel(getRVDataModel());
		filterField.getDisplayTableModel().setAndMode(true);
		toolbar.add(filterField, BorderLayout.EAST);
		
		/*
		 * Table
		 */		
		table = new GroupTable(RVDataModel.createDisplayModel(filterField.getDisplayTableModel()));		
		// autofilter-header
		AutoFilterTableHeader header = new AutoFilterTableHeader(table);
		header.setAutoFilterEnabled(true);
		header.setShowFilterIcon(true);
		header.setShowFilterNameAsToolTip(true);
		table.setTableHeader(header);
		// popup-menu
		TableHeaderPopupMenuInstaller installer = new TableHeaderPopupMenuInstaller(table);
		installer.addTableHeaderPopupMenuCustomizer(new AutoResizePopupMenuCustomizer());
		installer.addTableHeaderPopupMenuCustomizer(new TableColumnChooserPopupMenuCustomizer());
		// make table searchable
		TableSearchable tableSearchable = SearchableUtils.installSearchable(table);
		tableSearchable.setMainIndex(
				((AbstractTableModel)table.getModel()).findColumn(RVColumn.NAME.getName()));
		add(new JScrollPane(table), BorderLayout.CENTER);

		/*
		 * Master-buttons
		 */		
		GridLayout layout = new GridLayout(5, 2);
		panelTmp = new JPanel(layout);

		// refinable master field
		JCheckBox masterRefinable = new JCheckBox();
		masterRefinable.addActionListener(new MasterRefinableAction());
		panelTmp.add(new JLabel("Refinable master field:"));
		panelTmp.add(masterRefinable);

		// value master field
		masterValue = new MatrixEditorComboBox(new DoubleMatrixTableModel(), true);
		masterValue.addActionListener(new MasterValueAction());
		panelTmp.add(new JLabel("Value master field:"));
		panelTmp.add(masterValue);

		// lower constraint master field
		masterLowerConstraint = new MatrixEditorComboBox(new DoubleMatrixTableModel(), true);
		masterLowerConstraint.addActionListener(new MasterValueAction());
		panelTmp.add(new JLabel("Lower constraint master field:"));
		panelTmp.add(masterLowerConstraint);

		// upper constraint master field
		masterUpperConstraint = new MatrixEditorComboBox(
				new DoubleMatrixTableModel(), true);
		masterUpperConstraint.addActionListener(new MasterValueAction());
		panelTmp.add(new JLabel("Upper constraint master field:"));
		panelTmp.add(masterUpperConstraint);

		// toggle, whether the master inputs should be distributed over the
		// selected rows or not
		masterValueDistr = new JCheckBox();
		panelTmp.add(new JLabel("Distribute master inputs over selected rows:"));
		panelTmp.add(masterValueDistr);

		add(panelTmp, BorderLayout.SOUTH);
	}

	public RVDataModel getRVDataModel() {
		return rvDataModel;
	}

	/**
	 * Returns the display model (NOT the data model, see getRVDataModel).
	 * @return 
	 */
	private TableModel getModel() {
		return table.getModel();
	}

	/**
	 * Gets the corresponding row in the underlying data model.
	 * @param rowIndex
	 * @return 
	 */
	private int getActualRowAt(int rowIndex) {

		return TableModelWrapperUtils.getActualRowAt(getModel(), rowIndex, getRVDataModel());
	}

	/**
	 * This action executes the master setting for "refinable"
	 */
	public class MasterRefinableAction implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {

			AbstractButton b = (AbstractButton) e.getSource();

			int[] selRows = table.getSelectedRows();

			// if no selection, apply to all rows
			if (selRows.length == 0) {
				for (int i = 0; i < getModel().getRowCount(); i++) {

					int row = getActualRowAt(i);
					int col = getRVDataModel().findColumn(RVColumn.REFINABLE.getName());

					getRVDataModel().setValueAt(b.isSelected(), row, col);
					// update model
					getRVDataModel().fireTableCellUpdated(row, col);
				}
			} else {

				for (int i = 0; i < selRows.length; i++) {

					int row = getActualRowAt(selRows[i]);
					int col = getRVDataModel().findColumn(RVColumn.REFINABLE.getName());

					getRVDataModel().setValueAt(b.isSelected(), row, col);
					// update model
					getRVDataModel().fireTableCellUpdated(row, col);
				}
			}
		}
	}

	/**
	 * This action executes the master setting for the other values
	 */
	public class MasterValueAction implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {

			MatrixEditorComboBox cmb = (MatrixEditorComboBox) e.getSource();

			int col = 0;

			// find out which master field was used
			if (cmb == masterValue) {
				col = getRVDataModel().findColumn(RVColumn.VALUE.getName());
			} else if (cmb == masterLowerConstraint) {
				col = getRVDataModel().findColumn(RVColumn.LOWER_CONSTRAINT.getName());
			} else if (cmb == masterUpperConstraint) {
				col = getRVDataModel().findColumn(RVColumn.UPPER_CONSTRAINT.getName());
			}

			int[] selRows = table.getSelectedRows();

			// distribute values or not
			if (!masterValueDistr.isSelected()) {

				// if no selection, apply to all rows
				if (selRows.length == 0) {
					for (int i = 0; i < getModel().getRowCount(); i++) {

						int row = getActualRowAt(i);

						getRVDataModel().setValueAt(cmb.getSelectedItem(), row, col);
						// update model
						getRVDataModel().fireTableCellUpdated(row, col);
					}
				} else {

					for (int i = 0; i < selRows.length; i++) {

						int row = getActualRowAt(selRows[i]);

						getRVDataModel().setValueAt(cmb.getSelectedItem(), row, col);
						// update model
						getRVDataModel().fireTableCellUpdated(row, col);
					}
				}
			} else {

				Double[][] mat = ((DoubleMatrix) cmb.getSelectedItem()).toArray();

				// validation
				if (mat.length == selRows.length) {

					// extract the i-th row of the master field and
					// assign this value into the i-th row of the selection
					for (int i = 0; i < selRows.length; i++) {

						int row = getActualRowAt(selRows[i]);

						getRVDataModel().setValueAt(new DoubleMatrix(mat[i]), row, col);
						// update model
						getRVDataModel().fireTableCellUpdated(row, col);
					}
				}
			}
		}
	}
}
