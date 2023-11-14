package rvgui.param;

import rvgui.matrix.DoubleMatrix;
import rvgui.util.IndexVector;

/**
 * This enumeration is used to specify the model column generally with its
 * classes, names and indices.
 * @author hsu
 */
public enum RVColumn {
	
	NAME(0, "Name", String.class),
	PHASE_INDEX(1, "Phase index", Integer.class),
	SPEC_INDEX(2, "Spec index", IndexVector.class),
	CATEGORY(3, "Category", String.class),
	CONSTANT(4, "Constant", Boolean.class),
	REFINABLE(5, "Refinable", Boolean.class),
	PARAM_SIZE(6, "Parameter size", IndexVector.class),
	VALUE(7, "Value", DoubleMatrix.class),
	LOWER_CONSTRAINT(8, "Lower constraint", DoubleMatrix.class),
	UPPER_CONSTRAINT(9, "Upper constraint", DoubleMatrix.class);
	
	private final int defaultColumnIndex;
	private final String name;
	private final Class<?> valueClass;

	/**
	 * Returns the default column index.
	 * @return 
	 */
	public int getColumnIndex() {
		return defaultColumnIndex;
	}

	/**
	 * Returns the display name of the column.
	 * @return 
	 */
	public String getName() {
		return name;
	}

	/**
	 * General column class.
	 * @return 
	 */
	public Class<?> getValueClass() {
		return valueClass;
	}

	private RVColumn(int defaultColumnIndex, String name, Class<?> valueClass) {
		this.defaultColumnIndex = defaultColumnIndex;
		this.name = name;
		this.valueClass = valueClass;
	}
	
	/**
	 * Finds the enumeration by its column-index.
	 * @param ind
	 * @return 
	 */
	public static RVColumn byColumnIndex(int ind) {
		
		for (int i = 0; i < values().length; i++)
			if (values()[i].getColumnIndex() == ind)
				return values()[i];
		
		throw new IllegalArgumentException("Column index is illegal!");
	}
}
