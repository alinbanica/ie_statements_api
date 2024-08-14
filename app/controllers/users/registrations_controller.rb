# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include RackSessionsFix

    respond_to :json

    private

    def respond_with(current_user, _opts = {})
      if resource.persisted?
        render json: { message: 'Signed up successfully'}, status: :ok
      else
        render json: {
          message: "User couldn't be created successfully",
          errors:  GenerateErrorMessages.new(current_user).call
        }, status: :unprocessable_entity
      end
    end
  end
end
