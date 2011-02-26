class MagazinesController < InheritedResources::Base
  before_filter :authenticate_person!
  before_filter :editors_only, :except => [:index]

  def create
    create!(:notice => nil) { magazines_path }
  end

  def update
    update!(:notice => nil)   { magazines_path }
  end

end
