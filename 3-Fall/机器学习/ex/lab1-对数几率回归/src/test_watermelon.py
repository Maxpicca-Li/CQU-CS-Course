import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from sklearn.utils import shuffle
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report

from MyLogisticRegression import MyLogisticRegression
from utils import my_save_fig

# LogisticRegression 边界函数
my_split_boundary_func = lambda x: (-my_model.intercept_ - my_model.coef_[0] * x) / my_model.coef_[1]
sk_split_boundary_func = lambda x: (-sk_model.intercept_ - sk_model.coef_[0][0] * x) / sk_model.coef_[0][1]

def plot_data(X,Y,img_name=None,my_acc=None,sk_acc=None):
    # Watermelon_data
    fig, ax = plt.subplots()
    scatter = ax.scatter(X[:, 0], X[:, 1], c=Y, marker='*')
    handles, labels = scatter.legend_elements()
    legend1 = ax.legend(handles, labels, loc="upper left", title="Classes")
    ax.add_artist(legend1)

    # boundary line
    boundx = np.linspace(0, 1, 50, endpoint=True)
    plt.plot(boundx, my_split_boundary_func(boundx), c='red')
    plt.plot(boundx, sk_split_boundary_func(boundx), c='blue')
    plt.title('Watermelon_data')
    if my_acc is not None and sk_acc is not None:
        plt.text(0.75, 0.7, "my_acc=%.4f\nsk_acc=%.3f" % (my_acc, sk_acc), transform=ax.transAxes)
    plt.legend(['my_model', 'sk_model'], )
    my_save_fig(fig, img_name)
    plt.show()

if __name__=="__main__":
    # 1、数据读取
    data = pd.read_excel('./Watermelon_data.xls')
    data = shuffle(data)
    data['好瓜'].replace('是',1,inplace=True)
    data['好瓜'].replace('否',0,inplace=True)

    # 2、数据准备
    X = np.array(data[['密度','含糖率']].values)
    Y = np.array(data['好瓜'].values)
    Y = Y[:,np.newaxis]

    # 3、训练集和测试集，这里数量比较少，全部作为训练集
    # train_percent = 1
    # train_num = int(np.floor(X.shape[0] * train_percent))
    # trainX,testX = X[0:train_num],X[train_num,-1]
    # trainY,testY = Y[0:train_num],X[train_num,-1]
    trainX = X
    trainY = Y

    # 4、建立模型
    print("="*20+"my model"+"="*20)
    my_model = MyLogisticRegression()
    my_model.fit(trainX,trainY)
    my_acc = my_model.score()
    my_loss = my_model.loss()
    my_predY = my_model.predict(trainX)
    print(f'1、模型参数：\n\tw={my_model.coef_.T}\n\tb={my_model.intercept_}')
    print("2、评级指标：")
    print(f'acc  = {my_acc}')
    print(f'loss = {my_loss}')
    print("3、分类结果：")
    print(classification_report(trainY, my_predY, target_names=['否', '是']))

    # 5、可视化训练过程
    img_name = 'Watermelon_data MyLogisticRegression Trian'
    my_model.draw_process(img_name)

    # ============== sklearn对比 ==============
    print("=" * 20 + "sk model" + "=" * 20)
    sk_model = LogisticRegression()
    sk_model.fit(trainX,trainY)
    sk_acc = sk_model.score(trainX,trainY)
    sk_predY = sk_model.predict(trainX)
    print(f'1、模型参数：\n\tw={sk_model.coef_}\n\tb={sk_model.intercept_}')
    print("2、评级指标：")
    print(f'acc  = {sk_acc}')
    print("3、分类结果：")
    print(classification_report(trainY, sk_predY, target_names=['否', '是']))

    # 可视化训练结果
    img_name = 'Watermelon_data'
    plot_data(X, Y, img_name, my_acc, sk_acc)