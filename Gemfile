source 'http://rubygems.org'

gem 'rake',  '0.8.7'
gem 'rails', '3.1.0'
gem 'pg', '~> 0.11'

# Views
gem 'haml'
gem 'sass'
gem 'simple_form'
gem 'rdiscount'
gem 'compass'
gem 'compass-susy-plugin'

# Controllers
gem 'aws-s3'
gem 'gravtastic', '3.1.0'
gem 'friendly_id', git: 'git://github.com/norman/friendly_id.git', branch: '3.x'
gem 'inherited_resources'
gem 'paperclip'

# Models
gem 'acts_as_list'
gem 'delayed_job'
gem 'devise'
gem 'escape_utils'
gem 'foreigner'
gem 'rack-recaptcha', require: 'rack/recaptcha'
gem 'oa-core'
gem 'workless' # automatically start & stop workers (on Heroku or locally) for DJ

# Mailers
gem 'handlers', :git => "git://github.com/chadoh/handlers.git"

gem 'airbrake'

group :development do
  gem 'annotate-models'
  gem 'heroku_san'
  gem 'rails3-generators'
  gem 'ruby-debug19'
end

group :development, :test do
  gem 'railroady'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'rb-fsevent'
  gem 'growl'
  gem 'guard-spork'
end

group :test do
  gem 'cucumber-rails'
  gem 'capybara'
  gem 'email_spec'
  gem 'factory_girl'
  gem 'shoulda'
  # gem 'launchy'
  gem 'database_cleaner'
  gem "spork", ">= 0.9.0.rc9"
end

group :production do
  gem 'newrelic_rpm'
end
