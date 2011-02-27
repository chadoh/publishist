class MeetingsController < InheritedResources::Base
  before_filter :editors_only, :except => [:index, :show]
  before_filter :coeditor_only, :only => :scores

  before_filter :resource, :only => [ :scores, :show]

  skip_before_filter :verify_authenticity_token, :only => :update

  custom_actions :resource => :search

  actions :all

  respond_to :html
  respond_to :js, :only => :update

  def show
    @show_score = current_person.can_enter_scores_for? resource
    @show_author = false
    @attendee = Attendee.find_by_person_id_and_meeting_id(current_person.id, resource.id)
    show!
  end

  def scores
    @attendees = resource.attendees
  end

end
