# Основы SQL и PostgreSQL

## PSQL
```shell
# подключиться к базе demo с пользователем postgres
psql -d demo -U postgres

# вывод информации о таблице
\d table_name 

#                    Table "public.aircrafts"
#     Column     |     Type     | Collation | Nullable | Default 
# ---------------+--------------+-----------+----------+---------
#  aircraft_code | character(3) |           | not null | 
#  model         | text         |           | not null | 
#  range         | integer      |           | not null | 
# Indexes:
#     "aircrafts_pkey" PRIMARY KEY, btree (aircraft_code)
# Check constraints:
#     "aircrafts_range_check" CHECK (range > 0)

# переключение на другую базу
\connect demo # или \c demo
```

## Работа с таблицами
### Создание таблицы
```sql
-- CREATE TABLE имя-таблицы
-- (
-- имя-поля тип-данных [ограничения-целостности],
-- имя-поля тип-данных [ограничения-целостности],
-- ...
-- имя-поля тип-данных [ограничения-целостности],
-- [ограничение-целостности],
-- [первичный-ключ],
-- [внешний-ключ]
-- );

CREATE TABLE aircrafts
( aircraft_code char( 3 ) NOT NULL,
  model text NOT NULL,
  range integer NOT NULL,
  CHECK ( range > 0 ),
  PRIMARY KEY ( aircraft_code )
);

-- DEFAULT
range integer DEFAULT 5000,

-- CHECK
CHECK ( range > 0 )
CHECK ( fare_conditions IN ('Economy', 'Comfort', 'Business') );

-- KEYS
-- primery key
PRIMARY KEY ( aircraft_code )
-- foreign key
FOREIGN KEY ( aircraft_code )
  REFERENCES aircrafts (aircraft_code )

-- каскадное удаление
FOREIGN KEY ( aircraft_code )
  REFERENCES aircrafts (aircraft_code )
  ON DELETE CASCADE
```

### Удаление таблицы
```sql
DROP TABLE table_name;

-- если таблица является главной (в др.таблицах есть внешние ключи на неё)
DROP TABLE table_name CASCADE;

-- если не известно существует ли таблица
DROP TABLE IF EXISTS table_name CASCADE;
```

### Обновление таблицы
```sql
-- добавление нового столбца
ALTER TABLE airports
  ADD COLUMN speed integer NOT NULL;

-- удаление столбца
ALTER TABLE aircrafts DROP COLUMN speed;

-- переименование столбца
ALTER TABLE seats
  RENAME COLUMN fare_conditions TO fare_conditions_code;

-- добавление ограничения
ALTER TABLE aircrafts ADD CHECK( speed >= 300 );

-- удаление ограничений
-- имя constraint можно узнать в данных таблицы --> \d aircrafts
ALTER TABLE aircrafts ALTER COLUMN speed DROP NOT NULL;
ALTER TABLE aircrafts DROP CONSTRAINT aircrafts_speed_check;

-- переименование ограничения
ALTER TABLE seats
  RENAME CONSTRAINT seats_fare_conditions_fkey
  TO seats_fare_conditions_code_fkey;

-- изменение типа данных столбца (в рамках одного типа)
ALTER TABLE airports
  ALTER COLUMN longitude SET DATA TYPE numeric( 5,2 ),
  ALTER COLUMN latitude SET DATA TYPE numeric( 5,2 );

-- изменения типа данных столбца (на другой тип)
ALTER TABLE seats
  ALTER COLUMN fare_conditions SET DATA TYPE integer
  USING ( CASE WHEN fare_conditions ='Economy' THEN 1
               WHEN fare_conditions ='Business' THEN 2
               ELSE 3
          END );

-- добавление внешнего ключа
ALTER TABLE seats
  ADD FOREIGN KEY ( fare_conditions )
        REFERENCES fare_conditions ( fare_conditions_code );

-- добавление unique
ALTER TABLE fare_conditions ADD UNIQUE ( fare_conditions_name );
```

### Вставка данных в таблицу
```sql
-- INSERT INTO имя-таблицы [( имя-атрибута, имя-атрибута, ... )]
-- VALUES ( значение-атрибута, значение-атрибута, ... );

-- вставлять можно более одной строки за раз
INSERT INTO aircrafts ( aircraft_code, model, range )
  VALUES ('SU9','Sukhoi SuperJet-100', 3000 );
  --     ( еще значения);

-- вставка без перечисления атрибутов
INSERT INTO aircrafts
  VALUES ('SU9', 'Sukhoi SuperJet-100', 3000 );
```

