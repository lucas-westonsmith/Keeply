# config/environments/production.rb

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.action_mailer.default_url_options = { host: "http://TODO_PUT_YOUR_DOMAIN_HERE" }

  # Enable Importmap in production (important for production environment)
  config.importmap.enabled = true

  # Other production settings
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.assets.compile = false  # Prevent falling back to assets pipeline
  config.active_storage.service = :cloudinary
  config.force_ssl = true  # Force all access to the app over SSL

  config.logger = ActiveSupport::Logger.new(STDOUT).tap { |logger| logger.formatter = ::Logger::Formatter.new }
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # Ensure DNS rebinding protection is set
  # config.hosts = ["example.com"]

end
