package rvgui.param;

import java.io.Serializable;
import rvgui.param.cell.*;

/**
 * This class represents a rietveld-parameter. All properties are inherited by
 * Cell. They can be access directly by getters or by name/enum.
 * @author hsu
 */
public abstract class RVParameter implements Serializable {
	
	protected RVCellName name;
	protected RVCellPhaseIndex phaseIndex;
	protected RVCellSpecIndex specIndex;
	protected RVCellCategory category;
	protected RVCellConstant constant;
	
	protected RVCellRefinable refinable;
	protected RVCellParamSize paramSize;
	protected RVCellValue value;
	protected RVCellLowerConstraint lowerConstraint;
	protected RVCellUpperConstraint upperConstraint;
	
	/**
	 * Returns the cell by its column enum.
	 * @param col
	 * @return 
	 */
	public Cell getByName(RVColumn col) {
		
		switch (col) {
			
			case NAME: return getName();
			case PHASE_INDEX: return getPhaseIndex();
			case SPEC_INDEX: return getSpecIndex();
			case CATEGORY: return getCategory();
			case CONSTANT: return getConstant();
			case REFINABLE: return getRefinable();
			case PARAM_SIZE: return getParamSize();
			case VALUE: return getValue();
			case LOWER_CONSTRAINT: return getLowerConstraint();
			case UPPER_CONSTRAINT: return getUpperConstraint();
			default: throw new IllegalArgumentException("Column was not found!");
		}
	}
	
	protected abstract void init();
	
	/**
	 * Creates a deep copy of this parameter.
	 * @return 
	 */
	public abstract RVParameter copy();

	public RVCellCategory getCategory() {
		return category;
	}

	public RVCellConstant getConstant() {
		return constant;
	}

	public RVCellLowerConstraint getLowerConstraint() {
		return lowerConstraint;
	}

	public RVCellName getName() {
		return name;
	}

	public RVCellPhaseIndex getPhaseIndex() {
		return phaseIndex;
	}

	public RVCellRefinable getRefinable() {
		return refinable;
	}

	public RVCellSpecIndex getSpecIndex() {
		return specIndex;
	}

	public RVCellUpperConstraint getUpperConstraint() {
		return upperConstraint;
	}

	public RVCellValue getValue() {
		return value;
	}

	public RVCellParamSize getParamSize() {
		return paramSize;
	}
}
