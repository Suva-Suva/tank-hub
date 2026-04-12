# config/initializers/jwt.rb
module JwtConfig
  def self.secret_key
    @secret_key ||= ENV.fetch("JWT_SECRET_KEY") { Rails.application.credentials.secret_key_base }
  end

  def self.expiration
    ENV.fetch("JWT_EXPIRATION", "15").to_i.minutes
  end

  def self.refresh_expiration
    ENV.fetch("JWT_REFRESH_EXPIRATION", "20160").to_i.minutes
  end

  def self.algorithm
    "HS256"
  end
end
