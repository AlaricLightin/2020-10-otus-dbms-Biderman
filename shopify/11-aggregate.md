# ДЗ 11. Отчётная выборка

Поскольку у меня в проекте пока не слишком много простора для отчётных выборок, я решил воспользоваться результатами импорта из CSV shopify. Поскольку там не нормализованная таблица, я для простоты исключаю те строки, где не указан тип или цена.

Запрос, который возвращает минимальный и максимальный товар в каждой категории:
```
SELECT type, MIN(CAST(v_price as decimal(10, 2))), MAX(CAST(v_price as decimal(10, 2))) FROM Fashion
WHERE (type <> '') AND (v_price <> '')
GROUP BY type
ORDER BY type;
```

Запрос, который возвращает количество товаров в каждой категории вместе с общим итогом:
```
SELECT 
    CASE GROUPING(type) WHEN 0 THEN type ELSE 'All types' END AS category,
    COUNT(*) FROM Fashion
WHERE (type <> '') AND (v_price <> '')
GROUP BY type WITH ROLLUP;
```

Запрос, который возвращает количество товаров в каждой категории, но выводит только категории, где больше 10 видов товаров:
```
SELECT 
    type, COUNT(*) AS c FROM Fashion
WHERE (type <> '') AND (v_price <> '')
GROUP BY type
HAVING c > 10
ORDER BY type;
```
