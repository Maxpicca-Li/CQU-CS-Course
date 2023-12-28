package control;

import java.io.File;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyAdapter;
import java.awt.event.KeyEvent;
import java.awt.event.MouseAdapter;
import java.awt.event.MouseEvent;
import java.io.IOException;

import javax.swing.JOptionPane;
import javax.swing.JTextField;

import data.FileTable;
import data.FileTree;
import helper.CodeHelper;
import helper.DoubleNameHelper;
import helper.NewHelper;
import helper.RemoveHelper;
import helper.ZipHelper;
import view.GUIFrame;

/**
 * 监听中心
 * 
 * @author Maxpicca
 * 
 */
public class GUIController {
	private static final int DOUBLE_CLICK = 2;
	private static final String ZIP_SUFFIX = ".zip";
	private static enum Choose {
		/**
		 * TreeChoosed 鼠标焦点在文件树上，TableChoosed 鼠标焦点在文件表上
		 */
		TreeChoosed, TableChoosed
	};

	private static Choose chooseModel;

	private File rootFile;
	private File binFile;
	private File currFile;

	private FileTree fileTree;
	private FileTable fileTable;
	private JTextField urlField;
	private GUIFrame guiFrame;
	private DoorKeeper doorKeeper;
	private CVEngineer myCVEngineer;

	public GUIController(GUIFrame myguiFrame) {
		this.fileTree = myguiFrame.getFileTree();
		this.fileTable = myguiFrame.getFileTable();
		this.urlField = myguiFrame.getUrlField();
		this.rootFile = myguiFrame.getRootFile();
		this.binFile = myguiFrame.getBinFile();
		this.currFile = rootFile;
		this.guiFrame = myguiFrame;

		doorKeeper = new DoorKeeper();
		myCVEngineer = new CVEngineer();

//		toolBar事件
		guiFrame.addBackListener(new BackListener());
		guiFrame.addGoListener(new GoListener());
		guiFrame.addUrlEnterListener(new UrlEnterListener());
//		filePopupMenu事件
		guiFrame.addCopyListener(new CopyListener());
		guiFrame.addEncodeListener(new EncodeListener());
		guiFrame.addDecodeListener(new DecodeListener());
		guiFrame.addRemoveListener(new RemoveListener());
		guiFrame.addZipListener(new ZipListener());
		guiFrame.addUnzipListener(new UnzipListener());
//		blankPopupMenu事件
		guiFrame.addPasteListener(new PasteListener());
		guiFrame.addRefreshListener(new RefreshListener());
		guiFrame.addNewdirListener(new NewdirListener());
		guiFrame.addNewFileListener(new NewfileListener());

//		界面监听
		guiFrame.addTreeOpenListener(new TreeOpenListener());
		guiFrame.addTablePaneListener(new TableClickListener());

	}

