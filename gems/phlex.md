# Phlex

[Гайдлайн](https://www.phlex.fun/)

## Важно

Используй view_template вместо deprecated template (в версии 2.0 будет рендерить template тег)

## Представление view

Обычный HTML

```rb
class Hello < Phlex::HTML
	def view_template
		h1 { "👋 Hello World!" }
	end
end
```

Передача агрументов

```rb
class Hello < Phlex::HTML
	def initialize(name:)
		@name = name
	end

	def template
		h1 { "👋 Hello #{@name}!" }
	end
end
```

Рендеринг других view/compenents

```rb
	def view_template
  # ...
		render Hello.new(name: "Joel")
  # ...
	end
```

Передача блока для render

```rb
class Card < Phlex::HTML
	def template
		article(class: "drop-shadow") {
			yield
		}
	end
end

class Example < Phlex::HTML
	def template
		render(Card.new) {
			h1 { "👋 Hello!" }
		}
	end
end

# <article class="drop-shadow">
#   <h1>👋 Hello!</h1>
# </article>
```

Хуки

```rb
# в хуках всегда нужно вызывать super

class Example < Phlex::HTML
	def before_template
		h1 { "Before" }
		super
	end

	def template
		h2 { "Hello World!" }
	end

	def after_template
		super
		h3 { "After" }
	end
end
```

## Теги

Для использование тегов вызывай соответствующие методы и передавай им блок.

Если блок возвращает String/Symbol/Integer/Float и не использовались output methods то возвращаемое значение будет text.

```rb
# использование классов
h1(class: "text-xl font-bold") { "👋 Hello World!" }

# underscore классы "foo_bar" будут преобразованы в "foo-bar"
# если нужно именно "foo_bar" используй String key
h1("foo_bar" => "hello") { "👋 Hello World!" }

# можно передавай hash - тогда атрибуты будут соединены с "-"
div(data: { controller: "hello" }) { ...} # => data-controller="hello"

# boolean атрибуты
input(checked: true, ...)  # => <input checked ...>
input(checked: false, ...) # => <input ...>
```

## Хелперы

```rb
# для текста
strong { "Hello " }
plain "World!" # для простого текста без использования обёртки

# проблелы между inline элементами
whitespace  # <a...> <a...>

# HTML comments
comment { "Hello" }

# условия для классов
# обычный токен 
tokens("a", "b", "c") # → "a b c"
# условие может быть Proc или Symbol
class Link < Phlex::HTML
	def initialize(text, to:, active:)
		@text = text
		@to = to
		@active = active
	end

	def template
		a(href: @to, class: tokens("nav-item",
				active?: "active")) { @text }
	end

  # или использовать **classes
  # def template
	# 	a(href: @to, **classes("nav-item",
	# 		active?: "active")) { @text }
	# end

	private

	def active? = @active
end
```

## Slots

Для вызова slots нужно определить их как public instance методы которые принимают блок
Slots можно вызывать многократно

```rb
class Card < Phlex::HTML
	def template(&)
		article(class: "card", &)
	end

	def title(&)
		div(class: "title", &)
	end

	def body(&)
		div(class: "body", &)
	end
end

class CardExample < Phlex::HTML
	def template
		render Card.new do |card|
			card.title do
				h1 { "Title" }
			end

			card.body do
				p { "Body" }
			end
		end
	end
end

# <article class="card">
#   <div class="title">
#     <h1>Title</h1>
#   </div>
#   <div class="body">
#     <p>Body</p>
#   </div>
# </article>
```

## Тестирование
```rb
require "phlex/testing/view_helper"

class TestHello < Minitest::Test
	include Phlex::Testing::ViewHelper

	def test_hello_output_includes_name
		output = render Hello.new("Joel")
		assert_equal "<h1>Hello Joel</h1>", output
	end
end
```

## Ruby on Rails

Для рендеринга из контроллера

```rb
# рендерит app/views/articles/index_view.rb

	def index
    # ...
		render Articles::IndexView.new
	end
```

Для использования layouts
```rb
# применяет layout из app/views/layouts/custom_layout.rb
class FooController < ApplicationController
	layout -> { CustomLayout }

	def index
		render Foo::IndexView
	end
end
```
