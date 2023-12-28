package control;

import java.io.File;
import java.util.Scanner;

import view.GUIFrame;

/**
* @author Maxpicca
* @version 创建时间：2020-11-14
* @Description
*/

public class GUIAPP {

	public static void main(String[] args) {
//		String testFilename = "D:\\GUITestLs";
//		String binFilename = "C:\\Users\\Maxpicca\\Desktop\\GUI回收站";
		Scanner in = new Scanner(System.in);
		System.out.println("请输入测试根文件路径：");
		String testFilename = in.nextLine();
		System.out.println("请输入测试回收站文件路径：");
		String binFilename = in.nextLine();
		
		File testFile = new File(testFilename);
		File binFile = new File(binFilename);
		GUIFrame myguiFrame = new GUIFrame(testFile,binFile);
		GUIController myguiController = new GUIController(myguiFrame);
		myguiFrame.setVisible(true);
	}

}
