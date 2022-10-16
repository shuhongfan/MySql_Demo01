/*==============================================================*/
/* DBMS name:      MySQL 5.0                                    */
/* Created on:     2021/12/29 22:25:18                          */
/*==============================================================*/


drop table if exists class;

drop table if exists student;

drop table if exists student_teacher_r;

drop table if exists teacher;

/*==============================================================*/
/* Table: class                                                 */
/*==============================================================*/
create table class
(
   class_id             int not null auto_increment,
   class_name           varchar(15) not null,
   class_count          int,
   class_intro          varchar(30),
   primary key (class_id)
);

/*==============================================================*/
/* Table: student                                               */
/*==============================================================*/
create table student
(
   student_id           int not null auto_increment,
   class_id             int,
   student_name         varchar(15) not null,
   student_age          int,
   primary key (student_id)
);

/*==============================================================*/
/* Table: student_teacher_r                                     */
/*==============================================================*/
create table student_teacher_r
(
   stu_tea_id           int not null auto_increment,
   student_id           int,
   teacher_id           int,
   primary key (stu_tea_id)
);

/*==============================================================*/
/* Table: teacher                                               */
/*==============================================================*/
create table teacher
(
   teacher_id           int not null auto_increment,
   teacher_name         varchar(15) not null,
   teacher_age          int not null,
   primary key (teacher_id)
);

alter table student add constraint FK_student_class_r foreign key (class_id)
      references class (class_id) on delete restrict on update restrict;

alter table student_teacher_r add constraint FK_Reference_2 foreign key (student_id)
      references student (student_id) on delete restrict on update restrict;

alter table student_teacher_r add constraint FK_Reference_3 foreign key (teacher_id)
      references teacher (teacher_id) on delete restrict on update restrict;

