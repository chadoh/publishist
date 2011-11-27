class SubmissionsController < InheritedResources::Base
  before_filter :only => [:index] do |c|
    c.must_orchestrate :any
  end
  before_filter :ensure_current_url, :only => :show

  def index
    @magazines = current_person.magazines
    @magazine = params[:m].present? ? Magazine.find(params[:m]) : Magazine.current.presence || Magazine.first
    @average = @magazine.try(:average_score)
    @meetings = @magazine.present? ? @magazine.meetings.sort {|a,b| b.datetime <=> a.datetime } : Meeting.all
    @meetings_to_come = @meetings.select {|m| Time.now - m.datetime < 0}
    @meetings_gone_by = @meetings - @meetings_to_come
    @show_author = false unless current_person.communicates?(@magazine)
    @unscheduled_submissions = Submission.where(:state => Submission.state(:submitted))
  end

  def show
    @submission = Submission.find(params[:id])
    @average = @submission.magazine.try(:average_score).presence

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @submission }
    end
  end

  def old_new
    session[:return_to] = request.referer unless begin URI(request.referer).path == "/submissions" rescue false end
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

  def new
    session[:return_to] = request.referer unless begin URI(request.referer).path == "/submissions" rescue false end
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
    session[:return_to] = request.referer unless begin URI(request.referer).path == "/submissions" rescue false end
    @submission = Submission.find(params[:id])
    unless person_signed_in? and (current_person.communicates?(@submission) or @submission.author == current_person)
      flash[:notice] = "You're not allowed to edit that."
      redirect_to request.referer
    end
  end

  def create
    set_params
    @submission = Submission.new params[:submission]

    respond_with(@submission) do |format|
      if @submission.valid?
        format.html {
          if person_signed_in?
            @submission.save
            redirect_to submissions_url and return if current_person.orchestrates?(:current) && params["preview"]
            if @submission.published?
              flash[:notice] = "#@submission has been published and is on <a href='/magazines/#{@submission.magazine.to_param}/#{@submission.page.to_param}'>page #{@submission.page} of #{@submission.magazine}</a>.".html_safe
              redirect_to new_submission_url and return
            end
            redirect_to person_url(current_person)
          else
            if recaptcha_valid?
              @submission.save
              flash[:notice] = "Thank you for helping make the world more beautiful! We look forward to reviewing it."
              redirect_to session[:return_to] || root_url
            else
              flash[:notice] = "You might be a bot! If you're fairly certain you're not, please try again. Elsewise, <i>go away</i>.".html_safe
              render action: 'new'
            end
          end
        }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @submission = Submission.find(params[:id])
    set_params
    @submission.attributes = params[:submission]

    # update! {
    #   if current_person.orchestrates?(:current) && params[:commit] != t('preview')
    #     session[:return_to] || submissions_url
    #   else
    #     @submission.author ? person_url(resource.author) : submission_url(@submission)
    #   end
    # }
    respond_with(@submission) do |format|
      if @submission.save
        format.html {
          if @submission.published?
            flash[:notice] = "#@submission has been published and is on <a href='/magazines/#{@submission.magazine.to_param}/#{@submission.page.to_param}'>page #{@submission.page} of #{@submission.magazine}</a>.".html_safe
            redirect_to new_submission_url and return
          else
            redirect_to session[:return_to] || request.referer
          end
        }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    unless person_signed_in? and (current_person.communicates?(resource) || current_person == resource.author)
      flash[:notice] = "You're not allowed to see that."
      redirect_to(root_url) and return
    else
      destroy!(:notice => "It is gone.") { request.referer }
    end
  end

protected

  def ensure_current_url
    redirect_to resource, :status => :moved_permanently unless resource.friendly_id_status.best?
  end

  def set_params
    params[:submission][:author] = Person.find_or_create(params[:submission][:author]) if !!params[:submission][:author]
    params[:submission][:updated_by] = current_person
    params[:submission][:state] = :submitted if params["submit"]
  end

end
