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
      redirect_to(root_url)
    end
  end

private

  def maintain_session_and_user
    if session[:id]
      if @application_session = Session.find_by_id(session[:id])
        @application_session.update_attributes(
          :ip_adddress => request.remote_addr,
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
