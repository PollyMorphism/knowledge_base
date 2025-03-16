# Securing rails applications

## Sessions

### Sessions hijacking 

Кража сессии пользователя позволит злоумышленнику залогиниться как пользователь

Решение: использовать SSL, делать reset_session после sign-in (device делает это из коробки)

### Сookies

Когда куки храняться на стороне клиента они могут быть скопированы

Решение: не хранить sensitive данные на стороне клиента или делать их encrypted

## CSRF

CSRF (Cross-Site Request Forgery) — это атака, при которой злоумышленник заставляет пользователя выполнить нежелательный запрос к веб-приложению, на котором он авторизован.

Пример:
1. Размещается изображение со ссылкой `<img src="http://www.webapp.com/project/1/destroy">`
2. Пользователь открывает страницу с этой ссылкой
3. Происходит авторизированный запрос на удаление ресурса

Решение проблемы:
1. Всегда использовать POST запросы для эшкнов типа create/update/delete
2. Rails по умолчанию использует `protect_from_forgery` для не-идемпотентных запросов (POST/PUT/PATCH/DELETE)
  - в формы на отрендеренных страницах встраивается `authenticity_token` который защищает от запросов на них извне
  - GET запросы не требуют этот токен так как должны быть идемпотентны (см п.1)
3. API контроллеры работают в основном с JWT токенами или session-less аутентификацией и не нуждаются в CSRF защите

## User management

1. Не хранить raw пароли в базе
2. Использовать капчу/троттлинг (rack-attack) на логин/forgot password формах
3. Ессно не засылать пароли или другую sensitive информацию в логи

## Injections

### SQL injections

```ruby
Project.where("name = '#{params[:name]}'") # with "' OR 1) --" will return

# => SELECT * FROM projects WHERE (name = '' OR 1) --')
```

Использовать экранирование

```ruby
Project.where("name = ?", params[:name])

# еще лучше
Project.where(name: params[:name])
```

### Cross-Site Scripting (XSS)

Вредоносный скрипт вставляется в user inputs чтобы далее быть отрисованным на странице куда может зайти пользователь

```js
<script>alert('Hello');</script>
```

Rails по умолчанию экранирует инпут, но нужно быть аккуратным с html_safe методом


