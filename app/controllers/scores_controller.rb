class ScoresController < InheritedResources::Base
  actions :create, :update, :destroy
  respond_to :js, :html

  def create
    create! do |wants|
      wants.html { redirect_to meeting_path(resource.packlet.meeting) }
      wants.js
    end
  end

  def update
    update! do |wants|
      wants.html { redirect_to meeting_path(resource.packlet.meeting) }
      wants.js { render :create }
    end
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to meeting_path(resource.packlet.meeting) }
      wants.js
    end
  end

end
