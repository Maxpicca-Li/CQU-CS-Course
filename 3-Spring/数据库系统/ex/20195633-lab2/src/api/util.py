exit = "exit"
def edit_mode(edit_keys,edit_keys_limit=None, db=None):
    edit_dict = {}
    print("="*5+"进入修改模式"+"="*5)
    print("可修改属性：", edit_keys)
    while True:
        key = input("请输入属性（，输入%s退出）："%(exit))
        if key == exit:
            break
        if not key in edit_keys:
            print("输入的属性不在可修改属性范围内，请重新输入")
        if edit_keys_limit!=None and key in edit_keys_limit.keys():
            value = edit_keys_limit[key]("请输入属性值：",db)
        else:
            value = input("请输入属性值：")
        edit_dict[key] = value
    return edit_dict
