# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-12 17:37 
# @Description: hmm

import pypinyin
import numpy as np
import time
import tqdm
import joblib
import logging
import sys
import os
from collections import Counter
from util import text_preprocess


class HMM:
    '''
    HMM(pi,A,B) ==> HMM(init_log, transition_log, emission_log)
    '''

    def __init__(self, datapath='data/toutiao_cat_data.txt'):
        '''
        初始化HMM模型，计算(init_log, transition_log, emission_log)的参数
        :param datapath:语料库路径
        '''
        self.word_counter = Counter()
        self.word_word = {}
        self.word_pinyin = {}
        self.pinyin_word = {}

        self.min_prob = 1e-10
        self.save_path = 'hmm_params.pkl'

        is_save = os.path.exists(self.save_path)
        start_time = time.time()
        if is_save:
            print('加载参数，开始初始化hmm...')
            self.load_params()
        else:
            print("来自", datapath, "的语料库，开始初始化hmm...")
            self.init_toutiao(datapath)
        print("用时", (time.time() - start_time) / 60, 'min\n')

    def init_toutiao(self, datapath, save=True):
        '''
        toutiao文本格式预览：\n
        6552407965343678723_!_101_!_news_culture_!_上联：黄山黄河黄皮肤黄土高原。怎么对下联？_!_\n
        '''
        cnt = 0
        with open(datapath, encoding="utf-8") as f:
            for line in tqdm.tqdm(f):
                line = line.strip()
                # 提取倒数第一、二个语句
                sentence = ','.join(line.split('_!_')[-2:])
                sent_list = text_preprocess(sentence)
                for sent in sent_list:
                    # 跳过空语句
                    if len(sent) == 0:
                        continue

                    # 更新字（单字列表）
                    self.word_counter.update(sent)

                    # 更新双字（字列表last_curr）
                    for last, curr in zip(list(sent)[:-1], list(sent)[1:]):
                        if self.word_word.get(last) == None:
                            # 添加新字
                            self.word_word[last] = Counter()
                        self.word_word[last].update([curr])

                    # 获取拼音，并验证word_pinyin
                    pinyin_list = pypinyin.lazy_pinyin(sent)
                    if len(sent) != len(pinyin_list):
                        logging.error('字符、拼音无法对应\n', sent, '\n', pinyin_list)
                        sys.exit(-1)

                    # 更新拼音（拼音列表）
                    for word, pinyin in zip(list(sent), pinyin_list):
                        if self.word_pinyin.get(word) == None:
                            # 添加新字
                            self.word_pinyin[word] = Counter()
                        self.word_pinyin[word].update([pinyin])

                    # 语句计数
                    cnt += 1

        # 获取pinyin_word的映射关系，便于根据拼音获取状态
        for word in self.word_pinyin:
            for pinyin in self.word_pinyin[word].keys():
                if self.pinyin_word.get(pinyin) == None:
                    self.pinyin_word[pinyin] = set()
                self.pinyin_word[pinyin].add(word)

        # 保存HMM模型训练参数
        if save:
            self.save_params()

        # 输出结果        
        print("初始化完毕，共处理断句", cnt, "条。")  # 共处理句子 382688 条  # 用时 7.137720946470896 min

    def save_params(self):
        ''' 保存模型的4个参数 '''
        hmm_params = [self.word_counter, self.word_word, self.word_pinyin, self.pinyin_word]
        joblib.dump(hmm_params, self.save_path)

    def load_params(self):
        ''' 加载模型的4个参数 '''
        self.word_counter, self.word_word, self.word_pinyin, self.pinyin_word = joblib.load(self.save_path)

    def get_init_log(self, pinyin):
        ''' 根据pinyin获取初始状态词，并根据频率计算其出现的概率log值'''
        init_log = {}
        init_word_set = self.get_curr_candidate_set(pinyin)
        n_total = 0

        for word in init_word_set:
            n_total += self.word_counter[word]
        for word in init_word_set:
            init_log[word] = np.log10(self.word_counter[word] / n_total)
        return init_word_set, init_log

    def get_emission_log(self, word, pinyin):
        ''' 计算 word_pinyin的发射概率 '''
        n_total = sum(self.word_pinyin[word].values())
        emission_prob = self.word_pinyin[word][pinyin] / n_total
        return np.log10(max(emission_prob, self.min_prob))

    def get_transition_log(self, last, curr):
        ''' 计算 last_curr 的状态转移概率 '''
        if self.word_word.get(last) == None:
            return np.log(self.min_prob)
        n_total = sum(self.word_word[last].values())
        transition_prob = self.word_word[last][curr] / n_total
        return np.log(max(transition_prob, self.min_prob))

    def get_curr_candidate_set(self, pinyin, last_delta=None):
        ''' 确定搜索空间 '''
        curr_search_set = set()

        # 获取pinyin对应的字列表
        if self.pinyin_word.get(pinyin) != None:
            curr_search_set.update(self.pinyin_word[pinyin])
        else:
            # 当该pinyin不存在于语料库时
            if last_delta == None:
                # 方法一：所有词语作为搜索空间
                curr_search_set.update(self.word_counter.keys())
            else:
                # 方法二：获取上一个最大出现概率的词，对应的word_word的所有词
                k = -1
                lastk_word = sorted(zip(last_delta.keys(), last_delta.values()), key=lambda x: x[1])[k:]
                for last, _ in lastk_word:
                    if self.word_word.get(last) != None:
                        curr_search_set.update(self.word_word[last].keys())

        return curr_search_set