### Выборка данных из таблицы
```sql
-- SELECT имя-атрибута, имя-атрибута, ...
-- FROM имя-таблицы;

-- выбрать все поля
SELECT * FROM aircrafts;

-- выбрать с сортировкой по полю
SELECT model, aircraft_code, range
  FROM aircrafts
  ORDER BY model;
--ORDER BY model DESC; - меняем порядок

-- выбрать с условием
SELECT model, aircraft_code, range
  FROM aircrafts
  WHERE range >= 4000 AND range <= 6000;
```

### Обновление данных в таблице
```sql
-- UPDATE имя-таблицы
--   SET имя-атрибута1 = значение-атрибута1,
--       имя-атрибута2 = значение-атрибута2, ...
--   WHERE условие;

-- если условие не задано, то обновяться все строки в таблице

UPDATE aircrafts SET range = 3500
  WHERE aircraft_code ='SU9';

-- доступны арифметические операции
UPDATE aircrafts SET range=range*2
  WHERE aircraft_code = 'SU9';
```

### Удаление данных из таблицы
```sql
-- DELETE FROM имя-таблицы WHERE условие;
DELETE FROM aircrafts WHERE range > 10000 OR range < 3000;

-- для удаления всех строк 
DELETE FROM aircrafts;
```

### Агрегация данных
```sql
-- вывести кол-во
SELECT count( * ) FROM seats WHERE aircraft_code ='SU9';

-- группировка по значению
SELECT aircraft_code, count( * ) FROM seats
  GROUP BY aircraft_code;
```

# Типы данных

## Числовые типы

### Последовательные
Тип serial удобен в тех случаях, когда требуется в какой-либо столбец вставлять
уникальные целые значения, например, значения суррогатного первичного ключа.
```shell
serial 
bigserial   # по размеру как bigint
smallserial # по размеру как smallint
```

### Целочисленные
```shell
smallint # int2
integer  # int4
bigint   # int8
```

### Числа фиксированной точности
131 072 цифры — до десятичной точки 

16 383 — после точки

Данный тип следует выбирать для хранения денежных сумм, а также в других случаях, когда требуется гарантировать точность вычислений.

```shell
numeric # такие же воз-ти как и у decimal

numeric(точность, масштаб)
# точность - общее кол-во цифр (до и после точки)
# масштаб  - кол-во цифр после точки
# 12.345 -> numeric(6,4)
```

### Числа с плавающей точкой
При работе с числами таких типов нужно помнить, что сравнение двух чисел с пла-
вающей точкой на предмет равенства их значений может привести к неожиданным
результатам.

```shell
# от 1E−37 до 1E+37 с точностью не меньше 6 десятичных цифр
real

# от 1E−307 до 1E+308 с точностью не меньше 15 десятичных цифр
double precision

# p = 1..24 - тоже саоме что и real
# p = 25..53 - тоже самое что и double precision
# без передачи p будет double precision -> float
float(p)
```

### Спец.значения
```shell
Infinity
-Infinity
NaN
```

## Символьные (строковые типы)

Документация рекомендует использовать типы text и varchar так как дополнение пробелами в char почти не востребовано.

В PostgreSQL обычно используется тип text.

```shell
# n - длинна в символах

# если значение короче, то дополняется пробелами
character(n) # char(n)

# если значени короче, то сохраняется как есть
character varying(n) # varchar(n)

# сколь угодно большое значение
text
```

## Дата и время

### Типы данных
```sql
-- Даты
-- Рекомендуемый стандартом ISO 8601 формат вво-да дат таков: «yyyy-mm-dd»
date

-- Время
-- просто время -> 21:00
time
-- время с таймзоной (документация не рекомендует его использовать)
time with time zone

-- Дата и время
-- без таймзоны 
timestamp
-- с таймзоной (сервера)
timestampz

-- Интервалы
SELECT '1 year 2 months ago'::interval;
SELECT ('2016-09-16'::timestamp -'2016-09-01'::timestamp)::interval;
```

