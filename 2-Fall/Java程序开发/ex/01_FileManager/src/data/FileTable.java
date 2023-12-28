package data;

import java.io.File;
import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.Vector;

import javax.swing.JTable;
import javax.swing.ListSelectionModel;
import javax.swing.table.DefaultTableModel;

/**
 * 文件罗列表
 * 
 * @author Maxpicca
 *
 */
public class FileTable extends JTable {
	private File currFile;

	public FileTable(File currFile) {
//    	table的网格线
		setShowGrid(false);
//      TODO 多选功能实现
//      setSelectionMode(ListSelectionModel.MULTIPLE_INTERVAL_SELECTION);
		setSelectionMode(ListSelectionModel.SINGLE_INTERVAL_SELECTION);
//		TODO 想设置系统图标
//		setDefaultRenderer(getColumnClass(-1), new MyTableCellRenderer());
		updateTable(currFile);
	}

	public void updateTable(File dir) {
		if (dir.isFile()) {
			return;
		}
		this.currFile = dir;
		Vector<String> columnNames = new Vector<String>(4);
		columnNames.add("文件名");
		columnNames.add("文件类型");
		columnNames.add("文件大小");
		columnNames.add("修改时间");
		Vector<Vector<String>> data = new Vector<Vector<String>>();
		for (File file : dir.listFiles()) {
			Vector<String> temp = new Vector<String>();
			temp.add(file.getName());
			if (file.isDirectory()) {
				temp.add("文件夹");
			} else {
				temp.add("文件");
			}
			String size = "";
			if (file.isFile()) {
				size = (int) Math.ceil(file.length() / 1024) + "KB";
			}
			temp.add(size);
			SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
			temp.add(sdf.format(new Date(file.lastModified())));
			data.add(temp);
		}
		DefaultTableModel fTableModel = new DefaultTableModel(data, columnNames) {
			@Override
			public boolean isCellEditable(int row, int column) {
//				设置为不可编辑
				return false;
			}
		};
		setModel(fTableModel);
	}

	public File getSelectedFile() {
//		TODO Table的多选功能
//		int[] index = getSelectedRows(); 
		int row = getSelectedRow();
		String fileName = (String) getValueAt(row, 0);
		File selectedFile = new File(currFile.getPath() + File.separator + fileName);
		return selectedFile;
	}

//	class MyTableCellRenderer extends DefaultTableCellRenderer {
//		
//		@Override
//		public Component getTableCellRendererComponent(JTable table, Object value,
//                boolean isSelected, boolean hasFocus, int row, int column) {
//			File file = new File(currFile+File.separator+value);
//			Icon ico = FileIconHelper.getIcon(file);
//	        setIcon(ico);
//			return this;
//		}
//	}

}
