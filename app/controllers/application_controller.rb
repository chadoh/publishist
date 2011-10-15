class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers

  protect_from_forgery
  layout 'application'

protected

  def must_orchestrate *args
    unless person_signed_in? and current_person.orchestrates? *args
      flash[:notice] = "You're not allowed to see that."
      redirect_to root_url
    end
  end

end
