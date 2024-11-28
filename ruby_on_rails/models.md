# Working with jsonb

Для хранения сложных структур в базе часто используют json/jsonb колонки

Для удобства работы со значениями из этих колонок можно использовать ```serialize :attr_name, coder: ClassName```

Зачем это нужно?
- данные из колонки будут представлены в виде объекта 
- можно валидировать значения внутри json/jonb
- инкапсуляция логики

```rb
class User < ApplicationRecord
  #  id                   :uuid    not null, primary key
  #  email                :string
  #  contact_information  :jsonb

  # этот класс будет отвечать за представление user.contact_information в удобной форме
  class ContactInformation
    # для методов валидации
    include ActiveModel::Model
    # для метода serializible_hash (перед сохранением объекта в jsonb колонку)
    include ActiveModel::Serialization
    # для метода attribute - позволяет отпеделять типы атрибутов и их default value
    include ActiveModel::Attributes

    # то, что будет внутри jsonb
    attribute(:first_name, :string)
    attribute(:last_name,  :string)
    attribute(:phone,      :string)
    attribute(:address,    :string)

    # можно делать валидации для значений
    validates(
      :first_name,
      :last_name,
      :phone,
      :address,
      presence: true
    )

    validate :validate_address

    # для того чтобы работало через user.contact_information нужно определить метод load
    def self.load(hash)
      new(hash)
    end

    # для сохранения в базу нужно определить метод dump
    def self.dump(obj)
      obj.serializable_hash
    end
  end

  # подключаем наш класс как сериалайзер
  serialize :contact_information, coder: ContactInformation
end
```

# Нормализация 

## До RoR 7.1

Используем хуки

```rb
class User < ApplicationRecord
  before_save :downcase_email, if :email_present?

  private

    def email_present?
      email.present?
    end

    def downcase_email
      email.downcase!
    end
end
```

## RoR 7.1

Новый метод ```normalizes```

```rb
class User < ApplicationRecord
  normalizes :email, with: -> email { email.downcase }
end
```

Или передаёт класс для нормализации

```rb
normalizes :city, with: NormalizeCityName

# должен иметь метод класса call и возвращать нормализованное значение аттрибута
class NormalizeCityName
  CITY_REDUCTIONS = {
    "St." => "Saint"
  }

  def self.call(city)
    CITY_REDUCTIONS.each do |abbr, full_name|
      city.gsub!(abbr, full_name)
    end
    city
  end
end
```



