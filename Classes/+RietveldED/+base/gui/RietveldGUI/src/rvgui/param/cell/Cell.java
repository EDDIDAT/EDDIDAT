package rvgui.param.cell;

import com.jidesoft.comparator.ComparatorContext;
import com.jidesoft.converter.ConverterContext;
import com.jidesoft.grid.EditorContext;
import java.io.Serializable;

/**
 * This generic interface represents a cell in our RVDataModel.
 * @author hsu
 */
public interface Cell<T> extends Serializable {
	
	ConverterContext getConverterContext();
	EditorContext getEditorContext();
	ComparatorContext getComparatorContext();
	
	boolean isEditable();
	
	T getValue();
	void setValue(T value);
}
