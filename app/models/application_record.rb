class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  # Отключаем автоматическое создание контр-индексов для FK
  # если они уже есть в миграциях (оптимизация)
  self.implicit_order_column = :created_at
end
