class MagazinesController < InheritedResources::Base
  before_filter only: [:new, :create] do |c|
    c.must_orchestrate @publication
  end
  before_filter only: [:edit, :update, :destroy, :staff_list] do |c|
    c.must_orchestrate resource, :or_adjacent
  end
  before_filter only: [:publish, :highest_scores, :notify_authors_of_published_magazine] do |c|
    c.must_orchestrate resource
  end
  before_filter :ensure_current_url,   only:   :show

  action [:create, :update, :destroy]
  custom_actions :resource => [:highest_scores, :publish]

  def index
    @magazines = if person_signed_in?
                   @publication.magazines
                 else
                   @publication.magazines.where('published_on IS NOT NULL')
                 end
    @show_conditional_tips = @magazines.any?(&:timeframe_freshly_over?)
    set_tips
  end

  def new
    @magazine = Magazine.new publication_id: @publication.id
  end

  def show
    if resource.published_on.blank?
      redirect_to root_url(subdomain: @publication.subdomain), notice: "That issue hasn't been published yet!" and return
    elsif not @magazine.notification_sent?
      unless person_signed_in? && current_person.orchestrates?(@magazine, :or_adjacent)
        flash[:notice] = "That hasn't been published yet, check back soon!"
        redirect_to root_url(subdomain: @publication.subdomain) and return
      end
      redirect_to magazine_page_url @magazine, @magazine.pages.with_content.first, subdomain: @publication.subdomain and return
    else
      redirect_to magazine_page_url @magazine, @magazine.pages.with_content.first, subdomain: @publication.subdomain and return
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash.now[:notice] = nil
        if current_person.orchestrates? @magazine, :or_adjacent
          redirect_to staff_for_magazine_url(@magazine, subdomain: @publication.subdomain)
        else
          redirect_to magazines_url subdomain: @publication.subdomain
        end
      end
      failure.html { render :edit }
    end
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
    winners = Submission.where(id: params[:submission_ids])
    resource.publish winners
    flash[:notice] =  "Now make it look pretty! You can add cover art & such to a page with the "
    flash[:notice] += "big X near the bottom left of each page, you can drag submissions to different "
    flash[:notice] += "pages using their right edge, you can add new pages by clicking the pluses in "
    flash[:notice] += "the page list, remove the current page by using the little 'x', and "
    flash[:notice] += "rename the current page by simply clicking on its name. "
    flash[:notice] += "When it's looking really nice, you can send a notification to everyone who "
    flash[:notice] += "submitted by using the button at the bottom of the page."
    redirect_to magazine_page_url @magazine, @magazine.pages.first, subdomain: @publication.subdomain
  end

  def notify_authors_of_published_magazine
    @magazine.notify_authors_of_published_magazine
    redirect_to request.referer, notice: "Everyone who submitted was notified that they can now view the magazine online"
  end

  def staff_list
    @magazine = Magazine.find params[:id]
  end

protected

  def ensure_current_url
    if request.path != magazine_path(resource)
      redirect_to resource, :status => :moved_permanently
    end
  end

end
