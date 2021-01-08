CREATE DATABASE doc_creation;
\c doc_creation

CREATE TABLESPACE ts_users
    LOCATION '/var/lib/postgresql/data/users';
COMMENT ON TABLESPACE ts_users
    IS 'Хранение данных, связанных с пользователями';
    
CREATE TABLESPACE ts_main
    LOCATION '/var/lib/postgresql/data/main';
COMMENT ON TABLESPACE ts_main
    IS 'Хранение основных таблиц';
      
CREATE ROLE doc_admin;
CREATE ROLE doc_manager;
CREATE ROLE doc_writer;

COMMENT ON ROLE doc_admin
    IS 'Администратор, занимается вопросами пользователей';
COMMENT ON ROLE doc_manager
    IS 'Руководитель, создаёт проекты, разделы и распределяет работы';
COMMENT ON ROLE doc_writer
    IS 'Технический писатель';
   
CREATE SCHEMA content;
COMMENT ON SCHEMA content
    IS 'Всё, что относится собственно к документации';
    
CREATE SCHEMA users;
COMMENT ON SCHEMA users
    IS 'Информация о пользователях';
    
CREATE SCHEMA tasks;
COMMENT ON SCHEMA tasks
    IS 'Информация о задачах';

CREATE TABLE content.projects (
    project_id bigint NOT NULL PRIMARY KEY,
    title character varying(255) NOT NULL,

    CONSTRAINT projects_name_key UNIQUE (title)
)
TABLESPACE ts_main;

COMMENT ON TABLE content.projects 
    IS 'Проекты документации';
COMMENT ON COLUMN content.projects.title 
    IS 'Название проекта';
COMMENT ON CONSTRAINT projects_name_key ON content.projects 
    IS 'Названия проектов не должны совпадать, иначе пользователи в них запутаются.';

CREATE TABLE content.chapters (
    chapter_id bigint NOT NULL PRIMARY KEY,
    project_id bigint NOT NULL,
    parent_id bigint,
    title character varying(255),
    
    CONSTRAINT chapters_project_fkey FOREIGN KEY (project_id)
        REFERENCES content.projects (project_id),
    CONSTRAINT chapters_parent_fkey FOREIGN KEY (parent_id)
        REFERENCES content.chapters (chapter_id)
)
TABLESPACE ts_main;

COMMENT ON TABLE content.chapters
    IS 'Разделы документации';
COMMENT ON COLUMN content.chapters.project_id
    IS 'К какому проекту относится этот раздел';
COMMENT ON COLUMN content.chapters.parent_id
    IS 'Идентификатор родительского раздела, null - если это корневой раздел';
COMMENT ON COLUMN content.chapters.title
    IS 'Название раздела';
COMMENT ON CONSTRAINT chapters_project_fkey ON content.chapters
    IS 'Ссылка на проект';
COMMENT ON CONSTRAINT chapters_parent_fkey ON content.chapters
    IS 'Связь с родительским разделом';
    
CREATE INDEX chapters_title_index ON content.chapters (project_id, title);

COMMENT ON INDEX content.chapters_title_index
    IS 'По названиям разделов нужен пользовательский поиск. Но искать имеет смысл только в рамках проекта.';
    
CREATE TABLE content.modules (
    module_id bigint NOT NULL PRIMARY KEY,
    chapter_id bigint NOT NULL,
    code character varying(50) NOT NULL,
    module_type character varying(20) NOT NULL,
    
    CONSTRAINT modules_chapter_fkey FOREIGN KEY (chapter_id) 
        REFERENCES content.chapters(chapter_id)
)
TABLESPACE ts_main;

COMMENT ON TABLE content.modules
    IS 'Модули документации';
COMMENT ON COLUMN content.modules.chapter_id 
    IS 'В каком разделе находится модуль';
COMMENT ON COLUMN content.modules.code
    IS 'Код модуля';
COMMENT ON COLUMN content.modules.module_type
    IS 'Тип модуля';
COMMENT ON CONSTRAINT modules_chapter_fkey ON content.modules
    IS 'Ссылка на раздел документации';
    
CREATE TABLE content.versions (
    version_id bigint NOT NULL PRIMARY KEY,
    module_id bigint NOT NULL,
    num smallint NOT NULL,
    language character varying(10) NOT NULL,
    title character varying(255),
    
    CONSTRAINT versions_modules_fkey FOREIGN KEY (module_id)
        REFERENCES content.modules(module_id),
    CONSTRAINT versions_dm_num_language_key UNIQUE (module_id, num, language)
)
TABLESPACE ts_main;

COMMENT ON TABLE content.versions
    IS 'Версии модулей';
COMMENT ON COLUMN content.versions.module_id
    IS 'К какому модулю относится';
COMMENT ON COLUMN content.versions.num
    IS 'Номер версии';
COMMENT ON COLUMN content.versions.language 
    IS 'Язык версии';
COMMENT ON COLUMN content.versions.title
    IS 'Название версии';
COMMENT ON CONSTRAINT versions_modules_fkey ON content.versions
    IS 'Ссылка на модуль';
