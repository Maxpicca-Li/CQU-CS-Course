# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-19 9:35 
# @Description: MLutil 因几次机器学习实验都用到了这些，所以这里写一个MLutil，方便几次实验调用

import numpy as np
import random


# =============================== 常用数据获取函数 ===============================

def get_iris_data(filepath='./iris.csv'):
    ''' 获取鸢尾花数据集 '''
    import pandas as pd
    iris_df = pd.read_csv(filepath)
    iris_data = iris_df.values
    X = iris_data[:, :-1]
    Y = iris_data[:, -1][:, np.newaxis]
    return X, Y


def get_wine_data(filepath='./wine.data'):
    ''' 获取红酒数据集 '''
    wine_data = np.loadtxt(filepath, delimiter=",")
    Y = wine_data[:, 0][:, np.newaxis]
    X = wine_data[:, 1:]
    return X, Y


def get_boston_data(file_path='./boston_house_prices.csv'):
    ''' 获取波斯顿房价预测 '''
    import pandas as pd
    boston_df = pd.read_csv(file_path)
    boston_data = boston_df.values
    X = boston_data[1:, :-1].astype(float)
    Y = boston_data[1:, -1][:, np.newaxis].astype(float)
    return X, Y

def get_diabetes_data():
    ''' 获取糖尿病数据集 '''
    from sklearn.datasets import load_diabetes
    data = load_diabetes()
    X = data.data
    Y = data.target
    return X,Y

def get_airfoil_data(file_path='./airfoil_self_noise.dat'):
    data = np.loadtxt(file_path)
    X = data[:,:-1]
    Y = data[:,-1]
    return X,Y

# =============================== 常用损失函数 ===============================
def mean_squared_loss(y_true, y_pred):
    y_true = dim_check(y_true)
    y_pred = dim_check(y_pred)
    return ((y_true - y_pred) ** 2).mean(axis=0).sum() / 2


# =============================== 常用评估函数 ===============================
def dim_check(y):
    if y.ndim ==1:
        y = y.reshape((-1,1))
    return y

def accuracy(y_true, y_pred):
    y_true = dim_check(y_true)
    y_pred = dim_check(y_pred)
    return (y_true == y_pred).mean(axis=0)


def relative_error(y_true, y_pred):
    y_true = dim_check(y_true)
    y_pred = dim_check(y_pred)
    return (np.abs(y_true - y_pred) / np.abs(y_true + 1e-5)).mean(axis=0).sum()


def squared_error(y_true, y_pred):
    return ((y_true - y_pred) ** 2).sum(axis=0).sum()

def mean_squared_error(y_true, y_pred):
    return ((y_true - y_pred) ** 2).mean(axis=0).sum()

def mean_squared_root_error(y_true, y_pred):
    y_true = dim_check(y_true)
    y_pred = dim_check(y_pred)
    return np.sqrt(((y_true - y_pred) ** 2).mean(axis=0).sum())

def R2(y_true,y_pred):
    y_true = dim_check(y_true)
    y_pred = dim_check(y_pred)
    u = ((y_pred-y_true)**2).sum()
    v = ((y_true-y_true.mean())**2).sum()
    return 1-u/v

# =============================== 常用激活函数及其求导 ===============================
def sigmoid(X):
    return 1 / (1 + np.exp(-X))


def sigmoid_diff(y):
    return y * (1 - y)


def tanh(X):
    return (np.exp(X) - np.exp(-X)) / (np.exp(X) + np.exp(-X))


def tanh_diff(y):
    return 1 - y ** 2


def softmax(X):
    return np.exp(X) / np.sum(np.exp(X), axis=1).reshape(-1, 1)  # X / 按照行求和,得到(n_samples,1)矩阵


# =============================== 其他功能函数 ===============================
def train_test_split(X, Y, train_percent=0.7, shuffle=True, seed=None):
    ''' 自定义数据分割 '''
    n_smaples = X.shape[0]
    if shuffle:
        idx = np.arange(n_smaples, dtype=int)
        if seed:
            random.seed(2)
        random.shuffle(idx)
        X = X[idx]
        Y = Y[idx]
    n_train = int(np.floor(n_smaples * train_percent))
    trainX, testX = X[0:n_train], X[n_train:-1]
    trainY, testY = Y[0:n_train], Y[n_train:-1]
    return trainX, testX, trainY, testY


def one_hot_encoder(y, class_encoder=None):
    if class_encoder == None:
        y_set = set(y.ravel())
        class_encoder = {label: idx for idx, label in enumerate(y_set)}
    n_classes = len(class_encoder)
    n_samples = len(y)
    y_one_hot = np.zeros((n_samples, n_classes), dtype=int) + 0.01
    for idx, label in enumerate(y.ravel()):
        y_one_hot[idx, class_encoder[label]] = 1 - 0.01
    return y_one_hot


def one_hot_decoder(y_one_hot, class_decoder=None):
    if class_decoder == None:
        class_decoder = {label: idx for idx, label in enumerate(range(y_one_hot.shape[1]))}
    y_transfer = y_one_hot.copy()
    for idx, col in enumerate(y_transfer.T):
        # 注意，这里的col只是 y_transfer 的一个视图
        col[col == 1] = class_decoder[idx]
    y = np.max(y_transfer, axis=1).astype(int)
    return y.reshape(-1, 1)  # [r,1]
