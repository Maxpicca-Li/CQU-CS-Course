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
public class FilePopupMenu extends JPopupMenu {

	private JMenuItem removeItem;
	private JMenuItem copyItem;
	private JMenuItem encodeItem;
	private JMenuItem decodeItem;
	private JMenuItem zipItem;
	private JMenu unzipMenu;
	private JMenuItem unzipCurrItem;
	private JMenuItem unzipNewItem;
	
	public FilePopupMenu() {
		init();
	}

	private void init() {
		copyItem = new JMenuItem("复制");
		encodeItem = new JMenuItem("加密");
		decodeItem = new JMenuItem("解密");
		zipItem = new JMenuItem("压缩");
		unzipMenu = new JMenu("解压");
		unzipCurrItem = new JMenuItem("解压到当前文件夹");
		unzipNewItem = new JMenuItem("解压到新建文件夹");
		removeItem = new JMenuItem("移除");

		unzipMenu.add(unzipCurrItem);
		unzipMenu.add(unzipNewItem);
		add(copyItem);
		add(encodeItem);
		add(decodeItem);
		add(zipItem);
		add(unzipMenu);
		add(removeItem);
	}

	public JMenuItem getUnzipCurrItem() {
		return unzipCurrItem;
	}

	public JMenuItem getUnzipNewItem() {
		return unzipNewItem;
	}

	public void addRemoveListener(ActionListener removeListener) {
		removeItem.addActionListener(removeListener);
	}

	public void addCopyListener(ActionListener copyListener) {
		copyItem.addActionListener(copyListener);
	}

	public void addEncodeListener(ActionListener encodeListener) {
		encodeItem.addActionListener(encodeListener);
	}

	public void addDecodeListener(ActionListener decodeListener) {
		decodeItem.addActionListener(decodeListener);
	}

	public void addZipListener(ActionListener zipListener) {
		zipItem.addActionListener(zipListener);
	}

	public void addUnzipListener(ActionListener unzipListener) {
		unzipCurrItem.addActionListener(unzipListener);
		unzipNewItem.addActionListener(unzipListener);
	}
}