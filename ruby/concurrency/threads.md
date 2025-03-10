# Threads
Позволяет создавать новые потоки для параллельного выполнения задач в рамках одного процесса

## Создание потоков
```ruby
# один поток
t = Thread.new do
  # some code
end

# передача управления
t.join

# несколько потоков
ts = (1..5).map do |i|
  Thread.new do
    # some code
  end
end

ts.each(&:join)
```

## Прикрепление информации к thread
```ruby
t = Thread.new do
  Thread.current[:name] = "ololo"
end
```

## Возвращение значений из threads
```ruby
t = Thread.new do
  # preform operations
  rand(1..100)
end

# вызывает thread и получает знаечние
t.value
```

## Exceptions
Исключения пробрасываются в родительский поток если не были обзаботаны внутри thread

## Команды управление threads
```ruby
Thread.current

Thread.main

Thread.list

Thread.kill(thread)

# показать статус для thread
thread.status
# выполнить
thread.join
# выполнить и вернуть значение
thread.value
# остановить
thread.exit
# вернуть ключи заданные с помощью Thread.current[:key]
thread.keys
```

## Возможные проблемы
Обращай внимание на общие ресурсы во избежание race-conditions



