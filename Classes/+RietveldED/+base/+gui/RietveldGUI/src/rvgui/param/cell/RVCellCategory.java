package rvgui.param.cell;

/**
 * Category column cell.
 * @author hsu
 */
public class RVCellCategory extends DefaultCell<String> {

	public RVCellCategory() {
		
		setValue("No category");
	}

	@Override
	public boolean isEditable() {
		return false;
	}
}
