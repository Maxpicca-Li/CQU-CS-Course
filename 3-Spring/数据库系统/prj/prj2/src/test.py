import os
from util import generate_random_str
import shutil
import random
import time
from DateBase import DataBase
from NIDataBase import NIDataBase
import sys

# 全局变量
# name长度控制
down = 5
up = 10
test_num = 500
new_num = 10 # [10, new_num)
global_name_age = []
global_age = []

def test(db):
    global test_num
    global new_num
    st = time.time()
    db.create_db("test")
    db.use_db("test")
    ''' 创建测试 '''
    db.create("t1",["id","name","age"],["int","str","int"],"id")


    ''' insert 测试'''
    for i in range(0,test_num):
        name,age = global_name_age[i]
        db.insert("t1",(i,name,age))

    ''' update测试 '''
    db.update("t1","name","Maxpicca",0)  # UPDATE t1 SET age=2 where id=1
    db.update("t1","age","19",0)
    db.update("t1","name","Yangtze",1)
    db.update("t1","age","21",1)

    ''' 删除覆盖测试 '''
    db.delete("t1",10)
    db.delete("t1",499)
    db.insert("t1",(499,"YangXuFeng",22))  # 物理行为10，主键为499

    ''' 删除覆盖测试2 '''
    for i in range(10,new_num):
        db.delete("t1",i)
        name = "DBUSER"+str(i)
        age = global_age[i]
        db.insert("t1",(i,name,age))

    ''' select测试'''
    db.select("t1",["name","age"],499)
    db.select("t1",["name","age"])

    et = time.time()
    print("用时%.3fs"%(et-st))

def get_random_value():
    global test_num
    global new_num
    for i in range(0,test_num):
        name = generate_random_str(down,up)
        age = random.randint(0,100)
        global_name_age.append((name,age))
    for i in range(0,new_num):
        age = random.randint(0,100)
        global_age.append(age)

def init():
    global test_num
    global new_num
    if os.path.exists("./databases"):
        shutil.rmtree("./databases/")
    if os.path.exists("./nidatabases"):
        shutil.rmtree("./nidatabases/")
    s = input("请输入测试数据量，默认为500: ")
    test_num = 500 if s=="" else int(s)
    s = input("请输入重置数据量，默认为20: ")
    new_num = 20 if s=="" else int(s)
    get_random_value()

if __name__=="__main__":
    init()
    print(f"测试量：{test_num}, 重置数据量：{new_num}")
    
    save_stdout = sys.stdout #保存标准输出流
    with open('DataBase.log', 'w+') as file:
        sys.stdout = file #标准输出重定向至文件
        db = DataBase()
        test(db)
    
    with open('NIDataBase.log', 'w+') as file:
        sys.stdout = file #标准输出重定向至文件
        db = NIDataBase()
        test(db)
    
    sys.stdout = save_stdout #恢复标准输出流