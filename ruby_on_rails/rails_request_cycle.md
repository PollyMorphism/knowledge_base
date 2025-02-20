# Путь запроса в Rails

Когда приходит запрос, создаётся новый экземпляр RackApp(это может быть любой класс). Затем метод run запускает метод call на экземпляре RackApp

1. Puma ищет config.ru файл
```rb
# в config.ru в твоём проекте по умолчанию
require_relative "config/environment"

run Rails.application
Rails.application.load_server
```
2. Подгружается config/environment - там инициализируется `Rails.application` с помощью `Rails.application.initialize!`
3. run метод запускает `call` метод на классе приложения
4. У `Rails.application` есть `call` метод определённый в `Rails::Engine` классе (суперкласс для `Rails::Application` ).
```rb
module Rails
  class Engine < Railtie
  
    # Define the Rack API for this engine.
    def call(env)
      req = build_request env
      app.call req.env
    end
  end
end
```
5. Rails подгружает middleware из `ActionDispatch` (компонент `ActionPack`) и управление по очереди передаётся им
6. Последний в списке `YourApp::Application.routes`  - это rack app сгенерированное Rails на основе routes файла. Оно вызывается с run методом  конце стека.
  - хэш `env` конвертируется в объект `ActionDispatch::Request` - его уже понимает Rails
  - создаётся `ActionDispatch::Response`
  - ищется контроллер ответственный за обработку запроса
```rb
Rails.application.routes.draw do
  get 'hello', to: HelloController.action(:index)
end
```

7. Когда контроллер найден вызывается метод `action` из `ActionController::Metal` 
  - вызывается метод `dispatch` (self указывает на класс нашего контроллера)
  ```rb
  # actionpack/lib/action_controller/metal.rb

  # Returns a Rack endpoint for the given action name.
  def self.action(name)
    app = lambda { |env|
      req = ActionDispatch::Request.new(env)
      res = make_response! req
      #new вызывает метод dispatch (на экземпляре найденного контроллера)
      new.dispatch(name, req, res)
    }
    
    if middleware_stack.any?
      middleware_stack.build(name, app)
    else
      app
    end
  end
  ```
  - Метод `dispatch` принимает имя экшна, объект запроса и объект ответа и возвращает Rack response (массив со status, headers, body)
  ```rb
  def dispatch(name, request, response)
    set_request!(request)
    set_response!(response)
    process(name)
    request.commit_flash
    to_a
  end
  ```
Здесь происходит следующее:

1. Создаются request/response instance variables с которыми ты взаимодействуешь в контроллере
2. Выполняется экшн - process(name)
3. Экшн возвращает ответ через `render` 
4. `to_a` конвертирует ответ в приемлемый для rack
5. Вызываются колбеки и.д.т
6. Ответ идёт обратно через middleware для модификации 

После выполнения всех middleware ответ возвращается обратно к веб серверу который сериализует его в HTTP responce string и возвращает клиенту.
