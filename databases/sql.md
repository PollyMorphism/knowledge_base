# SQL

SQL — язык структурированных запросов (SQL, Structured Query Language), который используется в качестве эффективного способа сохранения данных, поиска их частей, обновления, извлечения и удаления из базы данных.

Обращение к реляционным СУБД осуществляется именно благодаря SQL. С помощью него выполняются все основные манипуляции с базами данных, например:

- Извлекать данные из базы данных
- Вставлять записи в базу данных
- Обновлять записи в базе данных
- Удалять записи из базы данных
- Создавать новые базы данных
- Создавать новые таблицы в базе данных
- Создавать хранимые процедуры в базе данных
- Создавать представления в базе данных
- Устанавливать разрешения для таблиц, процедур и представлений

## Порядок операторов

![Картинка](/databases/images/operators_order.png)

## Выборка данных

SELECT

```sql
-- вывод литерала
SELECT 'Hello!';

-- вычисления 
SELECT (5 * 2 - 6) / 2 AS result;

-- вывод всех полей таблицы
SELECT * FROM users;

-- вывод отперелённых полей таблицы
SELECT name, age FROM users;

-- псевдонимы
SELECT name AS user_name, age FROM users;
SELECT name user_name, age FROM users;
```

DISTINCT
```sql
-- удаление дубликатов
SELECT DISTINCT name FROM users;

-- для нескольких колонок
-- удаляет записи, где в обоих колонка одинаковые значения
-- id: 1, name: ivan, age: 15
-- id: 2, name: ivan, age: 15
-- какая именно будет удалена - случайность
SELECT DISTINCT name, age FROM users;
```

WHERE

```sql
-- выборка с условием
SELECT * FROM users WHERE name = 'Ivan';

-- логические операторы
-- AND
-- OR
-- NOT
SELECT * FROM users WHERE name = 'Ivan' AND age = 18;
SELECT * FROM users WHERE name = 'Ivan' OR name = 'Igor';
SELECT * FROM users WHERE NOT name = 'Ivan';

-- операторы сравнения
-- =   - равно
-- !=  - не равно
-- <   - меньше
-- <=  - меньше или равно
-- >   - больше
-- >=  - больше или равно
SELECT * FROM users WHERE name != 'Ivan' AND age >= 20;

-- проверка на NULL
SELECT * FROM users WHERE bio IS NOT NULL;
SELECT * FROM users WHERE bio IS NULL;

-- BETWEEN
-- то же самое что и SELECT * FROM users WHERE age >= 18 AND age <= 20;
SELECT * FROM users WHERE age BETWEEN 18 AND 20;

-- IN
SELECT * FROM users WHERE status IN ('active', 'canceled');

-- LIKE
SELECT * FROM users WHERE email LIKE '%@gmail.com';
SELECT * FROM users WHERE email NOT LIKE '%@gmail.com';

-- регулярные выражение (ПРИМЕР ДЛЯ PostgreSQL)
SELECT * FROM aircrafts WHERE model ~ 'Boeing';
```

ORDER BY

```sql
-- сортировка по полю
SELECT * FROM users ORDER BY name DESC; -- ASC по умолчаанию

-- сортировка по нескольким полям
-- сортирует по имени, но если есть одинаковые, то сортирует их по возрасту
SELECT * FROM users ORDER BY name, age;
```

GROUP BY

```sql
-- вывод групп имён
SELECT name FROM users GROUP BY name;

-- т.к мы группируем записи, то вывод остальных полей доступен только с использованием функций агрегации
-- AVG
-- COUNT
-- MAX
-- MIN
-- SUM
-- вывести статус и средий возраст для каждого статуса
SELECT status, AVG(age) AS avg_age FROM users GROUP BY status;
-- вывести статус и кол-во пользователей для каждого статуса
SELECT status, COUNT(status) AS count FROM users GROUP BY status;

-- группировка по неск.полям
-- разбивает группы name на более мелкие учитывая значения age
SELECT name, age FROM users GROUP BY name, age;

-- HAVING
-- фильтрация групп невозможна в использованием WHERE из-за порядка операторов (сначала должен быть WHERE, потом GROUP BY)
-- WHERE перед GROUP BY не будет учитывать записи в выборке
-- вывести только группы, где больше 10 пользователей
SELECT status, COUNT(*) AS count FROM users 
  GROUP BY status
  HAVING count > 10
```

LIMIT и OFFSET

```sql
-- первые 10 пользователей (порядок случайный)
SELECT * FROM users LIMIT 10;

-- первые 10 пользователей начиная с 5го
SELECT * FROM users LIMIT 10 OFFSET 4;
```

## Многотабличные запросы, JOIN

Шаблон JOIN

```sql
SELECT поля_таблиц
FROM таблица_1
[INNER] | [[LEFT | RIGHT | FULL][OUTER]] JOIN таблица_2
    ON условие_соединения
[[INNER] | [[LEFT | RIGHT | FULL][OUTER]] JOIN таблица_n
    ON условие_соединения]
```

### INNER JOIN
INNER JOIN используется по умолчанию -> JOIN

```sql
SELECT id, name, total AS order_total FROM users
  JOIN orders
    ON users.id = orders.user_id;

-- вместо INNER JOIN также можно использовать WHERE
SELECT name, total AS order_total FROM users, orders
  WHERE users.id = orders.user_id;

-- JOIN с фильтрацией
SELECT orders.code, users.name, items.name FROM orders
  JOIN users
    ON orders.user_id = users.id
  JOIN items
    ON orders.item_id = items.id
  WHERE orders.total > 2000;

-- JOIN с группировкой
SELECT users.id AS user_id, SUM(orders.total) AS orders_sum FROM users
  JOIN orders
    ON users.id = orders.user_id
  GROUP BY user_id
  HAVING orders_sum > 5000;
```

### OUTER JOIN

LEFT JOIN

Получение всех данных из левой таблицы, соединённых с соответствующими данными из правой

Если нет совпадений - значения из правой таблицы заполнябтся NULL

```sql
SELECT поля_таблиц 
FROM левая_таблица LEFT JOIN правая_таблица 
    ON правая_таблица.ключ = левая_таблица.ключ 
```

RIGHT JOIN

Получение всех данных из правой таблицы, соединённых с соответствующими данными из левой

Если нет совпадений - значения из левой таблицы заполнябтся NULL

```sql
SELECT поля_таблиц
FROM левая_таблица RIGHT JOIN правая_таблица
    ON правая_таблица.ключ = левая_таблица.ключ
```




