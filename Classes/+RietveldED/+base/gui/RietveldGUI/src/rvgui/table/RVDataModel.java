package rvgui.table;

import com.jidesoft.converter.*;
import com.jidesoft.grid.*;
import java.util.ArrayList;
import java.util.LinkedList;
import javax.swing.SwingConstants;
import javax.swing.table.AbstractTableModel;
import javax.swing.table.TableModel;
import rvgui.param.*;
import rvgui.param.cell.Cell;

/**
 * Basic table model for our rietveld-parameters. The underlying structure is a
 * RVParameterContainer.
 * @author hsu
 */
public final class RVDataModel extends AbstractTableModel 
implements ContextSensitiveTableModel, StyleModel {

	/**
	 * Wraps the dataModel into the display model used by RVTable.
	 * @param dataModel
	 * @return 
	 */
	public static TableModel createDisplayModel(TableModel dataModel) {
		
		// Filter-model
		FilterableTableModel filterModel = new FilterableTableModel(dataModel);
		
		// Group-model
		DefaultGroupTableModel groupModel = new DefaultGroupTableModel(filterModel);
		// add Category-group
		groupModel.clearGroupColumns();
		groupModel.addGroupColumn(groupModel.findColumn(RVColumn.CATEGORY.getName()));
		groupModel.groupAndRefresh();
		
		return groupModel;
	}
	
	/**
	 * The underlying container.
	 */
	private RVParameterContainer container;
	
	/**
	 * A simple list of containers that stores recent parameter-configs.
	 */
	private LinkedList<RVParameterContainer> undoList;
	
	/**
	 * A dummy parameter to get information about the columns.
	 */
	private RVParameter dummy;
	
	/**
	 * Init with an empty container.
	 */
	public RVDataModel() {
		
		dummy = new RVFitParameter();
		
		undoList = new LinkedList<RVParameterContainer>();
		
		setContainer(new RVParameterContainer(new ArrayList<RVParameter>()));
	}
	
	/**
	 * Init with a container.
	 * @param container 
	 */
	public RVDataModel(RVParameterContainer container) {
		
		dummy = new RVFitParameter();
		
		undoList = new LinkedList<RVParameterContainer>();
		
		setContainer(container);
	}
	
	/**
	 * Adds the current container to the undo-list.
	 */
	public void addToUndoList() {
		
		undoList.addFirst(getContainer().copy());
		// there are a maximum 20 entries in the undo-list
		if (undoList.size() > 20) {
			
			undoList.removeLast();
		}
	}
	
	/**
	 * Get the last container from undo-list.
	 */
	public void undo() {
		
		if (!undoList.isEmpty()) {
			setContainer(undoList.getFirst());
			undoList.removeFirst();
		}
	}
	
	/**
	 * Get the underlying container.
	 * @return 
	 */
	public RVParameterContainer getContainer() {
		
		return container;
	}
	
	/**
	 * Set a new container and update the model.
	 * @param container 
	 */
	public void setContainer(RVParameterContainer container) {
		
		this.container = container;
		// notify the table model
		fireTableDataChanged();
	}
	
	/**
	 * Delegates the byColumnIndex-methods of RVColumn.
	 * @param columnIndex
	 * @return 
	 */
	private static RVColumn byColumnIndex(int columnIndex) {
		
		return RVColumn.byColumnIndex(columnIndex);
	}

	@Override
	public int getColumnCount() {
		return RVColumn.values().length;
	}

	@Override
	public String getColumnName(int columnIndex) {
		return byColumnIndex(columnIndex).getName();
	}

	@Override
	public Class<?> getColumnClass(int columnIndex) {
		return getCell(-1, columnIndex).getValue().getClass();
	}	

	@Override
	public int getRowCount() {
		return container.size();
	}
	
	/**
	 * Access cells by indices.
	 */
	private Cell getCell(int rowIndex, int columnIndex) {
		// -1 means information about the columns/header
		if (rowIndex == -1)
			return dummy.getByName(byColumnIndex(columnIndex));
		else
			return container.get(rowIndex).getByName(byColumnIndex(columnIndex));
	}

	@Override
	public Object getValueAt(int rowIndex, int columnIndex) {
		return getCell(rowIndex, columnIndex).getValue();
	}

	@Override
	public ConverterContext getConverterContextAt(int rowIndex, int columnIndex) {
		return getCell(rowIndex, columnIndex).getConverterContext();
	}

	@Override
	public EditorContext getEditorContextAt(int rowIndex, int columnIndex) {
		return getCell(rowIndex, columnIndex).getEditorContext();
	}

	@Override
	public Class<?> getCellClassAt(int rowIndex, int columnIndex) {
		return getCell(rowIndex, columnIndex).getValue().getClass();
	}

	@Override
	public boolean isCellEditable(int rowIndex, int columnIndex) {
		return getCell(rowIndex, columnIndex).isEditable();
	}

	@Override
	public void setValueAt(Object aValue, int rowIndex, int columnIndex) {
		if (isCellEditable(rowIndex, columnIndex)) {
			getCell(rowIndex, columnIndex).setValue(aValue);
		}
	}

	@Override
	public CellStyle getCellStyleAt(int rowIndex, int columnIndex) {
		
		// align numbers at the left
		if (Number.class.isAssignableFrom(getCellClassAt(rowIndex, columnIndex))) {
			
			CellStyle style = new CellStyle();
			style.setHorizontalAlignment(SwingConstants.LEFT);
			return style;
		} else {
		
			return null;
		}
	}

	@Override
	public boolean isCellStyleOn() {
		return true;
	}
}
