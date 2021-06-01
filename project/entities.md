## Описание сущностей

### Projects - проекты

В одной базе может идти работа над несколькими разными проектами документации, не связанными друг с другом.

Свойства:

- project_id - идентификатор
- title - название проекта

### Chapters - разделы

Проект для целей разработки делится на разделы, которые имеют древовидную структуру (в разделе может быть несколько подразделов).

Свойства:

- chapter_id - идентификатор
- project_id - к какому проекту относится этот разделы
- chapter_id - идентификатор родительского раздела 
- title - название раздела

### Modules - модули

Модуль --- это элемент документации: документ в формате xml, построенный по той или иной схеме (в зависимости от задачи).

Свойства:

- module_id - идентификатор
- chapter_id - в каком разделе находится этот модуль
- code - код (идентификатор модуля с точки зрения пользователя)
- module_type - тип модуля данных

### Versions - версии

Поскольку документация может изменяться с течением времени, а также переводиться на другие языки, у модулей есть версии.

Свойства:

- version_id - идентификатор
- module_id - к какому МД относится эта версия
- issue_number - "мажорный" номер версии
- in_work - номер подверсии (используемый для разработки)
- language - язык версии
- title - заголовок 

### Versions Content - содержимое версии МД

Собственно содержимое модуля данных

Свойства:

- version_id - идентификатор версии
- content - содержимое xml

### Media - иллюстрации, 3D-модели и прочие мультимедиа

Документация может содержать дополнительные мультимедийные материалы.

- media_id - идентификатор
- project_id - к какому проекту относится
- icn - код мультимедийного элемента (его идентификатор с точки зрения пользователя)
- filetype - тип файла
- filesize - размер файла
- path - место на диске, где физически хранится файл

### View sets - готовые комплекты документации для просмотра

Сущность для описания готовых комплектов документации, которые могут просматривать эксплуатанты.

Свойства:

- set_id - идентификатор
- project_id - к какому проекту относится этот комплект документации
- name - название комплекта
- release_date - дата выпуска комплекта

Сущность "комплект документации" связана с версиями модулей данных через таблицу view_sets_versions, и с мультимедийными элементами через таблицу view_sets_media.

### Users - пользователи

Свойства:

- user_id - идентификатор
- login - логин
- password - пароль
- enabled - разрешён ли вход этому пользователю или нет
- is_super_admin - есть ли у этого пользователя права администратора на все проекты

Отдельная таблица user_details отвечает за информацию о пользователе (ФИО, телефон, компания, должность).

### Groups - группы пользователей

Сущность для описания пользователей с одинаковыми правами.

Свойства:

- group_id - идентификатор
- name - название группы

Группы пользователей связываются с пользователями через таблицу user_groups

### Права пользователей

За права пользователей отвечают таблицы user_authorities (права на разработку документации) и view_authorities (права на просмотр документации).

### Tasks - задачи на разработку документации

Свойства:

- task_id - идентификатор задачи
- user_id - на какого пользователя назначена задача
- chapter_id - какой раздел будет редактироваться в рамках этой задачи
- state - состояние задачи (не начата, выполняется, закончена)
- start_date - планируемая дата начала работы
- finish_date - планируемая дата окончания работы

### Comments - обратная связь от эксплуатантов

Свойства:

- comment_id - идентификатор
- set_id - к какому комплекту относится
- version_id - к какой версии МД относится
- user_id - какой пользователь оставил комментарий
- timestamp - время
- xpath_position - к какому месту в документе относится комментарий
- remark - собственно текст комментария