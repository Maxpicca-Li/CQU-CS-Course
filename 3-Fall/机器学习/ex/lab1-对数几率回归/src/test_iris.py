# 导入包
from sklearn import datasets
import numpy as np

from sklearn.model_selection import train_test_split
from MyMultiLogisticRegression import MyMultiLogisticRegression

iris = datasets.load_iris()
# 键：data target target_names
X = iris.data
Y = iris.target
Y = Y[:,np.newaxis]
train_X,test_X,train_Y,test_Y = train_test_split(X,Y,test_size=0.3)

mmLR = MyMultiLogisticRegression()
mmLR.fit(train_X,train_Y)
mmLR.get_params()
mmLR.draw_process()
print("训练准确率:%f"%(mmLR.score()))
print("测试准确率:%f"%(mmLR.score(test_X,test_Y)))
