from distutils.log import error
import os
from util import decorator
import joblib
import pandas as pd

# 宏定义 ni = no index
DATABASE = "./nidatabases/"
FIELD = "field.pkl"
BLOCK = "block.pkl"
BLOCKSIZE = 32

class NIDataBase:
    
    def __init__(self) -> None:
        self.curr_db = None
        self.curr_pk = "id" # FIXME: 默认id，先不管它
        if not os.path.exists(DATABASE):
            os.mkdir(DATABASE)
    
    @decorator
    def create_db(self,db_name:str):
        path = DATABASE+db_name
        isExists = os.path.exists(path)
        if isExists:
            print(f"数据库{db_name}已存在")
        else:
            os.mkdir(path)   #在databases文件夹下创建子文件夹
    
    @decorator
    def use_db(self,db_name):
        self.curr_db = db_name
        print("当前数据库为：",db_name)

    @decorator
    def create(self,t_name, cols, types, pk:str):
        # 文件夹
        tb_dir = DATABASE+self.curr_db+"/"+t_name+"/"
        tb_exists = os.path.exists(tb_dir)
        if tb_exists:
            print(f"表{t_name}已存在")
        else:
            os.mkdir(tb_dir)
            # 字段文件
            field = {}
            for i in range(0,len(cols)):
                field[cols[i]] = types[i]  
            self.__save_field(t_name, field)
            # 数据块文件
            block = []
            self.__save_block(t_name, block)
            # 元数据文件夹
            data_path = DATABASE+self.curr_db+"/"+t_name+"/data"
            os.mkdir(data_path)
            self.curr_pk = pk
       
    @decorator
    def insert(self,t_name:str, row:tuple, cols:tuple=None):
        field = self.__load_field(t_name)

        # 构造元数据
        metadata = {}
        for col in field.keys():
            metadata[col] = None # 占位（关系型数据库）
        
        # 赋值数据
        if cols is None:
            cols = list(metadata.keys())
        for i in range(0,len(row)):
            metadata[cols[i]] = row[i]
        pk_value = metadata[self.curr_pk]

        # 检查有无重复
        block = self.__load_block(t_name)
        for bid in range(0,len(block)):
            num = block[bid]
            if num==0:
                continue
            df = self.__load_df(t_name,bid)
            for lid in range(0,BLOCKSIZE):
                if num&1: # 存在数值
                    if df.loc[lid,self.curr_pk]==pk_value:  # 判断主键
                        print(f"主键为{metadata[self.curr_pk]}的数据已存在，无法插入！")
                        return
                num >>=1

        # 数据块的确定
        bid,lid = self.__get_available_bl(block)
        # 数据存储
        if bid==-1:  
            # 新增块
            bid = len(block)
            lid = 0
            block.append(1<<lid)
            print(f"新增数据块：{bid}")
            df = pd.DataFrame(columns=cols)
        else:
            block[bid] |= (1<<lid)  # block置位
            df = self.__load_df(t_name, bid)
        print(f"块{bid},行{lid}，主键为{pk_value}")
        df.loc[lid] = metadata
        # save
        self.__save_df(t_name, bid, df)
        self.__save_block(t_name, block)

    @decorator
    def delete(self,t_name,pk_value):
        block = self.__load_block(t_name)
        for bid in range(0,len(block)):
            num = block[bid]
            if num==0:
                continue
            df = self.__load_df(t_name,bid)
            for lid in range(0,BLOCKSIZE):
                if num&1: # 存在数值
                    if df.loc[lid,self.curr_pk]==pk_value:  # 判断主键
                        print(f"删除主键为{pk_value}的数据")
                        block[bid] &= ~(1<<lid)
                        self.__save_block(t_name, block)
                        return
                num >>=1
        print(f"主键为{pk_value}的数据不存在")
        return

    @decorator
    def update(self,t_name,update_col,update_value,pk_value):
        block = self.__load_block(t_name)
        for bid in range(0,len(block)):
            num = block[bid]
            if num==0:
                continue
            df = self.__load_df(t_name,bid)
            for lid in range(0,BLOCKSIZE):
                if num&1: # 存在数值
                    if df.loc[lid,self.curr_pk]==pk_value:  # 判断主键
                        df.loc[lid,update_col] = update_value
                        self.__save_df(t_name,bid,df)
                        return
                num >>=1
        print(f"主键为{pk_value}的数据不存在")

    @decorator
    def select(self,t_name,sel_cols,pk_value=None):
        for item in sel_cols:
            print(item,end="\t")
        print("\n"+"--\t"*(len(sel_cols)))
        block = self.__load_block(t_name)
        if pk_value:
            for bid in range(0,len(block)):
                num = block[bid]
                if num==0:
                    continue
                df = self.__load_df(t_name,bid)
                for lid in range(0,BLOCKSIZE):
                    if num&1: # 存在数值
                        if df.loc[lid,self.curr_pk]==pk_value:  # 判断主键
                            for item in sel_cols:
                                print(df.loc[lid,item],end="\t")
                            print()
                            return
                    num >>=1
            print(f"主键为{pk_value}的数据不存在")
        else:
            for bid in range(0,len(block)):
                num = block[bid]
                if num==0:
                    continue
                df = self.__load_df(t_name,bid)
                for lid in range(0,BLOCKSIZE):
                    if num&1: # 存在数值
                        for item in sel_cols:
                            print(df.loc[lid,item],end="\t")
                        print()
                    num >>=1
    
    def __load_field(self,t_name) -> dict: 
        path = os.path.join(DATABASE,self.curr_db,t_name,FIELD)
        return joblib.load(path)
    
    def __load_df(self,t_name,bid)->pd.DataFrame:
        path = os.path.join(DATABASE,self.curr_db,t_name,"data",f"{t_name}_{bid}.csv")
        return pd.read_csv(path)

    def __load_block(self,t_name) -> list:
        path = os.path.join(DATABASE,self.curr_db,t_name,BLOCK)
        return joblib.load(path)

    def __save_field(self,t_name,field:dict):
        path = os.path.join(DATABASE,self.curr_db,t_name,FIELD)
        joblib.dump(field,path)

    def __save_block(self, t_name, block):
        path = os.path.join(DATABASE,self.curr_db,t_name,BLOCK)
        joblib.dump(block, path)

    def __save_df(self,t_name,bid,df:pd.DataFrame):
        path = os.path.join(DATABASE,self.curr_db,t_name,"data",f"{t_name}_{bid}.csv")
        return df.to_csv(path,index=False)

    def __get_available_bl(self,block:dict):
        for i in range(0,len(block)):
            a = block[i]
            if a==0:
                continue
            for j in range(0,BLOCKSIZE):
                if a&1==0: # 不存在数值
                    return i,j
                a >>=1
        return -1,-1