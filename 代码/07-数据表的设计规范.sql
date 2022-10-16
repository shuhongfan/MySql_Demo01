
#07-数据表的设计规范

#反范式化的举例：

CREATE DATABASE atguigudb3;

USE atguigudb3;

#学生表
CREATE TABLE student(
stu_id INT PRIMARY KEY AUTO_INCREMENT,
stu_name VARCHAR(25),
create_time DATETIME
);

#课程评论表
CREATE TABLE class_comment(
comment_id INT PRIMARY KEY AUTO_INCREMENT,
class_id INT,
comment_text VARCHAR(35),
comment_time DATETIME,
stu_id INT
);

###创建向学生表中添加数据的存储过程
DELIMITER //

CREATE PROCEDURE batch_insert_student(IN START INT(10), IN max_num INT(10))
BEGIN
DECLARE i INT DEFAULT 0;
DECLARE date_start DATETIME DEFAULT ('2017-01-01 00:00:00');
DECLARE date_temp DATETIME;
SET date_temp = date_start;
SET autocommit=0;
REPEAT
SET i=i+1;
SET date_temp = DATE_ADD(date_temp, INTERVAL RAND()*60 SECOND);
INSERT INTO student(stu_id, stu_name, create_time)
VALUES((START+i), CONCAT('stu_',i), date_temp);
UNTIL i = max_num
END REPEAT;
COMMIT;
END //

DELIMITER ;

#调用存储过程，学生id从10001开始，添加1000000数据
CALL batch_insert_student(10000,1000000);

####创建向课程评论表中添加数据的存储过程
DELIMITER //

CREATE PROCEDURE batch_insert_class_comments(IN START INT(10), IN max_num INT(10))
BEGIN
DECLARE i INT DEFAULT 0;
DECLARE date_start DATETIME DEFAULT ('2018-01-01 00:00:00');
DECLARE date_temp DATETIME;
DECLARE comment_text VARCHAR(25);
DECLARE stu_id INT;
SET date_temp = date_start;
SET autocommit=0;
REPEAT
SET i=i+1;
SET date_temp = DATE_ADD(date_temp, INTERVAL RAND()*60 SECOND);
SET comment_text = SUBSTR(MD5(RAND()),1, 20);
SET stu_id = FLOOR(RAND()*1000000);
INSERT INTO class_comment(comment_id, class_id, comment_text, comment_time, stu_id)
VALUES((START+i), 10001, comment_text, date_temp, stu_id);
UNTIL i = max_num
END REPEAT;
COMMIT;
END //

DELIMITER ;

#添加数据的存储过程的调用，一共1000000条记录
CALL batch_insert_class_comments(10000,1000000);

#########
SELECT COUNT(*) FROM student;

SELECT COUNT(*) FROM class_comment;

###需求######
SELECT p.comment_text, p.comment_time, stu.stu_name 
FROM class_comment AS p LEFT JOIN student AS stu 
ON p.stu_id = stu.stu_id 
WHERE p.class_id = 10001 
ORDER BY p.comment_id DESC 
LIMIT 10000;


#####进行反范式化的设计######
#表的复制
CREATE TABLE class_comment1
AS
SELECT * FROM class_comment;

#添加主键，保证class_comment1 与class_comment的结构相同
ALTER TABLE class_comment1
ADD PRIMARY KEY (comment_id);

SHOW INDEX FROM class_comment1;

#向课程评论表中增加stu_name字段
ALTER TABLE class_comment1
ADD stu_name VARCHAR(25);

#给新添加的字段赋值
UPDATE class_comment1 c
SET stu_name = (
SELECT stu_name
FROM student s
WHERE c.stu_id = s.stu_id
);

#查询同样的需求
SELECT comment_text, comment_time, stu_name 
FROM class_comment1 
WHERE class_id = 10001 
ORDER BY comment_id DESC 
LIMIT 10000;


