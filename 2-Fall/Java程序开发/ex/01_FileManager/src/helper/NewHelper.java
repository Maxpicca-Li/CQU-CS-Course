package helper;

import java.io.File;
import java.io.IOException;

import javax.swing.JOptionPane;

/**
 * @author Maxpicca
 * @version 创建时间：2020-11-14
 * @Description
 */

public class NewHelper {

	public static void newDir(String dirName, File currFile) {
		if (dirName == "") {
			dirName = "新建文件夹";
		}
		File newdir = new File(currFile.getPath() + File.separator + dirName);
		if (!newdir.exists()) {
			newdir.mkdir();
			return;
		}
		JOptionPane.showMessageDialog(null, "文件夹已存在");
	}

	public static void newFileOpperation(String fileName, File currFile) {
		if (fileName == "") {
			fileName = "新建文件";
		}
		File newfile = new File(currFile.getPath() + File.separator + fileName);
		if (!newfile.exists()) {
			try {
				newfile.createNewFile();
			} catch (IOException e) {
				JOptionPane.showMessageDialog(null, "创建文件失败");
				e.printStackTrace();
			}
			return;
		}
		JOptionPane.showMessageDialog(null, "文件已存在");
	}
}
