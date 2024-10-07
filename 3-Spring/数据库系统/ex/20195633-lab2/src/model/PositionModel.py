from pydantic import BaseModel

class Position(BaseModel):
    pid: int
    pname: str
    baseSalary: float = 0
    pinfo: str = "无职位描述"
