package rvgui.param.cell;

import rvgui.matrix.DoubleMatrix;

/**
 * The value cell. By default it contains a 1x1 NaN-matrix, which means that
 * the parameters won't be considered during import/export in MATLAB.
 * @author hsu
 */
public class RVCellValue extends DefaultCell<DoubleMatrix> {

	public RVCellValue() {
		
		setValue(new DoubleMatrix(Double.NaN));
	}

	@Override
	public boolean isEditable() {
		return true;
	}	
}
