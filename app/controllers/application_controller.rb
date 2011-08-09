class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  def initialize_mixpanel
     @mixpanel = Mixpanel.new("a74ffdcff8f485143b89e03835339d2a", request.env, true)
     @mixpanel.append_api("identify", "#{"#{current_person.full_name} from " if !!current_person}#{request.remote_ip}")
  end

  def staff_only
    unless person_signed_in? and current_person.ranks.present?
      flash[:notice] = "Only staff can see that page."
      redirect_to root_url
    end
  end

  def editors_only
    unless person_signed_in? and current_person.editor?
      flash[:notice] = "Only #{Person.editors.collect{|e| e.name }.join(" & ")} can see that."
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
