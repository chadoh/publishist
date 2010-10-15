class CompositionsController < ApplicationController
  before_filter :editors_only, :only => [:index]
  before_filter :editors_and_owner_only, :only => [:show]
  before_filter :editor_only, :only => [:edit, :destroy]
  def index
    @compositions = Composition.order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @compositions }
    end
  end

  def show
    @composition = Composition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @composition }
    end
  end

  def new
    if @user
      @composition = Composition.new(:author_id => @user.id)
    else
      @composition = Composition.new
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @composition }
    end
  end

  def edit
    @composition = Composition.find(params[:id])
  end

  def create
    params[:composition][:author] = Person.find_or_create(params[:composition][:author])
    @composition = Composition.new(params[:composition])

    respond_to do |format|
      if @composition.save
        Notifications.new_composition(@composition).deliver
        format.html {
          flash[:notice] = "Thank you for helping make the world more beautiful! We look forward to reviewing it."
          if @user and @user.the_editor?
            redirect_to compositions_url
          elsif @user
            redirect_to person_url(@user)
          else
            redirect_to(root_url)
          end
        }
        format.xml  { render :xml => @composition, :status => :created, :location => @composition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @composition.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params[:composition][:author] = Person.find_or_create(params[:composition][:author])
    @composition = Composition.find(params[:id])

    respond_to do |format|
      if @composition.update_attributes(params[:composition])
        format.html { redirect_to(@composition, :notice => 'Success!') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @composition.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @composition = Composition.find(params[:id])
    @composition.destroy

    respond_to do |format|
      format.html { redirect_to(compositions_url) }
      format.xml  { head :ok }
    end
  end

protected
  
  def editor_and_owner_only
    @composition = Composition.find(params[:id])
    unless @user && (@user.the_editor? || @user == @composition.author)
      flash[:notice] = "You didn't write that, and you're not the editor. Sorry!"
      redirect_to root_url
    end
  end
  def editors_and_owner_only
    @composition = Composition.find(params[:id])
    unless @user && (@user.editor? || @user.name == @composition.author)
      flash[:notice] = "You didn't write that, and you're not the editor. Sorry!"
      redirect_to root_url
    end
  end
end
