import time
from hmm import HMM
from util import score
from viterbi import pinyin2hanzi


def sent_test(model, pinyin, sent):
    '''
    hmm语句测试
    :param model: hmm模型
    :param pinyin: 测试拼音
    :param sent: 具体句子
    '''
    start_time = time.time()
    print("拼   音：", pinyin)
    print("真实句子：", sent)

    # 预测
    pinyin = str.lower(pinyin)
    pinyin_list = pinyin.split(" ")
    pred_list, max_prob = pinyin2hanzi(model, pinyin_list)
    print("预测结果：", "".join(pred_list), )
    print("max_prob=%.3f,acc=%.3f" % (max_prob, score(list(sent), pred_list)))
    print("用时：%.3fs" % (time.time() - start_time))
    print()

if __name__ == '__main__':
    test_filepath = 'data/测试集.txt'
    test_pinyin = None
    test_sent = None
    model = HMM()

    # 获取测试句子
    with open(test_filepath, 'r') as f:
        i = 0
        for line in f:
            i += 1
            line = line.strip()
            if i % 2:
                test_pinyin = line
            else:
                test_sent = line
                sent_test(model, test_pinyin, test_sent)


