class CoverArtsController < InheritedResources::Base
  actions :create, :update
  respond_to :html, only: [:create, :update]
  respond_to :js,   only: [:new, :edit]

  def new
    @page = Page.find params[:page_id]
    @cover_art = CoverArt.new page_id: @page.id
  end

  def edit
    @cover_art = CoverArt.find params[:id]
  end

  def create
    create! do |wants|
      wants.html { redirect_to [@cover_art.page.magazine, @cover_art.page] }
    end
  end

  def update
    update! do |wants|
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
