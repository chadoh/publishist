class RolesController < InheritedResources::Base
  actions :new, :create, :destroy
  respond_to :html, :js

  def new
    session[:return_to] = request.referer
    @role = Role.new position_id: params[:position_id]
  end

  def create
    params[:role][:person] = Person.find_or_create(params[:role][:person])
    create! do |wants|
      wants.html { redirect_to session[:return_to] }
      wants.js
    end
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to request.referer }
      wants.js
    end
  end
end
