class SubmissionsController < InheritedResources::Base
  before_filter :editors_only, :only => [:index]

  def index
    @magazines = Magazine.all
    @magazine = params[:m].present? ? Magazine.find(params[:m]) : Magazine.current.presence || Magazine.first
    @meetings = @magazine.present? ? @magazine.meetings : Meeting.all
    @meetings_to_come = @meetings.select {|m| Time.now - m.datetime < 0}
    @meetings_gone_by = @meetings - @meetings_to_come
    @unscheduled_submissions = Submission.where :state => Submission.state(:submitted)
    @show_author = false if current_person.the_coeditor?
    index!
  end

  def show
    @submission = Submission.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  def new
    if person_signed_in?
      @submission = Submission.new :author_id => current_person.id, :state => :draft
    else
      @submission = Submission.new :state => :submitted
    end

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  def edit
    @submission = Submission.find(params[:id])
    unless person_signed_in? and (current_person.the_editor? or @submission.author == current_person)
      flash[:notice] = "You're not allowed to edit that."
      redirect_to request.referer
    end
  end

  def create
    params[:submission][:author] = Person.find_or_create(params[:submission][:author])
    params[:submission][:state]  = params[:commit] == "Submit!" ? :submitted : :draft
    @submission = Submission.new(params[:submission])

    respond_to do |format|
      if @submission.save
        format.html {
          if person_signed_in?
            redirect_to submissions_url and return if current_person.the_editor? && params[:commit] != t('preview')
            redirect_to person_url(current_person)
          else
            flash[:notice] = "Thank you for helping make the world more beautiful! We look forward to reviewing it."
            redirect_to root_url
          end
        }
        format.xml  { render :xml => @submission, :status => :created, :location => @submission }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @submission.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    if !!params[:submission][:author]
      params[:submission][:author] = Person.find_or_create(params[:submission][:author])
    end
    if request.referer == new_submission_url or request.referer == edit_submission_url(resource)
      params[:submission][:state] = :submitted if params[:commit] == "Submit!"
    end

    update! do
      if current_person.the_editor? && params[:commit] != t('preview')
        submissions_url
      else
        person_url(resource.author)
      end
    end
  end

  def destroy
    unless person_signed_in? and (current_person.the_editor? || current_person == resource.author)
      flash[:notice] = "You didn't write that, and you're not the editor. Sorry!"
      redirect_to(root_url) and return
    else
      destroy!(:notice => "It is gone.") { request.referer }
    end
  end

end
