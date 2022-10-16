
#1. table：表名
#查询的每一行记录都对应着一个单表
EXPLAIN SELECT * FROM s1;

#s1:驱动表  s2:被驱动表
EXPLAIN SELECT * FROM s1 INNER JOIN s2;

#2. id：在一个大的查询语句中每个SELECT关键字都对应一个唯一的id
 SELECT * FROM s1 WHERE key1 = 'a';


 SELECT * FROM s1 INNER JOIN s2
 ON s1.key1 = s2.key1
 WHERE s1.common_field = 'a';


 SELECT * FROM s1 
 WHERE key1 IN (SELECT key3 FROM s2);


 SELECT * FROM s1 UNION SELECT * FROM s2;


 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a';
 
 
 EXPLAIN SELECT * FROM s1 INNER JOIN s2;
 
 
 EXPLAIN SELECT * FROM s1 WHERE key1 IN (SELECT key1 FROM s2) OR key3 = 'a';
 
 ######查询优化器可能对涉及子查询的查询语句进行重写,转变为多表查询的操作########
 EXPLAIN SELECT * FROM s1 WHERE key1 IN (SELECT key2 FROM s2 WHERE common_field = 'a');
 
 #Union去重
 EXPLAIN SELECT * FROM s1 UNION SELECT * FROM s2;
 
 
 EXPLAIN SELECT * FROM s1  UNION ALL SELECT * FROM s2;
 
 
 #3. select_type：SELECT关键字对应的那个查询的类型,确定小查询在整个大查询中扮演了一个什么角色
 
 # 查询语句中不包含`UNION`或者子查询的查询都算作是`SIMPLE`类型
 EXPLAIN SELECT * FROM s1;
 
 
 #连接查询也算是`SIMPLE`类型
 EXPLAIN SELECT * FROM s1 INNER JOIN s2;
 
 
 #对于包含`UNION`或者`UNION ALL`或者子查询的大查询来说，它是由几个小查询组成的，其中最左边的那个
 #查询的`select_type`值就是`PRIMARY`
 
 
 #对于包含`UNION`或者`UNION ALL`的大查询来说，它是由几个小查询组成的，其中除了最左边的那个小查询
 #以外，其余的小查询的`select_type`值就是`UNION`
 
 #`MySQL`选择使用临时表来完成`UNION`查询的去重工作，针对该临时表的查询的`select_type`就是
 #`UNION RESULT`
 EXPLAIN SELECT * FROM s1 UNION SELECT * FROM s2;
 
 EXPLAIN SELECT * FROM s1 UNION ALL SELECT * FROM s2;
 
 #子查询：
 #如果包含子查询的查询语句不能够转为对应的`semi-join`的形式，并且该子查询是不相关子查询。
 #该子查询的第一个`SELECT`关键字代表的那个查询的`select_type`就是`SUBQUERY`
 EXPLAIN SELECT * FROM s1 WHERE key1 IN (SELECT key1 FROM s2) OR key3 = 'a';
 
 
 #如果包含子查询的查询语句不能够转为对应的`semi-join`的形式，并且该子查询是相关子查询，
 #则该子查询的第一个`SELECT`关键字代表的那个查询的`select_type`就是`DEPENDENT SUBQUERY`
 EXPLAIN SELECT * FROM s1 
 WHERE key1 IN (SELECT key1 FROM s2 WHERE s1.key2 = s2.key2) OR key3 = 'a';
 #注意的是，select_type为`DEPENDENT SUBQUERY`的查询可能会被执行多次。
 
 
 #在包含`UNION`或者`UNION ALL`的大查询中，如果各个小查询都依赖于外层查询的话，那除了
 #最左边的那个小查询之外，其余的小查询的`select_type`的值就是`DEPENDENT UNION`。
 EXPLAIN SELECT * FROM s1 
 WHERE key1 IN (SELECT key1 FROM s2 WHERE key1 = 'a' UNION SELECT key1 FROM s1 WHERE key1 = 'b');
 
 
 #对于包含`派生表`的查询，该派生表对应的子查询的`select_type`就是`DERIVED`
 EXPLAIN SELECT * 
 FROM (SELECT key1, COUNT(*) AS c FROM s1 GROUP BY key1) AS derived_s1 WHERE c > 1;
 
 
 #当查询优化器在执行包含子查询的语句时，选择将子查询物化之后与外层查询进行连接查询时，
 #该子查询对应的`select_type`属性就是`MATERIALIZED`
 EXPLAIN SELECT * FROM s1 WHERE key1 IN (SELECT key1 FROM s2); #子查询被转为了物化表
 
 
 
 # 4. partition(略)：匹配的分区信息
 
 
 # 5. type：针对单表的访问方法
 
 #当表中`只有一条记录`并且该表使用的存储引擎的统计数据是精确的，比如MyISAM、Memory，
 #那么对该表的访问方法就是`system`。
 CREATE TABLE t(i INT) ENGINE=MYISAM;
 INSERT INTO t VALUES(1);
 
 EXPLAIN SELECT * FROM t;
 
 #换成InnoDB
 CREATE TABLE tt(i INT) ENGINE=INNODB;
 INSERT INTO tt VALUES(1);
 EXPLAIN SELECT * FROM tt;
 
 
 #当我们根据主键或者唯一二级索引列与常数进行等值匹配时，对单表的访问方法就是`const`
 EXPLAIN SELECT * FROM s1 WHERE id = 10005;
 
 EXPLAIN SELECT * FROM s1 WHERE key2 = 10066;
 
 
 #在连接查询时，如果被驱动表是通过主键或者唯一二级索引列等值匹配的方式进行访问的
 #（如果该主键或者唯一二级索引是联合索引的话，所有的索引列都必须进行等值比较），则
 #对该被驱动表的访问方法就是`eq_ref`
 EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s1.id = s2.id;
  
  
 #当通过普通的二级索引列与常量进行等值匹配时来查询某个表，那么对该表的访问方法就可能是`ref`
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a';
 
 
 #当对普通二级索引进行等值匹配查询，该索引列的值也可以是`NULL`值时，那么对该表的访问方法
 #就可能是`ref_or_null`
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a' OR key1 IS NULL;
 
 
 #单表访问方法时在某些场景下可以使用`Intersection`、`Union`、
 #`Sort-Union`这三种索引合并的方式来执行查询
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a' OR key3 = 'a';
 
 
 #`unique_subquery`是针对在一些包含`IN`子查询的查询语句中，如果查询优化器决定将`IN`子查询
 #转换为`EXISTS`子查询，而且子查询可以使用到主键进行等值匹配的话，那么该子查询执行计划的`type`
 #列的值就是`unique_subquery`
 EXPLAIN SELECT * FROM s1 
 WHERE key2 IN (SELECT id FROM s2 WHERE s1.key1 = s2.key1) OR key3 = 'a';
 
 
 #如果使用索引获取某些`范围区间`的记录，那么就可能使用到`range`访问方法
 EXPLAIN SELECT * FROM s1 WHERE key1 IN ('a', 'b', 'c');
 
 #同上
 EXPLAIN SELECT * FROM s1 WHERE key1 > 'a' AND key1 < 'b';
 
 
 #当我们可以使用索引覆盖，但需要扫描全部的索引记录时，该表的访问方法就是`index`
 EXPLAIN SELECT key_part2 FROM s1 WHERE key_part3 = 'a';
 
 
 #最熟悉的全表扫描
 EXPLAIN SELECT * FROM s1;
 
 
 #6. possible_keys和key：可能用到的索引 和  实际上使用的索引
 
 EXPLAIN SELECT * FROM s1 WHERE key1 > 'z' AND key3 = 'a';
 

 
