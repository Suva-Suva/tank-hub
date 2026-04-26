require "rails_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  describe "POST /api/v1/auth/register" do
    context "с корректными данными" do
      let(:params) do
        {user: {email: "newuser@example.com", password: "SecurePass123!", password_confirmation: "SecurePass123!"}}
      end

      it "создаёт пользователя и возвращает токены" do
        post api_v1_auth_register_path, params: params, as: :json

        expect(response).to have_http_status(:created)
        json = response.parsed_body
        expect(json).to include("access", "refresh", "user")
        expect(json["user"]["email"]).to eq("newuser@example.com")
        expect(User.find_by(email: "newuser@example.com")).to be_present
      end

      it "нормализует email к нижнему регистру" do
        post api_v1_auth_register_path,
          params: {user: {email: "User@Example.COM", password: "SecurePass123!", password_confirmation: "SecurePass123!"}},
          as: :json

        expect(response).to have_http_status(:created)
        expect(User.last.email).to eq("user@example.com")
      end

      it "возвращает access и refresh токены, а также token_type и expires_in" do
        post api_v1_auth_register_path, params: params, as: :json

        json = response.parsed_body
        expect(json["token_type"]).to eq("Bearer")
        expect(json["expires_in"]).to be_a(Integer)
      end
    end

    context "с дублирующимся email" do
      before { create(:user, email: "existing@example.com") }

      it "возвращает 422 с ошибками" do
        post api_v1_auth_register_path,
          params: {user: {email: "existing@example.com", password: "SecurePass123!", password_confirmation: "SecurePass123!"}},
          as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.parsed_body).to have_key("errors")
      end
    end

    context "с пустым email" do
      it "возвращает 422" do
        post api_v1_auth_register_path, params: {user: {email: "", password: "pass"}}, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "с невалидным форматом email" do
      it "возвращает 422" do
        post api_v1_auth_register_path,
          params: {user: {email: "not-an-email", password: "SecurePass123!", password_confirmation: "SecurePass123!"}},
          as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /api/v1/auth/login" do
    let!(:user) { create(:user, password: "SecurePass123!") }

    context "с верными учётными данными" do
      it "возвращает токены и данные пользователя" do
        post api_v1_auth_login_path, params: {email: user.email, password: "SecurePass123!"}, as: :json

        expect(response).to have_http_status(:ok)
        json = response.parsed_body
        expect(json).to include("access", "refresh")
        expect(json["user"]["email"]).to eq(user.email)
        expect(json["user"]["id"]).to eq(user.id)
      end
    end

    context "с неверным паролем" do
      it "возвращает 401 с сообщением об ошибке" do
        post api_v1_auth_login_path, params: {email: user.email, password: "wrongpass"}, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid credentials")
      end
    end

    context "с несуществующим email" do
      it "возвращает 401" do
        post api_v1_auth_login_path, params: {email: "nobody@example.com", password: "pass"}, as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "с email в другом регистре" do
      it "успешно авторизуется (email нечувствителен к регистру)" do
        post api_v1_auth_login_path, params: {email: user.email.upcase, password: "SecurePass123!"}, as: :json
        expect(response).to have_http_status(:ok)
      end
    end
  end

  describe "POST /api/v1/auth/refresh" do
    let!(:user) { create(:user) }

    context "с валидным refresh-токеном" do
      it "возвращает новую пару токенов" do
        refresh_token = Auth::TokenService.new(user).generate_tokens[:refresh]
        post api_v1_auth_refresh_path, params: {refresh_token: refresh_token}, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to include("access", "refresh")
      end
    end

    context "с невалидным токеном" do
      it "возвращает 401" do
        post api_v1_auth_refresh_path, params: {refresh_token: "invalid.token.here"}, as: :json

        expect(response).to have_http_status(:unauthorized)
        expect(response.parsed_body["error"]).to eq("Invalid refresh token")
      end
    end

    context "с токеном неактивного пользователя" do
      it "возвращает 401" do
        inactive = create(:user, :inactive)
        token = Auth::TokenService.new(inactive).generate_tokens[:refresh]
        post api_v1_auth_refresh_path, params: {refresh_token: token}, as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout" do
    it "возвращает 204 No Content" do
      delete api_v1_auth_logout_path, as: :json
      expect(response).to have_http_status(:no_content)
    end
  end
end
