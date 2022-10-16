#08-数据库的其他优化策略
CREATE TABLE `user1` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) DEFAULT NULL,
  `age` INT DEFAULT NULL,
  `sex` VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_name` (`name`) USING BTREE
) ENGINE=INNODB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb3;

#######
SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER //
CREATE FUNCTION  rand_num (from_num INT ,to_num INT) RETURNS INT(11)
BEGIN   
DECLARE i INT DEFAULT 0;  
SET i = FLOOR(from_num +RAND()*(to_num - from_num+1))   ;
RETURN i;  
END //
DELIMITER ;

###
DELIMITER //
CREATE PROCEDURE  insert_user( max_num INT )
BEGIN  
DECLARE i INT DEFAULT 0;   
 SET autocommit = 0;    
 REPEAT  
 SET i = i + 1;  
 INSERT INTO `user1` ( NAME,age,sex ) 
 VALUES ("atguigu",rand_num(1,20),"male");  
 UNTIL i = max_num  
 END REPEAT;  
 COMMIT; 
END //
DELIMITER;

##
CALL insert_user(1000);

SHOW INDEX FROM user1;

SELECT * FROM user1;

UPDATE user1 SET NAME = 'atguigu03' WHERE id = 3;

#分析表
ANALYZE TABLE user1;

#检查表
CHECK TABLE user1;

#优化表
CREATE TABLE t1(id INT,NAME VARCHAR(15)) ENGINE = MYISAM;

OPTIMIZE TABLE t1;


CREATE TABLE t2(id INT,NAME VARCHAR(15)) ENGINE = INNODB;

OPTIMIZE TABLE t2;


####
CREATE TABLESPACE atguigu1 ADD DATAFILE 'atguigu1.ibd' file_block_size=16k;


CREATE TABLE test(id INT,NAME VARCHAR(10)) ENGINE=INNODB DEFAULT CHARSET utf8mb4 TABLESPACE atguigu1;

ALTER TABLE test TABLESPACE atguigu1;

DROP TABLESPACE atguigu1;

DROP TABLE test;