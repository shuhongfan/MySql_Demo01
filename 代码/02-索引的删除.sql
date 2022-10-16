# 02-索引的删除

SHOW INDEX FROM book5;

#方式1：ALTER TABLE .... DROP INDEX ....
ALTER TABLE book5 
DROP INDEX idx_cmt;


#方式2：DROP INDEX ... ON ...
DROP INDEX uk_idx_bname ON book5;

#测试：删除联合索引中的相关字段，索引的变化
ALTER TABLE book5
DROP COLUMN book_name;

ALTER TABLE book5
DROP COLUMN book_id;

ALTER TABLE book5
DROP COLUMN info;

