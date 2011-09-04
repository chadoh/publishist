class CoverArtsController < ActionController::Base
  respond_to :html

  def create
    @page = Page.find params[:page_id]
    @cover_art = @page.cover_art = CoverArt.create
    respond_with(@cover_art) do |wants|
      wants.html { redirect_to [@cover_art.page.magazine, @cover_art.page] }
    end
  end

  def destroy
    @cover_art = CoverArt.find params[:id]
    @cover_art.destroy
    respond_with(@cover_art) do |wants|
      wants.html { redirect_to [@cover_art.page.magazine, @cover_art.page] }
    end
  end
end
