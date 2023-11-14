package rvgui.param.cell;

/**
 * Name of the parameter.
 * @author hsu
 */
public class RVCellName extends DefaultCell<String> {

	public RVCellName() {
		
		setValue("Untitled");
	}

	@Override
	public boolean isEditable() {
		return false;
	}
}
