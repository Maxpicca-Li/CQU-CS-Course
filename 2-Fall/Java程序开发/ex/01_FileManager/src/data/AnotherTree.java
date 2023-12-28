package idea;
//package idea;
//
//import java.awt.event.MouseListener;
//import java.io.File;
//import java.util.Enumeration;
//import java.util.List;
//
//import javax.swing.JTree;
//import javax.swing.tree.DefaultMutableTreeNode;
//import javax.swing.tree.DefaultTreeModel;
//import javax.swing.tree.MutableTreeNode;
//import javax.swing.tree.TreePath;
//import javax.swing.tree.TreeSelectionModel;
//
///**
//* @author Maxpicca
//* @version 创建时间：2020-11-14
//* @Description
//*/
//
//public class AnotherTree extends JTree {
//	public FileTree(List<File> rootFiles) {
//		init(rootFiles);
//	}
//
//	private void init(List<File> rootFiles) {
//		DefaultMutableTreeNode roots = new DefaultMutableTreeNode();
//		for(File file: rootFiles){
//			DefaultMutableTreeNode node = buildTree(file);
//			roots.add(node);
//		}
//		setModel(new DefaultTreeModel(roots));  // 都要default才行
//		getSelectionModel().setSelectionMode(TreeSelectionModel.SINGLE_TREE_SELECTION);
////		setCellRenderer(new systemCellRenderer());
//	}
//	private DefaultMutableTreeNode buildTree(File file) {
//		DefaultMutableTreeNode root = new DefaultMutableTreeNode(file) {
////			 如果FileTree只显示文件的话
//			public boolean isLeaf() {
//			    return false;
//			  }
//			public String toString() {
//				return file.getName();
//			}
//		};
//		if(file.isDirectory()) {
//			for(File childfile:file.listFiles()) {
//				if(childfile.isDirectory()) {
//					MutableTreeNode child = buildTree(childfile);
//					// TODO 能不能实现当要展开某节点的时候，才读取它。
////					MutableTreeNode child = new DefaultMutableTreeNode(childfile) {
////						public boolean isLeaf() {
////						    return false;
////						  }
////						public String toString() {
////							return childfile.getName();
////						}
////					};
//					root.add(child);
//				}
//			}
//		}
//		return root;
//	}
//	
//	// 内置数据更新树
//	public void updateTree() {
//		init(defaultfile);
//	}
//	
//	/**
//	 * 内置数据获取
//	 * @return currFile 当前展示的文件
//	 */
//	public File getcurrFile() {
//		DefaultMutableTreeNode seletedNode = (DefaultMutableTreeNode) getLastSelectedPathComponent();
//		File currFile = (File) seletedNode.getUserObject();
//		return currFile;
//	}
//	
//	public TreePath getTreePath(File file) {
//		DefaultMutableTreeNode root = buildTree(defaultfile);
//		// depthFirstEnumeration创建并返回以深度优先顺序遍历以此节点为根的子树的枚举。
//		Enumeration<DefaultMutableTreeNode> e = root.depthFirstEnumeration();
//		while(e.hasMoreElements()) {
//			DefaultMutableTreeNode node = e.nextElement();
//			if(node.getUserObject().equals(file)) {
//				return new TreePath(node.getPath());
//			}
//		}
//		return null;
//	}
//	// 树的监听
//	public void addTreeOpenListener(MouseListener mouse) {
//		addMouseListener(mouse);
//	}
//}
