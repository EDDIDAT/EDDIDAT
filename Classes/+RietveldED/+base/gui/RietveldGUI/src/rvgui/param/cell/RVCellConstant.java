package rvgui.param.cell;

import com.jidesoft.comparator.ComparatorContext;
import com.jidesoft.converter.ConverterContext;
import com.jidesoft.grid.*;

/**
 * Constant column cell, that means it specifies whether the parameter is
 * constant or not. A check box is used for rendering.
 * @author hsu
 */
public abstract class RVCellConstant implements Cell<Boolean> {
	
	@Override
	public ConverterContext getConverterContext() {
		return ConverterContext.DEFAULT_CONTEXT;
	}

	@Override
	public ComparatorContext getComparatorContext() {
		return ComparatorContext.DEFAULT_CONTEXT;
	}
	
	@Override
	public EditorContext getEditorContext() {
		return BooleanCheckBoxCellEditor.CONTEXT;
	}

	@Override
	public boolean isEditable() {
		return false;
	}

	@Override
	public void setValue(Boolean value) {}
}
