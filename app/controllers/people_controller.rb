require 'lib/crypto'

class PeopleController < InheritedResources::Base
  before_filter :resource, :only => [:set_password, :make_staff, :make_editor, :make_coeditor]
  before_filter :ensure_login, :only => [:edit, :update, :destroy]
  before_filter :ensure_logout, :only => [:new, :create], :unless => :editor?
  before_filter :staff_only, :only => [:index]
  before_filter :editors_only, :only => [:destroy]
  skip_before_filter :check_that_user_is_verified, :only => [:set_password, :update]

  def show
    @person = Person.find(params[:id])
    if @user && (@user.the_editor? || @user == @person)
      @compositions = @person.compositions.order("created_at DESC")
    end
    show!
  end

  def create
    @person = Person.new(params[:person])
    o =  [('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten;  
    password  =  (0..10).map{ o[rand(o.length)]  }.join;    
    @person.password = @person.password_confirmation = password
    @person.salt = "n00b"
    @person.verified = false
    if @person.save
      Notifications.signup(Crypto.encrypt("#{@person.id}:#{@person.salt}"), @person).deliver
      unless session[:id]
        flash[:notice] = "Welcome, #{@person.name}; you need to check your email to finish signing up."
        redirect_to root_url
      else
        flash[:notice] = "#{@person.first_name} will get a Welcome email soon."
        redirect_to people_url
      end
    else
      render :action => 'new'
    end
  end

  def update
    update! do |success, failure|
      failure.html { render :action => 'edit' }
    end
  end

  def recover
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

  def make_staff
    promote(@person, 1)
  end

  def make_coeditor
    promote(@person, 2)
  end

  def make_editor
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
    destroy! do |success, failure|
      session[:id] = @user = nil
      success.html { redirect_to root_url }
      failure.html { render :action => 'edit' }
    end
  end

protected

  def collection
    @people ||= end_of_association_chain.includes(:ranks).order('created_at')
  end

  def resource
    @person ||= Person.find(params[:id])
  end

  def editor?
    @user && @user.editor?
  end
end
