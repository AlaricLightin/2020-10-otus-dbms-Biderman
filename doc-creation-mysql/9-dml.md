# ДЗ 9. SQL выборка

## Запрос с INNER JOIN

```
SELECT modules.code, versions.ident, versions.title
FROM modules JOIN versions ON modules.module_id = versions.module_id
WHERE chapter_id = 1;
```

Для всех модулей, входящих в первую главу, запрос выводит все версии с указанием кода модуля.

## Запрос с LEFT JOIN

```
SELECT users.login, tasks.task_id, tasks.state
FROM users LEFT JOIN tasks ON users.user_id = tasks.user_id;
```

Выводит всех пользователей и назначенные на них задачи. Если у пользователя нет задач, во второй и третьей колонке будет `NULL`.

## Запросы с WHERE

```
SELECT * FROM modules
WHERE (code LIKE '%-A') OR (code LIKE '%-D');
```

Запрос выведет все элементы из таблицы modules, в которых код заканчивается на `-A` или на `-D`. (В стандарте S1000D последний сегмент кода модуля данных состоит из одной буквы, которая указывает на то, где находится узел, который описывает модуль. Вариант "А или D" описывает все узлы, которые могут оказаться установлены на изделии.)

```
SELECT * FROM modules
WHERE code REGEXP '-[A|D]$';
```

То же самое, что и в предыдущем случае, только с регулярными выражениями.

```
WITH RECURSIVE cte (chapter_id, parent_id, title) AS (
    SELECT chapter_id, parent_id, title FROM chapters
    WHERE project_id = 1 AND parent_id IS NULL
    UNION ALL
    SELECT c.chapter_id, c.parent_id, c.title FROM chapters c
    INNER JOIN cte ON c.parent_id = cte.chapter_id
)
SELECT * FROM cte;
```

Рекурсивный запрос, возвращающий все главы в проекте.

```
SELECT * FROM tasks
WHERE finish_date > NOW();
```

Возвращает все задачи, у которых ещё не истекло время завершения.

```
SELECT * FROM tasks
WHERE (finish_date < NOW()) AND (state <> 'COMPLETED');
```

Возвращает задачи, которые должны были уже завершиться, но ещё не завершились.