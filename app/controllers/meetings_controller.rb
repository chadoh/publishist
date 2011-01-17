class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :coeditor_only, :only => :scores
  before_filter :resource, :only => :scores

  actions :index, :show, :new, :create, :update, :destroy, :scores

  def show
    @show_score = current_person.can_enter_scores_for? resource
    @show_author = false
    @attendee = Attendee.find_by_person_id_and_meeting_id(current_person.id, resource.id)
    show!
  end

  def scores
    @attendees = resource.attendees_who_have_not_entered_scores_themselves
  end

protected

  def resource
    @meeting = Meeting.includes(:attendees).find(params[:id])
  end
end
