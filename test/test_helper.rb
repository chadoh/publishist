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
  def sign_in_user(person = nil)
    @user = person || Factory.create(:person)
    @application_session = Session.create(:email => @user.email, :password => "secret") 
    session[:id] = @application_session.id
  end

  def current_user
    @user
  end
  
  def sign_out_user
    @application_session.destroy if @application_session
    session.delete :id
  end
end
