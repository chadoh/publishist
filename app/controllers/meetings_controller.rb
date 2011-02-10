class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :coeditor_only, :only => :scores
  before_filter :resource, :only => [ :scores, :show]

  custom_actions :resource => :search

  def show
    @show_score = current_person.can_enter_scores_for? resource
    @show_author = false
    @attendee = Attendee.find_by_person_id_and_meeting_id(current_person.id, resource.id)
    show!
  end

  def scores
    @attendees = resource.attendees
  end

protected

  def meeting_with_attendees
    @meeting = Meeting.includes(:attendees).find(params[:id])
  end
end
