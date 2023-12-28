package view;

import java.awt.BorderLayout;
import java.awt.Color;
import java.awt.event.ActionListener;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;
import java.io.File;

import javax.swing.JFrame;
import javax.swing.JScrollPane;
import javax.swing.JSplitPane;
import javax.swing.JTextField;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import data.FileTable;
import data.FileTree;
import data.ToolBar;

/**
 * GUI主界面设计
 * 
 * @author Maxpicca
 *
 */
public class GUIFrame extends JFrame {
	private static final String DEFAULT_TITLE = "文件资源管理器";
	private File binFile;
	private File rootFile;

	private JSplitPane splitPane;
	private JScrollPane tableScrollPane;
	private JScrollPane treeScrollPane;

	private FileTable fileTable;
	private FileTree fileTree;
	private FilePopupMenu filePopupMenu;
	private BlankPopupMenu blankPopupMenu;
	private ToolBar toolBar;

	public GUIFrame(File initialFile, File binFile) {
		init(DEFAULT_TITLE, initialFile, binFile);
	}

	public GUIFrame(String title, File initialFile) {
		init(title, initialFile, binFile);
	}

	private void init(String title, File initialFile, File binFile) {
//		设置系统格式
//		try {
//            UIManager.setLookAndFeel(UIManager.getSystemLookAndFeelClassName());
//            // UIManager 设置当前外观和感觉。setLookAndFeel 将当前的外观设置为 newLookAndFeel。
//            // getSystemLookAndFellClassName 返回实现本机系统外观的 LookAndFeel类的名称，如果有的话，否则为默认的跨平台 LookAndFeel类的名称。 
//        } catch (ClassNotFoundException | InstantiationException | IllegalAccessException
//                | UnsupportedLookAndFeelException e) {
//            e.printStackTrace();
//        }
		this.rootFile = initialFile;
		this.binFile = binFile;
		fileTree = new FileTree(rootFile);
		fileTable = new FileTable(initialFile);
		toolBar = new ToolBar(initialFile);
		filePopupMenu = new FilePopupMenu();
		blankPopupMenu = new BlankPopupMenu();

		treeScrollPane = new JScrollPane(fileTree);
		tableScrollPane = new JScrollPane(fileTable);
//		tableScrollPane.setBackground(Color.white);
//		tableScrollPane.setForeground(Color.black);
		splitPane = new JSplitPane(JSplitPane.HORIZONTAL_SPLIT);
		splitPane.setOneTouchExpandable(true);
		splitPane.setDividerLocation(0.5);

		splitPane.setLeftComponent(treeScrollPane);
		splitPane.setRightComponent(tableScrollPane);
		add(splitPane, BorderLayout.CENTER);
		add(toolBar, BorderLayout.NORTH);
		this.pack();

		setTitle(title);
		setSize(800, 500);
		setLocationRelativeTo(null);
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
	}
//	数据获取
	
	public File getBinFile() {
		return binFile;
	}

	public File getRootFile() {
		return rootFile;
	}

	public FileTable getFileTable() {
		return fileTable;
	}

	public FileTree getFileTree() {
		return fileTree;
	}
	public JTextField getUrlField() {
		return toolBar.getUrlField();
	}

	public String getUnzipCurrCmd() {
		return filePopupMenu.getUnzipCurrItem().getText();
	}

	public String getUnzipNewCmd() {
		return filePopupMenu.getUnzipNewItem().getText();
	}

	public void showFilePopupMenu(MouseEvent e) {
		filePopupMenu.show(e.getComponent(), e.getX(), e.getY());
	}

	public void showBlankPopupMenu(MouseEvent e) {
		blankPopupMenu.show(e.getComponent(), e.getX(), e.getY());
	}

	public void addTreeOpenListener(MouseListener mouseListener) {
		fileTree.addMouseListener(mouseListener);
	}

	public void addTablePaneListener(MouseListener mouseListener) {
		tableScrollPane.addMouseListener(mouseListener);
		fileTable.addMouseListener(mouseListener);
	}

//	 总感觉下面的addListener不是guiFramer该做的事
//	ToolBar事件监听

	public void addBackListener(ActionListener backListener) {
		toolBar.addBackListener(backListener);
	}

	public void addGoListener(ActionListener goListener) {
		toolBar.addGoListener(goListener);
	}

	public void addUrlEnterListener(KeyListener keyListener) {
		toolBar.addUrlEnterListener(keyListener);
	}

//	filePopupMenu事件监听
	
	public void addRemoveListener(ActionListener removeListener) {
		filePopupMenu.addRemoveListener(removeListener);
	}

	public void addCopyListener(ActionListener copyListener) {
		filePopupMenu.addCopyListener(copyListener);
	}

	public void addEncodeListener(ActionListener encodeListener) {
		filePopupMenu.addEncodeListener(encodeListener);
	}

	public void addDecodeListener(ActionListener decodeListener) {
		filePopupMenu.addDecodeListener(decodeListener);
	}

	public void addZipListener(ActionListener zipListener) {
		filePopupMenu.addZipListener(zipListener);
	}

	public void addUnzipListener(ActionListener unzipListener) {
		filePopupMenu.addUnzipListener(unzipListener);
	}

//	blankPopupMenu事件监听
	
	public void addNewFileListener(ActionListener newfileListener) {
		blankPopupMenu.addNewFileListener(newfileListener);
	}

	public void addNewdirListener(ActionListener newdirListener) {
		blankPopupMenu.addNewdirListener(newdirListener);
	}

	public void addPasteListener(ActionListener pasteListener) {
		blankPopupMenu.addPasteListener(pasteListener);
	}

	public void addRefreshListener(ActionListener refreshListener) {
		blankPopupMenu.addRefreshListener(refreshListener);
	}
}
