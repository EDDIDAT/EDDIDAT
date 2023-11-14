package rvgui;

import com.jidesoft.plaf.*;
import java.util.ArrayList;
import javax.swing.*;
import rvgui.matrix.DoubleMatrix;
import rvgui.matrix.DoubleMatrixTableModel;
import rvgui.matrix.MatrixEditorComboBox;
import rvgui.param.RVConstantParameter;
import rvgui.param.RVFitParameter;
import rvgui.param.RVParameter;
import rvgui.param.RVParameterContainer;
import rvgui.table.RVDataModel;
import rvgui.table.RVTable;
import rvgui.util.IndexVector;

/**
 *
 * @author hsu
 */
public class RietveldGUI extends JFrame {

	/**
	 * @param args the command line arguments
	 */
	public static void main(String[] args) {
				
		SwingUtilities.invokeLater(new Runnable() {
			@Override
            public void run() {
                LookAndFeelFactory.installDefaultLookAndFeelAndExtension();
				RietveldGUI rietveldGUI = new RietveldGUI();
				rietveldGUI.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            }
        });
	}
	
	public void createRVTable() {
		
		ArrayList<RVParameter> list = new ArrayList<RVParameter>();
		
		RVParameter p1 = new RVConstantParameter();
		p1.getCategory().setValue("Test");
		RVParameter p2 = new RVFitParameter();
		p1.getSpecIndex().setValue(new IndexVector(new int[]{1, 2, 3}));
		p2.getSpecIndex().setValue(new IndexVector(new int[]{1, 2, 3}));
		list.add(p1);
		list.add(p2);
		
		RVTable table = new RVTable(new RVDataModel(new RVParameterContainer(list)));
		table.initComponents();
		this.add(table);
		this.setBounds(100, 100, 800, 800);
		this.setVisible(true);
	}
	
	public void testMatrixEditor() {
	    
	    DoubleMatrix m = new DoubleMatrix(2, 2);
	    m.set(1.0, 1, 1);
    
//	    this.getContentPane().add(new MatrixEditorPanel(m));
	    this.getContentPane().add(new MatrixEditorComboBox(new DoubleMatrixTableModel()));
	    
	    this.setBounds(100, 100, 800, 800);
	    this.setVisible(true);
	
	}
	
	public RietveldGUI() {
	    
//	    MatrixConverter c = new MatrixConverter(true);
//	    
//	    System.out.println(c.fromString("[2, 2 , 5; 3, 4, -1 ]", 
//		    new ConverterContext("MatrixConverter")));
	    
		createRVTable();
	}
}
