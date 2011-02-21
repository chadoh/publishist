class MagazinesController < InheritedResources::Base
  before_filter :editors_only

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
  end

end
