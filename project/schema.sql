CREATE ROLE doc_developer;
COMMENT ON ROLE doc_developer
    IS 'Роль для разработки документации';

CREATE ROLE doc_viewer;
COMMENT ON ROLE doc_viewer
    IS 'Роль для просмотра документации';

CREATE SCHEMA content;
COMMENT ON SCHEMA content
    IS 'Всё, что относится собственно к документации';

CREATE SCHEMA development;
COMMENT ON SCHEMA development
    IS 'То, что относится к процессу разработки документации';

CREATE SCHEMA users;
COMMENT ON SCHEMA users
    IS 'Информация о пользователях';
    
CREATE SCHEMA feedback;
COMMENT ON SCHEMA feedback
    IS 'Таблицы для обратной связи';

CREATE TABLE development.projects (
    project_id bigserial NOT NULL PRIMARY KEY,
    title varchar(255) NOT NULL,

    CONSTRAINT projects_name_key UNIQUE (title)
);

COMMENT ON TABLE development.projects 
    IS 'Проекты документации';
COMMENT ON COLUMN development.projects.title 
    IS 'Название проекта';
COMMENT ON CONSTRAINT projects_name_key ON development.projects 
    IS 'Названия проектов не должны совпадать, иначе пользователи в них запутаются.';

CREATE TABLE development.chapters (
    chapter_id bigserial NOT NULL PRIMARY KEY,
    project_id bigint NOT NULL,
    parent_id bigint,
    title varchar(255),
    
    CONSTRAINT chapters_project_fkey FOREIGN KEY (project_id)
        REFERENCES development.projects (project_id),
    CONSTRAINT chapters_parent_fkey FOREIGN KEY (parent_id)
        REFERENCES development.chapters (chapter_id)
);

COMMENT ON TABLE development.chapters
    IS 'Разделы документации';
COMMENT ON COLUMN development.chapters.project_id
    IS 'К какому проекту относится этот раздел';
COMMENT ON COLUMN development.chapters.parent_id
    IS 'Идентификатор родительского раздела, null - если это корневой раздел';
COMMENT ON COLUMN development.chapters.title
    IS 'Название раздела';
COMMENT ON CONSTRAINT chapters_project_fkey ON development.chapters
    IS 'Ссылка на проект';
COMMENT ON CONSTRAINT chapters_parent_fkey ON development.chapters
    IS 'Связь с родительским разделом';
    
CREATE INDEX chapters_title_index ON development.chapters (project_id, title);

COMMENT ON INDEX development.chapters_title_index
    IS 'По названиям разделов нужен пользовательский поиск. Но искать имеет смысл только в рамках проекта.';
    
CREATE TABLE content.modules (
    module_id bigserial NOT NULL PRIMARY KEY,
    chapter_id bigint NOT NULL,
    code varchar(50) NOT NULL,
    module_type varchar(20) NOT NULL,
    
    CONSTRAINT modules_chapter_fkey FOREIGN KEY (chapter_id) 
        REFERENCES development.chapters(chapter_id)
);

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
    version_id bigserial NOT NULL PRIMARY KEY,
    module_id bigint NOT NULL,
    issue_number smallint NOT NULL,
    in_work smallint NOT NULL,
    language varchar(5) NOT NULL,
    title varchar(255),
    
    CONSTRAINT versions_modules_fkey FOREIGN KEY (module_id)
        REFERENCES content.modules(module_id),
    CONSTRAINT versions_issue_language_key UNIQUE (module_id, issue_number, in_work, language)
);

COMMENT ON TABLE content.versions
    IS 'Версии модулей';
COMMENT ON COLUMN content.versions.module_id
    IS 'К какому модулю относится';
COMMENT ON COLUMN content.versions.issue_number
    IS 'Номер версии';
COMMENT ON COLUMN content.versions.in_work
    IS 'Номер подверсии';
COMMENT ON COLUMN content.versions.language 
    IS 'Язык версии';
