# app/controllers/api/v1/auth_controller.rb
module Api
  module V1
    class AuthController < BaseController
      def register
        user = User.new(user_params)
        if user.save
          tokens = ::Auth::TokenService.new(user).generate_tokens
          render json: { user: { id: user.id, email: user.email }, **tokens }, status: :created
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_content
        end
      end

      def login
        user = User.find_by(email: params[:email]&.downcase)

        if user&.authenticate(params[:password])
          tokens = ::Auth::TokenService.new(user).generate_tokens
          render json: { user: { id: user.id, email: user.email }, **tokens }
        else
          render json: { error: "Invalid credentials" }, status: :unauthorized
        end
      end

      def refresh
        user = ::Auth::TokenService.decode(params[:refresh_token], type: :refresh)
        tokens = ::Auth::TokenService.new(user).generate_tokens
        render json: tokens
      rescue ::Auth::TokenService::InvalidToken, Auth::TokenService::ExpiredToken
        render json: { error: "Invalid refresh token" }, status: :unauthorized
      end

      def logout
        # TODO: В приложении добавить токен в blacklist
        head :no_content
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation)
      end
    end
  end
end
