class MagazinesController < InheritedResources::Base
  before_filter :authenticate_person!
  before_filter :editors_only, :except => [:index]

  custom_actions :resource => [:highest_scores, :publish]

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
  end

  def highest_scores
    # TODO: chance this to `resource.submissions.count` when nested hm:t support is added
    @max = resource.meetings.collect(&:submissions).flatten.uniq.reject {|s| !s.scored? }.count
    if @max.present?
      @default = [@max * 3 / 4, 50].min
      @highest = params[:highest].presence || (@max * 3 / 4)
      @submissions = resource.highest_scores @highest.to_i
    end
  end

  def publish
    winners = Submission.where(:id + params[:submission_ids])
    resource.publish winners
    redirect_to magazines_path
  end

end
