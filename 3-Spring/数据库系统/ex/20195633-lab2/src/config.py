import jaydebeapi

# 一些全局变量
JDBC_DRIVER = "org.postgresql.Driver"
DB_URL = "jdbc:postgresql://120.46.185.95:8000/finance?ApplicationName=app1"
USER = "db_user54"
PASS = "db_user@54"
JARFILE = './openGauss-1.1.0-JDBC/postgresql.jar'
DEPARTMENT = "department"
POSITION = "position"
EMPLOYEE = "employee"

# 数据库
class DataBase:
    def __init__(self):
        self.conn = None
        self.curs = None
        self.connect()
        
    def connect(self):
        self.conn = jaydebeapi.connect(JDBC_DRIVER,DB_URL,[USER,PASS],JARFILE)
        self.curs=self.conn.cursor()

    def close(self):
        # 先关闭游标
        if self.curs != None:
            self.curs.close()
        # 再关闭连接
        if self.conn != None:    
            self.conn.close()