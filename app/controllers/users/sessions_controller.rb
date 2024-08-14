# frozen_string_literal: true

module Users
  class SessionsController < Devise::SessionsController
    include RackSessionsFix

    respond_to :json

    private

    def respond_with(current_user, _opts = {})
      render json: current_user, status: :ok
    end

    def respond_to_on_destroy
      if request.headers['Authorization'].present?
        jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last,
                                 Rails.application.credentials.devise_jwt_secret_key!).first
        current_user = User.find(jwt_payload['sub'])
      end

      if current_user
        render json: { message: 'Logged out successfully' }, status: :ok
      else
        render json: { message: 'Authentication credentials were missing or incorrect' },
          status: :unauthorized
      end
    end
  end
end
