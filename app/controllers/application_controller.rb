class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  def default_url_options
    { host: ENV["DOMAIN"] || "localhost:3000" }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name, :avatar, :country, :phone_number, :preferred_language, :date_of_birth])
  end

  # Rediriger vers /menu après la connexion
  def after_sign_in_path_for(resource)
    menu_path # URL helper défini dans vos routes
  end

  # Rediriger vers /menu après l'inscription
  def after_sign_up_path_for(resource)
    menu_path # Redirection après sign up
  end
end