### Функции для работы с датами и временем
```sql
-- текущая дата
SELECT current_date;

-- вывод даты строкой
SELECT to_char(current_date, 'dd-mm-yyyy');

-- текущее время (с таймзоной сервера)
SELECT current_time;

-- текущая дата и время
SELECT current_timestamp;
```

## Логический тип

Логический (boolean) тип может принимать три состояния: истина и ложь, а так-
же неопределенное состояние, которое можно представить значением NULL.

```sql
-- true значения  -> TRUE, 't', 'true', 'y', 'yes', 'on', '1'
-- false значения -> FALSE, 'f', 'false', 'n', 'no', 'off', '0'
boolean
```

## Массивы

```sql
-- пример создания таблицы с массивом
CREATE TABLE pilots
(
  pilot_name text,
  schedule integer[]
);

-- вставка данных в табицу с массивом
INSERT INTO pilots
  VALUES ( 'Ivan',  '{ 1, 3, 5, 6, 7 }'::integer[] ),
         ( 'Boris', '{ 3, 5, 6       }'::integer[] );

-- обновление массива
UPDATE pilots
  SET schedule = array_append( schedule, 6 )
  WHERE pilot_name ='Pavel';

UPDATE pilots
  SET schedule = array_prepend( 1, schedule )
  WHERE pilot_name ='Pavel';

UPDATE pilots
  SET schedule = array_remove( schedule, 5 )
  WHERE pilot_name ='Ivan';

-- поиск записей по значению из массива
SELECT * FROM pilots
  WHERE array_position( schedule, 3 ) IS NOT NULL;

-- &&
SELECT * FROM pilots
  WHERE schedule @>'{ 1, 7 }'::integer[];

-- ||
SELECT * FROM pilots
  WHERE schedule && ARRAY[ 2, 5 ];
```

## JSON
Основное различие между json и jsonb заключается в быстродействии.

Если столбец имеет тип json, тогда сохранение значений происходит быстрее, потому что они записываются в том виде, в котором были введены. Но при последующем использовании этих значений в качестве операндов или параметров функций
будет каждый раз выполняться их разбор, что замедляет работу.

При использовании
типа jsonb разбор производится однократно, при записи значения в таблицу. Это
несколько замедляет операции вставки строк, в которых содержатся значения дан-
ного типа. Но все последующие обращения к сохраненным значениям выполняются
быстрее, т. к. выполнять их разбор уже не требуется.

json сохраняет порядок следования ключей
в объектах и повторяющиеся значения ключей, а тип jsonb этого не делает.

Рекомендуется в приложениях использовать тип jsonb, если только нет каких-то особых
аргументов в пользу выбора типа json.

```sql
json
jsonb

-- пример создания таблицы
CREATE TABLE pilot_hobbies
(
  pilot_name text,
  hobbies jsonb
);

-- создание новых записей
INSERT INTO pilot_hobbies
VALUES ('Ivan',
        '{ "sports": [ "футбол", "плавание" ],
           "home_lib": true, "trips": 3
         }'::jsonb
       );

-- поиск записей по ключ-значение
SELECT * FROM pilot_hobbies
  WHERE hobbies @>'{ "sports": [ "футбол" ] }'::jsonb;

-- обновление значений
UPDATE pilot_hobbies
  SET hobbies = hobbies ||'{ "sports": [ "хоккей" ] }'
  WHERE pilot_name ='Boris';

-- добавление новых значений
UPDATE pilot_hobbies
  SET hobbies = jsonb_set( hobbies,'{ sports, 1 }'
  WHERE pilot_name ='Boris';
```

# Основы DDL

## Значение по умолчанию и constraints

### DEFAULT

```sql
CREATE TABLE progress
( ...
  mark numeric( 1 ) DEFAULT 5,
  ...
);
```

### CHECK

```sql
-- создание таблицы с ограничениями по полям
CREATE TABLE progress
( ...
  term numeric( 1 ) CHECK ( term = 1 OR term = 2 ),
  mark numeric( 1 ) CHECK ( mark >= 3 AND mark <= 5 ),
  ...
);

-- имя constraint можно задать вручную
CREATE TABLE progress
( ...
  mark numeric( 1 ),
  CONSTRAINT valid_mark CHECK ( mark >= 3 AND mark <= 5 ),
  ...
);
```

