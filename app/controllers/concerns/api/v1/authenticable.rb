# app/controllers/concerns/api/v1/authenticable.rb
module Api
  module V1
    module Authenticable
      extend ActiveSupport::Concern

      included do
        before_action :authenticate_user!
      end

      private

      def authenticate_user!
        token = request.headers["Authorization"]&.split(" ")&.last

        unless token
          render_unauthorized("Missing authentication token")
          return
        end

        begin
          @current_user = Auth::TokenService.decode(token)
        rescue Auth::TokenService::InvalidToken
          render_unauthorized("Invalid authentication token")
        rescue Auth::TokenService::ExpiredToken
          render_unauthorized("Token expired", status: :gone)
        end
      end

      def current_user
        @current_user
      end

      def require_role(*roles)
        # Проверка: есть ли юзер и есть ли его роль в списке разрешенных
        is_authorized = current_user && roles.map(&:to_s).include?(current_user.role)

        unless is_authorized
          render json: {error: "Insufficient permissions"}, status: :forbidden
          # Останавливает выполнение контроллера после рендера
          throw :abort
        end
      end

      def render_unauthorized(message, status: :unauthorized)
        render json: {error: message}, status: status
      end
    end
  end
end
