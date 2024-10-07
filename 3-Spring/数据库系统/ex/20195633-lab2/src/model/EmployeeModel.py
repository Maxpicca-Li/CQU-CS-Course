from pydantic import BaseModel
from datetime import date

class Employee(BaseModel):
    eid:  int
    pid:  int
    did:  int
    ename:str
    sex:  str = "N"
    tel:  str 
    birth:date
    ebg:  str 
    einfo:str = '无个人描述'