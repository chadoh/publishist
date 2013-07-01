source 'http://rubygems.org'
ruby "2.0.0"

gem 'rake',  '10.0.4'
gem 'rails', '~> 3.1.3'
gem 'pg', '~> 0.11'
gem 'unicorn'
gem 'newrelic_rpm'
gem 'rack-timeout'

# Views
gem 'haml', '3.1.3'
gem 'sass'
gem 'simple_form'
gem 'rdiscount', git: 'https://github.com/sunaku/rdiscount.git' # remove when on 1.9.3

# Controllers
gem 'aws-s3'
gem 'aws-sdk'
gem 'gravtastic', '3.1.0'
gem 'friendly_id'
gem 'inherited_resources'
gem 'paperclip'

# Models
gem 'acts_as_list'
gem 'delayed_job', '~>2.1'
gem 'devise', '~> 1.5.0'
gem 'escape_utils'
gem 'foreigner'
gem 'rack-recaptcha', require: 'rack/recaptcha'
gem 'oa-core'
gem 'workless' # automatically start & stop workers (on Heroku or locally) for DJ

# Mailers
gem 'handlers', :git => "git://github.com/chadoh/handlers.git"

gem 'airbrake'

group :development do
  gem 'annotate'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails', '3.1.7'
  gem 'coffee-rails', '~> 3.1.0'
  gem 'uglifier'
  gem 'compass-rails'
  gem 'susy'
end

gem 'jquery-rails'

group :development, :test do
  gem 'railroady'
  gem 'rspec-rails'
  gem 'rb-fsevent'
end

group :test do
  gem 'cucumber-rails', :require => false
  gem 'capybara', '~>1.1'
  gem 'poltergeist'
  gem 'email_spec'
  gem 'factory_girl', '~> 2.0' # current is 4.x
  gem 'shoulda'
  gem 'database_cleaner'
end
