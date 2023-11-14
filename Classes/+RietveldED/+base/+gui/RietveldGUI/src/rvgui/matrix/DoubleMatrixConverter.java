package rvgui.matrix;

import com.jidesoft.converter.*;

/**
 * A MATLAB-like converter for DoubleMatrix-instances.
 * @author martin
 */
public class DoubleMatrixConverter implements ObjectConverter {

	@Override
	public String toString(Object o, ConverterContext cc) {

		// use default Double-converter
		if (o instanceof DoubleMatrix) {
			return ((DoubleMatrix) o).toString(
					ObjectConverterManager.getConverter(Double.class));
		} else {
			return "";
		}
	}

	@Override
	public boolean supportToString(Object o, ConverterContext cc) {
		return (o instanceof DoubleMatrix);
	}

	@Override
	public Object fromString(String string, ConverterContext cc) {
		
		// default Double-converter
		ObjectConverter dc = ObjectConverterManager.getConverter(Double.class);

		int rowCnt = 1;
		int columnCnt = 0;

		// count rows
		for (int i = 0; i < string.length(); i++) {

			if (string.charAt(i) == ';') {
				rowCnt++;
			}
		}

		// seperate the entries
		String[] entries = string.split(",|;");

		// compute column count
		columnCnt = entries.length / rowCnt;

		DoubleMatrix m = new DoubleMatrix(rowCnt, columnCnt);
		// fill the matrix
		for (int i = 0; i < entries.length; i++) {

			m.set((Double)dc.fromString(entries[i].trim(), null), 
					i / columnCnt, i % columnCnt);
		}

		return m;
	}

	@Override
	public boolean supportFromString(String string, ConverterContext cc) {
		return true;
	}
}
