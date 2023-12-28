package helper;

import java.io.File;

/**
 * @author Maxpicca
 * @version 创建时间：2020-11-15
 * @Description
 */

public class DoubleNameHelper {
	/**
	 * 判断一个目录下的文件是否与选中文件重名
	 * 
	 * @param dir          文件目录
	 * @param selectedFile 待测试的文件
	 * @return 待测试的文件的新路径
	 */
	public static File solve(File dir, File selectedFile) {
		String name1 = selectedFile.getName();
		String selectedFilePath = selectedFile.getPath();
		for (File childFile : dir.listFiles()) {
//			TODO 没有实现多副本存在功能
			if (childFile.getName().equals(name1)) {
				if(childFile.isDirectory()) {
					selectedFilePath = dir.getPath() + File.separator + name1 + "-副本";
					break;
				}
				if ((name1 != null) && (name1.length() > 0)) {
					int dot = name1.lastIndexOf('.');
					if ((dot > -1) && (dot < (name1.length()))) {
						String frontname = name1.substring(0, dot);
						String endname = name1.substring(dot);
						String name2 = frontname + "-副本" + endname;
						selectedFilePath = dir.getPath() + File.separator + name2;
					}
//					没有找到点'.'，及是一个文件夹
				}
			}
		}
		return new File(selectedFilePath);
	}
}
