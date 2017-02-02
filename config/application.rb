require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module BootstrapStarter
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]


    # Activate observers that should always be running.
    config.active_record.observers = :user_observer, :story_observer, :news_observer, :invitation_observer,
                                    :asset_observer, :story_translation_observer, :section_translation_observer,
                                    :content_translation_observer, :embed_medium_translation_observer,
                                    :medium_translation_observer, :slideshow_translation_observer,
                                    :youtube_translation_observer, :theme_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Tbilisi'

    config.i18n.enforce_available_locales = true

    config.i18n.available_locales = [:en, :ka, :hy, :az, :ru]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :en

    # rails will fallback to config.i18n.default_locale translation
    config.i18n.fallbacks = true

    # rails will fallback to en, no matter what is set as config.i18n.default_locale
    #config.i18n.fallbacks = [:en]
    config.i18n.fallbacks = {'az' => 'ru', 'hy' => 'ru', 'ka' => 'en', 'ru' => 'en'}

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # tell the assest pipeline to add the public/javascripts dir as assets path
    config.assets.paths << "#{Rails.root}/public/javascripts/"

    # in app/assets folder
    config.assets.precompile += %w( collaborators.js filter.js follow.js logos.js modalos.js news.js nickname.js search.js settings.js story.js stories.js storyteller.js themes.js )
    config.assets.precompile += %w( about.css author.css authors.css collaborators.css embed.css filter.css grid.css grid2.css logos.css modalos.css navbar.css navbar2.css news.css root.css settings.css story.css stories.css storyteller.css themes.css todo.css highcharts.css)
    # in vendor/assets folder
    config.assets.precompile += %w( bootstrap-select.min.js jquery.tokeninput.js olly.js zeroclipboard.min.js jquery.tipsy.js )
    config.assets.precompile += %w( bootstrap-select.min.css jquery-ui-1.7.3.custom.css token-input-facebook.css tipsy.css)
    # build into gems
    config.assets.precompile += %w( dataTables/bootstrap/3/jquery.dataTables.bootstrap.css )
    config.assets.precompile += %w( dataTables/jquery.dataTables.js dataTables/bootstrap/3/jquery.dataTables.bootstrap.js jquery.ui.datepicker.js )

    config.assets.precompile += %w( jquery.ui.datepicker.js )
    config.assets.precompile += %w( jquery.ui.datepicker.css )


    # from: http://stackoverflow.com/a/24727310
    # to try and catch the following errors:
    # - invalid byte sequence in UTF-8
    # - invalid %-encoding
    require "#{Rails.root}/app/middleware/handle_invalid_percent_encoding.rb"
    config.middleware.insert 0, HandleInvalidPercentEncoding
    config.middleware.insert 0, Rack::UTF8Sanitizer

    # http://blog.gingerlime.com/2012/rails-ip-spoofing-vulnerabilities-and-protection/
    # The fact that Rails checks for IP spoofing can be a nuisance for sites that do heavy traffic with cell phones, because their proxies don't generally set things up right.
    config.action_dispatch.ip_spoofing_check = false

    # from: https://robots.thoughtbot.com/content-compression-with-rack-deflater
    # compress all html/json responses
    config.middleware.use Rack::Deflater

  end
end
