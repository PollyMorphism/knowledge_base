# Sorbet

[Документация](https://sorbet.org/docs/adopting)

[Гайдлайн](https://learnxinyminutes.com/docs/sorbet/)

Sorbet - статический анализатор типов для Ruby (type checker)
 - позволяет добавлять типы в виде аннотаций
 - аннотации содержат типы агрументов и возвращаемых значений
 - позволяет проверять ошибки типов до запуска приложения

Tapioca - гем для генерации RBI файлов (файлов сигнатур)

RBI файлы содержат определения типов которые Sorbet использует для анализа
 - тут описываются классы, модули и их методы
 - содержит тип возвращаемых значений
 - генерируются автоматически с помощью Tapioca
 - коммитятся в репозиторий вместе с кодом приложения

```rb
# typed: true

class User
  sig { returns(String) }
  def name; end

  sig { params(age: Integer).void }
  def set_age(age); end
end
```

## Структура

```shell
sorbet/
├── config
└── rbi/
    └── ···
```

## Команды

Sorbet

```shell
# запуск type checker
srb tc
```

Tapioca
```shell
tapioca init  # инициализация проекта для работы с Tapioca
tapioca gem   # генерация .rbi файлов для гемов
tapioca sync  # обновление .rbi файлов для приложения
tapioca check # проверка актуальности .rbi файлов
```

## Уровни проверок

```rb
# ничего не проверяем, sorbet даже не смотрит в эти файлы
typed: ignore

# sorbet знает о файле, но не проверяет
# используется для пометки, что тут нужно добавить типы
# типы и сигнатуры игнорируются
typed: false

# sorbet проверяет типы и сигнатуры (где объявлены)
# не аннотированные методы считаются "правильными"
typed: true

# sorbet требует аннотации всех методов, типы для констант и instance variables
typed: strict

# доп.проверки, нельзя использовать T.untyped
typed: strong
```

## Аннотации

Используем это хелпер везде, где нужен доступ к аннотациям и определению типов

```rb
class Foo
  extend T::Sig

  # some code
end
```

Определение аннотаций

```rb
# sig передаётся блок 
# returns определяет тип возвращаемого значения
sig { returns(String) }
def greet
  'Hello, World!'
end

# тип параметров методы
# keyword параметры определяются так-же
sig { params(n: Integer, sep: String).returns(String) }
def greet_repeat_2(n, sep: "\n")
  (1..n).map { greet }.join(sep)
end

# когда много параметров, лучше использовать do...end
sig do
  params(
    str: String,
    num: Integer,
    sym: Symbol,
  ).returns(String)
end
def uhh(str:, num:, sym:)
  'What would you even do with these?'
end

# если метод ничего не возвращает
sig { parameters(name: String).void } # или sig { void } если параметров нет
def say_hello(name)
  puts "Hello, #{name}!"
end

# большинство initialize методов будут с void
sig { params(name: String).void }
def initialize(name:)
  # instance variables должны иметь аннотации типов

  # `T.let` проверяется при static type check и runtime check
  @upname = T.let(name.upcase, String)

  # sorbet уже знает тип т.к он объявлен в параметрах метода -> sig
  @name = name
end

# константы тоже должны иметь тип
SORBET = T.let('A delicious frozen treat', String)

# также как и class variables
@@the_answer = T.let(42, Integer)

# sorbet знает о attr_* методах
sig { returns(String) }
attr_reader :upname

sig { params(write_only: Integer).returns(Integer) }
attr_writer :write_only

# если тип объявлен для reader, то для writer он такой-же
sig { returns(String) }
attr_accessor :name

# если параметр это класс, а не его инстанс
sig { params(dep: T.class_of(Dep)).returns(Dep) }
def dependency_injection(dep:)
  dep.new
end

# `T.any` для значений кот. могут быть нескольких типов
sig { params(num: T.any(Integer, Float)).returns(Rational) }
def hundreds(num)
  num.rationalize
end

# `T.nilable(Type)` когда значение может быть nil (а может и не быть)
# alias for `T.any(Type, NilClass)`.
sig { params(val: T.nilable(String)).returns(Integer) }
def strlen(val)
  val.nil? ? -1 : val.length
end

# когда значение должно удовлетворять нескольким типам (для интерфейсов, но может исп.для описания модулей)
sig { params(list: T.all(Reversible, Sortable)).void }

# если описание типа длинное и используется несколько раз его можно вынести
JSONLiteral = T.type_alias { T.any(Float, String, T::Boolean, NilClass) }

sig { params(val: JSONLiteral).returns(String) }
def stringify(val)
  val.to_s
end

# T::Struct для определения типизированного struct
class MonetaryAmount < T::Struct
  # prop -> типизированный attr_accessor
  prop :amount, Integer
  # const -> типизированный attr_reader
  const :currency, Integer
  # можно задавать значения по умолчанию
  const :foo, String, default: 'bar'

  # initialize не нужен
  # sig тоже не нужен

  extend T::Sig

  # всё еще можно опредеять методы, но разумеется нужно писать sig
  sig { void }
  def reset
    self.amount = 0
  end
end

# будут выполнены проверки атрибутов и их типов
m = MonetaryAmount.new(amount: 123, currency: 234)

# ENUMS
# для перечисления конечного набора значений используй T::Enum
class Color < T::Enum
  extend T::Sig

  # используй new, каждый цвнт - инстанс класса Color
  enums do
    Red = new("red")
    Yellow = new("yellow")
    Blue = new("blue")
  end
end

# для получения значения
Color::Blue.serialize # => "blue"

# для получения enum
Color.deserialize("blue") # => Color::Blue

# получение всех значений
Color.values # => [Color::Red, Color::Yellow, Color::Blue]

# при попытке десериализовать неправильное значение будет ошибка
Color.deserialize('bad value')
# => KeyError: Enum Suit key not found: "bad value"

# если ошибка не нужно то ипользуй try_deserialize (он вернёт nil)
Color.try_deserialize('bad value')
# => nil

# проверка есть ли цвет в списке
Color.has_serialized?("blue") # => true
Color.has_serialized?("bad")  # => false
```

## Типы

```rb
# sorbet предоставляет хелперы для ruby standard library
# Boolean может быть true или false
# можно было бы и так T.type_alias { T.any(TrueClass, FalseClass) }
T::Boolean

# nil
NilClass

# остальные хелперы
T::Array
T::Enumerable
T::Enumerator
T::Hash
T::Range
T::Set

# для передачи класса (dependency injection
T.class_of(Dep)

# blocks, lambdas, procs имеют общий Т.proc
T.proc.params(val: String).returns(Integer)
```

## Настройка VSCode extension

1. Установить extension
2. Активировать его в settings.json -> ```"sorbet.enabled": true```
3. Если сервер не запускается проверить output (в последний раз был конфликт asdf и mise)
