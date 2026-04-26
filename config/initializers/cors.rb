# config/initializers/cors.rb
# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#   allow do
#     origins "example.com"
#
#     resource "*",
#       headers: :any,
#       methods: [:get, :post, :put, :patch, :delete, :options, :head]
#   end
# end

# Rails.application.config.middleware.insert_before 0, Rack::Cors do
#  allow do
#    # TODO: В проде заменить на домен (убрать localhost)
#    origins ENV.fetch("FRONTEND_URL", "http://localhost:5173")
#
#    resource "/api/v1/*",
#      headers: :any,
#      methods: [:get, :post, :put, :patch, :delete, :options, :head],
#      credentials: true,
#      expose: ["Authorization", "Content-Type", "X-Total-Pages", "X-Current-Page"],
#      max_age: 600
#  end
# end


Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Разрешаем запросы абсолютно ототовсюду для локальной разработки
    origins "*"

    resource "*",
             headers: :any,
             methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
