module AuthHelpers
  def auth_token_for(user)
    Auth::TokenService.new(user).generate_tokens[:access]
  end

  def auth_headers_for(user)
    {"Authorization" => "Bearer #{auth_token_for(user)}"}
  end
end
