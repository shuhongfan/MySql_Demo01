#09-事务的基础知识

#1.事务的完成过程
#步骤1：开启事务
#步骤2：一系列的DML操作 
#....
#步骤3：事务结束的状态：提交的状态(COMMIT) 、 中止的状态(ROLLBACK)

#2. 显式事务

#2.1 如何开启？ 使用关键字：start transaction  或 begin

# start transaction 后面可以跟：read only / read write (默认) / with consistent snapshot 


#2.2 保存点(savepoint)



#3. 隐式事务

# 3.1 关键字：autocommit 
#set autocommit = false;

SHOW VARIABLES LIKE 'autocommit';#默认是ON

UPDATE account SET balance = balance - 10 WHERE id = 1; #此时这条DML操作是一个独立的事务

UPDATE account SET balance = balance + 10 WHERE id = 2; #此时这条DML操作是一个独立的事务

#3.2 如果关闭自动提交？
#方式1：
SET autocommit = FALSE; #针对于DML操作是有效的，对DDL操作是无效的。

UPDATE account SET balance = balance - 10 WHERE id = 1;

UPDATE account SET balance = balance + 10 WHERE id = 2; 

COMMIT; #或rollback;

#方式2：我们在autocommit为true的情况下，使用start transaction 或begin开启事务，那么DML操作就不会自动提交数据

START TRANSACTION;

UPDATE account SET balance = balance - 10 WHERE id = 1;

UPDATE account SET balance = balance + 10 WHERE id = 2; 

COMMIT; #或rollback;

#4. 案例分析
#SET autocommit = TRUE; 
#举例1： commit 和 rollback

USE atguigudb2;
#情况1：
CREATE TABLE user3(NAME VARCHAR(15) PRIMARY KEY);

SELECT * FROM user3;

BEGIN;
INSERT INTO user3 VALUES('张三'); #此时不会自动提交数据
COMMIT;

BEGIN; #开启一个新的事务
INSERT INTO user3 VALUES('李四'); #此时不会自动提交数据
INSERT INTO user3 VALUES('李四'); #受主键的影响，不能添加成功
ROLLBACK;

SELECT * FROM user3;

#情况2：
TRUNCATE TABLE user3;  #DDL操作会自动提交数据，不受autocommit变量的影响。

SELECT * FROM user3;

BEGIN;
INSERT INTO user3 VALUES('张三'); #此时不会自动提交数据
COMMIT;

INSERT INTO user3 VALUES('李四');# 默认情况下(即autocommit为true)，DML操作也会自动提交数据。
INSERT INTO user3 VALUES('李四'); #事务的失败的状态

ROLLBACK;

SELECT * FROM user3;


#情况3：
TRUNCATE TABLE user3;

SELECT * FROM user3;

SELECT @@completion_type;

SET @@completion_type = 1;

BEGIN;
INSERT INTO user3 VALUES('张三'); 
COMMIT;


SELECT * FROM user3;

INSERT INTO user3 VALUES('李四');
INSERT INTO user3 VALUES('李四'); 

ROLLBACK;


SELECT * FROM user3;

#举例2：体会INNODB 和 MyISAM

CREATE TABLE test1(i INT) ENGINE = INNODB;

CREATE TABLE test2(i INT) ENGINE = MYISAM;

#针对于innodb表
BEGIN
INSERT INTO test1 VALUES (1);
ROLLBACK;

SELECT * FROM test1;


#针对于myisam表:不支持事务
BEGIN
INSERT INTO test2 VALUES (1);
ROLLBACK;

SELECT * FROM test2;


#举例3：体会savepoint

CREATE TABLE user3(NAME VARCHAR(15),balance DECIMAL(10,2));

BEGIN
INSERT INTO user3(NAME,balance) VALUES('张三',1000);
COMMIT;

SELECT * FROM user3;


BEGIN;
UPDATE user3 SET balance = balance - 100 WHERE NAME = '张三';

UPDATE user3 SET balance = balance - 100 WHERE NAME = '张三';

SAVEPOINT s1;#设置保存点

UPDATE user3 SET balance = balance + 1 WHERE NAME = '张三';

ROLLBACK TO s1; #回滚到保存点


SELECT * FROM user3;

ROLLBACK; #回滚操作

SELECT * FROM user3;
