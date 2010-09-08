class PeopleController < ApplicationController
  before_filter :ensure_login, :only => [:edit, :update, :destroy]
  before_filter :ensure_logout, :only => [:new, :create]
  before_filter :staff_only, :only => [:index]
  before_filter :editors_only, :only => [:destroy]
  skip_before_filter :check_that_user_is_verified, :only => [:set_password, :update]

  def index
    @people = Person.includes(:ranks).order('created_at')
  end

  def show
    @person = Person.find(params[:id])
    @compositions = @person.compositions.order("created_at DESC")
  end

  def new
    @person = Person.new
  end

  def create
    @person = Person.new(params[:person])
    if @person.save
      @session = @person.sessions.create
      session[:id] = @session.id
      flash[:notice] = "Welcome, #{@person.name}, you are now registered"
      redirect_to root_url
    else
      render :action => 'new'
    end
  end

  def edit
    @person = Person.find(params[:id])
  end

  def update
    @person = Person.find(@user)
    if @person.update_attributes(params[:person])
      flash[:notice] = "Your account has been updated"
      redirect_to root_url
    else
      render :action => 'edit'
    end
  end

  def recover
    require 'lib/crypto'
    person = Person.find_by_email(params[:recover_password][:email])
    if person
      Notifications.forgot_password(Crypto.encrypt("#{person.id}:#{person.salt}"), person.email).deliver
      person.update_attributes(:verified => false)
      flash[:notice] = "Please check your email."
      redirect_to root_url
    else
      flash[:notice] = "Your account couldn't be found. Perhaps you entered the wrong email address?"
      redirect_to help_people_path
    end
  end

  def set_password
    @person = Person.find(params[:id])
  end

  def help
  end

  def make_staff
    @person = Person.find(params[:id])
    promote(@person, 1)
  end

  def make_coeditor
    @person = Person.find(params[:id])
    promote(@person, 2)
  end

  def make_editor
    @person = Person.find(params[:id])
    promote(@person, 3)
  end

  def promote(person, to_rank)
    rank = Rank.new(:person => person, :rank_type => to_rank, :rank_start => Time.now)
    if rank.save
      flash[:notice] = "#{person.first_name} has been promoted!"
      redirect_to :action => :index
    else
      flash[:alert] = "There was an error promoting #{person.first_name}. Try again."
      redirect_to :action => :index
    end
  end

  def contact
    @to = Person.find(params[:contact_person][:to])
    @from = Person.find(params[:contact_person][:from])
    @subject = params[:contact_person][:subject]
    @message = params[:contact_person][:message]
    Communications.contact_person(@to, @from, @subject, @message).deliver
    flash[:notice] = "Your message has been sent!"
    redirect_to person_url(@to)
  end

  def destroy
    Person.destroy(@user)
    session[:id] = @user = nil
    flash[:notice] = "Goodbye! We're sad to see you go."
    redirect_to root_url
  end
end
