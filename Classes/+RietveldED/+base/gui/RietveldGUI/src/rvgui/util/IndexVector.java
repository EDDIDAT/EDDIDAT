package rvgui.util;

import java.io.Serializable;
import java.util.Arrays;

/**
 * A simple class, that represents an index vector. Internally an integer-array 
 * is used. Comparator and toString are included.
 * @author hsu
 */
public class IndexVector implements Comparable<IndexVector>, Serializable {

	private int[] index;

	public IndexVector(int[] index) {

		if (index == null) {
			this.index = new int[]{};
		} else {
			this.index = index.clone();
		}
	}

	public IndexVector(Integer[] index) {

		if (index == null) {
			this.index = new int[]{};
		} else {
			this.index = new int[index.length];
			for (int i = 0; i < index.length; i++) {
				this.index[i] = index[i];
			}
		}
	}

	/**
	 * Converts the index vector into an array.
	 * @return 
	 */
	public int[] toArray() {

		return index.clone();
	}

	@Override
	public boolean equals(Object obj) {

		if (obj instanceof IndexVector) {
			return (this.compareTo((IndexVector) obj) == 0);
		} else {
			return false;
		}
	}

	@Override
	public int hashCode() {
		int hash = 3;
		hash = 67 * hash + Arrays.hashCode(this.index);
		return hash;
	}

	@Override
	public String toString() {

		if (index.length == 0) {
			return "";
		}

		StringBuilder sb = new StringBuilder();

		for (int i = 0; i < index.length - 1; i++) {

			// if the current index is free or unknown, we use -1 displayed by ?
			if (index[i] == -1) {
				sb.append("?");
			} else {
				sb.append(index[i]);
			}
			// comma-separator
			sb.append(", ");
		}
		if (index[index.length - 1] == -1) {
			sb.append("?");
		} else {
			sb.append(index[index.length - 1]);
		}

		return sb.toString();
	}

	@Override
	public int compareTo(IndexVector ind2) {

		// the vectors are compared lexeographically from left to right
		if (index.length < ind2.index.length) {
			return -1;
		} else if (index.length > ind2.index.length) {
			return 1;
		} else {
			for (int i = 0; i < index.length; i++) {
				if (index[i] < ind2.index[i]) {
					return -1;
				} else if (index[i] > ind2.index[i]) {
					return 1;
				}
			}
			return 0;
		}
	}
}