	/**
	 * Tree打开事件监听并更新界面
	 * 
	 * @author Maxpicca
	 */
	class TreeOpenListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			Object clickedObject = e.getSource();
//			判断是否选中Tree
			if (fileTree.equals(clickedObject)) {
				return;
			} else {
				fileTree.clearSelection();
			}
		}

		@Override
		public void mousePressed(MouseEvent e) {
			int selectedRow = fileTree.getRowForLocation(e.getX(), e.getY());
			if (selectedRow == -1) {
				fileTree.clearSelection();
				return;
			}
			if (e.getButton() == MouseEvent.BUTTON3) {
//				鼠标右击
				guiFrame.showFilePopupMenu(e);
				chooseModel = Choose.TreeChoosed;
			} else if (e.getClickCount() == DOUBLE_CLICK) {
				File selectedFile = fileTree.getSelectedFile();
				try {
					currFile = doorKeeper.openFile(currFile, selectedFile);
				} catch (IOException e1) {
					JOptionPane.showMessageDialog(null, selectedFile.getName() + "打开出错");
					e1.printStackTrace();
				}
				treeToRefresh(selectedFile);
			}
		}
	}

	/**
	 * Table点击事件监听并更新界面
	 */
	class TableClickListener extends MouseAdapter {
		@Override
		public void mouseClicked(MouseEvent e) {
			Object clickedObject = e.getSource();
//			判断选中的是TablePane还是FileTable
			if (fileTable.equals(clickedObject)) {
				return;
			} else {
				fileTable.clearSelection();
			}
		}

		@Override
		public void mousePressed(MouseEvent e) {
			if (e.getButton() == MouseEvent.BUTTON3) {
//				鼠标右击
				if (fileTable.getSelectedRow() != -1) {
					guiFrame.showFilePopupMenu(e);
					chooseModel = Choose.TableChoosed;
				} else {
					guiFrame.showBlankPopupMenu(e);
				}
			} else if (e.getButton() == MouseEvent.BUTTON1 && e.getClickCount() == DOUBLE_CLICK) {
//				鼠标双击
				if (fileTable.getSelectedRow() != -1) {
					File selectedFile = fileTable.getSelectedFile();
					try {
						currFile = doorKeeper.openFile(currFile, selectedFile);
					} catch (IOException e1) {
						JOptionPane.showMessageDialog(null, selectedFile.getName() + "打开出错");
						e1.printStackTrace();
					}
					treeToRefresh(currFile);
				}
			}
		}
	}

	/**
	 * 复制监听器
	 */
	class CopyListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			File seletedFile = fileChoose(e);
			myCVEngineer.copy(seletedFile);
		}
	}

	/**
	 * 粘贴监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class PasteListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			myCVEngineer.paste(currFile);
			allRefresh();
		}
	}

	/**
	 * 刷新监听器
	 * 
	 * @author Maxpicca
	 */
	class RefreshListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			allRefresh();
		}
	}

	/**
	 * 新建文件夹监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class NewdirListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			String dirName = JOptionPane.showInputDialog("请输入新建文件夹名称", "新建文件夹");
			if (dirName == null) {
				return;
			}
			NewHelper.newDir(dirName, currFile);
			allRefresh();
		}
	}

	/**
	 * 新建文件监听器
	 * 
	 * @author Maxpicca
	 */
	class NewfileListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			String fileName = JOptionPane.showInputDialog("请输入新建文件名称", "新建文件");
			if (fileName == null) {
				return;
			}
			NewHelper.newFileOpperation(fileName, currFile);
			allRefresh();
		}
	}

	/**
	 * 加密监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class EncodeListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			String s = JOptionPane.showInputDialog("请设置数字密码：");
			if (s == null) {
				return;
			}
			String regex = "^[0-9]+$";
			if (s == "") {
				JOptionPane.showMessageDialog(null, "您未输入密码");
				return;
			}
			if (!s.matches(regex)) {
				JOptionPane.showMessageDialog(null, "设置密码格式不对。");
				return;
			}
			int key = Integer.parseInt(s);
			File sourceFile = fileChoose(e);
			File dir = sourceFile.getParentFile();
			try {
				CodeHelper.encode(sourceFile, dir, key);
				// 可以调用RemoveHelper.itDelete达到真正的delete
				RemoveHelper.remove(sourceFile, binFile);
				currFile = dir;
				JOptionPane.showMessageDialog(null, sourceFile.getName() + "加密成功");
			} catch (IOException e1) {
				JOptionPane.showMessageDialog(null, "加密文件" + sourceFile.getName() + "出错");
				e1.printStackTrace();
			}
			allRefresh();
		}
	}

	/**
	 * 解密监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class DecodeListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			String s = JOptionPane.showInputDialog("请输入数字密码：");
			if (s == null) {
				return;
			}
			String regex = "^[0-9]+$";
			if (s == "") {
				JOptionPane.showMessageDialog(null, "您未输入密码");
				return;
			}
			if (!s.matches(regex)) {
				JOptionPane.showMessageDialog(null, "输入密码格式不对。");
				return;
			}
			int key = Integer.parseInt(s);
			File sourceFile = fileChoose(e);
			File dir = sourceFile.getParentFile();
			try {
				CodeHelper.decode(sourceFile, dir, key);
			} catch (IOException e1) {
				JOptionPane.showMessageDialog(null, "解密文件" + sourceFile.getName() + "出错");
				e1.printStackTrace();
			}
			allRefresh();
		}
	}

	/**
	 * 删除文件夹监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class RemoveListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			File sourceFile = fileChoose(e);
			if (rootFile.equals(sourceFile)) {
				Object[] options = { "确定", "取消" };
				int option = JOptionPane.showOptionDialog(null, "确定要删除根目录吗？", "Warning", JOptionPane.DEFAULT_OPTION,
						JOptionPane.WARNING_MESSAGE, null, options, options[1]);
				if (option == JOptionPane.CLOSED_OPTION || option == JOptionPane.NO_OPTION) {
					return;
				}
				System.exit(1);
			}
			try {
				if (!RemoveHelper.remove(sourceFile, binFile)) {
					JOptionPane.showMessageDialog(null, "文件移除失败");
				}
			} catch (IOException e1) {
				JOptionPane.showMessageDialog(null, "文件移除失败");
				e1.printStackTrace();
			}
			if (!currFile.exists()) {
				currFile = currFile.getParentFile();
			}
			allRefresh();
		}
	}

	/**
	 * 压缩监听器
	 * 
	 * @author Maxpicca
	 */
	class ZipListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			File sourceFile = fileChoose(e);
			String sourceFileName = sourceFile.getName();
			String prefix;
			if (sourceFile.isFile()) {
				prefix = sourceFileName.substring(0, sourceFileName.lastIndexOf('.'));
			} else {
				prefix = sourceFileName;
			}
			String resultFileName = JOptionPane.showInputDialog("请输入压缩文件名", prefix);
			if (resultFileName == null) {
				return;
			}
			resultFileName += ".zip";
			File resultFile = new File(sourceFile.getParent() + File.separator + resultFileName);
			try {
				ZipHelper.zip(sourceFile, resultFile);
			} catch (IOException e1) {
				JOptionPane.showMessageDialog(null, "压缩文件出错啦");
				e1.printStackTrace();
			}
			allRefresh();
		}
	}

	/**
	 * 解压监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class UnzipListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			File selectedFile = fileChoose(e);
			String fileName = selectedFile.getName();
			if (selectedFile.isDirectory()) {
				JOptionPane.showMessageDialog(null, "此文件不是压缩文件，无法解压");
				return;
			}
			String suffix = fileName.substring(fileName.lastIndexOf('.'));
			if (!ZIP_SUFFIX.equals(suffix)) {
				JOptionPane.showMessageDialog(null, "此文件不是压缩文件，无法解压");
				return;
			}
			File resultDir;
//			解压到新建文件夹
			if (guiFrame.getUnzipNewCmd().equals(e.getActionCommand())) {
				String prefix = fileName.substring(0, fileName.lastIndexOf('.'));
				String resultName = JOptionPane.showInputDialog("请输入新建文件夹名", prefix);
				if(resultName == null) {
					return;
				}
				resultDir = new File(selectedFile.getParent() + File.separator + resultName);
			}else {
				resultDir = currFile;
			}
			try {
				ZipHelper.unzip(selectedFile, resultDir);
			} catch (IOException e1) {
				JOptionPane.showMessageDialog(null, "解压文件出错啦");
				e1.printStackTrace();
			}
			allRefresh();
		}
	}

	/**
	 * 返回上一次监听器
	 * 
	 * @author Maxpicca
	 *
	 */
	class BackListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			currFile = doorKeeper.back(currFile);
			allRefresh();
		}
	}

	/**
	 * 进入下一次监听
	 * 
	 * @author Maxpicca
	 *
	 */
	class GoListener implements ActionListener {

		@Override
		public void actionPerformed(ActionEvent e) {
			currFile = doorKeeper.go(currFile);
			allRefresh();
		}
	}

	/**
	 * 输入文件监听
	 * 
	 * @author Maxpicca
	 *
	 */
	class UrlEnterListener extends KeyAdapter {

		@Override
		public void keyPressed(KeyEvent e) {
			if (e.getKeyCode() == KeyEvent.VK_ENTER) {
				String fileName = urlField.getText();
				if (fileName.endsWith(File.separator)) {
					fileName = fileName.substring(0, fileName.lastIndexOf('\\'));
				}
				File selectedFile = new File(fileName);
				if (!selectedFile.exists()) {
					JOptionPane.showMessageDialog(null, "输入的文件路径有误");
					return;
				}
				try {
					currFile = doorKeeper.openFile(currFile, selectedFile);
				} catch (IOException e1) {
					JOptionPane.showMessageDialog(null, selectedFile.getName() + "打开出错");
					e1.printStackTrace();
				}
				allRefresh();
			}
		}
	}

	private File fileChoose(ActionEvent e) {
		File sourceFile;
		if (Choose.TreeChoosed.equals(chooseModel)) {
			sourceFile = fileTree.getSelectedFile();
		} else {
			sourceFile = fileTable.getSelectedFile();
		}
		return sourceFile;
	}

	public void treeToRefresh(File selectedFile) {
		fileTable.updateTable(selectedFile);
		urlField.setText(selectedFile.getPath());
	}

	public void allRefresh() {
		fileTree.updateTree();
		fileTable.updateTable(currFile);
		urlField.setText(currFile.getPath());

//		TODO 想实现JTree在指定文件节点处展开，但好像行不通。
//		TreePath path = fileTree.getTreePath(currFile);
//		fileTree.addSelectionPath(path);
//		System.out.println(path);
//		fileTree.expandPath(path);
//		fileTree.scrollPathToVisible(path);	

//		想让它刷新的时候闪一下，额，感觉重绘，要导入好多东西，算了，不重绘了
//		guiFrame.removeAll();
//		guiFrame.repaint();
//		guiFrame.add(fileTree,BorderLayout.WEST);
//		guiFrame.add(fileTable,BorderLayout.CENTER);
//		guiFrame.revalidate();
	}
}