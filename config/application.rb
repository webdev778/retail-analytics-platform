require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RetailAnalyticsPlatform
  class Application < Rails::Application
    config.autoload_paths += %W(#{config.root}/lib #{config.root}/services)
    config.eager_load_paths += %W(
      #{config.root}/lib/file_reader
      #{config.root}/lib/mws
      #{config.root}/lib/report_parser
      #{config.root}/services
    )
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.active_job.queue_adapter = :sidekiq

    config.to_prepare do
      Devise::SessionsController.layout 'devise'
      Devise::RegistrationsController.layout 'devise'
      Devise::ConfirmationsController.layout 'devise'
      # Devise::UnlocksController.layout 'devise'
      Devise::PasswordsController.layout 'devise'
      # Devise::Mailer.layout 'default_mailer'
    end
  end
end
