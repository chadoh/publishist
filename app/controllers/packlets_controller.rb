class PackletsController < ApplicationController
  before_filter :editors_only
  skip_before_filter :verify_authenticity_token

  def create
    @old_packlet = params[:packlet] || false
    @submission = @old_packlet ? Packlet.find(@old_packlet).submission : Submission.find(params[:submission])
    @meeting = Meeting.find params[:meeting]
    @packlet = @meeting.packlets.new :submission => @submission
    if @packlet.valid?
      @packlet.save
    else
      render :nothing => true and return
    end
  end

  def update_position
    @packlet = Packlet.find params[:id]
    @packlet.insert_at params[:position]
    render :nothing => true
  end

  def destroy
    @packlet = Packlet.find params[:id]
    @packlet.destroy
  end

end