### NOT NULL
Эквивалентен записи CHECK ( column_name IS NOT NULL), но рекомендуется использовать именно NOT NULL

```sql
CREATE TABLE aircrafts
(
  ...
  range integer NOT NULL,
  ...
)
```

### UNIQUE
Такое ограничение, наложенное на конкретный столбец, означает, что все значения, содержа-
щиеся в этом столбце в различных строках таблицы, должны быть уникальными, т. е. не должны повторяться.

При добавлении ограничения уникальности автоматически создается индекс на основе B-дерева для поддержки этого ограничения.

```sql
CREATE TABLE students
( record_book numeric( 5 ) UNIQUE,
  ...
);

-- задать имя ограничения вручную
CREATE TABLE students
( record_book numeric( 5 ),
  ...
  CONSTRAINT unique_record_book UNIQUE ( record_book ),
  ...
);

-- ограничение на несколько столбцов
CREATE TABLE students
( ...
  doc_ser numeric( 4 ),
  doc_num numeric( 6 ),
  ...
  CONSTRAINT unique_passport UNIQUE ( doc_ser, doc_num ),
  ...
);
```

### Первичные ключи

Первичный ключ является уникальным идентификатором строк в таблице.

Ключ может быть как простым, т. е. включать только один атрибут, так и составным, т. е. включать более одного атрибута.

Запись PRIMARY KEY подразумевает ограничения UNIQUE и NOT NULL (но заменять его этими ограничениями не следует).

При добавлении первичного ключа автоматически создается индекс на основе B-дерева для поддержки этого ограничения.

Первичный ключ должен быть один на таблицу (unique - сколько хочешь).

```sql
-- при определении полей таблицы
CREATE TABLE students
( record_book numeric( 5 ) PRIMARY KEY,
  ...
);

-- как отдельное ограничение
CREATE TABLE students
( record_book numeric( 5 ),
  ...
  PRIMARY KEY ( record_book )
);

-- составной ключ
PRIMARY KEY ( имя-столбца1, имя-столбца2, ...)
```

### Внешние ключи

Внешний ключ ссылающейся таблицы ссылается на первичный ключ ссылочной таблицы.

```sql
-- на уровне атрибута таблицы
CREATE TABLE progress
( record_book numeric( 5 ) REFERENCES students ( record_book ),
  ...
);

-- сокращенная форма записи (т.к. ссылаемся на первичный ключ другой таблицы)
CREATE TABLE progress
( record_book numeric( 5 ) REFERENCES students,
  ...
);

-- на уровне таблицы
CREATE TABLE progress
( record_book numeric( 5 ),
  ...
  FOREIGN KEY ( record_book )
    REFERENCES students ( record_book )
);

-- ограничения на внешние ключи

-- каскадное удаление
-- удалит все соответствующие записи из ссылающейся таблицы при удалении записи из ссылочной таблицы
CREATE TABLE progress
( record_book numeric( 5 ),
  ...
  FOREIGN KEY ( record_book )
    REFERENCES students ( record_book )
    ON DELETE CASCADE
);

-- запрет удаления
-- используется по умолчанию (NO ACTION)
-- при NO ACTION проверку можно отложить на потом ( в рамках транзакции)
-- при RESTRICT проверка выполняется сразу
CREATE TABLE progress
( record_book numeric( 5 ),
  ...
  FOREIGN KEY ( record_book )
    REFERENCES students ( record_book )
    ON DELETE RESTRICT
);

-- обнуление с NULL
CREATE TABLE progress
( record_book numeric( 5 ),
  ...
  FOREIGN KEY ( record_book )
    REFERENCES students ( record_book )
    ON DELETE SET NULL
);

-- заполнение значением по умолчанию
-- должен быть установлен DEFAULT
-- ссылочная таблица должна уметь такое значение (первичный ключ), иначе ошибка
CREATE TABLE progress
( record_book numeric( 5 ) DEFAULT 12345,
  ...
  FOREIGN KEY ( record_book )
    REFERENCES students ( record_book )
    ON DELETE SET DEFAULT
);
```

# Представления
Для сохранения длинных запросов можно использовать предсталения.

