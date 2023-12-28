package control;

import java.awt.Desktop;
import java.io.File;
import java.io.IOException;
import java.util.Stack;
import java.util.Vector;

import javax.swing.JOptionPane;

/**
 * 门卫大叔，拥有进出记录
 * 
 * @author Maxpicca
 *
 */
public class DoorKeeper {
	private Stack<File> goFileStack;
	private Stack<File> backFileStack;

	public DoorKeeper() {
		init();
	}

	private void init() {
		goFileStack = new Stack<File>();
		backFileStack = new Stack<File>();
	}

	/**
	 * 栈记录+打开文件
	 * 
	 * @param currFile      当前文件夹
	 * @param selectedFile  选中文件夹
	 * @return currFile
	 * @throws IOException
	 */
	public File openFile(File currFile, File selectedFile)
			throws IOException {
		if (selectedFile == null) {
			JOptionPane.showMessageDialog(null, "文件不存在");
			return currFile;
		}
		if (selectedFile.isFile()) {
//			Desktop类允许Java应用程序启动在本机桌面上注册的相关应用程序来处理URI或文件。
			Desktop.getDesktop().open(selectedFile);
			return currFile;
		}
		backFileStack.add(currFile);
		currFile = selectedFile;
		goFileStack.clear();
//		进入文件，则没有新的可以进入，故清空goFileStack
		return currFile;
	}

	/**
	 * 栈记录
	 * 
	 * @param currFile
	 * @return currFile
	 */
	public File back(File currFile) {
		if (currFile == null || backFileStack.isEmpty()) {
			return currFile;
		}
		goFileStack.push(currFile);
		currFile = backFileStack.pop();
		return currFile;
	}

	/**
	 * 栈记录
	 * 
	 * @param currFile
	 * @return currFile
	 */
	public File go(File currFile) {
		if (goFileStack.isEmpty()) {
			return currFile;
		}
		backFileStack.push(currFile);
		currFile = goFileStack.pop();
		return currFile;
	}
}