COMMENT ON COLUMN content.versions.title
    IS 'Название версии';
COMMENT ON CONSTRAINT versions_modules_fkey ON content.versions
    IS 'Ссылка на модуль';
COMMENT ON CONSTRAINT versions_issue_language_key ON content.versions
    IS 'Номер и версия не могут повторяться одновременно для одного модуля';
    
CREATE INDEX versions_title_index ON content.versions (title);

COMMENT ON INDEX content.versions_title_index
    IS 'Часто приходится искать по названию версий.';
    
CREATE TABLE content.versions_content (
    version_id bigint NOT NULL PRIMARY KEY ,
    content xml,
    
    CONSTRAINT versions_content_version_id_fkey FOREIGN KEY (version_id)
        REFERENCES content.versions (version_id)
);

COMMENT ON TABLE content.versions_content
    IS 'Файлы с содержимым модулей';
COMMENT ON CONSTRAINT versions_content_version_id_fkey ON content.versions_content
    IS 'Ссылка на версию';

CREATE TABLE content.media (
    media_id bigserial NOT NULL PRIMARY KEY,
    project_id bigint NOT NULL,
    icn varchar(60) NOT NULL,
    filetype varchar(4) NOT NULL,
    filesize bigint NOT NULL,
    path varchar(255) NOT NULL,

    CONSTRAINT media_icn_pkey UNIQUE (project_id, icn),
    CONSTRAINT media_projects_fkey FOREIGN KEY (project_id)
        REFERENCES development.projects (project_id)
);

COMMENT ON TABLE content.media
    IS 'Файлы с мультимедиа (изображения, 3D, видео)';
COMMENT ON COLUMN content.media.project_id
    IS 'К какому проекту относится';
COMMENT ON COLUMN content.media.icn
    IS 'ICN - уникальный код мультимедиа в рамках проекта';
COMMENT ON COLUMN content.media.filetype
    IS 'Тип файла (пока расширение)';
COMMENT ON COLUMN content.media.filesize
    IS 'Размер файла';
COMMENT ON COLUMN content.media.path
    IS 'Место хранения файла на диске';

CREATE TABLE content.view_sets (
    set_id bigserial NOT NULL PRIMARY KEY,
    project_id bigint NOT NULL,
    name varchar(255) NOT NULL,
    release_date date NOT NULL,

    CONSTRAINT view_sets_projects_fkey FOREIGN KEY (project_id)
        REFERENCES development.projects(project_id)
);

COMMENT ON TABLE content.view_sets
    IS 'Готовые комплекты документации для просмотра';

CREATE TABLE content.view_sets_versions (
    set_id bigint NOT NULL,
    version_id bigint NOT NULL,

    CONSTRAINT view_sets_versions_set_fkey FOREIGN KEY (set_id)
        REFERENCES content.view_sets (set_id),
    CONSTRAINT view_sets_versions_version_fkey FOREIGN KEY (version_id)
        REFERENCES content.versions (version_id),
    CONSTRAINT view_sets_unique_key UNIQUE (set_id, version_id)
);

COMMENT ON TABLE content.view_sets_versions
    IS 'Связь версий с готовыми комплектами документации';

CREATE TABLE content.view_sets_media
(
    set_id     bigint NOT NULL,
    media_id   bigint NOT NULL,

    CONSTRAINT view_sets_media_set_fkey FOREIGN KEY (set_id)
        REFERENCES content.view_sets (set_id),
    CONSTRAINT view_sets_media_media_fkey FOREIGN KEY (media_id)
        REFERENCES content.media (media_id),
    CONSTRAINT view_sets_media_unique_key UNIQUE (set_id, media_id)
);

COMMENT ON TABLE content.view_sets_media
    IS 'Связь мультимедиа с готовыми комплектами документации';

