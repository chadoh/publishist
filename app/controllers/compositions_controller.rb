class CompositionsController < ApplicationController
  # GET /compositions
  # GET /compositions.xml
  def index
    @compositions = Composition.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @compositions }
    end
  end

  # GET /compositions/1
  # GET /compositions/1.xml
  def show
    @composition = Composition.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @composition }
    end
  end

  # GET /compositions/new
  # GET /compositions/new.xml
  def new
    @composition = Composition.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @composition }
    end
  end

  # GET /compositions/1/edit
  def edit
    @composition = Composition.find(params[:id])
  end

  # POST /compositions
  # POST /compositions.xml
  def create
    @composition = Composition.new(params[:composition])

    respond_to do |format|
      if @composition.save
        format.html { redirect_to(@composition, :notice => 'Composition was successfully created.') }
        format.xml  { render :xml => @composition, :status => :created, :location => @composition }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @composition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /compositions/1
  # PUT /compositions/1.xml
  def update
    @composition = Composition.find(params[:id])

    respond_to do |format|
      if @composition.update_attributes(params[:composition])
        format.html { redirect_to(@composition, :notice => 'Composition was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @composition.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /compositions/1
  # DELETE /compositions/1.xml
  def destroy
    @composition = Composition.find(params[:id])
    @composition.destroy

    respond_to do |format|
      format.html { redirect_to(compositions_url) }
      format.xml  { head :ok }
    end
  end
end
