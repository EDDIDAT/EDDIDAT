package rvgui.matrix;

import com.jidesoft.converter.ConverterContext;
import com.jidesoft.converter.ObjectConverter;
import com.jidesoft.grid.DoubleCellEditor;
import com.jidesoft.grid.EditorContext;

/**
 * The default implementation for a DoubleMatrix.
 * @author martin
 */
public final class DoubleMatrixTableModel extends MatrixTableModel<Double> {

	/**
	 * Init a new model with a 1x1 NaN-matrix.
	 */
	public DoubleMatrixTableModel() {

		super(1, 1);
		setMatrix(new DoubleMatrix(Double.NaN));
	}

	@Override
	public Matrix<Double> getMatrix() {

		// read out the entries of the DefaultTableModel an fill it into the matrix
		DoubleMatrix matrix = new DoubleMatrix(this.getRowCount(), this.getColumnCount());

		for (int i = 0; i < matrix.getRowCnt(); i++) {
			for (int j = 0; j < matrix.getColumnCnt(); j++) {
				matrix.set((Double) this.getValueAt(i, j), i, j);
			}
		}

		return matrix;
	}
	
	@Override
	public void setMatrix(Matrix<Double> matrix) {
		
		// reset the model
		setRowCount(matrix.getRowCnt());
		setColumnCount(matrix.getColumnCnt());
		// fill in the matrix entries
		for (int i = 0; i < matrix.getRowCnt(); i++) {
			for (int j = 0; j < matrix.getColumnCnt(); j++) {
				this.setValueAt(matrix.get(i, j), i, j);
			}
		}
	}

	@Override
	public ConverterContext getConverterContextAt(int i, int i1) {
		return new ConverterContext("DoubleMatrixEntry");
	}

	@Override
	public EditorContext getEditorContextAt(int i, int i1) {
		return new DoubleCellEditor().getEditorContext();
	}

	@Override
	public Class<?> getCellClassAt(int i, int i1) {
		return Double.class;
	}

	@Override
	public void reset(int rowCnt, int columnCnt) {
		setMatrix(new DoubleMatrix(rowCnt, columnCnt));
	}

	@Override
	public ObjectConverter getDefaultConverter() {
		return new DoubleMatrixConverter();
	}
}
