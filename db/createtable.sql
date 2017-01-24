--drop database kousuan;
create database if not exists kousuan default character set utf8;

use kousuan;

--drop table classes;
create table if not exists classes (
    id integer primary key auto_increment,
    name varchar(256),
    description varchar(1024),
    creatorid integer,
    managerid integer,
    create_time timestamp);

--drop table teachers;
create table if not exists teachers (
    id integer primary key auto_increment,
    name varchar(128),
    description varchar(1024),
    qqnumber varchar(64),
    wxnumber varchar(64));

--drop table students;
create table if not exists students (
    id integer primary key auto_increment,
    name varchar(128),
    qqnumber varchar(64),
    wxnumber varchar(64));

--drop table studentclassrelations;
create table if not exists studentclassrelations (
    studentid integer not null,
    classid integer not null,
    primary key (studentid, classid));

--drop table testpapers;
create table if not exists testpapers (
    paperid integer primary key auto_increment,
    name varchar(256),
    description varchar(1024),
    creatorid integer,
    create_time timestamp default current_timestamp,
    question_number integer,
    duration integer);

--drop table questions;
create table if not exists questions (
    paperid integer not null,
    sequence smallint unsigned not null,
    qtype tinyint unsigned,
    operand1 tinyint unsigned,
    operand2 tinyint unsigned,
    operand3 tinyint unsigned,
    question integer,
    primary key (paperid, sequence)) engine=myisam;

--drop table qtypes;
create table if not exists qtypes (
    sequence tinyint unsigned primary key,
    qtype tinyint unsigned unique not null,
    grade tinyint unsigned not null,
    semester tinyint unsigned not null,
    qtypestr varchar(10),
    name_zh varchar(256),
    name_en varchar(256));

--drop table answersheets;
create table if not exists answersheets (
    sheetid integer primary key auto_increment,
    studentid integer,
    submit_time timestamp default current_timestamp,
    duration integer unsigned);

--drop table answers;
create table if not exists answers (
    sheetid integer not null,
    sequence smallint unsigned not null,
    qtype tinyint unsigned,
    operand1 tinyint unsigned,
    operand2 tinyint unsigned,
    operand3 tinyint unsigned,
    answer smallint unsigned,
    duration smallint unsigned,
    primary key (sheetid, sequence)) engine=myisam;
