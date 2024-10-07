import time
import random
base_str = 'ABCDEFGHIGKLMNOPQRSTUVWXYZabcdefghigklmnopqrstuvwxyz0123456789'
def generate_random_str(down,up):
    """
    生成一个指定长度的随机字符串
    """
    random_str = ''
    length = len(base_str) - 1
    str_len = random.randint(down, up)
    for i in range(str_len):
        random_str += base_str[random.randint(0,length)]
    return random_str


def decorator(func):
    def wrapper(*args, **kvargs):
        st=time.time()#----->函数运行前时间
        # print(func.__name__+":")
        func(*args, **kvargs)
        et=time.time()#----->函数运行后时间
        print("消耗时间为%.5fs"%(et-st))
        with open("time.log","a+") as f:
            print("%.5f"%(et-st),file=f)
    return wrapper  # ---->装饰器其实是对闭包的一个应用
