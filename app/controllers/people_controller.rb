class PeopleController < ApplicationController
  before_filter :ensure_login, :only => [:edit, :update, :destroy]
  before_filter :ensure_logout, :only => [:new, :create]
  before_filter :staff_only, :only => [:index, :show]
  before_filter :editors_only, :only => [:destroy]

  def index
    @people = Person.includes(:ranks).order('created_at')
  end

  def show
    @person = Person.find(params[:id])
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

  def destroy
    Person.destroy(@user)
    session[:id] = @user = nil
    flash[:notice] = "Goodbye! We're sad to see you go."
    redirect_to root_url
  end
end
