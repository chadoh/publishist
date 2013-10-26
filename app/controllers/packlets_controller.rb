class PackletsController < InheritedResources::Base
  before_filter except: [:create] do |c|
    c.must_orchestrate resource
  end

  respond_to :js

  def create
    @old_packlet = params[:packlet] || false
    @submission = @old_packlet ? Packlet.find(@old_packlet).submission : Submission.find(params[:submission])
    @meeting = Meeting.find params[:meeting]
    @packlet = @meeting.packlets.new :submission => @submission
    if @packlet.valid?
      @packlet.save
    else
      head :not_acceptable
    end
  end

  def update_position
    @packlet = Packlet.find params[:id]
    @packlet.insert_at params[:position]
    render :nothing => true
  end

  def destroy
    resource.destroy :current_person => current_person
  end

end
