class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  before_filter :maintain_session_and_user

  def ensure_login
    unless @user
      flash[:notice] = "Please sign in to continue"
      redirect_to new_session_path
    end
  end

  def ensure_logout
    if @user
      flash[:notice] = "You must sign out before you can sign in or register"
      redirect_to root_url
    end
  end

  def staff_only
    if !@user || @user.ranks.blank?
      flash[:notice] = "Only staff can see that page."
      redirect_to root_url
    end
  end

  def editors_only
    unless @user && @user.editor?
      flash[:notice] = "Only #{Person.editors.collect{|e| e.name }.join(" & ")} can see that."
      redirect_to root_url
    end
  end

  def coeditor_only
    unless @user && @user.highest_rank == 2
      flash[:notice] = "Only #{Person.coeditor.name} can see that."
      redirect_to root_url
    end
  end

  def editor_only
    unless @user && @user.the_editor?
      flash[:notice] = "Only #{Person.editor.name} can see that."
      redirect_to root_url
    end
  end

private

  def maintain_session_and_user
    if session[:id]
      if @application_session = Session.find_by_id(session[:id])
        @application_session.update_attributes(
          :ip_address => request.remote_addr,
          :path => request.path_info
        )
        @user = @application_session.person
      else
        session[:id] = nil
        redirect_to root_url
      end
    end
  end
end
