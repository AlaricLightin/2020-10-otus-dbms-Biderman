--- Используется диалект PostgreSQL

CREATE TABLE projects (
    project_id bigint NOT NULL PRIMARY KEY,
    title character varying(255) NOT NULL,

    CONSTRAINT projects_name_key UNIQUE (title)
);

COMMENT ON TABLE projects 
    IS 'Проекты документации';
COMMENT ON COLUMN projects.title 
    IS 'Название проекта';
COMMENT ON CONSTRAINT projects_name_key ON projects 
    IS 'Названия проектов не должны совпадать, иначе пользователи в них запутаются.';

CREATE TABLE chapters (
    chapter_id bigint NOT NULL PRIMARY KEY,
    project_id bigint NOT NULL,
    parent_id bigint,
    title character varying(255),
    
    CONSTRAINT chapters_project_fkey FOREIGN KEY (project_id)
        REFERENCES projects (project_id),
    CONSTRAINT chapters_parent_fkey FOREIGN KEY (parent_id)
        REFERENCES chapters (chapter_id)
);

COMMENT ON TABLE chapters
    IS 'Разделы документации';
COMMENT ON COLUMN chapters.project_id
    IS 'К какому проекту относится этот раздел';
COMMENT ON COLUMN chapters.parent_id
    IS 'Идентификатор родительского раздела, null - если это корневой раздел';
COMMENT ON COLUMN chapters.title
    IS 'Название раздела';
COMMENT ON CONSTRAINT chapters_project_fkey ON chapters
    IS 'Ссылка на проект';
COMMENT ON CONSTRAINT chapters_parent_fkey ON chapters
    IS 'Связь с родительским разделом';
    
CREATE INDEX chapters_title_index ON chapters (project_id, title);

COMMENT ON INDEX chapters_title_index
    IS 'По названиям разделов нужен пользовательский поиск. Но искать имеет смысл только в рамках проекта.';
    
CREATE TABLE modules (
    module_id bigint NOT NULL PRIMARY KEY,
    chapter_id bigint NOT NULL,
    code character varying(50) NOT NULL,
    module_type character varying(20) NOT NULL,
    
    CONSTRAINT modules_chapter_fkey FOREIGN KEY (chapter_id) 
        REFERENCES chapters(chapter_id)
);

COMMENT ON TABLE modules
    IS 'Модули документации';
COMMENT ON COLUMN modules.chapter_id 
    IS 'В каком разделе находится модуль';
COMMENT ON COLUMN modules.code
    IS 'Код модуля';
COMMENT ON COLUMN modules.module_type
    IS 'Тип модуля';
COMMENT ON CONSTRAINT modules_chapter_fkey ON modules
    IS 'Ссылка на раздел документации';
    
CREATE TABLE versions (
    version_id bigint NOT NULL PRIMARY KEY,
    module_id bigint NOT NULL,
    num smallint NOT NULL,
    language character varying(10) NOT NULL,
    title character varying(255),
    
    CONSTRAINT versions_modules_fkey FOREIGN KEY (module_id)
        REFERENCES modules(module_id),
    CONSTRAINT versions_dm_num_language_key UNIQUE (module_id, num, language)
);

COMMENT ON TABLE versions
    IS 'Версии модулей';
COMMENT ON COLUMN versions.module_id
    IS 'К какому модулю относится';
COMMENT ON COLUMN versions.num
    IS 'Номер версии';
COMMENT ON COLUMN versions.language 
    IS 'Язык версии';
COMMENT ON COLUMN versions.title
    IS 'Название версии';
COMMENT ON CONSTRAINT versions_modules_fkey ON versions
    IS 'Ссылка на модуль';
COMMENT ON CONSTRAINT versions_dm_num_language_key ON versions
    IS 'Номер и версия не могут повторяться одновременно для одного модуля';
    
CREATE INDEX versions_title_index ON versions (title);

COMMENT ON INDEX versions_title_index
    IS 'Часто приходится искать по названию версий.';
    
