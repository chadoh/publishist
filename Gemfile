source 'http://rubygems.org'
ruby "2.0.0"

gem 'rake',  '10.0.4'
gem 'rails', '~> 3.2.0'
gem 'pg', '~> 0.11'
gem 'unicorn'
gem 'newrelic_rpm'
gem 'rack-timeout'

gem 'rails_12factor', group: :production

# Views
gem 'haml'
gem 'sass'
gem 'simple_form'
gem 'rdiscount', git: 'https://github.com/sunaku/rdiscount.git' # remove when on 1.9.3
gem 'font-awesome-rails'

# Controllers
gem 'aws-s3'
gem 'aws-sdk'
gem 'gravtastic', '3.1.0'
gem 'friendly_id'
gem 'inherited_resources'
gem 'paperclip'

# Models
gem 'acts_as_list'
gem 'delayed_job_active_record'
gem 'devise', '~> 1.5.0'
gem 'escape_utils'
gem 'foreigner'
gem 'memoist'
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
  gem 'sass-rails', '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'compass-rails'
  gem 'susy'
end

gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'wysihtml5-rails' # should this be in the above 'group :asset'?

group :development, :test do
  gem 'rspec-rails'
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
