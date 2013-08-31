class RolesController < InheritedResources::Base
  actions :destroy
  respond_to :html, :js

  def new
    session[:return_to] = request.referer
    @role = Role.new position_id: params[:position_id]
    must_orchestrate @role, :or_adjacent
  end

  def create
    params[:role][:person] = Person.find_or_create(params[:role][:person])
    @role = Role.create params[:role]
    logger.debug "@role = #@role; @role.valid? #{@role.valid?}"
    must_orchestrate @role, :or_adjacent
    respond_with(@role) do |wants|
      wants.html { redirect_to session[:return_to] || request.referer }
      wants.js {
        if @role.valid?
          render :create
        else
          render :error
        end
      }
    end
  end

  def destroy
    must_orchestrate resource, :or_adjacent
    destroy! do |wants|
      wants.html { redirect_to request.referer }
      wants.js
    end
  end
end