```sql
-- создание представления
CREATE VIEW seats_by_fare_cond AS
  SELECT aircraft_code,
         fare_conditions,
         count( * )
  FROM seats
  GROUP BY aircraft_code, fare_conditions
  ORDER BY aircraft_code, fare_conditions;

-- вызов запроса
SELECT * FROM seats_by_fare_cond;

-- удаление представления
DROP VIEW seats_by_fare_cond;

-- переименование столбцов в представлении
CREATE OR REPLACE VIEW seats_by_fare_cond
AS
  SELECT aircraft_code,
         fare_conditions,
         count( * ) AS num_seats
  FROM seats
  GROUP BY aircraft_code, fare_conditions
  ORDER BY aircraft_code, fare_conditions;

-- или для всех столбцов
CREATE OR REPLACE VIEW seats_by_fare_cond ( code, fare_cond, num_seats )
AS
  SELECT aircraft_code,
         fare_conditions,
         count( * )
  FROM seats
  GROUP BY aircraft_code, fare_conditions
  ORDER BY aircraft_code, fare_conditions;

-- просмотр представлений для таблицы
\d flights_v
```

# Схема БД 
Схема — это логический фрагмент базы данных, в котором могут содержаться различные объекты: таблицы, представления, индексы и др.

Схемы нужны для разграничения пространства имён.

В БД должна быть хотябы одна схема.

По умолчанию в postgres применяется схема public

```shell
# посмотреть схемы
\dn
```

При обращении к другой схеме нужно использовать её имя 
```sql
SELECT * FROM bookings.aircrafts;
```

Команды для работы со схемой
```sql
-- переключиться на схему
SET search_path = bookings;
-- или сразу на несколько схем
SET search_path = bookings, public;

-- посмотреть search_path
SHOW search_path;

-- посмотреть текущую схему
SELECT current_schema;

-- создание таблицы в определённой схеме
CREATE TABLE my_schema.airports
```

# Запросы

## SELECT

```sql
-- простой SELECT
SELECT * FROM aircrafts;

-- с условием >, <
SELECT model, aircraft_code, range
  FROM aircrafts
  WHERE range >= 4000 AND range <= 6000;

-- с поиском по строке
SELECT * FROM aircrafts WHERE model LIKE 'Airbus%';

SELECT * FROM aircrafts
  WHERE model NOT LIKE 'Airbus%'
  AND model NOT LIKE 'Boeing%';

--- с поиском по шаблону слова
--- LEV TOLSTOY
SELECT passenger_name
  FROM tickets
  WHERE passenger_name LIKE'___ %';

SELECT passenger_name FROM tickets
  WHERE passenger_name LIKE 'L%V %';

-- диапазон значений
SELECT * FROM aircrafts WHERE range BETWEEN 3000 AND 6000;

-- вычисления по время выборки
SELECT model, range, round( range / 1.609, 2 ) AS miles
  FROM aircrafts;

-- сортировка (ASC по умолчанию) -> ORDER
SELECT * FROM aircrafts ORDER BY range DESC;

-- выбор уникальных значений -> DISTINCT
SELECT DISTINCT timezone FROM airports;

-- выбор ограниченного числа записей -> LIMIT
SELECT airport_name, city, longitude
  FROM airports
  ORDER BY longitude DESC
  LIMIT 3;

-- LIMIT со сдвигом -> OFFSET
SELECT airport_name, city, longitude
  FROM airports
  ORDER BY longitude DESC
  LIMIT 3
  OFFSET 3;

-- преобразование данных в условием
SELECT model, range,
  CASE WHEN range < 2000 THEN'Ближнемагистральный'
       WHEN range < 5000 THEN'Среднемагистральный'
       ELSE 'Дальнемагистральный'
  END AS type
  FROM aircrafts
  ORDER BY model;
```

## JOINS

### JOIN

JOIN формирует декартово произведение строк таблиц (все возможные пары) и затем фильтрует их, обычно на соответствие значений с колонках.

JOIN можно производить с одной и той же таблицей

```sql
-- соединение двух таблиц на основе равенства значений атрибутов
-- выбрать все места, предусмотренные компоновкой салона самолета Cessna 208 Caravan
SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions
  FROM seats AS s
  JOIN aircrafts AS a
    ON s.aircraft_code = a.aircraft_code
  WHERE a.model ~ '^Cessna'
  ORDER BY s.seat_no;

-- для простых запросов можно также использовать запись без JOIN - ON
-- JOIN заменяется FROM (с несколькими таблицами)
-- ON заменяется WHERE AND
SELECT a.aircraft_code, a.model, s.seat_no, s.fare_conditions
  FROM seats s, aircrafts a
  WHERE s.aircraft_code = a.aircraft_code
    AND a.model ~ '^Cessna'
  ORDER BY s.seat_no;
```

