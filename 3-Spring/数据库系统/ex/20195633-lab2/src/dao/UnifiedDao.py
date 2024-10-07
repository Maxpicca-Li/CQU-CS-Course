from pydantic import BaseModel


def _add(model:BaseModel, db, table):
    res = model.dict()
    values = ""
    for k in res:
        values += "'" + str(res[k]) + "'" + ','
    values = values[:-1]
    sql = "INSERT INTO %s VALUES (%s)"%(table, values)
    try:
        db.curs.execute(sql)
    except:
        print(sql)
        db.conn.rollback()

def _edit(key, value, edit_dict, db, table):
    sql = "UPDATE %s "%(table)
    flag = 1
    for k in edit_dict:
        if flag:
            sql += "SET %s = '%s'"%(k, edit_dict[k])
            flag = 0
        else:
            sql += ", %s = '%s'"%(k, edit_dict[k])
    sql += " WHERE %s = '%s'"%(key,value)
    try:
        db.curs.execute(sql)  # 执行数据库语句
    except:
        print(sql)
        db.conn.rollback()

def _del(key,value,db, table):
    # 删除某行数据的数据库语句
    sql = "DELETE FROM %s WHERE %s = '%s'" % (table, key, value)
    try:
        db.curs.execute(sql)
    except:
        print(sql)
        db.conn.rollback()

def _get_all(db, table):
    sql = "SELECT * FROM %s" % (table)
    results = None
    try:
        db.curs.execute(sql)
        results = db.curs.fetchall()  # 获取所有数据
    except:
        print(sql)
        db.conn.rollback()
    return results

def _get_spec(key, value, db, table):
    sql = "SELECT * FROM %s WHERE %s = '%s'" % (table, key, value)
    results = None
    try:
        db.curs.execute(sql)
        results = db.curs.fetchall()  # 获取所有数据
    except:
        print(sql)
        db.conn.rollback()
    return results
    