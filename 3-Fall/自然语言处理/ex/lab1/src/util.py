# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-12 17:47
# @Description: util

import re

# 非中文字符、数字、大小写字母等其他字符，替换为中文逗号
replacer = "([^\u4e00-\u9fa5\u0030-\u0039\u0041-\u005a\u0061-\u007a])"
# 数字、大小写字母直接去除（不替换其他元素）
remover = '[a-zA-Z0-9]'
# 分割中文标点符号
splitter = r',|\.|/|;|\'|`|\[|\]|<|>|\?|？|:|"|\{|\}|\~|!|@|#|\$|%|\^|&|\(|\)|-|=|\_|\+|，|。|、|；|‘|’|【|】|·|！| |…|（|）|：|《|》|——'


def text_preprocess(sentence):
    ''' 文本预处理，去除特殊字符、数字字符、大小写字母等 '''
    s1 = re.sub(replacer, "，", sentence)
    s2 = re.sub(remover, "", s1)
    s_list = re.split(splitter, s2)
    s_list = [s for s in s_list if len(s) > 0]
    return s_list


def score(true_list, pred_list):
    ''' 预测准确率计算 '''
    score = 0
    for i, j in zip(true_list, pred_list):
        if i == j:
            score += 1
    return score / len(true_list)
