package helper;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.zip.CRC32;
import java.util.zip.CheckedOutputStream;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;
import java.util.zip.ZipOutputStream;

import javax.swing.JOptionPane;

/**
 * 压缩，解压
 * 
 * @author Maxpicca
 * @version 创建时间：2020-11-14
 * @Description
 */

public class ZipHelper {

	public static void zip(File sourceFile, File resultFile) throws IOException {
		if (!resultFile.exists()) {
			resultFile.createNewFile();
		}
		if (!sourceFile.exists()) {
			JOptionPane.showMessageDialog(null, "压缩原文件不存在");
			return;
		}
		FileOutputStream fos = new FileOutputStream(resultFile);
		CheckedOutputStream cos = new CheckedOutputStream(fos, new CRC32());
		ZipOutputStream zos = new ZipOutputStream(cos);
		String zipPath = sourceFile.getName();
//		 注意这里是相对路径哦，不是绝对路径
		zipHelp(sourceFile, zos, zipPath);
		zos.close();
	}

	public static void unzip(File sourceFile, File resultDir) throws IOException {
//		解压到resultDir目录下
		if (!sourceFile.exists()) {
			JOptionPane.showMessageDialog(null, "该文件不存在");
			return;
		}
		if (!resultDir.exists()) {
			resultDir = DoubleNameHelper.solve(resultDir.getParentFile(), resultDir);
			resultDir.mkdir();
		}
		ZipInputStream zis = new ZipInputStream(new FileInputStream(sourceFile));
		ZipEntry zipEntry;
//		压缩条目，类似于文件，一样的管理，但是zipentry里面是绝对路径
		while ((zipEntry = zis.getNextEntry()) != null) {
			if (zipEntry.getName().endsWith(File.separator)) {
				File file = new File(resultDir + File.separator + zipEntry.getName());
				file = DoubleNameHelper.solve(resultDir, file);
				if (!file.exists()) {
					file.mkdir();
				}
			} else {
				File file = new File(resultDir + File.separator + zipEntry.getName());
				file = DoubleNameHelper.solve(resultDir, file);
				if (!file.exists()) {
					file.createNewFile();
				}
				FileOutputStream fos = new FileOutputStream(file);
				byte[] buffer = new byte[1024];
				int len = 0;
				while ((len = zis.read(buffer)) != -1) {
					fos.write(buffer, 0, len);
				}
				fos.close();
			}
		}
		zis.close();
	}

	private static void zipHelp(File sourceFile, ZipOutputStream zos, String zipPath) throws IOException {
		if (sourceFile.isFile()) {
			zos.putNextEntry(new ZipEntry(zipPath));
//			压缩文件内部，保证源文件结构，需要的相对路径！！
			FileInputStream fis = new FileInputStream(sourceFile);
			byte[] buffer = new byte[1024];
			int len = 0;
			while ((len = fis.read(buffer)) != -1) {
				zos.write(buffer, 0, len);
			}
			zos.closeEntry();
			fis.close();
		} else {
			File[] childFiles = sourceFile.listFiles();
			if (childFiles == null || childFiles.length == 0) {
//				即为空文件，为保证源文件结构
				zos.putNextEntry(new ZipEntry(zipPath + File.separator));
				zos.closeEntry();
			} else {
				zos.putNextEntry(new ZipEntry(zipPath + File.separator));
				for (File childFile : sourceFile.listFiles()) {
					zipHelp(childFile, zos, zipPath + File.separator + childFile.getName());
				}
				zos.closeEntry();
			}
		}
	}
}
