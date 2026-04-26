# app/services/auth/token_service.rb
module Auth
  class TokenService
    class InvalidToken < StandardError; end
    class ExpiredToken < StandardError; end

    def initialize(user)
      @user = user
    end

    def generate_tokens
      {
        access: generate_token(JwtConfig.expiration),
        refresh: generate_token(JwtConfig.refresh_expiration),
        expires_in: JwtConfig.expiration.to_i,
        token_type: "Bearer"
      }
    end

    def self.decode(token, type: :access)
      (type == :access) ? JwtConfig.expiration : JwtConfig.refresh_expiration

      begin
        payload = JWT.decode(
          token,
          JwtConfig.secret_key,
          true,
          { algorithm: JwtConfig.algorithm, exp: true }
        ).first

        user = User.find_by(id: payload["sub"])
        raise ExpiredToken if payload["exp"] && payload["exp"] < Time.current.to_i
        raise InvalidToken unless user&.active?

        user
      rescue JWT::DecodeError
        raise InvalidToken
      rescue JWT::ExpiredSignature
        raise ExpiredToken
      end
    end

    private

    def generate_token(expiration)
      payload = {
        sub: @user.id,
        role: @user.role,
        exp: (Time.current + expiration).to_i,
        jti: SecureRandom.uuid
      }
      JWT.encode(payload, JwtConfig.secret_key, JwtConfig.algorithm)
    end
  end
end
