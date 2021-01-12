# ДЗ 5. DML в PostgreSQL

## Напишите запрос по своей базе с регулярным выражением, добавьте пояснение, что вы хотите найти

```
SELECT * FROM content.modules 
WHERE code ~ '-[A|D]$';
```

Запрос выведет все элементы из таблицы content.modules, в которых код заканчивается на `-A` или на `-D`. (В стандарте S1000D последний сегмент кода модуля данных состоит из одной буквы, которая указывает на то, где находится узел, который описывает модуль. Вариант "А или D" описывает все узлы, которые могут оказаться установлены на изделии.)

## Напишите запрос по своей базе с использованием LEFT JOIN и INNER JOIN, как порядок соединений в FROM влияет на результат? Почему?

```
SELECT 
  content.chapters.chapter_id AS chapter_id,
  content.chapters.title AS chapter_title,
  tasks.tasks.task_id,
  content.modules.code
FROM content.chapters 
  INNER JOIN tasks.tasks ON tasks.tasks.chapter_id = content.chapters.chapter_id
  LEFT JOIN content.modules ON content.chapters.chapter_id = content.modules.chapter_id;
```

Запрос выводит, какие главы и какие модули входят в какие задачи.

При изменении порядка соединений ничего не меняется. В данном случае `LEFT JOIN` возвращает всё, что вернул бы `INNER JOIN` плюс те главы, в которых сейчас нет ни одного модуля. Нет никакой разницы (кроме, быть может, скорости выполнения, но и тут наверное оптимизатор справится), мы сначала исключим те главы, которые не соответствуют никакой задаче, или потом.

## Напишите запрос на добавление данных с выводом информации о добавленных строках

```
INSERT INTO tasks.tasks(task_id, user_id, chapter_id) VALUES 
  (1, 1, 2),
  (2, 1, 3)
RETURNING *;
```

## Напишите запрос с обновлением данные используя UPDATE FROM

```
UPDATE tasks.tasks
SET state = 'FINISHED'
FROM content.chapters 
WHERE content.chapters.chapter_id = tasks.tasks.chapter_id
  AND content.chapters.title = 'Chapter 2';
```

Помечает как завершённые все задачи, относящиеся к главе "Chapter 2".

## Напишите запрос для удаления данных с оператором DELETE используя join с другой таблицей с помощью using

```
DELETE FROM content.modules
USING content.chapters
WHERE content.chapters.chapter_id = content.modules.chapter_id
	AND content.chapters.title = 'Chapter 2';
```

Удаляет все модули из главы с названием "Chapter 2".

## Приведите пример использования утилиты COPY (по желанию)

```
COPY (
	SELECT content.chapters.title, content.modules.code 
	FROM content.chapters JOIN content.modules 
	ON content.chapters.chapter_id = content.modules.chapter_id
)		  
	  TO '/tmp/result.csv'
WITH CSV;
```