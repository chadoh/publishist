class MeetingsController < InheritedResources::Base
  before_filter :editors_only, :except => [:index, :show]
  before_filter :coeditor_only, :only => :scores
  before_filter :authenticate_person!

  before_filter :resource, :only => [:scores, :show]

  custom_actions :resource => :search

  actions :all

  respond_to :js, :only => :update
  respond_to :html

  def index
    @magazines = Magazine.all
    @magazine = params[:m].present? ? Magazine.find(params[:m]) : Magazine.current.presence || Magazine.first
    @meetings = @magazine.present? ? @magazine.meetings.sort {|a,b| b.datetime <=> a.datetime } : Meeting.all
  end

  def show
    @show_author = false
    unless !current_person
      @show_score = current_person.can_enter_scores_for? resource
      @attendee = Attendee.find_by_person_id_and_meeting_id(current_person.id, resource.id)
    end
    show!
  end

  def scores
    @attendees = resource.attendees
  end

  def new
    session[:return_to] = request.referer
    new!
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
