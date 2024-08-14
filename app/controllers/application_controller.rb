# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  rescue_from StandardError, with: :render_internal_server_error_response
  rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable_entity_response
  rescue_from ActiveRecord::RecordNotFound, with: :render_record_not_found_response

  respond_to :json

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end

  def render_unprocessable_entity_response(exception)
    render json: { errors: GenerateErrorMessages.new(exception.record).call },
      status: :unprocessable_entity
  end

  def render_record_not_found_response
    render json: { message: 'The record does not exist' }, status: :not_found
  end

  def render_internal_server_error_response(exception)
    render json: { message: "Internal Server Error" }, status: :internal_server_error
  end

end
