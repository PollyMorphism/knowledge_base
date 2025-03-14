# Indexes

## Создание индексов

Rails по умолчанию создаст тебе индексы для 
  - id (primary key)
  - user_id

```ruby
class CreatePosts < ActiveRecord::Migration[7.0]
  def change
    create_table :posts do |t|
      t.string :title
      t.string :body
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
```

Отдельно создать или удалить индекс можно с помощью

```ruby
def change
  # создать
  add_index :posts, :title

  # удалить по column_name -> обратимая миграция
  remove_index :posts, column: :status

  # удалить по index_name -> необратимая миграция!
  remove_index :posts, name: "index_posts_on_status"
end
```

## Модифицирование индексов

```ruby
def change
  # уникальный индекс
  add_index :users, :email, unique: true

  # задать своё имя
  add_index :posts, :status, name: "status_index"

  # индекс на несколько полей
  add_index :posts, [:user_id, :status]

  # создание сортировки (по умолчанию всегда asc)
  add_index :posts, [:user_id, :status], order: {status: :desc} 

  # partial индексы
  add_index :users, :email, where: "active = true"
end
```

## Составные индексы

Всегда помещай на первое место поле которое выберет макс.меньшее число строк (чтобы упросить поиск)!

Индекс типа `add_index :posts, [:user_id, :status]` будет оптимизировать запросы:
  - запросы, где задействованы оба поля -> `where(user_id: 2, status: "pending")`
  - запросы, где задействовано первое поле -> `where(user_id: 3)`
  - запросы, где задействовано первое поле и сортировка по второму -> `where(user_id: 4).order(:status)

И не будет оптимизировать запросы:
  - для второго поля -> `where(status: 'reviewed')`
  - для сортировки в обратном порядке -> `where(user_id: 2).order(status: :desc)` (найдёт по user_id, но сортировка может не использовать индекс)

## Partial индексы

Помогают сократить размер индекса (избегая индексации ненужных данных) и ускорить запросы по нужному условию

`add_index :users, :email, where: "status = active"`

- поможет при `where(status: "active", email: "test@example.com")
- поможет при `where(status: "active").order(:email)
- не поможет при `where(email: "...")` т.к не гарантирован status: active
- не поможет при `where(email: "...", status: "inactive")`
- не поможе при `where(status: "active).or(where(email: "test@example.com"))` т.к во втором случае не гарантирован status: active


## Добавление индексов на большие таблицы

При добавлении индексов таблица блокируется для операций INSERT, UPDATE, DELETE

```ruby
class AddIndexToUsers < ActiveRecord::Migration[7.0]
  # отключает транзакцию т.к CREATE INDEX CONCURRENTLY нельзя поместить внутрь
  disable_ddl_transaction!

  def change
    # опция :concurrently позволяет не блокировать таблицу при создании индекса
    add_index :users, :email, algorithm: :concurrently
  end
end
```

## Типы индексов

1. B-Tree

B-tree используется по умолчанию
Поддерживает операции: равенство (=), диапазоны (<, >, BETWEEN), сортировка

```ruby
add_index :users, :email
```

2. Hash

Обычно не используется т.к B-tree перекрывает его своей универсальностью
Поддерживает операцию равенства (=)
Более быстрый для (=) по сравнению с B-tree

```ruby
add_index :users, :email, using: :hash
```

3. GIST и SP-GIST

Представляют собой структуру для создания индексов
Для поиска по геометрическим данным (PostGIS) которые не поддаются обычному сравнению с B-tree

```ruby
add_index :table_name, :column_name, using: 'gist'
add_index :table_name, :column_name, using: 'spgist'
```

4. GIN

Для поиска по ARRAY
позволяет искать совпадению по нескольким строкам (где содерится значение)


```ruby
add_index :posts, :tags, using: :gin

Post.where("tags @> ARRAY[?]::varchar[]", ["rails", "ruby"])
```

5. BRIN

Если таблица очень большая и данные вставляются по порядку
Для очень больших таблиц (logs, events), где B-Tree индекс слишком дорог
BRIN хранит только диапазоны значений для блоков строк, а не сами значения.

```ruby
add_index :logs, :created_at, using: :brin
```

