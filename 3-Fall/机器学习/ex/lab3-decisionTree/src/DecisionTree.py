# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-18 19:04 
# @Description: DecisionTree

import numpy as np
import os
from collections import Counter
from MLutil import squared_error
import joblib
from pyecharts import options as opts
from pyecharts.charts import Tree


def cal_gini(y):
    ''' 计算基尼值 '''
    y = y.flatten()
    num = len(y)
    y_cnt = Counter(list(y))
    gini = 1 - sum(list(map(lambda k: (y_cnt[k] / num) ** 2, list(y_cnt.keys()))))
    return gini


def cal_gini_index(sub_datalist, n_output, data):
    ''' 计算基尼指数 '''
    father_len = len(data)
    res = map(lambda x: len(x) / father_len * cal_gini(x[:, -n_output]),sub_datalist)
    res = sum(list(res))
    return res


def cal_squared_error(sub_datalist, n_output, data=None):
    ''' 计算误差平方和，其中data=None是为了保证接口一致性 '''
    res = map(lambda x: squared_error(x[:, -n_output], x[:, -n_output].mean(axis=0)),sub_datalist)
    res = sum(list(res))
    return res


TYPE_LIST = ['classfier', 'regressor']
CRITERION = {'classfier': cal_gini_index, 'regressor': cal_squared_error, }


