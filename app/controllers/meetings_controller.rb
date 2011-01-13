class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :resource, :only => :scores

  actions :index, :show, :new, :create, :update, :destroy, :scores

  def show
    @show_score = if person_viewing_attended? then true else false end
    @show_author = false
    @attendance = Attendance.new
    show!
  end

  def scores
    @attendees = resource.attendees_who_have_not_entered_scores_themselves
  end

protected

  def person_viewing_attended?
    resource.attendances.select {|a| a.person == current_person }
  end

  def resource
    @meeting = Meeting.includes(:attendances).find(params[:id])
  end
end
