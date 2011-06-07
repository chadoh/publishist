class MagazinesController < InheritedResources::Base
  before_filter :editors_only, :except => [:index, :show]
  before_filter :ensure_current_url, :only => :show

  custom_actions :resource => [:highest_scores, :publish]

  def index
    @orphaned_meetings = Meeting.where(:magazine_id => nil)
    @magazines = person_signed_in? ? Magazine.all : Magazine.where(:published_on ^ nil)
  end

  def show
    @magazine = Magazine.find(params[:id])
    if @magazine.published?
      @page = @magazine.page(params[:page])
    else
      redirect_to action: :index
    end
  end

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
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
    winners = Submission.where(:id + params[:submission_ids])
    resource.publish winners
    redirect_to magazine_path(resource)
  end

protected

  def ensure_current_url
    redirect_to resource, :status => :moved_permanently unless resource.friendly_id_status.best?
  end

end
