# 决策树

1. 理解并**描述**决策树分类、回归算法原理。
2. **编程**实践，将决策树分类、回归算法分别应用于合适的数据集(如鸢尾花、波士顿房价预测、UCI数据集、Kaggle数据集)，要求算法至少用于两个数据集(分类2个，回归2个)。



- [ ] 寻找适合决策树分类的数据集
- [ ] 寻找适合决策树回归的数据集
- [ ] baseline(不考虑预剪枝)
- [ ] 



决策树算法原理：

> 不同算法的优缺点，西瓜书

![查看源图像](https://www.freesion.com/images/946/a11b048afe54245ac67b0a75e8877852.png)



## 数据集

forestfires：

- http://www3.dsi.uminho.pt/pcortez/forestfires/forestfires-names.txt

- http://www3.dsi.uminho.pt/pcortez/forestfires/



## 决策分类树

[决策树—分类 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/42164714)

属性值的选择→基尼系数

**核心：特征选择+剪枝。**

1. 特征选择：选择当前具有最好的分类能力的特征



预测每个类的概率，这个概率是叶中相同类的训练样本的分数

因而对于一个具有多个取值（超过2个）的特征，需要计算以每一个取值作为划分点，对样本D划分之后子集的纯度Gini(D,Ai)，(其中Ai 表示特征A的可能取值)


$$
Gini(p) = \sum_{k=1}^kp_k(1-p_k)=1-\sum_{k=1}^kp_k^2 \\
Gini(D,A)=\frac{|D_1|}{|D|}Gini(D_1)+\frac{|D_2|}{|D|}Gini(D_2)
$$


## 决策回归树

[决策树—回归 - 知乎 (zhihu.com)](https://zhuanlan.zhihu.com/p/42505644)

**核心：划分点选择 + 输出值确定。**

属性值和划分值的选择→平方误差

根据平方误差和最小化的原则，选择最优切分点及其对应的特征。
$$
L(j,s)=	
	\sum_{x_i\in R_1(j,s)}(y_i-\hat{c_1})^2 + 
	\sum_{x_i\in R_2(j,s)}(y_i-\hat{c_2})^2 \\
\hat{c_1} = \frac{\sum_{x_i\in R_1(j,s)}y_i}{|R_1|} \\
\hat{c_2} = \frac{\sum_{x_i\in R_2(j,s)}y_i}{|R_2|} \\
$$


$$
\frac{1}{N}\times \frac{|y\_true - y\_pred|}{|y\_true|} \\
\frac{1}{N}\times \sqrt{(y\_true - y\_pred)^2} \\
R^2 = 1-\frac{u}{v} \\
u = \sum (y\_pred-y\_true)^2
v = \sum (y\_true-\overline{y\_true})^2
$$


**符号表**

| 符号             | 含义     |
| ---------------- | -------- |
| $V$，$x_{ij}$    | 特征数目 |
| $N$，$\vec{x},y$ | 样本数量 |
| $M$              | 类别数量 |
|                  |          |
|                  |          |
|                  |          |
|                  |          |
|                  |          |
|                  |          |



## 参考资料

### 参考书籍

- 周志华-机器学习



### 参考实现

- [详解决策树、python实现决策树 - 灰信网（软件开发博客聚合） (freesion.com)](https://www.freesion.com/article/7600779148/)
- [决策树算法原理(分类树)及实现 - 简书 (jianshu.com)](https://www.jianshu.com/p/8e9af0fe08b8)
- sklearn接口学习
  - [决策树算法及Python实现_Britesun的博客-CSDN博客_python 决策树](https://blog.csdn.net/qq_34807908/article/details/81539536)
  - [sklearn.tree.DecisionTreeClassifier — scikit-learn 1.0.1 documentation](https://scikit-learn.org/stable/modules/generated/sklearn.tree.DecisionTreeClassifier.html#sklearn.tree.DecisionTreeClassifier)



### 学习资料

- [决策树（decision tree）(三)——连续值处理_天泽28的专栏-CSDN博客_决策树连续变量的处理](https://blog.csdn.net/u012328159/article/details/79396893)

  



