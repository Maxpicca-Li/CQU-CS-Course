import numpy as np
import matplotlib.pyplot as plt
from utils import my_save_fig


def _sigmoid(z):
    return 1.0 / (1.0 + np.exp(-z))


class MyLogisticRegression:
    '''
    自定义对数几率回归，实现牛顿法和梯度下降法计算
    '''

    def __init__(self, method="drop", lr=0.1, max_iter=10000, seed=None, episilon=1e-6) -> None:
        '''
        模型初始化
        :param method: ["drop","Newton"] 求解梯度方法。注意：数据较多较杂时，使用Newton法，其二阶导数难以求出，建议选择drop法
        :param lr:学习率
        :param max_iter:最大迭代次数
        :param seed:随机数种子
        :param episilon:计算精度
        '''
        methods = ["drop", "Newton"]
        if method not in methods:
            method = "drop"
        if seed is not None:
            np.random.seed(seed)
        self.lr = lr
        self.max_iter = max_iter  # 优化次数限制，防止无限循环
        self.method = method
        self.episilon = episilon  # 计算精度

    def fit(self, X, Y):
        '''
        自定义对数几率回归，牛顿法进行训练\n
        参考资料：\n
        - 《机器学习》-周志华\n
        - 框架参考 https://zhuanlan.zhihu.com/p/36670444 \n
        :param X:
        :param Y:
        :return:
        '''
        self.X = X
        self.Y = Y
        self.train_score_list = []  # 准确率得分
        self.train_loss_list = []  # 损失函数
        self.new_X = np.hstack([X, np.ones([X.shape[0], 1])])

        self.beta = np.random.random([self.new_X.shape[1], 1])
        for i in range(0, self.max_iter):
            delta = self.cal_grad_drop()
            # delta = self.cal_grad_Newton()
            if np.abs(np.max(delta)) < self.episilon:
                break
            self.beta = self.beta - delta
            self.train_loss_list.append(self.loss())
            self.train_score_list.append(self.score())

        # print("迭代次数：", i)
        self.coef_ = self.beta[:-1]
        self.intercept_ = self.beta[-1]

    def one_diff(self):
        ''' 求解一阶导数 '''
        p1 = self.predict_prob()  # 计算属于正类的概率
        one_diff = -np.sum(np.multiply(self.new_X, self.Y - p1), axis=0)
        # one_diff = -np.mean(self.new_X*(self.Y - p1),axis=0)
        one_diff = one_diff[:, np.newaxis]
        return one_diff

    def double_diff(self):
        ''' 求解二阶导数 '''
        p1 = self.predict_prob()  # 计算属于正类的概率
        samples_num, features_num = self.new_X.shape

        double_diff = np.zeros([features_num, features_num])
        for i, a in enumerate(self.new_X):
            a = a[:, np.newaxis]  # (3,1)
            double_diff += np.dot(a, a.T) * p1[i] * (1 - p1[i])
        return double_diff

    def cal_grad_Newton(self):
        '''
        牛顿法计算梯度：\n
        beta* = beta - np.linalg.inv(double_diff).dot(one_diff)\n
        '''
        return np.dot(np.linalg.inv(self.double_diff()), self.one_diff())

    def cal_grad_drop(self):
        '''
        梯度下降法计算梯度：\n
        beta* = beta - lr * one_diff \n
        NOTE:计算iris数据时，double_diff会非常小，inv(double_diff)会非常大，以至于beta非常大，计算就会出现误差，暂且不明白原因，所以提供了梯度下降法
        '''
        return self.lr * self.one_diff()

    def predict_prob(self, x=None):
        ''' 计算预测概率 '''
        if x is None:
            x = self.X
        new_X = np.hstack([x, np.ones([x.shape[0], 1])])
        pred_prob = _sigmoid(np.dot(new_X, self.beta))
        return pred_prob

    def predict(self, x=None):
        '''计算预测值'''
        if x is None:
            x = self.X
        if len(x.shape) == 1:
            x = x[np.newaxis, :]
        pred_prob = self.predict_prob(x)
        pred = np.array([0 if i < 0.5 else 1 for i in pred_prob])
        pred = pred[:, np.newaxis]
        return pred

    def loss(self, y=None, pred_prob=None):
        '''计算损失函数'''
        if y is None or pred_prob is None:
            y = self.Y
            pred_prob = self.predict_prob(self.X)
        return -np.log(y * (pred_prob) + (1 - y) * (1 - pred_prob)).sum()

    def score(self, x=None, y=None):
        '''计算准确率'''
        if x is None or y is None:
            x = self.X
            y = self.Y
            pred = self.predict(x)
        return (y == pred).sum() / len(y)

    def draw_process(self, img_name=None):
        '''绘制训练过程'''
        fig, axs = plt.subplots(2, 1, sharex='row')
        fig.suptitle(img_name)
        plt.subplots_adjust(left=None, bottom=None, right=None, top=None, wspace=None, hspace=0.5)

        axs[0].plot(self.train_loss_list, '-')
        axs[0].set_title("loss")
        axs[1].plot(self.train_score_list, '-')
        axs[1].set_title("acc")

        if img_name is not None:
            my_save_fig(fig, img_name)
        plt.show()
