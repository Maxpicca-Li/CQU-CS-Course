from pydantic import BaseModel

class Dept(BaseModel):
    did: int
    dname: str
    dinfo: str = "无部门描述"
