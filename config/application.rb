# config/application.rb

require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Propeez
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Enable Importmap for JavaScript management
    config.importmap.enabled = true  # Active Importmap

    # Set up the generators
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end

    # Autoload libraries (optional)
    config.autoload_lib(ignore: %w(assets tasks))
  end
end
