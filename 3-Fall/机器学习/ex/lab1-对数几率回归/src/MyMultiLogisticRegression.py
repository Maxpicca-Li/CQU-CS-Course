import numpy as np
from collections import Counter

from MyLogisticRegression import MyLogisticRegression
from utils import get_split_lists


class MyMultiLogisticRegression:
    '''
    以MyLogisticRegression为baseline的多分类模型
    '''

    def __init__(self, lr=0.1, max_iter=10000, seed=None, episilon=1e-6) -> None:
        if seed is not None:
            np.random.seed(seed)
        self.seed = seed
        self.lr = lr  # 学习率
        self.max_iter = max_iter  # 次数限制，防止无限循环
        self.episilon = episilon  # 计算精度

    def fit(self, train_X, train_Y):
        '''
        基于多个MyLogisticRegression实现多分类\n
        构建M个不同的分类器，并进行fit\n
        :param train_X:
        :param train_Y:
        :return:
        '''
        self.X = train_X
        self.Y = train_Y

        # TODO class_list，split_list，model_list 也许可以设置为私有变量
        self.class_list = list(set(train_Y.flatten()))  # set->list，好办事
        self.split_list = get_split_lists(len(self.class_list), seed=0)  # 每个分类器的数据，只需要重新构造0,1
        self.model_list = []
        for split in self.split_list:
            temp_Y = train_Y.copy()
            for idx, y in enumerate(self.class_list):
                temp_Y[temp_Y == y] = split[idx]
            model = MyLogisticRegression(lr=self.lr, max_iter=self.max_iter, seed=self.seed, episilon=self.episilon)
            model.fit(train_X, temp_Y)
            self.model_list.append(model)

    def predict(self, x=None):
        '''计算预测值'''
        if x is None:
            x = self.X.copy()
        pred = []
        if len(x.shape) == 1:
            return self.get_one_pred(x)
        else:
            for row in x:
                pred.append(self.get_one_pred(row))
        pred = np.array(pred)
        pred = pred[:, np.newaxis]
        return pred

    def get_one_pred(self, x):
        '''投票法获取单个预测值'''
        vote_cnt = Counter()
        for i, model in enumerate(self.model_list):
            temp_pred = model.predict(x)
            maybe_class_list = [self.class_list[idx] for idx, flag in enumerate(self.split_list[i]) if
                                flag == temp_pred]  # 有点长，慢慢看，其实很简单
            vote_cnt.update(maybe_class_list)
        one_pred = vote_cnt.most_common(n=1)[0][0]  # 获取最常见的类别，若有相同的，则按照字典序排序
        return one_pred

    def score(self, x=None, y=None):
        '''计算准确率'''
        if x is None or y is None:
            x = self.X
            y = self.Y
        pred = self.predict(x)
        return (y == pred).sum() / len(y)

    def get_params(self):
        '''获取模型参数'''
        print("=" * 20 + "模型参数" + "=" * 20)
        print("model\tcoef_\t\t\tintercept_")
        for i, model in enumerate(self.model_list):
            print(f'{i}\t{model.coef_.flatten().tolist()}\t{model.intercept_}')

    def draw_process(self, img_name=None):
        '''绘制训练过程'''
        for i, model in enumerate(self.model_list):
            model  # type:MyLogisticRegression
            model.draw_process(img_name="LR" + str(i) + " Trian Process")