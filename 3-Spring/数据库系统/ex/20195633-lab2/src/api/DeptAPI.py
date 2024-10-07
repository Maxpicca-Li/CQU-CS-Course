import config
from config import DEPARTMENT
from model import DeptModel
from dao import UnifiedDao
from api.util import edit_mode

table = DEPARTMENT
keys = ['did','dname', 'dinfo']
edit_keys = ['dname', 'dinfo']

def add_dept(db):
    # 操作提示
    did = int(input("请输入部门编号（需为正整数）："))
    dname = input("请输入部门名字（不超过10个字符串）：")
    dinfo = input("请输入部门描述：")
    dept = DeptModel.Dept(did=did,dname=dname,dinfo=dinfo)
    UnifiedDao._add(dept,db,table)

def edit_dept(db):
    # 编辑部门
    did = int(input("请输入需要编辑的部门编号（需为正整数）："))
    key = "did"
    value = did
    old = UnifiedDao._get_spec(key, value, db, table)
    if len(old)==0:
        print("不存在该数据")
        return
    print("旧数据:",old)
        
    edit_dict = edit_mode(edit_keys)
    UnifiedDao._edit(key, value, edit_dict, db, table)

    new = UnifiedDao._get_spec(key, value, db,table)
    print("新数据:",new)

def del_dept(db):
    did = int(input("请输入需要删除的部门编号（需为正整数）："))
    key = "did"
    value = did
    UnifiedDao._edit(key,value,{key:0},db,config.EMPLOYEE)
    UnifiedDao._del(key, value, db, table)

def get_all_dept(db):
    results = UnifiedDao._get_all(db,table)
    for i in keys:
        print(i,end='\t')
    print()
    for res in results:
        for i in res:
            print(i,end='\t')
        print()

def add_default_dept(db):
    depts = UnifiedDao._get_all(db,table)
    dept_list = []
    for dept in depts:
        dept_list.append(dept[0])
    if not 0 in dept_list:
        dept = DeptModel.Dept(did=0,dname="临时部门",dinfo="临时部门")
        UnifiedDao._add(dept,db,table)