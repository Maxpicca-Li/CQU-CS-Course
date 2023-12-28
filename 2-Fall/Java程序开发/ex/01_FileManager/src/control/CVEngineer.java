package control;

import java.io.File;
import java.util.Vector;

import javax.swing.JOptionPane;

import helper.CVHelper;
import helper.DoubleNameHelper;


/**
 * CV攻城狮，复制粘贴好手，不仅有剪切板+文件（夹）粘贴工具
* @author Maxpicca
* @version 创建时间：2020-11-14
* @Description
*/

public class CVEngineer {
	private Vector<String> copyBoard;

	public CVEngineer() {
		copyBoard = new Vector<String>();
	}
	
	public void copy(File file) { 
//		想实现多选复制，emmmm，有待实现，之后可以添加在后面，————多态List<File>
		copyBoard.clear();
		copyBoard.add(file.getPath());
	}
	
	public void paste(File currFile) {
//		在当前文件里粘贴
		if (copyBoard.isEmpty()) {
			JOptionPane.showMessageDialog(null, "没有可复制的文件");
			return;
		}
		for (String sourceFilePath : copyBoard) {
//			剪切板上的源文件
			File sourceFile = new File(sourceFilePath); 
			String resultFilePath = currFile.getPath() + File.separator + sourceFile.getName();
			File resultFile = new File(resultFilePath);
//			判断重名
			resultFile = DoubleNameHelper.solve(currFile, resultFile);
			if (sourceFile.isDirectory()) {
				CVHelper.pasteDir(sourceFile, resultFile);
			} else {
				CVHelper.pasteFile(sourceFile, resultFile);
			}
		}
	}
}
