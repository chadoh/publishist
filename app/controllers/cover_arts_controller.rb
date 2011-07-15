class CoverArtsController < InheritedResources::Base
  actions :update
  respond_to :html

  def update
    update! do |wants|
      wants.html { redirect_to [@cover_art.page.magazine, @cover_art.page] }
    end
  end
end