### LEFT OUTER JOIN

Если при формировании таблицы соединения нет комбинации по условию ON обычный JOIN удаляет такие строки из результирующей таблицы
LEFT OUTER JOIN оставляет из заполняя правую чать NULL

```sql
SELECT a.aircraft_code AS a_code,
       a.model,
       r.aircraft_code AS r_code,
       count( r.aircraft_code ) AS num_routes
  FROM aircrafts a
  LEFT OUTER JOIN routes r ON r.aircraft_code = a.aircraft_code
  GROUP BY 1, 2, 3
  ORDER BY 4 DESC;

-- a_code  | model               | r_code | num_routes
-- --------+---------------------+--------+------------
-- CR2     | Bombardier CRJ-200  | CR2    | 232
-- CN1     | Cessna 208 Caravan  | CN1    | 170
-- SU9     | Sukhoi SuperJet-100 | SU9    | 158
-- 319     | Airbus A319-100     | 319    | 46
-- 733     | Boeing 737-300      | 733    | 36
-- 321     | Airbus A321-200     | 321    | 32
-- 763     | Boeing 767-300      | 763    | 26
-- 773     | Boeing 777-300      | 773    | 10
-- 320     | Airbus A320-200     |        | 0
```

### RIGHT OUTER JOIN
В этом случает базовой считается таблица справа (после RIGHT OUTER JOIN)

### FULL OUTER JOIN
В этом случае в выборку включаются строки из левой таблицы, для которых не нашлось соответствующих строк в правой таблице, и строки из правой таблицы, для
которых не нашлось соответствующих строк в левой таблице.


## Выборка с множествами

### UNION

UNION используется для вычисления объединения множеств строк из двух выборок

Строка включается
в итоговое множество (выборку), если она присутствует хотя бы в одном из них.

Строки-дубликаты в результирующее множество не включаются. Для их включения
нужно использовать UNION ALL.

Выбираемое кол-во столбцов должно быть однинаковое, типы столбцов тоже

```sql
-- этот запрос можно было бы заменить SELECT DISTINCT ... WHERE OR
-- UNION может помочь когда таблицы разные

-- в какие города можно улететь из Москвы или из СПБ
SELECT arrival_city FROM routes
  WHERE departure_city ='Москва'
UNION
SELECT arrival_city FROM routes
  WHERE departure_city ='Санкт-Петербург'
ORDER BY arrival_city;
```

### INTERSECT

INTERSECT для вычисления пересечения множеств строк из двух выборок

Строка вклю-
чается в итоговое множество (выборку), если она присутствует в каждом из них.

Строки-дубликаты в результирующее множество не включаются. Для их включения
нужно использовать INTERSECT ALL.

```sql
-- в какие города можно улететь и из Москвы и из СПБ
SELECT arrival_city FROM routes
  WHERE departure_city ='Москва'
INTERSECT
SELECT arrival_city FROM routes
  WHERE departure_city ='Санкт-Петербург'
ORDER BY arrival_city;
```

### EXCEPT

EXCEPT для вычисления разности множеств строк из двух выборок.

Строка
включается в итоговое множество (выборку), если она присутствует в первом мно-
жестве (выборке), но отсутствует во втором. 

Строки-дубликаты в результирующее
множество не включаются. Для их включения нужно использовать EXCEPT ALL.

```sql
-- в какие города можно улететь из СПБ, но нельзя из Москвы
SELECT arrival_city FROM routes
  WHERE departure_city ='Санкт-Петербург'
EXCEPT
SELECT arrival_city FROM routes
  WHERE departure_city ='Москва'
ORDER BY arrival_city;
```

## Функции агрегации

```sql
count
avg
min
max
GROUP BY -> HAVING
PARTITION?
```

## Подзапросы

Подзапрос заключается в скобки

Подзапросы могут быть у SELECT, FROM, WHERE, HAVING, WITH

Подзапрос вызвращающий одно значение называется скалярным

