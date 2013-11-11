class MeetingsController < InheritedResources::Base
  before_filter only: [:new, :create] do |c|
    c.must_orchestrate @publication
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
    @issues = current_person.issues.with_meetings
    @issue = params[:m].present? ? Issue.find(params[:m]) : @issues.first
    must_view @issue if @issue
    @meetings = @issue.present? ? @issue.meetings : @publication.meetings
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
    @meeting = Meeting.new issue: @publication.current_issue
  end

  def create
    create!{ session[:return_to].presence || resource_url }
  end

  def edit
    session[:return_to] = request.referer
    edit!
  end

  def update
    update!{ session[:return_to].presence || issues_url }
  end

  def destroy
    destroy!{ issues_url }
  end

end
