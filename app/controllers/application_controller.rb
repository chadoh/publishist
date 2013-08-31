class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers

  protect_from_forgery
  layout 'application'

  before_filter :reset_return_to_maybe

  def reset_return_to_maybe
    if session[:return_to]
      session[:return_to_age] ||= 0
      session[:return_to_age] += 1
      if session[:return_to_age] > 1
        session[:return_to] = nil
        session[:return_to_age] = nil
      end
    end
  end

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