Подзапрос возвращающий множество скалярных значение можно использовать в IN

```sql
-- вывести заказы, где сумма больше средней по таблице
SELECT count( * ) FROM bookings
  WHERE total_amount >
    ( SELECT avg( total_amount ) FROM bookings );

-- вывести рейсы в таймзоне Красноярска
SELECT flight_no, departure_city, arrival_city
  FROM routes
  WHERE departure_city IN (
    SELECT city
      FROM airports
      WHERE timezone ~ 'Krasnoyarsk'
  )
  AND arrival_city IN (
    SELECT city
      FROM airports
      WHERE timezone ~ 'Krasnoyarsk'
  );

-- вывести самый западный и самый восточный аэропорты
SELECT airport_name, city, longitude
  FROM airports
  WHERE longitude IN (
    ( SELECT max( longitude ) FROM airports ),
    ( SELECT min( longitude ) FROM airports )
  )
  ORDER BY longitude;
```

Иногда от подзапроса требуется только установить наличие/отсутствие строки 

```sql
-- найти города куда нет рейсов из МСК
-- NOT EXIST просто проверяет условие по данныму городу (a.city)
-- те города, где это условие удовлетворено будут включены в результат
SELECT DISTINCT a.city
  FROM airports a
  WHERE NOT EXISTS (
    SELECT * FROM routes r
      WHERE r.departure_city ='Москва'
      AND r.arrival_city = a.city
    )
  AND a.city <>'Москва'
  ORDER BY city;

-- для таких подзапросов рекомендуется использовать SELECT 1 а не SELECT *
-- WHERE NOT EXISTS ( SELECT 1 FROM routes r ...

-- такой подзапрос будет связанным (условием) в главным запросом
-- подзапрос будет выполняться не один раз, как обычно, а для каждой строки
-- планировщик СУБД оптимизирует эти запросы?
```


# Индексы

Индекс —
специальная структура данных, которая связана с таблицей и создается на основе данных, содержа-
щихся в ней.

Основная цель создания индексов — повышение производительности функционирова-
ния базы данных.

Основным индексом и индексов по умолчанию является B-tree

Следует учитывать, что индексы требуют и некоторых накладных расходов на их со-
здание и поддержание в актуальном состоянии при выполнении обновлений данных
в таблицах.

Postgres сама создаёт индексы для PRIMARY KEY и UNIQUE

Индекс более полезен при высокой селективности выборки (из большего кол-ва строк выбираем лишь малую часть)

Индес полезен для команд:
- WHERE
- ORDER BY (если индекс на конкретно этот столбец)

## Создание индексов

```sql
-- создание индекса вручную
CREATE INDEX -- index_name если нужно
  ON table_name ( column_name, ... ); -- можно задавать несколько столбцов

-- по умолчанию порядок индекса ASC, NULL значения идут последними
-- порядок можно менять используя DESC, NULLS FIRST, NULLS LAST
CREATE INDEX имя-индекса
  ON имя-таблицы ( имя-столбца NULLS FIRST, ... );
-- или
CREATE INDEX имя-индекса
  ON имя-таблицы ( имя-столбца DESC NULLS LAST, ... );

-- индекс можно использовать для задания уникальности значений
-- в таких индексах всё равно могут быть NULL значения
CREATE UNIQUE INDEX aircrafts_unique_model_key
  ON aircrafts ( model );

-- использование выражений
-- теперь индекс не чувствителен к регистру 
-- если есть 'Boeing' то 'BOEING' уже не добавить
CREATE UNIQUE INDEX aircrafts_unique_model_key
  ON aircrafts ( lower( model ) );

-- частичные индексы (не на все строки таблицы)
-- такой индекс будет использоваться при WHERE total_amount > 1000 или 1000+
-- но не будет использоваться при WHERE > 900;
CREATE INDEX bookings_book_date_part_key
  ON bookings ( book_date )
  WHERE total_amount > 1000000;
```

## Удаление индексов

```sql
-- удаление индекса
DROP INDEX index_name;
```

## Полезные команды psql для индексов

```sql
-- просмотр всех индексов
\di
\di+

-- Чтобы отображать время затраченное на выполение запросов можно использовать таймер
-- включение таймера
\timing on

-- выключение таймера
\timing off
```





