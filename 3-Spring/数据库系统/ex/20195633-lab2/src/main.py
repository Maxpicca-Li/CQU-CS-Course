import sys
sys.path.append('./')
from config import DEPARTMENT, POSITION, EMPLOYEE, DataBase
from api import DeptAPI, EmployeeAPI, PositionAPI

infoIn = """
系统指令————
\texit 退出程序
\tdept 进入部门相关处理
\tposi 进入职业相关处理
\templ 进行员工相关处理"""
infoOp = '''
操作指令————
\tback 返回上一步
\tadd 增加一条数据
\tdel 删除一条数据
\tedit 修改一条数据
\tget 罗列所有数据'''

# 一个更邪恶更统一的方法，哈哈哈
cmd2table = {
    "dept":DEPARTMENT,
    "posi":POSITION,
    "empl":EMPLOYEE,
}

do2api = {
    "dept-add":DeptAPI.add_dept,
    "dept-del":DeptAPI.del_dept,
    "dept-edit":DeptAPI.edit_dept,
    "dept-get":DeptAPI.get_all_dept,
    "posi-add":PositionAPI.add_posi,
    "posi-del":PositionAPI.del_posi,
    "posi-edit":PositionAPI.edit_posi,
    "posi-get":PositionAPI.get_all_posi,
    "empl-add":EmployeeAPI.add_eee,
    "empl-del":EmployeeAPI.del_eee,
    "empl-edit":EmployeeAPI.edit_eee,
    "empl-get":EmployeeAPI.get_all_eee,
}

def init(db):
    DeptAPI.add_default_dept(db)
    PositionAPI.add_default_posi(db)
    

if __name__=='__main__':
    db = DataBase()
    init(db)
    # 循环运行，直至遇到exit退出
    # 系统说明
    print("="*20+"欢迎来到Maxpicca's Employee-Manager Command System"+"="*20)    
    print("现有数据表")
    print(DEPARTMENT + "(did, dname, dinfo)")
    print(POSITION + "(pid, pname, baseSalary, pinfo)")
    print(EMPLOYEE + "(eid, pid, did, ename, sex, tel, birth, ebg, einfo)")
    print("="*20+"请按照指定指令操作"+"="*20)

    while True:
        print(infoIn)
        cmd = input("请输入:")
        if cmd=="exit":
            break
        if not cmd in cmd2table:
            print("Error: 输入的系统指令有错误")
        while True:
            print(infoOp)
            op = input("请输入操作指令:")
            do = cmd+"-"+op # 执行相关程序
            if op=='back':
                break
            if do in do2api.keys():
                do2api[do](db)
            else:
                print("Error: 输入的操作指令有错误")

    db.close()
    print("="*20+"Maxpicca's Employee-Manager Command System"+"="*20)    