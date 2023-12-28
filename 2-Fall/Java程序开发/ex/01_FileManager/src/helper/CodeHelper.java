package helper;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import javax.swing.JOptionPane;

/**
 * 密码志愿者-static，加密和解密
* @author Maxpicca
* @version 创建时间：2020-11-14
* @Description
*/
public class CodeHelper {
	private static final String ENCODE_SUFFIX = ".encode";
	private static final int COUNT = 1024;
	public static void encode(File sourceFile,File dir, int key) throws IOException {
		File resultFile = new File(dir.getPath()+File.separator+sourceFile.getName() + ".encode");
		if (!resultFile.exists()) {
			if(sourceFile.isFile()) {
				resultFile.createNewFile();
			}else {
				resultFile.mkdir();
			}
		}
		if (sourceFile.isDirectory()) {
			for(File childFile:sourceFile.listFiles()) {
				encode(childFile,resultFile,key);
			}
		} else {
			codeHelp(sourceFile, resultFile, key);
		}
	}
	
	public static void decode(File sourceFile, File dir, int key) throws IOException {
		String filename = sourceFile.getName();
		int dot = filename.lastIndexOf('.');
		if (dot<0 || dot>=filename.length()) {
			JOptionPane.showMessageDialog(null, filename+"不是加密文件");
			return ;
		}
		String suffix = filename.substring(filename.lastIndexOf('.'));
		if(!ENCODE_SUFFIX.equals(suffix)) {
			JOptionPane.showMessageDialog(null, filename+"不是加密文件");
			return ;
		}
		filename = filename.substring(0, filename.lastIndexOf('.'));
		File resultFile = new File(dir.getPath()+File.separator+filename);
		if (!resultFile.exists()) {
			if(sourceFile.isFile()) {
				resultFile.createNewFile();
			}else {
				resultFile.mkdir();
			}
		}
		if (sourceFile.isDirectory()) {
			for(File childFile:sourceFile.listFiles()) {
				decode(childFile,resultFile,key);
			}
		} else {
			codeHelp(sourceFile, resultFile, key);
		}
	}
		
	private static void codeHelp(File sourceFile, File resultFile, int key) {
		try {
			BufferedInputStream bin = new BufferedInputStream(new FileInputStream(sourceFile));
			BufferedOutputStream bout = new BufferedOutputStream(new FileOutputStream(resultFile));
			byte[] buffer = new byte[COUNT];
			int count = 0;
			while ((count = bin.read(buffer)) != -1) {
				for (int i = 0; i < COUNT; i++) {
					buffer[i] ^= key;
				}
				bout.write(buffer, 0, count);
			}
			bin.close();
			bout.flush();
			bout.close();
		} catch (IOException e) {
			JOptionPane.showMessageDialog(null, "加密文件" + sourceFile.getName() + "出错");
			e.printStackTrace();
		}
	}
}
