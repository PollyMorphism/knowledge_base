# frozen_string_literal: true

require './rescue_from'

class Test
  include RescueFrom

  rescue_from StandardError, with: :handle_exception

  def foo
    p 'Foo method'
  end

  def bar
    raise StandardError
  end

  def handle_exception(_error)
    p 'Oops! There was an exception'
  end
end

controller = Test.new
controller.foo
controller.bar

p Test.instance_variable_get(:@exception_handlers)
