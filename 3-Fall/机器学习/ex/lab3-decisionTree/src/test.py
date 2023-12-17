# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-18 11:44 
# @Description: test.py

import time

import numpy as np

import DecisionTree
from DecisionTree import DecisionTreeClassifier
from DecisionTree import DecisionTreeRegressor
from MLutil import get_iris_data,get_wine_data,get_boston_data,get_diabetes_data, get_airfoil_data
from MLutil import accuracy, mean_squared_loss, mean_squared_root_error, relative_error, R2
from MLutil import train_test_split

def test(data_name):
    ''' 数据集统一测试 '''
    my_dataset = {
        "iris": {
            "name": "鸢尾花分类数据集",
            "get_fun": get_iris_data,
            "dt": DecisionTreeClassifier(max_depth=10,save_path="iris_dt.pkl",islog=False),
            'y_name': {
                0:'setosa',
                1:'versicolor',
                2:'virginica',
            },
            'feature_name': None,
            'type':'classfier',
        },
        "wine": {
            "name": "红酒分类数据集",
            "get_fun": get_wine_data,
            "dt": DecisionTreeClassifier(min_samples_leaf=3, max_depth=10,islog = False),
            'y_name':None,
            'feature_name': None,
            'type':'classfier',
        },
        'boston':{
            'name':'波士顿回归数据集',
            "get_fun":get_boston_data,
            "dt":DecisionTreeRegressor(min_samples_leaf=5),
            'y_name':None,
            'feature_name':{
                0:"CRIM",1:"ZN",2:"INDUS",3:"CHAS",4:"NOX",5:"RM",6:"AGE",7:"DIS",8:"RAD",9:"TAX",10:"PTRATIO",11:"B",12:"LSTAT",
            },
            'type':'regressor',
        },
        'diabetes':{
            'name':'糖尿病回归数据集',
            "get_fun":get_diabetes_data,
            'dt':DecisionTreeRegressor(min_samples_leaf=30),
            'y_name':None,
            'feature_name': {
                0:'age', 1:'sex', 2:'bmi', 3:'bp', 4:'s1', 5:'s2', 6:'s3', 7:'s4', 8:'s5', 9:'s6'
            },
            'type':'regressor',
        },
        'airfoil':{
            'name':'机翼自噪声回归数据集',
            "get_fun":get_airfoil_data,
            'dt':DecisionTreeRegressor(min_samples_leaf=10),
            'y_name':None,
            'feature_name': {
                # 0:'Frequency', 1:'Angle of attack', 2:'Chord length', 3:'Free-stream velocity', 4:'Suction side displacement thickness'
                0:'freq', 1:'angle', 2:'len', 3:'velocity', 4:'thickness'
            },
            'type':'regressor',
       },
    }

    print("=" * 30, my_dataset[data_name]["name"], "=" * 30)
    X, Y = my_dataset[data_name]["get_fun"]()
    trainX, testX, trainY, testY = train_test_split(X, Y)

    dt = my_dataset[data_name]["dt"]  # type: DecisionTree.DecisionTreeBase

    start_time = time.time()
    print("模型开始训练")
    dt.fit(trainX, trainY)
    print("模型结构：")
    print("树高度：%d; 树节点数目：%d; 其中叶节点%d个"%(dt.actual_max_depth, dt.node_num, dt.leaf_num))
    save_path = "./%s's Decision Tree.html"%(data_name)
    dt.plot(save_path=save_path,
            feature_name=my_dataset[data_name]['feature_name'],
            y_name=my_dataset[data_name]['y_name'],
            )
    print("树结构详见文件",save_path)
    print("模型训练结束，用时%.3fs" % (time.time() - start_time))

    # 预测和评估
    print("测试：")
    predY = dt.predict(testX)

    # 调bug神器
    # print("真实值：",testY.ravel())
    # print("预测值：",predY.ravel())

    if my_dataset[data_name]['type']=='classfier':
        print("损失函数值：%.3f" % (mean_squared_loss(testY, predY)))
        print("预测准确率：%.3f" % (accuracy(testY,predY)))
    elif my_dataset[data_name]['type']=='regressor':
        print("相对误差：%.2f %%" % (relative_error(testY,predY)*100))
        print("均方根误差：%.3f" % (mean_squared_root_error(testY,predY)))
        print("R2:%.3f"%(R2(testY,predY)))

    print()

if __name__ == "__main__":
    test('iris')
    test('wine')
    test('boston')
    test('airfoil')
