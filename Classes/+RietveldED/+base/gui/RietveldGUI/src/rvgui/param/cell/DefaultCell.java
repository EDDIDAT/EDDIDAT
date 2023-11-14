package rvgui.param.cell;

import com.jidesoft.comparator.ComparatorContext;
import com.jidesoft.converter.ConverterContext;
import com.jidesoft.grid.EditorContext;

/**
 * A default implementation of a cell, using default contexts and setter/getter.
 * You only have to implement isEditable.
 * @author hsu
 */
public abstract class DefaultCell<T> implements Cell<T> {
	
	private T value;

	@Override
	public ComparatorContext getComparatorContext() {
		return ComparatorContext.DEFAULT_CONTEXT;
	}

	@Override
	public ConverterContext getConverterContext() {
		return ConverterContext.DEFAULT_CONTEXT;
	}

	@Override
	public EditorContext getEditorContext() {
		return EditorContext.DEFAULT_CONTEXT;
	}
	
	@Override
	public T getValue() {
		return this.value;
	}

	@Override
	public void setValue(T value) {
		this.value = value;
	}
}
