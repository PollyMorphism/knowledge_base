# Singleton class

Реализация singleton паттерна в ruby

```ruby
require 'singleton'

class Shop
  include Singleton
end

Shop.new
# NoMethodError: private method `new' called for Shop:Class

Shop.instance.object_id
# 5659218
Shop.instance.object_id
# 5659218
```
