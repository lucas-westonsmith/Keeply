require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Propeez
  class Application < Rails::Application
    config.action_controller.raise_on_missing_callback_actions = false if Rails.version >= "7.1.0"
    config.generators do |generate|
      generate.assets false
      generate.helper false
      generate.test_framework :test_unit, fixture: false
    end
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w(assets tasks))

    # ✅ FORCER LE CHARGEMENT D'IMPORTMAP
    config.importmap.draw do
      pin "application"
      pin "@hotwired/turbo-rails", to: "turbo.min.js"
      pin "@hotwired/stimulus", to: "stimulus.min.js"
      pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
      pin_all_from "app/javascript/controllers", under: "controllers"
      pin "bootstrap", to: "bootstrap.min.js", preload: true
      pin "@popperjs/core", to: "popper.js", preload: true
    end
  end
end