#7.  key_len：实际使用到的索引长度(即：字节数)
# 帮你检查`是否充分的利用上了索引`，`值越大越好`,主要针对于联合索引，有一定的参考意义。
 EXPLAIN SELECT * FROM s1 WHERE id = 10005;


 EXPLAIN SELECT * FROM s1 WHERE key2 = 10126;


 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a';


 EXPLAIN SELECT * FROM s1 WHERE key_part1 = 'a';

 
 EXPLAIN SELECT * FROM s1 WHERE key_part1 = 'a' AND key_part2 = 'b';

 EXPLAIN SELECT * FROM s1 WHERE key_part1 = 'a' AND key_part2 = 'b' AND key_part3 = 'c';
 
 EXPLAIN SELECT * FROM s1 WHERE key_part3 = 'a';
 
#练习：
#varchar(10)变长字段且允许NULL  = 10 * ( character set：utf8=3,gbk=2,latin1=1)+1(NULL)+2(变长字段)

#varchar(10)变长字段且不允许NULL = 10 * ( character set：utf8=3,gbk=2,latin1=1)+2(变长字段)

#char(10)固定字段且允许NULL    = 10 * ( character set：utf8=3,gbk=2,latin1=1)+1(NULL)

#char(10)固定字段且不允许NULL  = 10 * ( character set：utf8=3,gbk=2,latin1=1)
 
 
 
 # 8. ref：当使用索引列等值查询时，与索引列进行等值匹配的对象信息。
 #比如只是一个常数或者是某个列。
 
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a';
 
 
 EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s1.id = s2.id;
 
 
 EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s2.key1 = UPPER(s1.key1);
 
 
 # 9. rows：预估的需要读取的记录条数
 # `值越小越好`
 EXPLAIN SELECT * FROM s1 WHERE key1 > 'z';
 
 
 
 # 10. filtered: 某个表经过搜索条件过滤后剩余记录条数的百分比
 
 #如果使用的是索引执行的单表扫描，那么计算时需要估计出满足除使用
 #到对应索引的搜索条件外的其他搜索条件的记录有多少条。
 EXPLAIN SELECT * FROM s1 WHERE key1 > 'z' AND common_field = 'a';
 
 
 #对于单表查询来说，这个filtered列的值没什么意义，我们`更关注在连接查询
 #中驱动表对应的执行计划记录的filtered值`，它决定了被驱动表要执行的次数(即：rows * filtered)
 EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s1.key1 = s2.key1 WHERE s1.common_field = 'a';
 
 
 #11. Extra:一些额外的信息
 #更准确的理解MySQL到底将如何执行给定的查询语句
 
 
 #当查询语句的没有`FROM`子句时将会提示该额外信息
 EXPLAIN SELECT 1;
 
 
 #查询语句的`WHERE`子句永远为`FALSE`时将会提示该额外信息
 EXPLAIN SELECT * FROM s1 WHERE 1 != 1;
 
 
 #当我们使用全表扫描来执行对某个表的查询，并且该语句的`WHERE`
 #子句中有针对该表的搜索条件时，在`Extra`列中会提示上述额外信息。
 EXPLAIN SELECT * FROM s1 WHERE common_field = 'a';
 
 
 #当使用索引访问来执行对某个表的查询，并且该语句的`WHERE`子句中
 #有除了该索引包含的列之外的其他搜索条件时，在`Extra`列中也会提示上述额外信息。
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a' AND common_field = 'a';
 
 
 #当查询列表处有`MIN`或者`MAX`聚合函数，但是并没有符合`WHERE`子句中
 #的搜索条件的记录时，将会提示该额外信息
 EXPLAIN SELECT MIN(key1) FROM s1 WHERE key1 = 'abcdefg';
 
 EXPLAIN SELECT MIN(key1) FROM s1 WHERE key1 = 'NlPros'; #NlPros 是 s1表中key1字段真实存在的数据
 
 #select * from s1 limit 10;
 
 #当我们的查询列表以及搜索条件中只包含属于某个索引的列，也就是在可以
 #使用覆盖索引的情况下，在`Extra`列将会提示该额外信息。比方说下边这个查询中只
 #需要用到`idx_key1`而不需要回表操作：
 EXPLAIN SELECT key1,id FROM s1 WHERE key1 = 'a';
 
 
 #有些搜索条件中虽然出现了索引列，但却不能使用到索引
 #看课件理解索引条件下推
 EXPLAIN SELECT * FROM s1 WHERE key1 > 'z' AND key1 LIKE '%a';
 
 
 #在连接查询执行过程中，当被驱动表不能有效的利用索引加快访问速度，MySQL一般会为
 #其分配一块名叫`join buffer`的内存块来加快查询速度，也就是我们所讲的`基于块的嵌套循环算法`
 #见课件说明
 EXPLAIN SELECT * FROM s1 INNER JOIN s2 ON s1.common_field = s2.common_field;
 
 
 #当我们使用左（外）连接时，如果`WHERE`子句中包含要求被驱动表的某个列等于`NULL`值的搜索条件，
 #而且那个列又是不允许存储`NULL`值的，那么在该表的执行计划的Extra列就会提示`Not exists`额外信息
 EXPLAIN SELECT * FROM s1 LEFT JOIN s2 ON s1.key1 = s2.key1 WHERE s2.id IS NULL;
 
 
 #如果执行计划的`Extra`列出现了`Using intersect(...)`提示，说明准备使用`Intersect`索引
 #合并的方式执行查询，括号中的`...`表示需要进行索引合并的索引名称；
 #如果出现了`Using union(...)`提示，说明准备使用`Union`索引合并的方式执行查询；
 #出现了`Using sort_union(...)`提示，说明准备使用`Sort-Union`索引合并的方式执行查询。
 EXPLAIN SELECT * FROM s1 WHERE key1 = 'a' OR key3 = 'a';
 
 
 #当我们的`LIMIT`子句的参数为`0`时，表示压根儿不打算从表中读出任何记录，将会提示该额外信息
 EXPLAIN SELECT * FROM s1 LIMIT 0;
 
 
 #有一些情况下对结果集中的记录进行排序是可以使用到索引的。
 #比如：
 EXPLAIN SELECT * FROM s1 ORDER BY key1 LIMIT 10;
 
 
 #很多情况下排序操作无法使用到索引，只能在内存中（记录较少的时候）或者磁盘中（记录较多的时候）
 #进行排序，MySQL把这种在内存中或者磁盘上进行排序的方式统称为文件排序（英文名：`filesort`）。
 
 #如果某个查询需要使用文件排序的方式执行查询，就会在执行计划的`Extra`列中显示`Using filesort`提示
 EXPLAIN SELECT * FROM s1 ORDER BY common_field LIMIT 10;
 
 
 #在许多查询的执行过程中，MySQL可能会借助临时表来完成一些功能，比如去重、排序之类的，比如我们
 #在执行许多包含`DISTINCT`、`GROUP BY`、`UNION`等子句的查询过程中，如果不能有效利用索引来完成
 #查询，MySQL很有可能寻求通过建立内部的临时表来执行查询。如果查询中使用到了内部的临时表，在执行
 #计划的`Extra`列将会显示`Using temporary`提示
 EXPLAIN SELECT DISTINCT common_field FROM s1;
 
 #EXPLAIN SELECT DISTINCT key1 FROM s1;
 
 #同上。
 EXPLAIN SELECT common_field, COUNT(*) AS amount FROM s1 GROUP BY common_field;
 
 #执行计划中出现`Using temporary`并不是一个好的征兆，因为建立与维护临时表要付出很大成本的，所以
 #我们`最好能使用索引来替代掉使用临时表`。比如：扫描指定的索引idx_key1即可
 EXPLAIN SELECT key1, COUNT(*) AS amount FROM s1 GROUP BY key1;
 
#json格式的explain
EXPLAIN FORMAT=JSON SELECT * FROM s1 INNER JOIN s2 ON s1.key1 = s2.key2 
WHERE s1.common_field = 'a';
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 