class DecisionTreeBase:
    ''' 决策树基类实现 '''
    def __init__(self, type='classfier', min_samples_leaf=1, criterion_threshold=None, max_depth=None, load_path=None,
                 save_path=None, islog=False):
        '''
        决策树基类初始化
        :param type: ['classfier', 'regressor'] 决策器类别
        :param min_samples_leaf: 最小叶子结点对应样本集数目
        :param criterion_threshold: 最优属性选择阈值
        :param max_depth: 最大的深度
        :param load_path: 参数 load
        :param save_path: 参数 save
        :param islog: 是否开启debug模式
        '''
        if type not in TYPE_LIST:
            print("输入类型错误")
            return
        self.type = type
        self.criterion_threshold = criterion_threshold
        self.max_depth = max_depth if max_depth is not None else 1000
        self.min_samples_leaf = min_samples_leaf
        self.n_samples = 0
        self.n_features = 0
        self.n_outputs = 0
        self.islog = islog
        self.tree = None
        self.load_path = load_path
        self.save_path = save_path

    def fit(self, X, y):
        # 数据预处理
        if y.ndim == 1:
            y = y.reshape((-1, 1))
        data = np.hstack((X, y))

        # 属性获取
        self.n_samples = len(data)
        self.n_features = X.shape[1]
        self.n_outputs = y.shape[1]

        # 训练过程变量
        self.actual_max_depth = 0
        self.node_num = 0
        self.leaf_num = 0

        if self.load_path is not None:
            # load 参数
            self.tree = self.load_params()
        else:
            # 生成树
            self.tree = self.tree_generate(data, 0)

        if self.save_path is not None:
            # 保存参数
            self.save_params()

    def get_node(self, depth):
        ''' 结点创建 '''
        node = {
            'depth': depth,  # 根据函数传递递增
            'is_leaf': False,
            'leaf_value': None,
            'best_fidx': None,
            'best_fvalue': None,
            'sub_node': [],
        }
        self.node_num += 1
        return node

    def get_leaf(self, node, leaf_value):
        ''' 叶结点创建 '''
        node['is_leaf'] = True
        node['leaf_value'] = leaf_value
        self.leaf_num += 1
        return node

    def tree_generate(self, data, depth):
        ''' 以字典的形式，深度优先递归创建树 '''
        if self.islog:
            print("数据长度:%d, 深度:%d\n" % (len(data), depth))

        # 最大高度设置
        self.actual_max_depth = max(self.actual_max_depth, depth)

        # 数据信息获取
        y = data[:, -self.n_outputs]
        leaf_value = 0
        y_cnt = Counter(list(y))

        # 获取叶结点的可能值
        if self.type == TYPE_LIST[0]:  # 分类
            leaf_value = y_cnt.most_common(1)[0][0]
        elif self.type == TYPE_LIST[1]:  # 回归
            leaf_value = y.mean()

        # 生成节点
        node = self.get_node(depth)

        # 样本数量过少
        if len(data) <= self.min_samples_leaf:
            return self.get_leaf(node, leaf_value)

        # data中的样本属于一类
        if len(y_cnt)==1:
            return self.get_leaf(node, leaf_value)

        # 特征为空，或data的样本值都一样，则返回样本数量最多的一类
        # 注：连续值数据，不需要考虑特征为空的情况

        # 深度限制，返回样本数量最多的一类的label
        if depth >= self.max_depth:
            return self.get_leaf(node, leaf_value)

        # 选择最优划分属性 fidx 和 fvalue
        min_criterion = float('inf')
        min_fvalue = 0
        min_fidx = 0
        min_sub_datalist = []
        for fidx in range(0, self.n_features):
            fvalue, fgini, f_sub_datalist = self.cal_continuous_criterion(data, fidx)
            if fgini < min_criterion:
                min_criterion = fgini
                min_fvalue = fvalue
                min_fidx = fidx
                min_sub_datalist = f_sub_datalist
        node['best_fidx'] = min_fidx
        node['best_fvalue'] = min_fvalue

        # 最优属性选择阈值判断
        if self.criterion_threshold is not None and min_criterion > self.criterion_threshold:
            return self.get_leaf(node, leaf_value)

        # 递归子集
        for sub_data in min_sub_datalist:
            if len(sub_data) == 0:
                return self.get_leaf(node, leaf_value)
            else:
                node['sub_node'].append(self.tree_generate(sub_data, depth + 1))

        return node

    def cal_continuous_criterion(self, data, f_idx):
        ''' 计算连续属性值的最优划分度量值 '''
        # 获取所有可能的取值，并从小到达排序
        f_values = list(set(data[:, f_idx]))
        f_values.sort()

        # 开始选择最小的候选值
        min_criterion = float('inf')
        min_fvalue = 0
        min_sub_datalist = []
        for i in range(len(f_values) - 1):
            # 计算后候选值
            f_value = (f_values[i] + f_values[i + 1]) / 2

            # 获取子集
            sub_datalist = []
            data1 = data[data[:, f_idx] >= f_value]
            data2 = data[data[:, f_idx] < f_value]
            sub_datalist.append(data1)
            sub_datalist.append(data2)

            # 计算最小的基尼指数
            f_criterion = CRITERION[self.type](sub_datalist, self.n_outputs, data)
            if f_criterion < min_criterion:
                min_criterion = f_criterion
                min_fvalue = f_value
                min_sub_datalist = sub_datalist

        return min_fvalue, min_criterion, min_sub_datalist

    def predict(self, X):
        ''' 深度优先递归决策树，进行预测 '''
        def f(node, x):
            if node['is_leaf']:
                return node['leaf_value']
            else:
                fidx = node['best_fidx']
                fvalue = node['best_fvalue']
                sub_id = 0 if x[fidx] >= fvalue else 1
                return f(node['sub_node'][sub_id], x)

        y_pred = np.zeros((len(X), 1))
        for i, r in enumerate(X):
            y_pred[i][0] = f(self.tree, r)
        return y_pred

    def save_params(self):
        ''' 保存参数 '''
        if self.save_path is not None:
            joblib.dump(self.tree, self.save_path)

    def load_params(self):
        ''' 加载参数 '''
        if self.load_path is not None:
            return joblib.load(self.load_path)

    def plot(self,save_path,feature_name=None,y_name=None):
        ''' 绘制决策树 '''
        def f(node):
            data = {}
            if node['is_leaf']:
                data['name'] = y_name[node['leaf_value']] if y_name is not None else node['leaf_value']
                return data
            else:
                fidx = node['best_fidx']
                fvalue = node['best_fvalue']
                if feature_name is None:
                    data['name'] = "%d:%.3f"%(fidx,fvalue)
                else:
                    data['name'] = "%s:%.3f"%(feature_name[fidx],fvalue)
                data['children']=[]
                for sub_node in node['sub_node']:
                    data['children'].append(f(sub_node))
                return data

        # 深度优先遍历，确认children
        data = f(self.tree)
        file_name = os.path.basename(save_path)
        if save_path.split('.')[-1]!='html':
            print("文件名需要以html结尾")
            return
        c = (
            Tree()
            .add("",[data],orient='TB') # 从上至下绘制
            .set_global_opts(title_opts=opts.TitleOpts(title=file_name))
            .render(save_path)
        )


class DecisionTreeClassifier(DecisionTreeBase):
    ''' 决策树分类器 '''
    def __init__(self, min_samples_leaf=1, gini_threshold=None, max_depth=None, load_path=None, save_path=None,
                 islog=False):
        super().__init__(type='classfier', min_samples_leaf=min_samples_leaf, criterion_threshold=gini_threshold,
            max_depth=max_depth, load_path=load_path, save_path=save_path, islog=islog, )


class DecisionTreeRegressor(DecisionTreeBase):
    ''' 决策树回归器 '''
    def __init__(self, min_samples_leaf=1, loss_threshold=None, max_depth=None, load_path=None, save_path=None,
                 islog=False):
        super().__init__(type='regressor', min_samples_leaf=min_samples_leaf, criterion_threshold=loss_threshold,
            max_depth=max_depth, load_path=load_path, save_path=save_path, islog=islog, )
