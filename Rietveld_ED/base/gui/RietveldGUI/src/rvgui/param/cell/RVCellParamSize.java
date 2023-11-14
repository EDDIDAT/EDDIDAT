package rvgui.param.cell;

import rvgui.util.IndexVector;

/**
 * Represents the parameter's dimensions.
 * @author hsu
 */
public class RVCellParamSize extends DefaultCell<IndexVector> {

	public RVCellParamSize() {
		
		setValue(new IndexVector(new int[]{-1, -1}));
	}
	
	@Override
	public boolean isEditable() {
		return false;
	}
}
