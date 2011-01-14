class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :coeditor_only, :only => :scores
  before_filter :resource, :only => :scores

  actions :index, :show, :new, :create, :update, :destroy, :scores

  def show
    @show_score = if person_viewing_attended? and editor_didnt_enter_their_score?
      then true else false end
    @show_author = false
    @attendance = Attendance.new
    show!
  end

  def scores
    @attendees = resource.attendees_who_have_not_entered_scores_themselves
  end

protected

  def viewers_attendance
    @viewers_attendance ||= resource.attendances.select  do |a|
      a.person == current_person
    end
  end

  def person_viewing_attended?
    viewers_attendance.present?
  end

  def editor_didnt_enter_their_score?
  end

  def resource
    @meeting = Meeting.includes(:attendances).find(params[:id])
  end
end
