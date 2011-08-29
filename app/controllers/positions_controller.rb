class PositionsController < InheritedResources::Base
  actions :destroy
  respond_to :html, :js

  def new
    session[:return_to] = request.referer
    @position = Position.new magazine_id: params[:magazine_id]
  end

  def create
    @position = Position.new params[:position]
    if @position.save
      redirect_to session[:return_to]
    else
      render action: 'new'
    end
  end

  def edit
    session[:return_to] = request.referer
    @position = Position.find params[:id]
  end

  def update
    @position = Position.find params[:id]
    if @position.update_attributes params[:position]
      redirect_to session[:return_to]
    else
      render action: 'new'
    end
  end
end
