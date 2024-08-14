# frozen_string_literal: true

module ApiHelper
  def authenticated_headers(user)
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    # This will add a valid token for `user` in the `Authorization` header
    auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)
    headers.merge!(auth_headers)
  end
end
