# Thread safe code

Thread-safe (потокобезопасный) код — это код, который может выполняться в нескольких потоках одновременно без неожиданных ошибок (гонки данных, deadlock'и, некорректные состояния).

## Race conditions

Ожидаем получить 220, но из-за race conditions это не так!

```ruby
class BankAccount
  attr_accessor :balance

  def initialize(balance)
    @balance = balance
  end

  def deposit(amount)
    new_balance = @balance + amount
    sleep(0.1)
    @balance = new_balance
  end
end

account = BankAccount.new(100)

t1 = Thread.new { account.deposit(50) }
t2 = Thread.new { account.deposit(70) }

t1.join
t2.join

puts "Final balance: #{account.balance}"
# => 150
# => 170
```

## Mutex 

Mutex - это механизм синхронизации потоков, который предотвращает одновременный доступ к общим данным

В Ruby Mutex реализован в стандартной библиотеке

Когда поток входит в блок synchronize:
  - он захватывает Mutex (другие потоки ждут)
  - выполняет код внутри блока
  - освобождает Mutex, позволяя другому потоку войти

```ruby
class BankAccount
  attr_accessor :balance

  def initialize(balance)
    @balance = balance
    @mutex = Mutex.new
  end

  def deposit(amount)
    mutex.synchronize do
      new_balance = @balance + amount
      sleep(0.1)
      @balance = new_balance
    end
  end
end

account = BankAccount.new(100)

t1 = Thread.new { account.deposit(50) }
t2 = Thread.new { account.deposit(70) }

t1.join
t2.join

puts "Final balance: #{account.balance}"
# => 220, как и должно быть
```

## Concurrent Ruby gem

`concurrent-ruby` гем предоставляет набор thread-safe структур которые будут гарантировать их атомарное изменение

```ruby
require 'concurrent'

class BankAccount
  attr_accessor :balance

  def initialize(balance)
    @balance = Concurrent::AtomicFixnum.new(balance)
  end

  def deposit(amount)
    # Concurrent::AtomicFixnum предоставляет методы increment/decrement (default = 1)
    @balance.increment(amount)
  end
end

account = BankAccount.new(100)

t1 = Thread.new { account.deposit(50) }
t2 = Thread.new { account.deposit(70) }

t1.join
t2.join

puts "Final balance: #{account.balance}"
# => 220, как и должно быть
```

Другие структуры `concurrent-ruby`

```ruby
Concurrent::AtomicFixnum
Concurrent::AtomicBoolean
Concurrent::AtomicReference
Concurrent::Array
Concurrent::Hash
Concurrent::Queue
# ...
```
