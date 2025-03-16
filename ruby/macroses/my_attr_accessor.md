# my_attr_accessor

***Алгоритм работы:***
- Во время загрузки класса User код внутри него исполняется
- Происходит вызов метода me_attr_accessor (self указывает на User)
- Ищем метод класса (User.my_attr_accessor) по цепочке
  - (klass)-> #User (super)-> #Object (super)-> #BaseObject (super)-> Class (super)-> Module
- Метод найден в Module и начинает выполняться
- Для каждого attr из attrs
  - выполняется define_method#1
    - определяет новый метод с именем attr и телом (внутри блока) -> возвращает знач.переменной
    - метод определяется в User т.к `self` указывает на него
  - выполняется define_method#2
    - определяет новый метод с именем attr и телом (внутри блока) -> значение переменной устанавливается
    - метод определяется в User т.к `self` указывает на него
- теперь у User определены геттеры и сеттеры как это делает `attr_accessor`

```ruby
# frozen_string_literal: true

class Module
  def my_attr_accessor(*attrs)
    attrs.each do |attr|
      define_method(attr) do
        instance_variable_get("@#{attr}")
      end

      define_method("#{attr}=") do |value|
        instance_variable_set("@#{attr}", value)
      end
    end
  end
end

class User
  my_attr_accessor :name, :age
end

user = User.new
user.name = 'Bob'
user.age = 25
p user.name
p user.age
```
