class PagesController < ApplicationController
  before_filter :resource

  respond_to :html
  respond_to :js, only: [:update, :add_submission]

  def show
    redirect_to magazines_url unless @page
  end

  def create
    coming_from_page = request.referer.split('/').last
    return_to = @magazine.pages.where("lower(title) = ?", coming_from_page).first || \
                @magazine.pages.where("position = ?", coming_from_page.to_i + 4).first
    @page = @magazine.create_page_at params[:page][:position]

    redirect_to magazine_page_path(@magazine, return_to.reload)
  end

  def update
    @page.update_attributes params[:page]

    respond_with [@magazine, @page.reload]
  end

  def add_submission
    submission = Submission.find params[:submission_id]

    @page.submissions << submission
    submission.move_to_top

    if submission.page == page
      head :accepted
    else
      head :not_acceptable
    end
  end

  def destroy
    new_page = @magazine.pages.where("position = ?", @page.position + 1).first || \
               @magazine.pages.where("position = ?", @page.position - 1).first

    new_page.submissions << @page.submissions
    @page.destroy

    respond_with [@magazine, @page = new_page.reload]
  end

protected

  def resource
    @magazine = Magazine.find params[:magazine_id]
    @page     = @magazine.pages.where("lower(title) = ?", params[:id]).first || \
                @magazine.pages.where("position = ?", params[:id].to_i + 4).first
  end
end
