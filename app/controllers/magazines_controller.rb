class MagazinesController < InheritedResources::Base
  before_filter :authenticate_person!
  before_filter :editors_only, :except => [:index]

  custom_actions :resource => :highest_scores

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
  end

  def highest_scores
    # TODO: chance this to `resource.submissions.count` when nested hm:t support is added
    @max = resource.meetings.collect(&:submissions).flatten.uniq.count
    @default = [@max * 3 / 4, 50].min
    @highest = params[:highest].presence || (@max * 3 / 4)
    @submissions = resource.highest_scores @highest.to_i
  end

end
