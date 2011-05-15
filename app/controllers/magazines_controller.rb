class MagazinesController < InheritedResources::Base
  before_filter :authenticate_person!, :only => :index
  before_filter :editors_only, :except => [:index]

  custom_actions :resource => [:highest_scores, :publish]

  def show
    @magazine = Magazine.find(params[:id])
    @submissions = @magazine.submissions.page(params[:page]).per(5)
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

end
