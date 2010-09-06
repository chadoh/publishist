class SessionsController < ApplicationController
  before_filter :ensure_login, :only => :destroy
  before_filter :ensure_logout, :only => [:new, :create]

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
      flash[:notice] = "You need to change your password."
      redirect_to edit_person_path(@person)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "That's not the link that you were emailed... Are you cheating?"
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
