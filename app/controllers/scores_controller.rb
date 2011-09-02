class ScoresController < InheritedResources::Base
  actions :create, :update, :destroy
  respond_to :js, :html

  def create
    create! do |success, failure|
      success.html { redirect_to meeting_path(resource.packlet.meeting) }
      success.js

      failure.html { redirect_to meeting_path(resource.packlet.meeting) }
      failure.js   { head :not_acceptable }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to meeting_path(resource.packlet.meeting) }
      success.js

      failure.html { redirect_to meeting_path(resource.packlet.meeting) }
      failure.js   { head :not_acceptable }
    end
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to meeting_path(resource.packlet.meeting) }
      wants.js
    end
  end

end
