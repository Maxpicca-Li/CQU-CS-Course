package data;

import java.awt.event.ActionListener;
import java.awt.event.KeyListener;
import java.io.File;

import javax.swing.JButton;
import javax.swing.JTextField;
import javax.swing.JToolBar;

/**
 * @author Maxpicca
 * @version 创建时间：2020-11-14
 * @Description
 */

public class ToolBar extends JToolBar {
	private File currFile;
	private JButton backButton;
	private JButton goButton;
	private JTextField urlField;

	public ToolBar(File currFile) {
		this.currFile = currFile;
		init();
	}
	
	private void init() {
		backButton = new JButton("返回");
		goButton = new JButton("前进");
		urlField = new JTextField();
		urlField.setText(currFile.getPath());
		
		add(backButton);
		add(goButton);
		add(urlField);

		setBorder(null);
		setFloatable(false);
		// 焦点遍历循环
		setFocusCycleRoot(true);
		// 将默认大小的分隔符附加到工具栏的末尾。
		addSeparator();
	}

//	数据获取
	
	public JTextField getUrlField() {
		return urlField;
	}
	
	public void addBackListener(ActionListener backListener) {
		backButton.addActionListener(backListener);
	}

	public void addGoListener(ActionListener goListener) {
		goButton.addActionListener(goListener);
	}

	public void addUrlEnterListener(KeyListener keyListener) {
		urlField.addKeyListener(keyListener);
	}

}
