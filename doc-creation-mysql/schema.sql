CREATE DATABASE IF NOT EXISTS doc_creation;

USE doc_creation;

CREATE TABLE IF NOT EXISTS projects (
    project_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    title varchar(255) NOT NULL COMMENT 'Название проекта',

    CONSTRAINT projects_name_key UNIQUE (title) COMMENT 'Названия проектов не должны совпадать, иначе пользователи в них запутаются.'
)
COMMENT 'Проекты документации';

CREATE TABLE IF NOT EXISTS chapters (
    chapter_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    project_id bigint NOT NULL COMMENT 'К какому проекту относится этот раздел',
    parent_id bigint COMMENT 'Идентификатор родительского раздела, null - если это корневой раздел',
    title varchar(255) COMMENT 'Название раздела',
    
    FOREIGN KEY chapters_project_fkey (project_id)
        REFERENCES projects (project_id),
    FOREIGN KEY chapters_parent_fkey (parent_id)
        REFERENCES chapters (chapter_id)
)
COMMENT 'Разделы документации';
  
CREATE INDEX chapters_title_index ON chapters (project_id, title) 
    COMMENT 'По названиям разделов нужен пользовательский поиск. Но искать имеет смысл только в рамках проекта.';
  
CREATE TABLE IF NOT EXISTS modules (
    module_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    chapter_id bigint NOT NULL COMMENT 'В каком разделе находится модуль',
    code varchar(50) NOT NULL COMMENT 'Код модуля',
    module_type varchar(20) NOT NULL COMMENT 'Тип модуля',
    
    FOREIGN KEY modules_chapter_fkey (chapter_id) 
        REFERENCES chapters(chapter_id)
)
COMMENT 'Модули документации';
   
CREATE TABLE IF NOT EXISTS versions (
    version_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    module_id bigint NOT NULL COMMENT 'К какому модулю относится',
    ident json COMMENT 'Идентификационные данные версии',
    title varchar(255) COMMENT 'Название версии',
    
    FOREIGN KEY versions_modules_fkey (module_id)
        REFERENCES modules(module_id) 
)
COMMENT 'Версии модулей';
   
CREATE INDEX versions_title_index ON versions (title) 
    COMMENT 'Часто приходится искать по названию версий.';

CREATE TABLE IF NOT EXISTS versions_content (
    version_id bigint NOT NULL COMMENT 'Идентификатор версии, к которой относится файл',
    filename varchar(50) NOT NULL COMMENT 'Имя файла',
    content mediumblob COMMENT 'Содержимое файла',
    
    CONSTRAINT versions_content_pkey PRIMARY KEY (version_id, filename),
    CONSTRAINT versions_content_version_id_fkey FOREIGN KEY (version_id)
        REFERENCES versions (version_id)
)
COMMENT 'Файлы с содержимым модулей';
  
CREATE TABLE IF NOT EXISTS users (
    user_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    login varchar(50) NOT NULL COMMENT 'Логин',
    password varchar(50) NOT NULL COMMENT 'Пароль',
    enabled boolean NOT NULL COMMENT 'Разрешён ли доступ этому пользователю',
    user_details json COMMENT 'Различная информация о пользователе - ФИО, телефон и так далее',
    
    CONSTRAINT users_login_key UNIQUE (login) COMMENT 'Логин должен быть уникален в рамках системы'
)
COMMENT 'Пользователи';

CREATE TABLE IF NOT EXISTS user_authorities (
    user_id bigint NOT NULL,
    authority varchar(20) NOT NULL,
    
    FOREIGN KEY user_authorities_fkey (user_id)
        REFERENCES users (user_id),        
    CONSTRAINT user_authorities_unique_key UNIQUE(user_id, authority)
        COMMENT 'Пара пользователь-право должна быть уникальна'
)
COMMENT 'Права пользователей';
  
CREATE TABLE IF NOT EXISTS tasks (
    task_id bigint NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id bigint NOT NULL COMMENT 'На какого пользователя назначена задача',
    chapter_id bigint NOT NULL COMMENT 'К какому разделу относится задача',
    state ENUM('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED') COMMENT 'Состояние задачи - (не начата, выполняется, закончена)',
    start_date date COMMENT 'Планируемая дата начала работы',
    finish_date date COMMENT 'Планируемая дата окончания работы',  
    
    CONSTRAINT tasks_user_fkey FOREIGN KEY (user_id)
        REFERENCES users(user_id),
    CONSTRAINT tasks_chapter_fkey FOREIGN KEY (chapter_id)
        REFERENCES chapters(chapter_id),
    CONSTRAINT finish_date_valid CHECK (finish_date > start_date)
)
COMMENT 'Задачи';