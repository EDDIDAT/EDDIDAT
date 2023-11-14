package rvgui.param.cell;

import rvgui.matrix.DoubleMatrix;

/**
 * Represents the upper constraint. The concrete implementation of this class
 * depends on whether the parameter is constant or not.
 * @author hsu
 */
public abstract class RVCellUpperConstraint extends DefaultCell<DoubleMatrix> {

	public RVCellUpperConstraint() {
	
		setValue(new DoubleMatrix(new Double[]{}));
	}
}