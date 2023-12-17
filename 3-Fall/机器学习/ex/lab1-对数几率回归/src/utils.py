import os
import numpy as np
from logging import error

image_cnt = 1


def my_save_fig(fig, img_name=None):
    global image_cnt
    if img_name is None:
        img_name = 'image' + str(image_cnt)
        image_cnt += 1
    save_path = os.path.join(os.getcwd(), img_name)
    fig.savefig(save_path, dpi=300, bbox_inches="tight", pad_inches=0.1)


def get_split_lists(N, M=None, seed=None):
    '''
    不重复生成M个长度为N的0，1序列
    :param N: 序列长度
    :param M: 序列个数
    :param seed: 随机数种子
    :return:
    '''
    if seed is not None:
        np.random.seed(seed)
    if M is None:
        M = N  # 默认OvR多分类方法
    if M > N*(N-1)/2:
        error("输入的M超过N*(N-1)/2的限制")
        return False
    split_list = []  # 输出结果为0,1代表二分类形式
    t = M
    while t:
        temp = np.random.randint(0, 2, N)
        if 0 <= sum(temp) < N:
            # 避免和已有split刚好相反
            flag = True
            for split in split_list:
                oxr_res = sum(split ^ temp)
                if oxr_res == N or oxr_res == 0:
                    flag = False
                    break
            if flag:
                split_list.append(temp)
                t -= 1
    return split_list
