create table photos (
       url varchar(255) primary key,
       description text,
       image_width integer);

create table people (
       uid varchar(16) primary key,
       given_name varchar(16) not null,
       patronymic varchar(64),
       surname varchar(32) not null,
       organization varchar(128) not null,
       faculty varchar(128),
       departement varchar(128),
       title varchar(128),
       job_title varchar(128),
       project_role varchar(64),
       photo varchar(255) references photos,
       large_photo varchar(255) references photos);

create table authors (
       uid varchar(16) primary key,
       given_name varchar(16) not null,
       patronymic varchar(64),
       surname varchar(32) not null,
       sort_order varchar(255),
       portrait varchar(255) references photos);

create table texts (
       url varchar(255) primary key,
       author_id varchar(16) not null references authors,
       title varchar(255) not null,
       original_title varchar(255),
       first_line varchar(255) unique,
       kind varchar(32),
       publisher varchar(255),
       written varchar(32),
       written_place varchar(64),
       published varchar(32),
       performed varchar(32),
       unique (author_id, title));

create table text_structure (
       section_id serial primary key,
       text_id varchar(255) not null references texts,
       label varchar(64),
       unique (text_id, label));

create table text_fragments (
       fragment_id serial primary key,
       section_id integer not null references text_structure,
       fragment text not null);

create table text_names (
       fragment_id integer not null references text_fragments,
       name_class varchar(16) not null,
       proper_name varchar(255) not null,
       primary key (fragment_id, name_class, proper_name));

create table text_annotations (
       section_id integer references text_structure,
       kind varchar(64) not null,
       annotation varchar(255) not null,
       primary key (section_id, kind, annotation));

create table text_pictures (
       text_id varchar(255) not null references texts,
       kind varchar(32) not null,
       url varchar(255) not null references photos);