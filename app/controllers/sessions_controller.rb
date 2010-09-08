class SessionsController < ApplicationController
  before_filter :ensure_login, :only => :destroy
  before_filter :ensure_logout, :only => [:new, :create]
  skip_before_filter :check_that_user_is_verified, :only => [:destroy]

  def index
    redirect_to new_session_path
  end

  def new
    @session = Session.new
  end

  def create
    @session = Session.new(params[:session])
    if @session.save
      session[:id] = @session.id
      flash[:notice] = "Welcome, #{@session.person.first_name}!"
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def recovery
    begin
      require 'lib/crypto'
      key = Crypto.decrypt(params[:id]).split(/:/)
      @person = Person.where(:id => key[0], :salt => key[1]).first
      @session = @person.sessions.create
      session[:id] = @session.id
      if @person.salt == "n00b"
        flash[:notice] = "You're thisclose to being all signed up. All you need to do is make a password!"
      else
        flash[:notice] = "You need to change your password."
      end
      redirect_to set_password_person_path(@person)
    rescue
      flash[:notice] = "There was no good in that link."
      redirect_to root_url
    end
  end

  def destroy
    Session.destroy(@application_session)
    session[:id] = @user = nil
    flash[:notice] = "You are no longer signed in"
    redirect_to root_url
  end
end
