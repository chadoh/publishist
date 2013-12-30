class PagesController < ApplicationController
  before_filter :resource

  respond_to :html
  respond_to :js, only: [:update, :add_submission]

  include ApplicationHelper

  before_filter except: :show do |c|
    c.must_orchestrate @publication
  end

  def show
    if not @page
      redirect_to issues_url
    elsif not @page.issue.viewable_by?(current_person, :or_adjacent)
      flash[:notice] = "That hasn't been published yet, check back soon!"
      redirect_to root_url and return
    end
    @show_conditional_tips = orchestrates?(@issue) && !@issue.notification_sent
  end

  def create
    coming_from_page = request.referer.split('/').last
    return_to = @issue.pages.where("lower(title) = ?", coming_from_page).first || \
                @issue.pages.where("position = ?", coming_from_page.to_i + 4).first
    @page = @issue.create_page_at params[:page][:position]

    redirect_to issue_page_path(@issue, return_to.reload)
  end

  def update
    @page.update_attributes params[:page]

    respond_with [@issue, @page.reload]
  end

  def add_submission
    submission = Submission.find params[:submission_id]

    submission.update_attributes page: @page
    submission.move_to_top

    if submission.reload.page == @page
      head :accepted
    else
      head :not_acceptable
    end
  end

  def destroy
    new_page = @issue.pages.where("position = ?", @page.position + 1).first || \
               @issue.pages.where("position = ?", @page.position - 1).first

    new_page.submissions << @page.submissions
    @page.destroy

    respond_with [@issue, @page = new_page.reload]
  end

protected

  def resource
    @issue = Issue.find params[:issue_id]
    @page     = @issue.pages.where("lower(title) = ?", params[:id]).first || \
                @issue.pages.where("position = ?", params[:id].to_i + 4).first
  end
end
