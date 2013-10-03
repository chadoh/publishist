require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module Pc
  class Application < Rails::Application
    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = false

    stylesheets_directory = "#{Rails.root}/app/assets/stylesheets"
    config.assets.precompile << /(^[^_]|\/[^_])[^\/]*/

    # Because I prefer sass, and use Heroku.
    # http://joeybeninghove.com/2011/10/01/rails-31-asset-pipeline-sass-syntax-heroku/
    if Rails.configuration.respond_to?(:sass)
      Rails.configuration.sass.tap do |config|
        # Prefer SASS, 'cause that's what real men use :)
        config.preferred_syntax = :sass
      end
    end

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Add additional load paths for your own custom dirs
    # config.load_paths += %W( #{config.root}/extras )

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Eastern Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure generators values. Many other options are available, be sure to check the documentation.
    config.generators do |g|
      g.orm                 'active_record'
      g.template_engine     'haml'
      g.test_framework      'rspec'
      g.helper              false
      g.assets              false
      g.stylesheets         false
      g.view_specs          false
      g.controller_specs    false
      g.scaffold_controller 'scaffold_controller'
    end

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.action_view.sanitized_allowed_tags = 'font', 's', 'u', 'audio', 'video'
    config.action_view.sanitized_allowed_attributes = 'color', 'style', 'controls'
  end
end