CREATE TABLE versions_content (
    version_id bigint NOT NULL,
    filename character varying(50) NOT NULL,
    content bytea,
    
    CONSTRAINT versions_content_pkey PRIMARY KEY (version_id, filename),
    CONSTRAINT versions_content_version_id_fkey FOREIGN KEY (version_id)
        REFERENCES versions (version_id)
);

COMMENT ON TABLE versions_content
    IS 'Файлы с содержимым модулей';
COMMENT ON COLUMN versions_content.version_id 
    IS 'Идентификатор версии, к которой относится файл';
COMMENT ON COLUMN versions_content.filename
    IS 'Имя файла';
COMMENT ON COLUMN versions_content.content
    IS 'Содержимое файла';
COMMENT ON CONSTRAINT versions_content_version_id_fkey ON versions_content
    IS 'Ссылка на версию';
    
CREATE TABLE users (
    user_id bigint NOT NULL PRIMARY KEY,
    login character varying(50) NOT NULL,
    password character varying(50) NOT NULL,
    enabled boolean NOT NULL,
    user_details json,
    
    CONSTRAINT users_login_key UNIQUE (login)
);

COMMENT ON TABLE users
    IS 'Пользователи';
COMMENT ON COLUMN users.login
    IS 'Логин';
COMMENT ON COLUMN users.password
    IS 'Пароль';
COMMENT ON COLUMN users.enabled
    IS 'Разрешён ли доступ этому пользователю';
COMMENT ON COLUMN users.user_details
    IS 'Различная информация о пользователе - ФИО, телефон и так далее';
COMMENT ON CONSTRAINT users_login_key ON users
    IS 'Логин должен быть уникален в рамках системы';

CREATE TABLE user_authorities (
    user_id bigint NOT NULL,
    authority character varying(20) NOT NULL,
    
    CONSTRAINT user_authorities_fkey FOREIGN KEY (user_id)
        REFERENCES users (user_id),        
    CONSTRAINT user_authorities_unique_key UNIQUE(user_id, authority)
);

COMMENT ON TABLE user_authorities
    IS 'Права пользователей';
COMMENT ON CONSTRAINT user_authorities_fkey ON user_authorities
    IS 'Ссылка на пользователя';
COMMENT ON CONSTRAINT user_authorities_unique_key ON user_authorities
    IS 'Пара пользователь-право должна быть уникальна';    
    
CREATE TABLE tasks (
    task_id bigint NOT NULL PRIMARY KEY,
    user_id bigint NOT NULL,
    chapter_id bigint NOT NULL,
    state character varying(20),
    start_date date,
    finish_date date, 
    
    CONSTRAINT tasks_user_fkey FOREIGN KEY (user_id)
        REFERENCES users(user_id),
    CONSTRAINT tasks_chapter_fkey FOREIGN KEY (chapter_id)
        REFERENCES chapters(chapter_id),
    CONSTRAINT finish_date_valid CHECK (finish_date > start_date)
);

COMMENT ON TABLE tasks
    IS 'Задачи';
COMMENT ON COLUMN tasks.user_id
    IS 'На какого пользователя назначена задача';
COMMENT ON COLUMN tasks.chapter_id
    IS 'К какому разделу относится задача';
COMMENT ON COLUMN tasks.state
    IS 'Состояние задачи - (не начата, выполняется, закончена)';
COMMENT ON COLUMN tasks.start_date
    IS 'Планируемая дата начала работы';
COMMENT ON COLUMN tasks.finish_date
    IS 'Планируемая дата окончания работы';
COMMENT ON CONSTRAINT tasks_user_fkey ON tasks
    IS 'Ссылка на пользователя';
COMMENT ON CONSTRAINT tasks_chapter_fkey ON tasks
    IS 'Ссылка на раздел';
COMMENT ON CONSTRAINT finish_date_valid ON tasks
    IS 'Дата завершения должна быть после даты начала';

--- Примечание к ДЗ 2. Индексов в явном виде создано всего 2, поскольку ограничение уникальности тоже создаёт индекс.