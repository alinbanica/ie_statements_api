# frozen_string_literal: true

module ApiHelper
  def authenticated_header(request, user)
    headers = { 'Accept' => 'application/json', 'Content-Type' => 'application/json' }
    # This will add a valid token for `user` in the `Authorization` header
    auth_headers = Devise::JWT::TestHelpers.auth_headers(headers, user)
    request.headers.merge!(auth_headers)
  end
end
