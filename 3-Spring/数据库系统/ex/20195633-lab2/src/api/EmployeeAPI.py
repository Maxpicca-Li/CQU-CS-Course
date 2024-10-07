from datetime import datetime
import config
from model import EmployeeModel
from dao import UnifiedDao
from api.util import edit_mode

def get_right_did(msg, db):
    depts = UnifiedDao._get_all(db, config.DEPARTMENT)
    while True:
        print("可选择的部门：")
        dept_list = []
        for dept in depts:
            dept_list.append(dept[0])
            print(dept[0]," ", dept[1])
        did = int(input(msg))
        if did in dept_list:
            break
        print("部门编号不在可选择范围内")
    return did

def get_right_pid(msg, db):
    posis = UnifiedDao._get_all(db, config.POSITION)
    while True:
        print("可选择的职业：")
        posi_list = []
        for posi in posis:
            posi_list.append(posi[0])
            print(posi[0]," ", posi[1])
        pid = int(input(msg))
        if pid in posi_list:
            break
        print("职业编号不在可选择范围内")
    return pid

def get_right_sex(msg, db=None): # 统一接口
    while True:
        sex = input(msg)
        if sex in sex_list:
            break
        print("性别符号不在可选择范围内")
    return sex

table = config.EMPLOYEE
# 属性
keys = ['eid','pid','did','ename','sex','tel','birth','ebg','einfo']
edit_keys = ['pid','did','ename','sex','tel','birth','ebg','einfo']
edit_keys_limit = {
    "did":get_right_did,
    "pid":get_right_pid,
    "sex":get_right_sex,
}
sex_list = ['N','F','M']
    
def add_eee(db):
    eid = int(input("员工编号（需为正整数）："))
    ename = input("员工姓名（不超过10个字符串）：")
    did = get_right_did("员工所在部门编号：",db)
    pid = get_right_pid("员工所在职业编号：", db)
    sex = get_right_sex("员工性别（N,M,F）：")
    tel = input("员工电话号码：")
    birth = input("员工出生日期（如2022-05-17）：")
    birth = datetime.strptime(birth, "%Y-%m-%d").date()
    ebg = input("员工教育背景：")
    einfo = input("员工个人描述：")
    
    eee = EmployeeModel.Employee(
        eid = eid,
        pid = pid,
        did = did,
        ename = ename,
        sex = sex,
        tel = tel,
        birth = birth,
        ebg = ebg,
        einfo = einfo
    )
    UnifiedDao._add(eee,db,table)

def edit_eee(db):
    eid = int(input("请输入需要编辑的员工编号（需为正整数）："))
    key = "eid"
    value = eid
    old = UnifiedDao._get_spec(key, value, db, table)
    if len(old)==0:
        print("不存在该数据")
        return
    print("旧数据:",old)
    edit_dict = edit_mode(edit_keys,edit_keys_limit,db)
    UnifiedDao._edit(key, value, edit_dict, db, table)

    new = UnifiedDao._get_spec(key, value, db, table)
    print("新数据:",new)

def del_eee(db):
    eid = int(input("请输入需要删除的员工编号（需为正整数）："))
    key = "eid"
    value = eid
    UnifiedDao._del(key, value, db, table)

def get_all_eee(db):
    results = UnifiedDao._get_all(db,table)
    for i in keys:
        print(i,end='\t')
    print()
    for res in results:
        for i in res:
            print(i,end='\t')
        print()