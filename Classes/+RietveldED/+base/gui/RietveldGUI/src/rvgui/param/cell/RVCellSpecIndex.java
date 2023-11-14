package rvgui.param.cell;

import rvgui.util.IndexVector;

/**
 * Spectrum-index of the parameter.
 * @author hsu
 */
public class RVCellSpecIndex extends DefaultCell<IndexVector> {

	public RVCellSpecIndex() {
		
		setValue(new IndexVector(new int[]{}));
	}

	@Override
	public boolean isEditable() {
		return false;
	}
}
