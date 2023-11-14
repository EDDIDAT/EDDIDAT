package rvgui.param;

import rvgui.param.cell.*;

/**
 * Implementation of a fit parameter. Refers to MATLAB's FitParameter.
 * @author hsu
 */
public final class RVFitParameter extends RVParameter {
	
	public RVFitParameter() {
		
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
				return false;
			}
		};
		
		this.refinable = new RVCellRefinable() {
			@Override
			public boolean isEditable() {return true;}
		};
		this.paramSize = new RVCellParamSize();
		this.value = new RVCellValue();
		this.lowerConstraint = new RVCellLowerConstraint() {
			@Override
			public boolean isEditable() {return true;}
		};
		this.upperConstraint = new RVCellUpperConstraint() {
			@Override
			public boolean isEditable() {return true;}
		};
	}

	@Override
	public RVParameter copy() {
		
		RVFitParameter param = new RVFitParameter();
		param.init();
		param.getName().setValue(getName().getValue());
		param.getPhaseIndex().setValue(getPhaseIndex().getValue());
		param.getSpecIndex().setValue(getSpecIndex().getValue());
		param.getCategory().setValue(getCategory().getValue());
		param.getRefinable().setValue(getRefinable().getValue());
		param.getParamSize().setValue(getParamSize().getValue());
		param.getValue().setValue(getValue().getValue());
		param.getLowerConstraint().setValue(getLowerConstraint().getValue());
		param.getUpperConstraint().setValue(getUpperConstraint().getValue());
		
		return param;
	}
}
