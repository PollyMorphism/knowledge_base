# Blocks

Блок - анонимная функция которую можно передать в метод в качестве аргумента. Блок это не объект! Он не может быть сохранён в переменную
```ruby
# явная передача блока
def some_method(&me_block)
	me_block.call(5)
end

some_method do |n|
	puts "Something #{n}"
end
# => "Something 5"

# неявная передача блока
def some_method
	yield 5
end

some_method do |n|
	p "Block! #{n}"
end
# => "Block 5"

# а передан ли блок?
def some_method 
	return "No block was found!" unless block_given

	yield
end

some_method
# => "No block was given"

some_method { puts "Block rules!" }
# => "Block rules!"
```

# Procs

Proc - это объект, содержащий кусок кода, который может быть сохранен в переменной и передан как аргумент другим методам

```ruby
my_proc = Proc.new { |x| puts x }

my_proc.call(10)
```

# Lambda

Lambda - это экземпляр класса Proc c небольшими отличиями (более строгие ограничения)

```ruby
say_something = -> { puts "This is lambda" }

say_something.call
# => "This is lambda"

# лямбда с параметрами
times_two = ->(x) { x * 2 }
times_two.call(10)
# => 20


# проверяем лямбда ли это

proc_one = proc { puts 'a proc' }
puts proc_one.lambda?  # => false

proc_two = lambda { puts 'a lambda' }
puts proc_two.lambda?  # => true
```

# Proc vs Lambda

```ruby
# Лямбда проверяет количество аргументов, которые в нее передаются, прок — нет.
t = Proc.new { |x,y| puts "I don't care about arguments!" }
t.call

# внутри lambda оператор return возвращает вызов как из обычного метода
# внутри proc, return вернёт из текущего контекста

# Should work
my_lambda = -> { return 1 }
puts "Lambda result: #{my_lambda.call}"

# Should raise exception
my_proc = Proc.new { return 1 }
puts "Proc result: #{my_proc.call}"

# => LocalJumpError (unexpected return)
```

# Closures

Lambda/Proc имею доступ к скоупу в котором они были определены

```ruby
# обычный метод так не может
name = 'ruby'

def print
  puts name
end

# undefined local variable or method 'name' for main:Object (NameError)
print


# а лямбда может!
name = 'ruby'

printer = -> { puts name }

printer.call  # ruby
```

# Where to use

Ты уже используешь lambdas!
```ruby
class User < ApplicationRecord
  # как условие при выборке
  scope :confirmed, -> { where(confirmed: true) }
end

class User < ApplicationRecord
  # как условие при валидации
  validates :email, if: -> { phone_number.blank? }
end
```

# Examples

## map_x2

```ruby
class Array
  def map_x2
    copy = self.dup
    result = []

    copy.each do |num|
      # если мы ходим что-то делать дополнительно передавая блок (например делать map_x2 { |x| x + 1 })
      r = yield num
      result.push(r * 2)
    end

    result
  end
end

initial_array = [0,1,2,3,4]
result = initial_array.map_x2 {|x| x + 1}
p initial_array
p result
```
