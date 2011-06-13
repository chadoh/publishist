class PagesController < InheritedResources::Base
  include Haml::Helpers
  actions :show, :create, :update, :destroy
  belongs_to :magazine

  respond_to :html, :js

  def create
    coming_from_page = request.referer.split('/').last
    return_to = Page.where("lower(title) = ?", coming_from_page).first || \
                Page.where("position = ?", coming_from_page.to_i + 4).first
    @magazine = Magazine.find_by_cached_slug params[:magazine_id]
    @page = @magazine.create_page_at params[:page][:position]

    redirect_to magazine_page_path(@magazine, return_to.reload)
  end

  def update
    init_haml_helpers
    @magazine = Magazine.find_by_cached_slug params[:magazine_id]
    @page = Page.where("lower(title) = ?", params[:id]).first || \
            Page.where("position = ?", params[:id].to_i + 4).first

    @page.update_attributes params[:page]

    respond_with [@magazine, @page.reload]
  end

protected

  def resource
    @magazine = Magazine.find_by_id params[:magazine_id]
    @page     = Page.where("lower(title) = ?", params[:id]).first || \
                Page.where("position = ?", params[:id].to_i + 4).first
  end
end
