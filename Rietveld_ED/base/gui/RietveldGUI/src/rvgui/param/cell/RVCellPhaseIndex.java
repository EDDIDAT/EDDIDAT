package rvgui.param.cell;

import com.jidesoft.converter.ConverterContext;

/**
 * Phase-index of the parameter.
 * @author hsu
 */
public class RVCellPhaseIndex extends DefaultCell<Integer> {

	public RVCellPhaseIndex() {
		
		setValue(0);
	}

	@Override
	public boolean isEditable() {
		return false;
	}

	@Override
	public ConverterContext getConverterContext() {
		
		return new ConverterContext("PhaseIndex");
	}
}
