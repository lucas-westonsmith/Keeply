class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language])
  end
end
