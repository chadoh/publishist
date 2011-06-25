class PagesController < InheritedResources::Base
  actions :show, :create, :update, :destroy
  belongs_to :magazine

  respond_to :html
  respond_to :js, only: [:update, :add_submission]

  def create
    coming_from_page = request.referer.split('/').last
    return_to = Page.where("lower(title) = ?", coming_from_page).first || \
                Page.where("position = ?", coming_from_page.to_i + 4).first
    @magazine = Magazine.find_by_cached_slug params[:magazine_id]
    @page = @magazine.create_page_at params[:page][:position]

    redirect_to magazine_page_path(@magazine, return_to.reload)
  end

  def update
    @magazine = Magazine.find_by_cached_slug params[:magazine_id]
    @page = Page.where("lower(title) = ?", params[:id]).first || \
            Page.where("position = ?", params[:id].to_i + 4).first

    @page.update_attributes params[:page]

    respond_with [@magazine, @page.reload]
  end

  def add_submission
    magazine   = Magazine.find_by_cached_slug params[:magazine_id]
    page       = Page.where("lower(title) = ?", params[:id]).first || \
                 Page.where("position = ?", params[:id].to_i + 4).first
    submission = Submission.find params[:submission_id]

    page.submissions << submission

    if submission.page == page
      head :accepted
    else
      head :not_acceptable
    end
  end

  def destroy
    @magazine = Magazine.find_by_cached_slug params[:magazine_id]
    @page = Page.where("lower(title) = ?", params[:id]).first || \
            Page.where("position = ?", params[:id].to_i + 4).first

    new_page = Page.where("position = ?", @page.position + 1).first || \
               Page.where("position = ?", @page.position - 1).first

    new_page.submissions << @page.submissions
    @page.destroy

    respond_with [@magazine, @page = new_page.reload]
  end

protected

  def resource
    @magazine = Magazine.find_by_id params[:magazine_id]
    @page     = Page.where("lower(title) = ?", params[:id]).first || \
                Page.where("position = ?", params[:id].to_i + 4).first
  end
end
