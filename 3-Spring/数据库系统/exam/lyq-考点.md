## 题型

- 单选题（2分*10）
- 简答题（5分*4）
- 综合应用题（6分*5）
  - 蓝色部分

## 范围

**1、数据库应用**

1~12章

- 设计模型

  - 概念设计：需求分析

  - 逻辑设计：ER模型，关系模型

  - 物理设计：数据库操作，SQL

- 数据模型

  - 概念模型

  - 数据模型（逻辑模型）


- DBMS
  - 相比于文件的特点
  - 开发运行环节

```sql
# group by前用where，后用having
select dname,count(*) from employee where egender='男' group by dname
select dname,sum(esalary) as sumValue from employee group by dname order by sumValue
```

**2、数据库原理**

13~22章



**3、当前发展趋势**

23~26章

- 数据库管理系统：DBMS→ 运行软件

- 数据库系统：DBS → 运行系统

