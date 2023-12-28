package view;

import java.awt.event.ActionListener;

import javax.swing.JMenu;
import javax.swing.JMenuItem;
import javax.swing.JPopupMenu;

/**
 * @author Maxpicca
 * @version 创建时间：2020-11-14
 * @Description
 */

public class BlankPopupMenu extends JPopupMenu {

	private JMenu newMenu;
	private JMenuItem newfileItem;
	private JMenuItem newdirItem;
	private JMenuItem pasteItem;
	private JMenuItem refreshItem;

	public BlankPopupMenu() {
		init();
	}

	private void init() {
		newdirItem = new JMenuItem("文件夹");
		newfileItem = new JMenuItem("文件");
		newMenu = new JMenu("新建");
		refreshItem = new JMenuItem("刷新");
		pasteItem = new JMenuItem("粘贴");

		newMenu.add(newdirItem);
		newMenu.add(newfileItem);
		add(newMenu);
		add(refreshItem);
		add(pasteItem);
	}

	public void addNewFileListener(ActionListener newfileListener) {
		newfileItem.addActionListener(newfileListener);
	}

	public void addNewdirListener(ActionListener newdirListener) {
		newdirItem.addActionListener(newdirListener);
	}

	public void addPasteListener(ActionListener pasteListener) {
		pasteItem.addActionListener(pasteListener);
	}

	public void addRefreshListener(ActionListener refreshListener) {
		refreshItem.addActionListener(refreshListener);
	}
}
