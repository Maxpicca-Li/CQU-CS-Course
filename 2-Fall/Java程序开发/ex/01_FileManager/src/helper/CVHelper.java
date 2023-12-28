package helper;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.swing.JOptionPane;

/**
* @author Maxpicca
* @version 创建时间：2020-11-14
* @Description
*/

public class CVHelper {

	public static void pasteDir(File sourceFile, File resultFile) {
		if(!resultFile.exists()) {
			resultFile.mkdir();
		}
		for(File childFile:sourceFile.listFiles()) {
			if(childFile.isDirectory()) {
				File temp = new File(resultFile.getPath()+File.separator+childFile.getName());
				pasteDir(childFile, temp);
			}
			else {
				File temp = new File(resultFile.getPath()+File.separator+childFile.getName());
				pasteFile(childFile, temp);
			}
		}
	}

	public static void pasteFile(File sourceFile, File resultFile) {
		try {
			if(!resultFile.exists()) {
				resultFile.createNewFile();
			}
			FileInputStream fileInput = new FileInputStream(sourceFile);
			FileOutputStream fileOutput = new FileOutputStream(resultFile);
			BufferedInputStream binput = new BufferedInputStream(fileInput);
			BufferedOutputStream boutput = new BufferedOutputStream(fileOutput);
			byte[] buffer = new byte[1024];
			int count = 0;
			while((count = binput.read(buffer)) != -1) {
				boutput.write(buffer,0,count);
			}
			binput.close();boutput.flush();boutput.close();
			fileInput.close();fileOutput.flush();boutput.close(); 
		} catch (IOException e) {
			JOptionPane.showMessageDialog(null, "复制文件"+sourceFile.getName()+"出错");
			e.printStackTrace();
		}
	}
}