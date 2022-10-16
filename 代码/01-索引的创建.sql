# 01-索引的创建

#第1种：CREATE TABLE 

#隐式的方式创建索引。在声明有主键约束、唯一性约束、外键约束的字段上，会自动的添加相关的索引
CREATE DATABASE dbtest2;

USE dbtest2;

CREATE TABLE dept(
dept_id INT PRIMARY KEY AUTO_INCREMENT,
dept_name VARCHAR(20)
);

CREATE TABLE emp(
emp_id INT PRIMARY KEY AUTO_INCREMENT,
emp_name VARCHAR(20) UNIQUE,
dept_id INT,
CONSTRAINT emp_dept_id_fk FOREIGN KEY(dept_id) REFERENCES dept(dept_id)
);

#显式的方式创建：
#① 创建普通的索引
CREATE TABLE book(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR,
#声明索引
INDEX idx_bname(book_name)
);

#通过命令查看索引
#方式1：
SHOW CREATE TABLE book;

#方式2：
SHOW INDEX FROM book;

#性能分析工具：EXPLAIN
EXPLAIN SELECT * FROM book WHERE book_name = 'mysql高级';


#② 创建唯一索引
# 声明有唯一索引的字段，在添加数据时，要保证唯一性，但是可以添加null
CREATE TABLE book1(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR,
#声明索引
UNIQUE INDEX uk_idx_cmt(COMMENT)
);

SHOW INDEX FROM book1;

INSERT INTO book1(book_id,book_name,COMMENT)
VALUES(1,'Mysql高级','适合有数据库开发经验的人员学习');

INSERT INTO book1(book_id,book_name,COMMENT)
VALUES(2,'Mysql高级',NULL);

SELECT * FROM book1;

#③ 主键索引
#通过定义主键约束的方式定义主键索引
CREATE TABLE book2(
book_id INT PRIMARY KEY ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR
);

SHOW INDEX FROM book2;

#通过删除主键约束的方式删除主键索引
ALTER TABLE book2
DROP PRIMARY KEY;

#④ 创建单列索引
CREATE TABLE book3(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR,
#声明索引
UNIQUE INDEX idx_bname(book_name)
);

SHOW INDEX FROM book3;

#⑤ 创建联合索引
CREATE TABLE book4(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR,
#声明索引
INDEX mul_bid_bname_info(book_id,book_name,info)
);

SHOW INDEX FROM book4;

#分析
EXPLAIN SELECT * FROM book4 WHERE book_id = 1001 AND book_name = 'mysql';

EXPLAIN SELECT * FROM book4 WHERE book_name = 'mysql';

#⑥ 创建全文索引
CREATE TABLE test4(
id INT NOT NULL,
NAME CHAR(30) NOT NULL,
age INT NOT NULL,
info VARCHAR(255),
FULLTEXT INDEX futxt_idx_info(info(50))
)

SHOW INDEX FROM test4;

#第2种：表已经创建成功

#① ALTER TABLE ... ADD ...

CREATE TABLE book5(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR
);

SHOW INDEX FROM book5;

ALTER TABLE book5 ADD INDEX idx_cmt(COMMENT);

ALTER TABLE book5 ADD UNIQUE uk_idx_bname(book_name);

ALTER TABLE book5 ADD INDEX mul_bid_bname_info(book_id,book_name,info);

#② CREATE INDEX ... ON ...

CREATE TABLE book6(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR
);

SHOW INDEX FROM book6;

CREATE INDEX idx_cmt ON book6(COMMENT);

CREATE UNIQUE INDEX  uk_idx_bname ON book6(book_name);

CREATE INDEX mul_bid_bname_info ON book6(book_id,book_name,info);
