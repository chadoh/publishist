class MeetingsController < InheritedResources::Base
  before_filter only: [:new, :create] do |c|
    c.must_orchestrate :any
  end
  before_filter only: [:edit, :update, :destroy] do |c|
    c.must_orchestrate resource
  end
  before_filter :authenticate_person!

  actions :all
  custom_actions :resource => [:scores]

  respond_to :js, :only => :update
  respond_to :html

  def index
    @magazines = current_person.magazines_with_meetings
    @magazine = params[:m].present? ? Magazine.find(params[:m]) : @magazines.first
    must_view @magazine if @magazine
    @meetings = @magazine.present? ? @magazine.meetings : Meeting.all
  end

  def show
    must_view resource
    @show_author = false
    unless !current_person
      @show_score = current_person.can_enter_scores_for? resource
      @attendee = Attendee.find_by_person_id_and_meeting_id(current_person.id, resource.id)
    end
  end

  def scores
    must_score resource
    @attendees = resource.attendees
  end

  def new
    session[:return_to] = request.referer
    @meeting = Meeting.new magazine: @publication.current_magazine
  end

  def create
    create!{ session[:return_to].presence || resource_url }
  end

  def edit
    session[:return_to] = request.referer
    edit!
  end

  def update
    update!{ session[:return_to].presence || magazines_url }
  end

  def destroy
    destroy!{ magazines_url }
  end

end