CREATE TABLE users.users (
    user_id bigserial NOT NULL PRIMARY KEY,
    login varchar(50) NOT NULL,
    password varchar(50) NOT NULL,
    enabled boolean NOT NULL,
    is_super_admin boolean NOT NULL DEFAULT false,

    CONSTRAINT users_login_key UNIQUE (login)
);

COMMENT ON TABLE users.users
    IS 'Пользователи';
COMMENT ON COLUMN users.users.login
    IS 'Логин';
COMMENT ON COLUMN users.users.password
    IS 'Пароль';
COMMENT ON COLUMN users.users.enabled
    IS 'Разрешён ли доступ этому пользователю';
COMMENT ON COLUMN users.users.is_super_admin
    IS 'Флаг суперпользователя, у которого есть все права на все проекты';
COMMENT ON CONSTRAINT users_login_key ON users.users
    IS 'Логин должен быть уникален в рамках системы';

CREATE TABLE users.user_details (
    user_id bigint NOT NULL PRIMARY KEY,
    first_name varchar(100),
    last_name varchar(100),
    phone varchar(15),
    company varchar,
    position varchar(100),

    CONSTRAINT user_details_users_fkey FOREIGN KEY (user_id)
        REFERENCES users.users (user_id)
);

COMMENT ON TABLE users.user_details
    IS 'Таблица с информацией о пользователях';

CREATE TABLE users.groups (
    group_id bigserial NOT NULL PRIMARY KEY,
    name varchar(255) NOT NULL,

    CONSTRAINT group_name_key UNIQUE (name)
);

COMMENT ON TABLE users.groups
    IS 'Группы пользователей';
COMMENT ON COLUMN users.groups.name
    IS 'Название группы';
COMMENT ON CONSTRAINT group_name_key ON users.groups
    IS 'Название группы должно быть уникально в рамках системы';

CREATE TABLE users.user_groups (
    group_id bigint NOT NULL,
    user_id bigint NOT NULL,

    CONSTRAINT user_groups_groups_fkey FOREIGN KEY (group_id)
        REFERENCES users.groups (group_id),
    CONSTRAINT user_groups_users_fkey FOREIGN KEY (user_id)
        REFERENCES users.users (user_id),
    CONSTRAINT user_groups_unique_key UNIQUE (group_id, user_id)
);

COMMENT ON TABLE users.user_groups
    IS 'Связь между пользователями и группами пользователей';

CREATE TYPE users.user_class AS ENUM ('USER', 'GROUP');
CREATE TYPE users.user_authority AS ENUM ('ADMIN', 'MANAGER', 'WRITER');

CREATE TABLE users.user_authorities (
    project_id bigint NOT NULL,
    user_class users.user_class NOT NULL,
    user_or_group_id bigint NOT NULL,
    authority users.user_authority NOT NULL,

    CONSTRAINT user_authorities_project_fkey FOREIGN KEY (project_id)
        REFERENCES development.projects (project_id),
    CONSTRAINT user_authorities_unique_key UNIQUE (project_id, user_class, user_or_group_id, authority)
);

COMMENT ON TABLE users.user_authorities
    IS 'Права пользователей';
COMMENT ON COLUMN users.user_authorities.project_id
    IS 'Проект, на который назначаются права';
COMMENT ON COLUMN users.user_authorities.user_class
    IS 'Права назначаются группе или отдельному пользователю?';
COMMENT ON COLUMN users.user_authorities.user_or_group_id
    IS 'Идентификатор группы или пользователя';
COMMENT ON CONSTRAINT user_authorities_unique_key ON users.user_authorities
    IS 'Строчки таблицы должны быть уникальны целиком';

CREATE TABLE users.view_authorities (
    set_id bigint NOT NULL,
    user_class users.user_class NOT NULL,
    user_or_group_id bigint NOT NULL,

    CONSTRAINT view_authorities_set_fkey FOREIGN KEY (set_id)
        REFERENCES content.view_sets (set_id),
    CONSTRAINT view_authorities_unique_key UNIQUE (set_id, user_class, user_or_group_id)
);

