require 'rubygems'

require 'rails/application'
# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'email_spec'

require 'coveralls'
Coveralls.wear!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

module RequestHelpers
  def sign_in(person: nil)
    unless person
      person = Factory.create :person
      person.confirm!
    end
    ApplicationController.any_instance.stub(:person_signed_in?).and_return(true)
    ApplicationController.any_instance.stub(:current_person).and_return(person)
  end
end

RSpec.configure do |config|
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false

  config.include(EmailSpec::Helpers)
  config.include(EmailSpec::Matchers)

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    editor = double("editor", name: "Spec Helper Editor", email: "woo@woo.woo").as_null_object
    publication = double("publication", editor: editor).as_null_object
    Submission.any_instance.stub(:publication).and_return(publication)
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.include RequestHelpers, type: :request
end

FactoryGirl.definition_file_paths = [
  File.join(Rails.root, 'spec', 'factories')
]
FactoryGirl.find_definitions
