import config
from config import POSITION
from model import PositionModel
from dao import UnifiedDao
from api.util import edit_mode

table = POSITION
# 属性
keys = ['pid','pname', 'baseSalary', 'pinfo']
edit_keys = ['pname', 'baseSalary', 'pinfo']

def add_posi(db):
    # 操作提示
    pid = int(input("请输入职位编号（需为正整数）："))
    pname = input("请输入职位名字（不超过10个字符串）：")
    baseSalary = input("请输入基础工资：")
    pinfo = input("请输入职位描述：")
    posi = PositionModel.Position(pid=pid,pname=pname,baseSalary=baseSalary,pinfo=pinfo)
    UnifiedDao._add(posi,db,table)

def edit_posi(db):
    pid = int(input("请输入需要编辑的职位编号（需为正整数）："))
    key = "pid"
    value = pid
    old = UnifiedDao._get_spec(key, value, db, table)
    if len(old)==0:
        print("不存在该数据")
        return
    print("旧数据:",old)
    edit_dict = edit_mode(edit_keys)
    UnifiedDao._edit(key, value, edit_dict, db, table)

    new = UnifiedDao._get_spec(key, value, db, table)
    print("新数据:",new)

def del_posi(db):
    pid = int(input("请输入需要删除的职位编号（需为正整数）："))
    key = "pid"
    value = pid
    # 其他员工岗位安置
    UnifiedDao._edit(key,value,{key:0},db,config.EMPLOYEE)
    UnifiedDao._del(key, value, db, table)

def get_all_posi(db):
    results = UnifiedDao._get_all(db,table)
    for i in keys:
        print(i,end='\t')
    print()
    for res in results:
        for i in res:
            print(i,end='\t')
        print()

def add_default_posi(db):
    posis = UnifiedDao._get_all(db,table)
    posi_list = []
    for posi in posis:
        posi_list.append(posi[0])
    if not 0 in posi_list:
        posi = PositionModel.Position(pid=0,pname="临时岗位",baseSalary=0,pinfo="临时岗位")
        UnifiedDao._add(posi,db,table)