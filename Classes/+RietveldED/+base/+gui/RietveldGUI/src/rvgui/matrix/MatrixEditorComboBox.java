package rvgui.matrix;

import com.jidesoft.combobox.*;
import java.awt.event.*;
import javax.swing.*;

/**
 * A ComboBox which uses MatrixEditorPanel to configure a matrix.
 * @author martin
 */
public class MatrixEditorComboBox extends AbstractComboBox implements ItemListener {

	private MatrixEditorPanel panel;
	
	private boolean actionOnEnter;

	/**
	 * Init with a matrix model.
	 * @param matrixTableModel 
	 */
	public MatrixEditorComboBox(MatrixTableModel matrixTableModel) {

		this(matrixTableModel, false);
	}
	
	/**
	 * Init with a matrix model.
	 * @param matrixTableModel
	 * @param actionOnEnter if true, an ActionEvent is fired when you press Shift-Enter
	 */
	public MatrixEditorComboBox(MatrixTableModel matrixTableModel, 
			boolean actionOnEnter) {
		
		super();
		
		this.actionOnEnter = actionOnEnter;

		// dialog, no popup
		setPopupType(DIALOG);

		// initialization
		initComponent();

		panel = new MatrixEditorPanel(matrixTableModel);
		setType(matrixTableModel.getMatrix().getClass());
		setConverter(matrixTableModel.getDefaultConverter());

		addItemListener(this);

		setSelectedItem(matrixTableModel.getMatrix());
	}

	@Override
	public EditorComponent createEditorComponent() {

		// a new text field component
		return new DefaultTextFieldEditorComponent(DoubleMatrix.class) {

			@Override
			protected void registerKeys(JComponent jc) {
				
				super.registerKeys(jc);
				
				// fire ActionEvent when Shift-Enter is pressed
				if (actionOnEnter) {
					
					jc.getInputMap().put(KeyStroke.getKeyStroke(KeyEvent.VK_ENTER, KeyEvent.SHIFT_MASK), 
							"action-on-enter");
					jc.getActionMap().put("action-on-enter", new AbstractAction() {

						@Override
						public void actionPerformed(ActionEvent e) {
							MatrixEditorComboBox.this.fireActionEvent();
						}
					});
				}
			}
		};
	}

	@Override
	public PopupPanel createPopupComponent() {

		// refresh panel's value (important)
		panel.setMatrix((Matrix) getSelectedItem());
		return panel;
	}

	@Override
	public void itemStateChanged(ItemEvent ie) {

		// refresh also panel
		panel.setMatrix((Matrix) getSelectedItem());
	}

	@Override
	protected Action getDialogOKAction() {
		return new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent ae) {
				setSelectedItem(panel.getMatrix());
				// hide dialog
				_dialog.setVisible(false);
			}
		};
	}

	@Override
	protected Action getDialogCancelAction() {
		return new AbstractAction() {

			@Override
			public void actionPerformed(ActionEvent ae) {
				// hide dialog
				_dialog.setVisible(false);
			}
		};
	}
}
