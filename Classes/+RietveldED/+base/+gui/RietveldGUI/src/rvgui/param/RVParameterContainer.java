package rvgui.param;

import java.io.*;
import java.util.*;

/**
 * A simple container for rietveld-parameters. This object can be saved to and
 * loaded from *.rvp files.
 * @author hsu
 */
public class RVParameterContainer implements Serializable {
	
	/**
	 * internally the parameters are managed in an ArrayList
	 */
	private ArrayList<RVParameter> parameterList;
	
	/**
	 * The only way to construct is to assign a List of rietveld-parameters.
	 * @param parameterList 
	 */
	public RVParameterContainer(List<RVParameter> parameterList) {
		this.parameterList = new ArrayList<RVParameter>(parameterList);
	}
	
	/**
	 * Tries to load a container from a rvp file.
	 * @param f
	 * @return 
	 */
	public static RVParameterContainer loadFromFile(File f) {

		RVParameterContainer container = null;
		
		try {
			FileInputStream fs = new FileInputStream(f);
			ObjectInputStream os = new ObjectInputStream(fs);

			container = (RVParameterContainer) os.readObject();
			os.close();
		} catch (ClassNotFoundException ex) {
			ex.printStackTrace();
		} catch (IOException ex) {
			ex.printStackTrace();
		}
		
		return container;
	}

	/**
	 * Saves this container to a rvp-file using ObjectOutputStream.
	 * @param f 
	 */
	public void saveToFile(File f) {

		try {

			FileOutputStream fs = new FileOutputStream(f);
			ObjectOutputStream os = new ObjectOutputStream(fs);

			os.writeObject(this);
			os.close();
		} catch (IOException ex) {
			ex.printStackTrace();
		}
	}

	/**
	 * Returns the length of the list.
	 * @return 
	 */
	public int size() {
		return parameterList.size();
	}

	/**
	 * Access on the entries.
	 * @param index
	 * @return 
	 */
	public RVParameter get(int index) {
		return parameterList.get(index);
	}
	
	/**
	 * Creates a deep copy of this container.
	 * @return 
	 */
	public RVParameterContainer copy() {
		
		ArrayList<RVParameter> list = new ArrayList<RVParameter>();
		
		for (int i = 0; i < size(); i++) {
			list.add(get(i).copy());
		}
		
		return new RVParameterContainer(list);
	}
}
