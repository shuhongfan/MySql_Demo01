#第16章_变量、流程控制与游标

#1. 变量
#1.1 变量： 系统变量（全局系统变量、会话系统变量）  vs 用户自定义变量

#1.2 查看系统变量
#查询全局系统变量
SHOW GLOBAL VARIABLES; #617
#查询会话系统变量
SHOW SESSION VARIABLES; #640

SHOW VARIABLES; #默认查询的是会话系统变量

#查询部分系统变量

SHOW GLOBAL VARIABLES LIKE 'admin_%';

SHOW VARIABLES LIKE 'character_%';

#1.3 查看指定系统变量

SELECT @@global.max_connections;
SELECT @@global.character_set_client;

#错误：
SELECT @@global.pseudo_thread_id;

#错误：
SELECT @@session.max_connections;

SELECT @@session.character_set_client;

SELECT @@session.pseudo_thread_id;

SELECT @@character_set_client; #先查询会话系统变量，再查询全局系统变量

#1.4 修改系统变量的值
#全局系统变量：
#方式1：
SET @@global.max_connections = 161;
#方式2：
SET GLOBAL max_connections = 171;

#针对于当前的数据库实例是有效的，一旦重启mysql服务，就失效了。


#会话系统变量：
#方式1：
SET @@session.character_set_client = 'gbk';
#方式2：
SET SESSION character_set_client = 'gbk';

#针对于当前会话是有效的，一旦结束会话，重新建立起新的会话，就失效了。


