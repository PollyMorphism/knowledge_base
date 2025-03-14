# Transactions

Транзакции - способ выполнить набор операций с БД только если каждая из них была завершена успешно (иначе откат)

Если внутри блока transaction возникает исключение, то все изменения в базе данных откатываются (rollback).

```ruby
# через ActiveRecord::Base class
ActiveRecord::Base.transaction do
  @new_user = User.create(user_params)
  raise ActiveRecord::RecordInvalid unless @new_user.persisted?
  ...
end

# у каждой модели есть метод transaction
Transfer.transaction do
  ...
end

# и даже у каждого объекта из модели
transfer = Transfer.new(...)
transfer.transaction do
  ...
end
```

Можно принудительно откатить транзакцию, вызвав `raise ActiveRecord::Rollback`

```ruby
ActiveRecord::Base.transaction do
  user = User.find(1)
  user.update!(balance: user.balance + 100)
  
  raise ActiveRecord::Rollback  # Все изменения в транзакции отменятся
end
```

# Вложенные транзакции

Rails поддерживает вложенные транзакции, но они работают не так, как можно ожидать

Вложенные транзакции в Rails на самом деле являются "point save" (savepoints). Если вложенная транзакция выполняет rollback, основная транзакция не отменяется.

```ruby
ActiveRecord::Base.transaction do
  user1.update!(balance: user1.balance + 100)

  ActiveRecord::Base.transaction do
    user2.update!(balance: user2.balance - 100)
    raise ActiveRecord::Rollback  # Откатится только вложенная транзакция
  end

  # user1.update! уже выполнился и не откатится!
end
```


# Locks

Локи нужны для предупреждения race conditions (когда 2 запроса выполняют транзакции для одной записи)

Транзакция сама по себе не защищает от состояния гонки (race condition), если несколько процессов одновременно читают и изменяют одну запись

Например
```ruby
class Product < ApplicationRecord
	#product.quantity - кол-во товаров
end
	
#где-то в коде
def buy(product_id, value)
	product = Product.find(product_id)
	product.quantity -= value
	product.save
end

#запрос 1 вызывает buy с value 10
#запрос 2 вызывает buy с value 5
#запрос 1 найдёт product и получит quantity 100
#запрос 2 найдёт product и получит quantity 100
#запрос 1 поменяет quantity на 90 и сохранит
#запрос 2 поменяет quantity на 95 и сохранит
#оба запроса выполнены, но quantity = 95 а не 85
```

## Optimistic locks

Предполагает, что race conditions будут редкими и в случае их появления 2й запрос будет завершен с ошибкой

Для того чтобы включить нужно создать в модели колонку lock_version (integer)

Каждый раз когда запись обновляется Rails увеличивает lock_version 

Если запрос на обновление включает устаревшую (прочитанную) версию, то будет ошибка `ActiveRecord::StaleObjectError`

### Плюсы

1. Лучше производительность
2. Ошибки падают на application уровне и их легче обрабатывать и выдавать user-friendly сообщения

### Минусы

1. Не лучшая идея, если кол-во конфликтов высокое
2. Требует доп.логики для обработки исключений

### Примеры

```ruby
def buy(value)
	product = Product.find(1)
	product.quantity -= value
	product.save
end

# запрос 1 вызывает buy с value 10
# запрос 2 вызывает buy с value 5
# запрос 1 найдёт product и получит quantity 100
# запрос 2 найдёт product и получит quantity 100
# запрос 1 поменяет quantity на 90 и сохранит

# запрос 2 попытается сохранить изменения используя
# UPDATE products SET quantity = ?, lock_version = ? WHERE id = ? AND lock_version = ?
# но т.к lock_version был изменён получит ошибку
# Attempted to update a stale object: Job. (ActiveRecord::StaleObjectError)
```

Можно задать имя для колонки lock_version

```ruby
class Person < ActiveRecord::Base
  self.locking_column = :lock_person
end
```

## Pessimistic locks

Записи блокируются явно на уровне БД используя методы lock/lock!/with_lock

### Плюсы

1. Гарантия отсутствия конфликтов при обновлении записей

### Минусы

1. Возможные проблемы производительности
2. Запросы ждущие заблокированную запись могут вылиться в задержке для пользователя

### with_lock

```ruby
def buy(value)
	product = Product.find(1)
  # with_lock оборачивает блок в транзакцию
	product.with_lock do # блокируем строку с id = 1
		product.quantity -= value # обновляем данные
		product.save
	end 
  # `COMMIT` -> строка разблокирована
  # `ROLLBACK` -> строка тоже разблокировалась
end

#запрос 1 выполняет операции над product
#запрос 2 ждёт освобождения ресурса
```

### Опции для with_lock

`require_new` - заставляет создать новую саб-транзакцию (savepoint) если ты внутри транзакции, в стучае rollback родительская транзакция продолжит работу

```ruby
product = Product.find(1)

product.with_lock do
  owner = product.owner
  product.count += 1
  product.save!

  # новая sub-transaction/savepoint
  owner.with_lock(requires_new: true) do
    owner.some_field += 1
    owner.save! 
  end
end
```

`isolation` - позволяет указать один из уровней изоляции транзакции
  - `:read_uncommitted` - транзакции могут читать данные, которые были изменены другими транзакциями, но ещё не зафиксированы. Этот уровень изоляции позволяет грязные чтения.
  - `:read_committed` - транзакции могут читать только те данные, которые были зафиксированы другими транзакциями. Это стандартный уровень изоляции для большинства баз данных.
  - `:repeatable_read` - транзакции видят те же данные на протяжении всей своей жизни, даже если другие транзакции изменяют их. Этот уровень предотвращает фантомные чтения.
  - `:serializable` - наивысший уровень изоляции, который гарантирует, что транзакции будут выполняться так, как если бы они выполнялись последовательно, а не параллельно.

`joinable` - позволяет присоединить текущую транзакцию к уже существующей транзакции. Это может быть полезно, если нужно, чтобы код внутри with_lock выполнялся в том же контексте транзакции, а не в новой.

### lock

Работает только внутри транзакции!

Нужно вызывать на самой модели чтобы запись заблокировалась!

```ruby
Product.transaction do
  product = Product.lock.find(1) # блокируем строку с id = 1
  product.update!(quantity: product.quantity - 1) # обновляем данные
end 
# `COMMIT` -> строка разблокирована
# `ROLLBACK` -> строка тоже разблокировалась
```

### lock!

Работает только внутри транзакции!

Нужно вызывать на объекте чтобы запись заблокировалась!

```ruby
Product.transaction do
  product = Product.find(1).lock! # блокируем строку с id = 1
  product.update!(quantity: product.quantity - 1) # обновляем данные
end 
# `COMMIT` -> строка разблокирована
# `ROLLBACK` -> строка тоже разблокировалась
```

### SQL опции для pessimistic locks

`FOR UPDATE` - если есть лок, то другая транзакция ждёт (пока не дойдёт до lock_timeout)
`FOR UPDATE NOWAIT` - если есть лок, то выбрасываем `PG::LockNotAvailable`
`FOR SHARE` - можно читать, но не изменять
`FOR UPDATE SKIP LOCKED` - пропустить уже заблокированные строки, FOR UPDATE на остальные

```ruby
# FOR_UPDATE используется по умолчанию
product.lock!


# FOR UPDATE NOWAIT
product = Product.lock("FOR UPDATE NOWAIT").find(1)
product = Product.find(1).lock!("FOR UPDATE NOWAIT")

product.with_lock("FOR UPDATE NOWAIT") do
  # ...
end

# остальные передаются так-же
```
