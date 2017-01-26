source 'https://rubygems.org'

ruby "2.3.1"

gem 'bundler'
gem "rails", "3.2.22.2"
gem "mysql2", "~> 0.3.21" # this gem works better with utf-8

gem "jquery-rails", '~> 3.1.4' #"~> 1.0.19"
gem "remotipart", '~> 1.2' # ajax file upload
gem 'omniauth' # to login via facebook
gem 'omniauth-facebook' # to login via facebook
gem 'acts_as_list', '~> 0.6.0' # for sorting ordering records
gem 'tinymce-rails', "~> 3.5.8.3", :branch => "tinymce-3" #tinymce editor https://github.com/spohlenz/tinymce-rails/tree/tinymce-4
#gem 'tinymce-rails-langs' #tinymce languages https://github.com/spohlenz/tinymce-rails-langs
gem 'tinymce-rails-imageupload', '3.5.8.6', :branch => "tinymce3"   #tinymce imageupload https://github.com/PerfectlyNormal/tinymce-rails-imageupload/tree/master
gem 'amoeba', '~> 2.1.0' # cloning objects with all children
gem 'devise', '~> 2.0.4' # user authentication
gem "cancan", "~> 1.6.8" # user authorization
gem "formtastic", "~> 2.2.1" # create forms easier
gem "formtastic-bootstrap", :git => "https://github.com/mjbellantoni/formtastic-bootstrap.git", :branch => "bootstrap3_and_rails4"
#gem "nested_form", "~> 0.1.1", :git => "https://github.com/davidray/nested_form.git" # easily build nested model forms with ajax links
gem 'globalize', '~> 3.1.0' # internationalization
gem 'psych', '~> 2.0.13' # yaml parser - default psych in rails has issues
gem "will_paginate", "~> 3.1.5" # add paging to long lists
#gem "kaminari", "~> 0.15.1" # paging
gem 'gon', '~> 5.2.3' # push data into js
gem "dynamic_form", "~> 1.1.4" # to see form error messages
gem "i18n-js", "~> 2.1.2" # to show translations in javascript
gem 'paperclip', '~> 3.5.4' # to upload files
gem "paperclip-ffmpeg"
# gem 'friendly_id', '~> 4.0.10' # create permalink slugs for nice urls with history
gem 'friendly_id', '~> 4.1.0.beta.1' # create permalink slugs for nice urls with history
#gem "has_permalink", "~> 0.1.4" # create permalink slugs for nice urls
gem "capistrano", "~> 2.12.0" # to deploy to server
gem "exception_notification", "~> 2.5.2" # send an email when exception occurs
gem "useragent", :git => "https://github.com/jilion/useragent.git" # browser detection
gem "rails_autolink", "~> 1.1.6" # convert string to link if it is url
gem "subexec", "~> 0.2.3"
gem "impressionist", "1.4.13" # keep track of views
gem 'active_attr', '~> 0.9.0' # to create tabless models; using for contact form
gem "unidecoder", "~> 1.1.2" #convert utf8 to ascii for permalinks
gem 'scoped_search', '~> 3.3.0' # search a model
gem 'acts_as_votable', '~> 0.10.0' # vote/like a story
gem 'acts-as-taggable-on', '~> 3.4.4' # tagging system
gem 'detect_language', '~> 1.0.7' # detect language story is in
gem 'whenever', '~> 0.9.7' # schedule cron jobs
gem 'rack-utf8_sanitizer', '~> 1.3.2' # prevent invalid encoding error
gem 'json', '~> 2.0', '>= 2.0.2' # json parser faster than default
gem 'nokogiri'
gem 'test-unit', '~> 3.0' # required for running rails console

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.6'
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier',     '>= 1.0.3'
  gem "therubyracer"
  gem 'less-rails', "~> 2.6.0"
  gem 'twitter-bootstrap-rails', :git => 'git://github.com/seyhunak/twitter-bootstrap-rails.git'  , branch: 'bootstrap3'
#	gem "twitter-bootstrap-rails", "~> 2.2.8"
  gem 'jquery-datatables-rails', '~> 3.4.0'
  gem "jquery-ui-rails" , "~> 4.2.1"
end

group :development do
 	# gem "mailcatcher", "0.5.12" # small smtp server for dev, http://mailcatcher.me/
#	gem "wkhtmltopdf-binary", "~> 0.9.5.3" # web kit that takes html and converts to pdf
  gem 'rb-inotify', '~> 0.9.7' # rails dev boost needs this
  gem 'rails-dev-boost', :git => 'git://github.com/thedarkone/rails-dev-boost.git' # speed up loading page in dev mode
# gem 'better_errors', '1.1.0'        # detailed exceptions view
# gem 'binding_of_caller', '0.7.2'    # needed for better_errors advanced features
end

group :staging, :production do
  gem 'unicorn', '~> 5.2.0' # http server
end