COMMENT ON TABLE users.view_authorities
    IS 'Права на просмотр готовой документации';
COMMENT ON COLUMN users.view_authorities.set_id
    IS 'Комплект, на который назначаются права';
COMMENT ON COLUMN users.view_authorities.user_class
    IS 'Права назначаются группе или отдельному пользователю?';
COMMENT ON COLUMN users.view_authorities.user_or_group_id
    IS 'Идентификатор группы или пользователя';

CREATE TYPE development.task_state AS ENUM (
    'NOT_STARTED', 'IN_PROGRESS', 'FROZEN', 'FINISHED'
    );

CREATE TABLE development.tasks (
    task_id bigserial NOT NULL PRIMARY KEY,
    user_id bigint NOT NULL,
    chapter_id bigint NOT NULL,
    state development.task_state,
    start_date date,
    finish_date date, 
    
    CONSTRAINT tasks_user_fkey FOREIGN KEY (user_id)
        REFERENCES users.users(user_id),
    CONSTRAINT tasks_chapter_fkey FOREIGN KEY (chapter_id)
        REFERENCES development.chapters(chapter_id),
    CONSTRAINT finish_date_valid CHECK (finish_date > start_date)
);

COMMENT ON TABLE development.tasks
    IS 'Задачи';
COMMENT ON COLUMN development.tasks.user_id
    IS 'На какого пользователя назначена задача';
COMMENT ON COLUMN development.tasks.chapter_id
    IS 'К какому разделу относится задача';
COMMENT ON COLUMN development.tasks.state
    IS 'Статус задачи';
COMMENT ON COLUMN development.tasks.start_date
    IS 'Планируемая дата начала работы';
COMMENT ON COLUMN development.tasks.finish_date
    IS 'Планируемая дата окончания работы';
COMMENT ON CONSTRAINT tasks_user_fkey ON development.tasks
    IS 'Ссылка на пользователя';
COMMENT ON CONSTRAINT tasks_chapter_fkey ON development.tasks
    IS 'Ссылка на раздел';
COMMENT ON CONSTRAINT finish_date_valid ON development.tasks
    IS 'Дата завершения должна быть после даты начала';

CREATE TABLE feedback.comments (
    comment_id bigserial NOT NULL PRIMARY KEY,
    set_id bigint NOT NULL,
    version_id bigint NOT NULL,
    user_id bigint NOT NULL,
    timestamp timestamp with time zone NOT NULL,
    xpath_position varchar(255),
    remark text NOT NULL,

    CONSTRAINT feedback_set_version_fkey FOREIGN KEY (set_id, version_id)
        REFERENCES content.view_sets_versions (set_id, version_id),
    CONSTRAINT feedback_users_fkey FOREIGN KEY (user_id)
        REFERENCES users.users (user_id)
);

COMMENT ON TABLE feedback.comments
    IS 'Обратная связь от пользователей документации';
COMMENT ON COLUMN feedback.comments.set_id
    IS 'Комплект документации';
COMMENT ON COLUMN feedback.comments.version_id
    IS 'К какой версии относится комментарий';
COMMENT ON COLUMN feedback.comments.user_id
    IS 'Автор комментария';
COMMENT ON COLUMN feedback.comments.timestamp
    IS 'Время оставления комментария';
COMMENT ON COLUMN feedback.comments.xpath_position
    IS 'К какому месту в документе относится. null - если к документу в целом';
COMMENT ON COLUMN feedback.comments.remark
    IS 'Текст комментария';

GRANT ALL ON ALL TABLES IN SCHEMA development, content, users, feedback
    TO doc_developer;
GRANT SELECT ON ALL TABLES IN SCHEMA content, users
    TO doc_viewer;
GRANT ALL ON ALL TABLES IN SCHEMA feedback
    TO doc_viewer;