class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language, :date_of_birth])
  end
end
