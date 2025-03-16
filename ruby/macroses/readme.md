# Useful Ruby Commands

## Instance variables
```ruby
# get instance variable
instance_variable_get("@#{attr}")
# set instance variable
instance_variable_set("@#{attr}", value)
```

## Calling methods
```ruby
# 'call' method
m = 12.method("+")
m.call(3)    #=> 15
m.call(20)   #=> 32

# 'send' method
# can call private methods 
1.send(:+, 1)  # > 2
1.send("+", 1) # > 2
```

## Define methods
```ruby
# without attributes
define_method(name) do
	# method body
end

# with attributes
define_method(name) do |attr1, attr2|
	# method body
end
```

## Method added
```ruby
# should be defined as class method to make it work
def method_added(method_name)
 # do something when method is added to class
end
```

## Binding
TBD
