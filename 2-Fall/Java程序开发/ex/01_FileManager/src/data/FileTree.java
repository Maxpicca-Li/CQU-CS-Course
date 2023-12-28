package data;

import java.awt.event.MouseListener;
import java.io.File;

import javax.swing.JTree;
import javax.swing.tree.DefaultMutableTreeNode;
import javax.swing.tree.DefaultTreeModel;
import javax.swing.tree.MutableTreeNode;
import javax.swing.tree.TreeSelectionModel;

/**
 * 文件树
 * 
 * @author Maxpicca
 */
public class FileTree extends JTree {

	private File defaultRootFile;

	public FileTree(File rootFile) {
		defaultRootFile = rootFile;
		init(rootFile);
	}

	private void init(File rootFile) {
		DefaultMutableTreeNode root = buildTree(rootFile);
		setModel(new DefaultTreeModel(root));
		getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
//		setCellRenderer(new systemCellRenderer());
	}

	private DefaultMutableTreeNode buildTree(File file) {
		DefaultMutableTreeNode root = new DefaultMutableTreeNode(file) {
//			 如果FileTree只显示文件的话
			@Override
			public boolean isLeaf() {
				return false;
			}
			@Override
			public String toString() {
				return file.getName();
			}
		};
		if (file.isDirectory()) {
			for (File childfile : file.listFiles()) {
				if (childfile.isDirectory()) {
					MutableTreeNode child = buildTree(childfile);
//					TODO  想实现当要展开某节点的时候，才读取它。
//					MutableTreeNode child = new DefaultMutableTreeNode(childfile) {
//						public boolean isLeaf() {
//						    return false;
//						  }
//						public String toString() {
//							return childfile.getName();
//						}
//					};
					root.add(child);
				}
			}
		}
		return root;
	}

	public void updateTree() {
		init(defaultRootFile);
	}

	/**
	 * 内置数据获取
	 * 
	 * @return SelectedFile 当前展示的文件
	 */
	public File getSelectedFile() {
		DefaultMutableTreeNode selectedNode = (DefaultMutableTreeNode) getLastSelectedPathComponent();
		File selectedFile = (File) selectedNode.getUserObject();
		return selectedFile;
	}

//	/**
//	 * 想让树可以展开指定的文件节点
//	 * 
//	 * @param file
//	 * @return
//	 */
//	public TreePath getTreePath(File file) {
//		DefaultMutableTreeNode root = buildTree(defaultRootFile);
////		depthFirstEnumeration创建并返回以深度优先顺序遍历以此节点为根的子树的枚举。
//		Enumeration<DefaultMutableTreeNode> e = root.depthFirstEnumeration();
//		while (e.hasMoreElements()) {
//			DefaultMutableTreeNode node = e.nextElement();
//			if (node.getUserObject().equals(file)) {
//				return new TreePath(node.getPath());
//			}
//		}
//		return null;
//	}

}