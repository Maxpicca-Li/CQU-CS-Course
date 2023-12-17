# -*- codeing = utf-8 -*-
# @Author: Maxpicca
# @Time: 2021-11-12 17:40
# @Description: viterbi

def pinyin2hanzi(model, pinyin_list):
    '''
    viterbi算法，计算给定显状态pinyin序列，求解最优的隐状态汉字序列
    :param model: hmm模型
    :param pinyin_list: 显状态pinyin序列
    :return:
        - pred_sent: 预测的语句
        - max_prob: 最大预测概率
    '''
    delta = [{} for i in range(len(pinyin_list))]

    # 状态初始化
    i = 0
    pinyin = pinyin_list[i]
    init_word_set, init_log = model.get_init_log(pinyin)
    for word in init_word_set:
        delta[0][word] = init_log[word] + model.get_emission_log(word,pinyin)
        
    # 状态前推
    max_last = [{} for i in range(len(pinyin_list))]
    for i in range(1,len(pinyin_list)):
        pinyin = pinyin_list[i]
        curr_candidate_set = model.get_curr_candidate_set(pinyin, delta[i - 1])
        for curr in curr_candidate_set:
            max_tran_log = -float('inf')
            max_tran_last = None
            for last in delta[i-1].keys():
                tran_value = delta[i-1][last]+model.get_transition_log(last,curr)
                if tran_value >= max_tran_log:
                    max_tran_log = tran_value
                    max_tran_last = last
            delta[i][curr] = max_tran_log + model.get_emission_log(curr,pinyin)
            max_last[i][curr] = max_tran_last

    # 获取最后的最大概率对应的状态字
    pred_sent = ['*' for i in range(len(pinyin_list))]
    last_i = len(pinyin_list)-1
    pred_sent[last_i],max_prob = max(zip(delta[last_i].keys(),delta[last_i].values()),key=lambda x:x[1])

    # 后向递归路径
    for i in range(last_i,0,-1):
        pred_sent[i-1] = max_last[i][pred_sent[i]]
    return pred_sent,max_prob
