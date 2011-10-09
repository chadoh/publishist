class ApplicationController < ActionController::Base
  include Rack::Recaptcha::Helpers

  protect_from_forgery
  layout 'application'

  def staff_only
    unless person_signed_in? and current_person.ranks.present?
      flash[:notice] = "Only staff can see that page."
      redirect_to root_url
    end
  end

  def editors_only
    unless person_signed_in? and current_person.editor?
      flash[:notice] = "You're not allowed to see that."
      redirect_to root_url
    end
  end

  def coeditor_only
    unless person_signed_in? and current_person.the_coeditor?
      flash[:notice] = "Only #{Person.coeditor.name} can see that."
      redirect_to root_url
    end
  end

  def editor_only
    unless person_signed_in? and current_person.the_editor?
      flash[:notice] = "Only #{Person.editor.name} can see that."
      redirect_to root_url
    end
  end

end
