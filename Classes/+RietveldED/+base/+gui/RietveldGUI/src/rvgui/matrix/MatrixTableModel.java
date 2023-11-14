package rvgui.matrix;

import com.jidesoft.converter.*;
import com.jidesoft.grid.*;
import java.io.Serializable;
import javax.swing.table.DefaultTableModel;

/**
 * An abstract table model for a general matrix.
 * @author martin
 */
public abstract class MatrixTableModel<T> extends DefaultTableModel 
implements ContextSensitiveTableModel, Serializable {

	public MatrixTableModel(int rowCnt, int columnCnt) {
		super(rowCnt, columnCnt);
	}
	
	/**
	 * Get the underlying matrix.
	 */
	public abstract Matrix<T> getMatrix();
	
	/**
	 * Edit the table model with a new matrix.
	 * @param matrix 
	 */
	public abstract void setMatrix(Matrix<T> matrix);
	
	@Override
	public boolean isCellEditable(int row, int column) {
		
		return true;
	}
	
	/**
	 * Resets the underlying matrix with rowCnt x columnCnt.
	 * @param rowCnt
	 * @param columnCnt 
	 */
	public abstract void reset(int rowCnt, int columnCnt);
	
	/**
	 * Returns the default matrix-converter
	 */
	public abstract ObjectConverter getDefaultConverter();
}
