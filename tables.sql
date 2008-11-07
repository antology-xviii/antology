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
       portrait varchar(255) references photos,
       unique (given_name, patronymic, surname));

create table texts (
       url varchar(255) primary key,
       author_id varchar(16) not null references authors,
       title varchar(255) not null,
       original_title varchar(255),
       first_line varchar(255) unique,
       publisher varchar(255),
       written varchar(32),
       written_place varchar(64),
       published varchar(32),
       performed varchar(32),
       unique (author_id, title, written));

create table text_transcribers (
       url varchar(255) not null references texts,
       transcriber varchar(16) not null references people);

create table text_structure (
       text_id varchar(255),
       label varchar(64),
       container varchar(64),
       fragment text,
       primary key (text_id, label),
       foreign key (text_id, container) references text_structure);

create table name_classes (
       name_class varchar(16) primary key,
       description text);

create table text_names (
       text_id varchar(255),
       frag_id varchar(64),
       name_class varchar(16) not null references name_classes,
       proper_name varchar(255) not null,
       occurrence varchar(255) not null,
       refid varchar(255) not null,
       foreign key (text_id, frag_id) references text_structure);

create table annotation_kinds (
       annotation_kind varchar(64) primary key,
       description text);

create table text_annotations (
       text_id varchar(255),
       frag_id varchar(64),
       kind varchar(64) not null references annotation_kinds,
       annotation varchar(255) not null,
       caption varchar(255),
       foreign key (text_id, frag_id) references text_structure);

create table text_pictures (
       text_id varchar(255) not null references texts,
       kind varchar(32) not null,
       url varchar(255) not null references photos);

create table taxonomy (
       id varchar(255) primary key,
       description text);

create table categories (
       taxonomy varchar(255) not null references taxonomy,
       id varchar(255) not null,
       ordering integer,
       caption varchar(64),
       description text,
       primary key (taxonomy, id));

create table metric_system (
       id varchar(32) primary key,
       pattern varchar(255),
       description text);

create table metric_elements (
       sys_id varchar(32) references metric_system,
       id varchar(32) not null,
       interpretation varchar(255),
       primary key (sys_id, id));

create table text_classification (
       text_id varchar(255) not null references texts,
       taxonomy varchar(255) not null,
       category varchar(255) not null,
       foreign key (taxonomy, category) references categories);

create table text_metric (
       text_id varchar(255),
       frag_id varchar(64),
       sys_id varchar(32) not null references metric_system,
       characteristic varchar(128) not null,
       foreign key (text_id, frag_id) references text_structure);
