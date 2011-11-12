class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers

  protect_from_forgery
  layout 'application'

protected

  def must_orchestrate *args
    unless person_signed_in? && current_person.orchestrates?(*args)
      flash[:notice] = "You're not allowed to see that"
      redirect_to root_url and return
    end
  end

  def must_score *args
    unless person_signed_in? && current_person.scores?(*args)
      flash[:notice] = "You're not allowed to see that."
      redirect_to root_url
    end
  end

  def must_view *args
    unless person_signed_in? && current_person.views?(*args)
      flash[:notice] = "You're not allowed to see that."
      redirect_to root_url
    end
  end

end
