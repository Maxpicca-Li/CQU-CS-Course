package helper;

import java.io.File;

import javax.swing.Icon;
import javax.swing.filechooser.FileSystemView;

/**
* @author Maxpicca
* @version 创建时间：2020-11-15
* @Description 获得系统图标
*/
public class FileIconHelper {
	public static Icon getIcon(File f ) {
        if ( f != null && f.exists() ) {
            FileSystemView fsv = FileSystemView.getFileSystemView();
            return(fsv.getSystemIcon( f ) );
        }
        return null;
    }
}
