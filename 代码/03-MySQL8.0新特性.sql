# 03-MySQL8.0新特性
#1. 支持降序索引
CREATE TABLE ts1(a INT,b INT,INDEX idx_a_b(a ASC,b DESC));

SHOW CREATE TABLE ts1;


DELIMITER //
CREATE PROCEDURE ts_insert()
BEGIN
	DECLARE i INT DEFAULT 1;
	WHILE i < 800
	DO
		INSERT INTO ts1 SELECT RAND()*80000,RAND()*80000;
		SET i = i + 1;
	END WHILE;
	COMMIT;
END //
DELIMITER ;

#调用
CALL ts_insert();

SELECT COUNT(*) FROM ts1;
#优化测试
EXPLAIN SELECT * FROM ts1 ORDER BY a,b DESC LIMIT 5;

#不推荐
EXPLAIN SELECT * FROM ts1 ORDER BY a DESC,b DESC LIMIT 5;

#2. 隐藏索引
#① 创建表时，隐藏索引
CREATE TABLE book7(
book_id INT ,
book_name VARCHAR(100),
AUTHORS VARCHAR(100),
info VARCHAR(100) ,
COMMENT VARCHAR(100),
year_publication YEAR,
#创建不可见的索引
INDEX idx_cmt(COMMENT) invisible
);

SHOW INDEX FROM book7;

EXPLAIN SELECT * FROM book7 WHERE COMMENT = 'mysql....';

#② 创建表以后
ALTER TABLE book7
ADD UNIQUE INDEX uk_idx_bname(book_name) invisible;

CREATE INDEX idx_year_pub ON book7(year_publication);

EXPLAIN SELECT * FROM book7 WHERE year_publication = '2022';

#修改索引的可见性
ALTER TABLE book7 ALTER INDEX idx_year_pub invisible; #可见--->不可见

ALTER TABLE book7 ALTER INDEX idx_cmt visible; #不可见 ---> 可见

#了解：使隐藏索引对查询优化器可见

SELECT @@optimizer_switch \G

SET SESSION optimizer_switch="use_invisible_indexes=on";

EXPLAIN SELECT * FROM book7 WHERE year_publication = '2022';
