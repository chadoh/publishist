ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  def sign_in_user
    @user = Factory(:person)
    @application_session = Session.create(:email => @user.email, :password => "secret") 
  end

  def current_user
    @user
  end
  
  def sign_out_user
    @application_session.destroy if @application_session
  end
end

class ActionController::TestCase
  def sign_in_user
    @user = Factory(:person)
    @application_session = Session.create(:person => @user.email, :password => "secret") 
  end

  def current_user
    @user
  end
  
  def sign_out_user
    @application_session.destroy if @application_session
  end
end
