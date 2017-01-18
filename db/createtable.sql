create database if not exists kousuan default character set utf8;

use kousuan;

create table if not exists classes (
    id integer primary key auto_increment,
    name varchar(256),
    description varchar(1024),
    creatorid integer,
    managerid integer,
    create_time timestamp);

create table if not exists teachers (
    id integer primary key auto_increment,
    name varchar(128),
    description varchar(1024),
    qqnumber varchar(64),
    wxnumber varchar(64));

create table if not exists students (
    id integer primary key auto_increment,
    name varchar(128),
    qqnumber varchar(64),
    wxnumber varchar(64));

create table if not exists studentclassrelations (
    studentid integer not null,
    classid integer not null,
    primary key (studentid, classid));

create table if not exists testpapers (
    paperid integer primary key auto_increment,
    name varchar(256),
    description varchar(1024),
    creatorid integer,
    create_time timestamp default current_timestamp,
    question_number integer,
    duration integer);

create table if not exists questions (
    paperid integer not null,
    sequence smallint not null,
    qtype tinyint,
    operand1 tinyint,
    operand2 tinyint,
    operand3 tinyint,
    question integer,
    primary key (paperid, sequence)) engine=myisam;

create table if not exists qtypes (
    qtype tinyint primary key,
    sequence tinyint not null,
    grade tinyint not null,
    semester tinyint not null,
    qtypestr varchar(10),
    name_zh varchar(256),
    name_en varchar(256));

create table if not exists answersheets (
    sheetid integer primary key auto_increment,
    paperid integer,
    studentid integer,
    submit_time timestamp default current_timestamp,
    duration integer);

create table if not exists answers (
    sheetid integer not null,
    sequence smallint not null,
    qtype tinyint,
    operand1 tinyint,
    operand2 tinyint,
    operand3 tinyint,
    answer smallint,
    duration smallint,
    primary key (sheetid, sequence)) engine=myisam;
