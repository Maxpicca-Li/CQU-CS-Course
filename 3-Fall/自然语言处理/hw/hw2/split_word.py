# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-23 20:05 
# @Description: split_word

from collections import Counter


def get_cn_ciku(filepath='../中文分词词库整理/30万 中文分词词库.txt'):
    ciku = Counter()
    with open(filepath, 'r') as f:
        for line in f:
            line = line.strip().split("\t")
            ciku.update([line[1]])
    return ciku


def forward_split(ciku, sent):
    ''' 前向算法 '''
    last = 0
    res = []
    for i in range(0 + 1, len(sent) + 1):
        word = sent[last:i]
        if i == len(sent):
            res.append(word)
            break
        unsure = sent[last:i + 1]
        if ciku[unsure] == 0:
            res.append(word)
            last = i
    return res


def backward_split(ciku, sent):
    ''' 后向算法 '''
    res = []
    last = len(sent)
    for i in range(len(sent) - 1 , -1, -1):
        word = sent[i:last]
        if i == 0:
            res.append(word)
            break
        unsure = sent[i - 1:last]
        if ciku[unsure] == 0:
            res.append(word)
            last = i
    res = res[::-1]
    return res

if __name__ =='__main__':
    fpath='30万 中文分词词库.txt'
    ciku = get_cn_ciku(fpath)
    sents = [
        '傻电脑每次关机后开机显卡几乎都要挂',
        '今天终于受不了了，所以就查了一下有没有其他的解决方案，然后就愉快的解决啦。',
        '我们经常有意见分歧',
        '他是研究生物化学的。'
    ]
    for sent in sents:
        print('初始句子:',sent)
        print('前向分割:',"/".join(forward_split(ciku,sent)))
        print('后向分割:',"/".join(backward_split(ciku, sent)))
        print()