package rvgui.matrix;

import com.jidesoft.combobox.PopupPanel;
import com.jidesoft.grid.*;
import com.jidesoft.spinner.*;
import com.jidesoft.swing.JideLabel;
import java.awt.*;
import javax.swing.event.*;
import javax.swing.*;

/**
 * A popup-panel which is used to edit a matrix table model comfortably.
 * @author hsu
 */
public class MatrixEditorPanel extends PopupPanel {

	private PointSpinner matrixSizeSpinner;
	private ContextSensitiveTable matrixTable;
	private MatrixTableModel matrixTableModel;
	private Point matrixSize;

	/**
	 * The only way is to init with a table model.
	 * @param matrixTableModel 
	 */
	public MatrixEditorPanel(MatrixTableModel matrixTableModel) {

		this.matrixTableModel = matrixTableModel;
		
		initComponents();
	}

	private void initComponents() {

		this.setLayout(new BorderLayout());

		setResizable(true);

		// create the table
		matrixTable = new SortableTable(matrixTableModel);
		matrixTable.setColumnAutoResizable(true);
		// selection
		matrixTable.setNonContiguousCellSelection(true);
		matrixTable.setRowSelectionAllowed(true);
		matrixTable.setColumnSelectionAllowed(true);
		matrixTable.getSelectionModel().setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
		matrixTable.getColumnModel().getSelectionModel().setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
		// misc properties
		matrixTable.setTableHeader(null);
		matrixTable.setAutoSelectTextWhenStartsEditing(true);
		add(new JScrollPane(matrixTable), BorderLayout.CENTER);
		
		// set the matrix size
		this.matrixSize = new Point(matrixTableModel.getRowCount(), 
				matrixTableModel.getColumnCount());

		// control panel
		JPanel tmpPanel = new JPanel(new BorderLayout());

		JideLabel lblMatrixSize = new JideLabel();
		lblMatrixSize.setText("Matrix size:");
		tmpPanel.add(lblMatrixSize, BorderLayout.WEST);

		// size spinner
		matrixSizeSpinner = new PointSpinner();
		matrixSizeSpinner.addChangeListener(new SizeChangedAction());
		matrixSizeSpinner.setValue(getMatrixSize());
		tmpPanel.add(matrixSizeSpinner, BorderLayout.CENTER);
		
		add(tmpPanel, BorderLayout.SOUTH);
	}

	/**
	 * Set the matrix size.
	 * @param matrixSize 
	 */
	private void setMatrixSize(Point matrixSize) {

		// when the size changed the matrix will be reseted and all values
		// will be refreshed
		if (!matrixSize.equals(getMatrixSize())) {

			this.matrixSize = new Point(matrixSize);
			matrixTableModel.reset(getMatrixSize().x, getMatrixSize().y);
			matrixSizeSpinner.setValue(matrixSize);
		}
	}

	private Point getMatrixSize() {

		return new Point(matrixSize);
	}

	/**
	 * Returns the underlying matrix of the model.
	 * @return 
	 */
	public Matrix getMatrix() {

		return matrixTableModel.getMatrix();
	}

	/**
	 * Inserts the matrix into the table model.
	 * @param matrix 
	 */
	public void setMatrix(Matrix matrix) {

		setMatrixSize(new Point(matrix.getRowCnt(), matrix.getColumnCnt()));
		matrixTableModel.setMatrix(matrix);
	}

	/**
	 * Listener for the size spinner.
	 */
	private class SizeChangedAction implements ChangeListener {

		@Override
		public void stateChanged(ChangeEvent ce) {

			if (ce.getSource() instanceof PointSpinner) {
				PointSpinner ps = (PointSpinner) ce.getSource();
				setMatrixSize((Point) ps.getValue());
			}
		}
	}
}
