package rvgui.param.cell;

import rvgui.matrix.DoubleMatrix;

/**
 * Represents the lower constraint. The concrete implementation of this class
 * depends on whether the parameter is constant or not.
 * @author hsu
 */
public abstract class RVCellLowerConstraint extends DefaultCell<DoubleMatrix> {
	
	public RVCellLowerConstraint() {
		
		setValue(new DoubleMatrix(new Double[]{}));
	}
}