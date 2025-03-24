# Configuring Rails apps

## Autoloading
```rb
# в rails 7 добавили shortcut для автозагрузки lib
config.autoload_lib(ignore: %w[assets tasks])
```

## Filtering params
```rb
# config/initializers/filter_parameter_logging rb

# добавляй сюда параметры которые хочешь скрывать в логах (не забудь перезапустить приложение после изменений)
Rails.application.config.filter_parameters += [
  :passw, :secret, :token, :_key, :crypt, :salt, :certificate, :otp, :ssn, :card_number, :expiration_date, :security_number
]
```