COMMENT ON CONSTRAINT versions_dm_num_language_key ON content.versions
    IS 'Номер и версия не могут повторяться одновременно для одного модуля';
    
CREATE INDEX versions_title_index ON content.versions (title);

COMMENT ON INDEX content.versions_title_index
    IS 'Часто приходится искать по названию версий.';
    
CREATE TABLE content.versions_content (
    version_id bigint NOT NULL,
    filename character varying(50) NOT NULL,
    content bytea,
    
    CONSTRAINT versions_content_pkey PRIMARY KEY (version_id, filename),
    CONSTRAINT versions_content_version_id_fkey FOREIGN KEY (version_id)
        REFERENCES content.versions (version_id)
)
TABLESPACE ts_main;

COMMENT ON TABLE content.versions_content
    IS 'Файлы с содержимым модулей';
COMMENT ON COLUMN content.versions_content.version_id 
    IS 'Идентификатор версии, к которой относится файл';
COMMENT ON COLUMN content.versions_content.filename
    IS 'Имя файла';
COMMENT ON COLUMN content.versions_content.content
    IS 'Содержимое файла';
COMMENT ON CONSTRAINT versions_content_version_id_fkey ON content.versions_content
    IS 'Ссылка на версию';
    
CREATE TABLE users.users (
    user_id bigint NOT NULL PRIMARY KEY,
    login character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    enabled boolean NOT NULL,
    user_details json,
    
    CONSTRAINT users_login_key UNIQUE (login)
)
TABLESPACE ts_main;

COMMENT ON TABLE users.users
    IS 'Пользователи';
COMMENT ON COLUMN users.users.login
    IS 'Логин';
COMMENT ON COLUMN users.users.password
    IS 'Пароль';
COMMENT ON COLUMN users.users.enabled
    IS 'Разрешён ли доступ этому пользователю';
COMMENT ON COLUMN users.users.user_details
    IS 'Различная информация о пользователе - ФИО, телефон и так далее';
COMMENT ON CONSTRAINT users_login_key ON users.users
    IS 'Логин должен быть уникален в рамках системы';

CREATE TABLE users.user_authorities (
    user_id bigint NOT NULL,
    authority character varying(20) NOT NULL,
    
    CONSTRAINT user_authorities_fkey FOREIGN KEY (user_id)
        REFERENCES users.users (user_id),        
    CONSTRAINT user_authorities_unique_key UNIQUE(user_id, authority)
)
TABLESPACE ts_users;

COMMENT ON TABLE users.user_authorities
    IS 'Права пользователей';
COMMENT ON CONSTRAINT user_authorities_fkey ON users.user_authorities
    IS 'Ссылка на пользователя';
COMMENT ON CONSTRAINT user_authorities_unique_key ON users.user_authorities
    IS 'Пара пользователь-право должна быть уникальна';    
    
CREATE TABLE tasks.tasks (
    task_id bigint NOT NULL PRIMARY KEY,
    user_id bigint NOT NULL,
    chapter_id bigint NOT NULL,
    state character varying(20),
    start_date date,
    finish_date date, 
    
    CONSTRAINT tasks_user_fkey FOREIGN KEY (user_id)
        REFERENCES users.users(user_id),
    CONSTRAINT tasks_chapter_fkey FOREIGN KEY (chapter_id)
        REFERENCES content.chapters(chapter_id),
    CONSTRAINT finish_date_valid CHECK (finish_date > start_date)
)
TABLESPACE ts_main;

COMMENT ON TABLE tasks.tasks
    IS 'Задачи';
COMMENT ON COLUMN tasks.tasks.user_id
    IS 'На какого пользователя назначена задача';
COMMENT ON COLUMN tasks.tasks.chapter_id
    IS 'К какому разделу относится задача';
COMMENT ON COLUMN tasks.tasks.state
    IS 'Состояние задачи - (не начата, выполняется, закончена)';
COMMENT ON COLUMN tasks.tasks.start_date
    IS 'Планируемая дата начала работы';
COMMENT ON COLUMN tasks.tasks.finish_date
    IS 'Планируемая дата окончания работы';
COMMENT ON CONSTRAINT tasks_user_fkey ON tasks.tasks
    IS 'Ссылка на пользователя';
COMMENT ON CONSTRAINT tasks_chapter_fkey ON tasks.tasks
    IS 'Ссылка на раздел';
COMMENT ON CONSTRAINT finish_date_valid ON tasks.tasks
    IS 'Дата завершения должна быть после даты начала';

GRANT ALL ON ALL TABLES IN SCHEMA users TO doc_admin;
GRANT ALL ON ALL TABLES IN SCHEMA content TO doc_admin;
GRANT ALL ON ALL TABLES IN SCHEMA tasks TO doc_admin;

GRANT ALL ON ALL TABLES IN SCHEMA content TO doc_manager;
GRANT ALL ON ALL TABLES IN SCHEMA tasks TO doc_manager;
GRANT SELECT ON ALL TABLES IN SCHEMA users TO doc_manager;

GRANT SELECT ON ALL TABLES IN SCHEMA content TO doc_writer;
GRANT INSERT, UPDATE, DELETE ON content.modules, content.versions, content.versions_content
    TO doc_writer;