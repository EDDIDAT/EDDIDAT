package rvgui.param.cell;

import com.jidesoft.grid.BooleanCheckBoxCellEditor;
import com.jidesoft.grid.EditorContext;

/**
 * Specifies whether the parameter is refinable or not. This cell will only be
 * editable if we have a fit parameter.
 * @author hsu
 */
public abstract class RVCellRefinable extends DefaultCell<Boolean> {

	public RVCellRefinable() {
		
		setValue(false);
	}

	@Override
	public EditorContext getEditorContext() {
		return BooleanCheckBoxCellEditor.CONTEXT;
	}
}
