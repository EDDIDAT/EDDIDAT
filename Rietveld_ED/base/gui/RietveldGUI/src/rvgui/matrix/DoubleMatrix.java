package rvgui.matrix;

import com.jidesoft.converter.*;

/**
 * The default implementation for a Double-Matrix.
 * @author hsu
 */
public final class DoubleMatrix implements Matrix<Double> {

	private Double[][] matrix;

	/**
	 * Create a new matrix filled with zeros
	 * @param i row count
	 * @param j column count
	 */
	public DoubleMatrix(int i, int j) {

		this.matrix = new Double[i][j];

		for (int ii = 0; ii < i; ii++) {
			for (int jj = 0; jj < j; jj++) {
				this.matrix[ii][jj] = 0.0;
			}
		}
	}

	/**
	 * Make a deep copy of matrix.
	 * @param matrix 
	 */
	public DoubleMatrix(DoubleMatrix matrix) {

		this(matrix.toArray());
	}

	public DoubleMatrix(Double[][] matrix) {

		this(matrix.length, matrix.length > 0 ? matrix[0].length : 0);

		for (int i = 0; i < getRowCnt(); i++) {
			for (int j = 0; j < getColumnCnt(); j++) {
				set(matrix[i][j], i, j);
			}
		}
	}

	/**
	 * Creates a (vec.length x 1)-matrix.
	 * @param vec 
	 */
	public DoubleMatrix(Double[] vec) {

		this(vec.length, 1);

		for (int i = 0; i < getRowCnt(); i++) {
			set(vec[i], i, 0);
		}
	}

	/**
	 * Creates a 1 x 1 matrix.
	 * @param v 
	 */
	public DoubleMatrix(Double v) {

		this(1, 1);

		set(v, 0, 0);
	}

	/**
	 * Creates an empty matrix.
	 */
	public DoubleMatrix() {

		this(0, 0);
	}

	@Override
	public int getRowCnt() {

		return matrix.length;
	}

	@Override
	public int getColumnCnt() {

		if (getRowCnt() > 0) {
			return matrix[0].length;
		} else {
			return 0;
		}
	}

	@Override
	public int getElementCnt() {

		return getRowCnt() * getColumnCnt();
	}

	@Override
	public void set(Double v, int i, int j) {

		matrix[i][j] = v;
	}

	@Override
	public Double get(int i, int j) {

		return matrix[i][j];
	}

	@Override
	public Double[][] toArray() {

		Double[][] arr = new Double[getRowCnt()][getColumnCnt()];

		for (int i = 0; i < getRowCnt(); i++) {
			for (int j = 0; j < getColumnCnt(); j++) {
				arr[i][j] = get(i, j);
			}
		}

		return arr;
	}

	@Override
	public String toString() {

		return toString(ObjectConverterManager.getConverter(Double.class));
	}

	/**
	 * The ObjectConverter dc is used to convert the double-entries of the 
	 * matrix. The matrix is converted in MATLAB-style, that means rows are 
	 * separated by ';' an columns by ','.
	 * @param dc
	 * @return 
	 */
	public String toString(ObjectConverter dc) {

		if (getRowCnt() == 0 || getColumnCnt() == 0) {
			return "";
		}

		StringBuilder sb = new StringBuilder();

		for (int i = 0; i < getRowCnt() - 1; i++) {
			for (int j = 0; j < getColumnCnt() - 1; j++) {
				sb.append(dc.toString(get(i, j), null));
				sb.append(", ");
			}
			sb.append(dc.toString(get(i, getColumnCnt() - 1), null));
			sb.append("; ");
		}
		for (int j = 0; j < getColumnCnt() - 1; j++) {
			sb.append(dc.toString(get(getRowCnt() - 1, j), null));
			sb.append(", ");
		}
		sb.append(dc.toString(get(getRowCnt() - 1, getColumnCnt() - 1), null));

		return sb.toString();
	}
}
