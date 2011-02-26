class MagazinesController < InheritedResources::Base

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
  end

end
