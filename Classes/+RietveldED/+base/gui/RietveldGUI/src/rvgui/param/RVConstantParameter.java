package rvgui.param;

import rvgui.param.cell.*;

/**
 * Implementation of a constant parameter. Refers to MATLAB's FunctionParameter.
 * @author hsu
 */
public final class RVConstantParameter extends RVParameter {

	public RVConstantParameter() {
		
		super();
		init();
	}
	
	@Override
	public void init() {
		
		// some cells are customized.
		
		this.name = new RVCellName();
		this.phaseIndex = new RVCellPhaseIndex();
		this.specIndex = new RVCellSpecIndex();
		this.category = new RVCellCategory();
		this.constant = new RVCellConstant() {

			@Override
			public Boolean getValue() {
				return true;
			}
		};
		
		this.refinable = new RVCellRefinable() {
			@Override
			public boolean isEditable() {return false;}
		};
		this.paramSize = new RVCellParamSize();
		this.value = new RVCellValue();
		this.lowerConstraint = new RVCellLowerConstraint() {
			@Override
			public boolean isEditable() {return false;}
		};
		this.upperConstraint = new RVCellUpperConstraint() {
			@Override
			public boolean isEditable() {return false;}
		};
	}

	@Override
	public RVParameter copy() {
		
		RVConstantParameter param = new RVConstantParameter();
		param.init();
		param.getName().setValue(getName().getValue());
		param.getPhaseIndex().setValue(getPhaseIndex().getValue());
		param.getSpecIndex().setValue(getSpecIndex().getValue());
		param.getCategory().setValue(getCategory().getValue());
		param.getParamSize().setValue(getParamSize().getValue());
		param.getValue().setValue(getValue().getValue());
		
		return param;
	}
}
