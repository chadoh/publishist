class PositionsController < InheritedResources::Base
  actions :destroy
  respond_to :html, :js

  def new
    session[:return_to] = request.referer
    @position = Position.new magazine_id: params[:magazine_id]
    must_orchestrate @position, :or_adjacent
  end

  def create
    @position = Position.new params[:position]
    must_orchestrate @position, :or_adjacent
    if @position.save
      redirect_to session[:return_to]
    else
      render action: 'new'
    end
  end

  def edit
    session[:return_to] = request.referer
    @position = Position.find params[:id]
    must_orchestrate @position, :or_adjacent
  end

  def update
    @position = Position.find params[:id]
    must_orchestrate @position, :or_adjacent
    if @position.update_attributes params[:position]
      redirect_to session[:return_to]
    else
      render action: 'edit'
    end
  end

  def destroy
    must_orchestrate @position, :or_adjacent
  end
end
