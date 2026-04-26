# app/controllers/api/v1/user/profile_controller.rb
module Api
  module V1
    module User
      class ProfileController < Api::V1::BaseController
        include Api::V1::Authenticable

        def show
          render json: {
            id: current_user.id,
            email: current_user.email,
            role: current_user.role,
            created_at: current_user.created_at
          }
        end

        def update
          if current_user.update(profile_params)
            render json: {message: "Profile updated"}
          else
            render json: {errors: current_user.errors.full_messages}, status: :unprocessable_content
          end
        end

        private

        def profile_params
          params.require(:user).permit(:email)
        end
      end
    end
  end
end
