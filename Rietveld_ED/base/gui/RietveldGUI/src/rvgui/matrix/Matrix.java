package rvgui.matrix;

import java.io.Serializable;

/**
 * A simple matrix interface.
 * @author martin
 */
public interface Matrix<T> extends Serializable {

	T get(int i, int j);

	int getColumnCnt();

	int getElementCnt();

	int getRowCnt();

	void set(T v, int i, int j);
	
	T[][] toArray();
}
