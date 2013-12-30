class IssuesController < InheritedResources::Base
  before_filter only: [:new, :create] do |c|
    c.must_orchestrate @publication
  end
  before_filter only: [:edit, :update, :destroy, :staff_list] do |c|
    c.must_orchestrate resource, :or_adjacent
  end
  before_filter only: [:publish, :highest_scores, :notify_authors_of_published_issue] do |c|
    c.must_orchestrate resource
  end
  before_filter :ensure_current_url,   only:   :show

  action [:create, :update, :destroy]
  custom_actions :resource => [:highest_scores, :publish]

  def index
    @issues = if person_signed_in?
                   @publication.issues
                 else
                   @publication.issues.where('published_on IS NOT NULL')
                 end
    @show_conditional_tips = @issues.any?(&:timeframe_freshly_over?)
  end

  def new
    @issue = Issue.new publication_id: @publication.id
  end

  def show
    if resource.published_on.blank?
      redirect_to root_url, notice: "That issue hasn't been published yet!" and return
    elsif not @issue.notification_sent?
      unless person_signed_in? && current_person.orchestrates?(@issue, :or_adjacent)
        flash[:notice] = "That hasn't been published yet, check back soon!"
        redirect_to root_url and return
      end
      redirect_to issue_page_url @issue, @issue.pages.with_content.first and return
    else
      redirect_to issue_page_url @issue, @issue.pages.with_content.first and return
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash.now[:notice] = nil
        if current_person.orchestrates? @issue, :or_adjacent
          redirect_to staff_for_issue_url(@issue)
        else
          redirect_to issues_url
        end
      end
      failure.html { render :edit }
    end
  end

  def update
    update!(:notice => nil)   { issues_path }
  end

  def highest_scores
    @max = resource.submissions.count
    if @above = params[:above].blank? ? nil : params[:above].to_f
      @submissions = resource.all_scores_above @above
    else
      @highest = params[:highest].presence || [@max * 3 / 4, 50].min
      @submissions = resource.highest_scores @highest.to_i
    end
  end

  def publish
    winners = Submission.where(id: params[:submission_ids])
    resource.publish winners
    current_person.update_attribute :show_tips_at_page_load, true
    redirect_to issue_page_url @issue, @issue.pages.first
  end

  def notify_authors_of_published_issue
    @issue.notify_authors_of_published_issue
    redirect_to request.referer, notice: "Everyone who submitted was notified that they can now view the issue online"
  end

  def staff_list
    @issue = Issue.find params[:id]
  end

protected

  def ensure_current_url
    if request.path != issue_path(resource)
      redirect_to resource, :status => :moved_permanently
    end
  end

end
