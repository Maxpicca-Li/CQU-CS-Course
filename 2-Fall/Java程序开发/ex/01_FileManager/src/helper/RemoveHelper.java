package helper;

import java.io.File;
import java.io.IOException;

/**
 * 保洁阿姨，清除文件
 * 
 * @author Maxpicca
 * @version 创建时间：2020-11-14
 * @Description
 */

public class RemoveHelper {

	public static boolean remove(File sourceFile, File binFile) throws IOException {
		if (!sourceFile.exists()) {
			return false;
		}
		if (sourceFile.isFile()) {
			File resultFile = new File(binFile.getPath() + File.separator + sourceFile.getName());
			if (!resultFile.exists()) {
				resultFile.createNewFile();
			}
			CVHelper.pasteFile(sourceFile, resultFile);
//			System.out.println(sourceFile.getPath()+"删除成功");
			return sourceFile.delete();
		}
		for (File childFile : sourceFile.listFiles()) {
			File tempBin = new File(binFile.getPath() + File.separator + sourceFile.getName());
			if (!tempBin.exists()) {
				tempBin.mkdir();
			}
			remove(childFile, tempBin);
		}
		return sourceFile.delete();
	}
	
	public static boolean itDelete(File sourceFile) {
		if (!sourceFile.exists()) {
			return false;
		}
		if (sourceFile.isFile()) {
			return sourceFile.delete();
		}
		for (File childFile : sourceFile.listFiles()) {
			itDelete(childFile);
		}
		return sourceFile.delete();
	}
}
