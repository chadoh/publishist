# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Pc::Application.initialize!

# Needs to be set for compositions to turn out right!
Haml::Template.options[:ugly] = true

Sass::Plugin.options[:template_location] = { 'app/stylesheets' => 'public/stylesheets' }
#Rails::Initializer.run do |config|
  #config.action_view.sanitized_allowed_tags = 'b', 'i', 'em', 'strong', 'sub', 'sup'
#end
